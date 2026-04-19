# Windows Reference

## Objetivo

Padronizar como a skill `shadow-sentinel-schedule` deve materializar jobs no Windows sem depender de quoting fragil ou improviso excessivo do LLM.

## Backend Preferido

- `powershell-scheduledtasks`

Cmdlets preferidos:

- `New-ScheduledTaskAction`
- `New-ScheduledTaskTrigger`
- `New-ScheduledTaskSettingsSet`
- `Register-ScheduledTask`
- `Get-ScheduledTask`
- `Get-ScheduledTaskInfo`
- `Start-ScheduledTask`
- `Disable-ScheduledTask`
- `Enable-ScheduledTask`
- `Unregister-ScheduledTask`

## Fallback

- `schtasks.exe`

Use so para:

- fallback
- debug/manual inspection
- compatibilidade quando `ScheduledTasks` nao estiver disponivel

## Regras de Materializacao

### 1. Preferir helper/template ao inves de comando inline rico

Evite montar comandos longos com:

- `-Command` grande
- quoting em varias camadas
- redirecionamentos complexos no argumento da task
- interpolacao de variaveis PowerShell dentro de outro shell

Prefira:

- `powershell.exe -File <runner.ps1>`
- helper `register-task.ps1`
- template de runner preenchido pela skill

Regra forte:

- no Windows, nao use `powershell.exe -Command "..."` para fluxos ricos de criacao, geracao de runner ou registro de task
- `-Command` so e aceitavel para comandos curtos e triviais de diagnostico

Distincao importante:

- `payload rico` e aceitavel
- `invocacao inline rica atraves de shell intermediario` e o anti-pattern

Em outras palavras:

- voce pode ter um job com prompt grande, muitos argumentos, paths com espacos e configuracao detalhada
- o que voce nao deve fazer e transportar essa riqueza por `powershell -Command "..."` passando por outra shell

Quando houver payload rico, materialize-o em artefato intermediario seguro, por exemplo:

- runner `.ps1` gerado
- script de registro `.ps1` gerado
- manifesto com argumentos finais

### 2. Working directory

Nao assuma que a task vai iniciar no diretorio correto.

Sempre trate working directory de forma defensiva dentro do runner.

Regra forte para CLIs que tambem aceitam diretorio por argumento:

- se o runner ja controla o diretorio via `Set-Location` ou `Start-Process -WorkingDirectory`, nao emita `--dir`, `--cwd` ou equivalente para a CLI
- escolha um lugar de controle do diretorio e mantenha apenas esse

No backend Windows desta skill, a preferencia e:

- o runner controla o working directory
- a CLI nao recebe argumento redundante de diretorio

Motivo:

- reduz complexidade de quoting
- evita duplicidade semantica
- reduz risco com paths contendo espacos

## Convencao de Artefatos Gerados

Quando a skill precisar gerar runners, launchers ou scripts auxiliares no Windows, use:

```text
%USERPROFILE%\.shadow_sentinel\skills\generated\
```

Exemplos:

- `%USERPROFILE%\.shadow_sentinel\skills\generated\my-job.ps1`
- `%USERPROFILE%\.shadow_sentinel\skills\generated\register-my-job.ps1`

Essa convencao deve ser tratada como padrao oficial do backend Windows.

## Templates e Exemplos Oficiais do Windows

Templates oficiais:

- `templates/windows/runner.ps1.tpl` para CLI generica
- `templates/windows/opencode-runner.ps1.tpl` para jobs com `opencode`

Exemplo oficial:

- `examples/windows/opencode-hello-world.yaml`

Use o template especializado do OpenCode quando o job precisar:

- `opencode.cmd`
- `--format json`
- captura de `raw stdout`
- extracao segura de blocos `type=text`

### 3. Variaveis PowerShell em scripts gerados

Quando um script gerado contiver variaveis como:

- `$root`
- `$env:USERPROFILE`
- `$os.Caption`
- `$_`

preserve-as literalmente no arquivo.

Prefira here-string literal:

```powershell
@'
...
'@
```

## Fluxo de Validacao Obrigatorio

Depois de criar um job no Windows, a skill deve validar:

1. manifesto existe
2. runner/helper alvo existe
3. task foi registrada
4. `run_now` funciona
5. stdout existe
6. stderr existe ou esta vazio
7. `LastTaskResult` foi lido
8. o resultado final so e `sucesso` se todos os itens acima passarem

Se qualquer ponto falhar, reporte `job criado com falha funcional`.

## Tratamento de stdout/stderr

No Windows, o runner oficial deve ser defensivo com redirecionamento.

Assuma que:

- stdout pode vir vazio
- stderr pode vir vazio
- arquivo redirecionado pode nao existir em caso de falha precoce

Entao:

- normalize conteudos nulos para string vazia antes de chamar metodos como `.Trim()`
- teste existencia de arquivos antes de le-los

## O Que Nao Fazer

- nao usar `%USERPROFILE%` ou `$env:USERPROFILE` em contexto onde outra shell possa expandir antes da hora
- nao depender de `schtasks.exe /TR` com comando complexo
- nao declarar sucesso so porque a task ficou `Ready`
- nao gerar runner que reintroduza `powershell.exe -Command <script-em-string>` internamente
- nao registrar a task antes de validar que o runner gerado existe e e sintaticamente plausivel

## Mapeamento Recomendado para Manifesto

No bloco `runtime`, prefira guardar:

```yaml
runtime:
  os_backend: windows-task-scheduler
  preferred_backend: powershell-scheduledtasks
  materialized_backend: powershell-scheduledtasks
  task_name: ShadowSentinel-Example
  registration_script: "%USERPROFILE%/.shadow_sentinel/skills/generated/register-example.ps1"
```

## Sequencia Oficial no Windows

1. preencher manifesto
2. gerar runner em `skills/generated/`
3. quando houver argumentos ricos, gerar script de registro em `skills/generated/` e evitar invocacao rica inline
4. registrar task via helper `register-task.ps1`
5. executar `run-task-now.ps1`
6. aguardar settle curto
7. ler stdout/stderr
8. ler `Get-ScheduledTaskInfo`
9. so entao declarar sucesso
