---
name: shadow-sentinel-schedule
description: "Cria, lista, inspeciona, pausa, retoma, testa e remove jobs recorrentes cross-platform usando os schedulers nativos do sistema operacional para executar comandos CLI. Use para agendar OpenCode, Claude Code, GitHub CLI, PowerShell, scripts e outras automacoes do ecossistema Shadow Sentinel."
---

# Shadow Sentinel Schedule

Voce e a skill de agendamento do ecossistema Shadow Sentinel.

Sua funcao e transformar pedidos de automacao recorrente em jobs reais do sistema operacional que executam comandos CLI. A skill nao faz o trabalho inteligente: ela apenas registra, gerencia e inspeciona comandos no scheduler nativo do SO.

Esta skill faz parte do namespace `shadow-sentinel-*`.

## Objetivo

Permitir que o usuario diga algo como:

- "todo dia as 9h me gera um resumo das prioridades"
- "toda segunda as 8h roda minha revisao semanal"
- "quando eu fizer login, abre meu planejamento"

E a skill:

1. entende a intencao
2. monta o comando correto
3. gera um manifesto simples do job
4. registra esse comando no scheduler nativo do SO
5. deixa claro como testar, pausar, listar e remover

## Storage Global do Produto

Use sempre a raiz global do ecossistema Shadow Sentinel:

- Windows: `%USERPROFILE%\\.shadow_sentinel\\`
- Exemplo generico: `%USERPROFILE%\\.shadow_sentinel\\`

Nunca use `.sentinel`, `.idea-memory`, ou o repo atual para os artefatos operacionais desta skill.

## Estrutura Recomendada

```text
%USERPROFILE%\.shadow_sentinel\
  skills\
  jobs\
  output\
  logs\
  state\
```

Para esta skill, trate como padrao:

- `jobs/`: manifestos portaveis dos jobs
- `output/`: saidas uteis das automacoes
- `logs/`: logs tecnicos de execucao
- `state/`: indices e estado auxiliar

## Modelo Mental

Esta skill nao e um scheduler proprio.

Ela e uma camada de orquestracao que:

- detecta o sistema operacional
- escolhe o backend nativo adequado
- monta um comando executavel
- materializa esse comando em um job real

O executor faz o trabalho pesado.
Esta skill apenas agenda e gerencia as chamadas.

## Papel do Executor

Considere o executor como o alvo principal da automacao.

A skill deve apenas decidir como chamar o comando certo.

Exemplos validos:

- `opencode run ...`
- `claude ...`
- `gh issue list ...`
- `pwsh -File ...`
- `python script.py`
- `node script.js`
- `curl ...`

## OpenCode como Caso Especial

OpenCode continua sendo um caso importante, mas nao o centro conceitual da skill.

Quando o job usar OpenCode, a skill pode montar chamadas como:

- `opencode run ...`
- opcionalmente com `--agent`
- opcionalmente com `--model`
- opcionalmente com parametros de sessao e projeto

Nao reimplemente na skill aquilo que o executor ja sabe fazer.

## Backends de Execucao

Executores possiveis incluem:

- `opencode-cli`
- `claude-code-cli`
- `gh`
- `powershell`
- `python`
- `node`
- qualquer CLI valida presente no sistema

So proponha modos mais sofisticados quando houver necessidade clara de controle mais fino ou integracao programatica.

## Backends por Sistema Operacional

### Windows

- usar o modulo PowerShell `ScheduledTasks` como backend primario
- usar `schtasks.exe` apenas como fallback, debug manual ou compatibilidade
- carregar a referencia `reference/windows.md` antes de materializar jobs no Windows
- preferir helpers em `helpers/windows/` e templates em `templates/windows/` em vez de improvisar comandos longos inline

### Linux

- preferir `systemd timer/service` quando disponivel
- usar `cron` como fallback

### macOS

- usar `launchd`

## Quando Usar

Ative esta skill quando o usuario quiser:

- criar rotina automatica
- agendar um comando
- disparar um resumo diario
- configurar follow-up recorrente
- listar ou remover jobs existentes
- pausar ou retomar automacoes do Shadow Sentinel

## Comandos Naturais que Esta Skill Deve Entender

- "agenda isso"
- "cria um job"
- "todo dia as 9h"
- "quero uma rotina automatica"
- "me lembra toda segunda"
- "cria um agendamento"
- "lista meus jobs"
- "pausa esse job"
- "roda agora"
- "remove esse agendamento"

## Unidades Principais

### 1. Job Manifest

Fonte de verdade portavel do job e do comando a ser executado.

Padrao de local:

```text
%USERPROFILE%\.shadow_sentinel\jobs\<job-id>.yaml
```

### 2. OS Backend

Representacao materializada do manifesto no scheduler nativo do SO.

No Windows, prefira materializar com:

- `New-ScheduledTaskAction`
- `New-ScheduledTaskTrigger`
- `New-ScheduledTaskSettingsSet`
- `Register-ScheduledTask`

### 3. Command Invocation

A chamada materializada que o scheduler do SO vai executar.

Exemplo conceitual:

```text
opencode run "Gere meu resumo diario..."
gh issue list --limit 20
pwsh -File C:\scripts\report.ps1
```

### 4. Output

Resultado util gerado pela automacao.

### 5. Log

Rastro tecnico de execucao e falha.

## Manifesto Portavel

Use esta estrutura conceitual como base.

O centro do manifesto e o comando, nao um runtime proprio.

```yaml
id: daily-summary
title: Daily Summary
enabled: true

schedule:
  kind: daily
  time: "09:00"
  timezone: "local"

command:
  program: opencode
  args:
    - "Gere meu resumo diario de prioridades, pendencias e proximos passos."
  working_directory: null

output:
  stdout_path: "%USERPROFILE%/.shadow_sentinel/output/daily-summary.stdout.txt"
  stderr_path: "%USERPROFILE%/.shadow_sentinel/logs/daily-summary.stderr.txt"

runtime:
  os_backend: auto
  retry_policy: native
  task_name: ShadowSentinel-DailySummary
  preferred_backend: powershell-scheduledtasks
  materialized_backend: null
```

## Arquitetura em Camadas

Esta skill deve operar em camadas.

### Camada 1 - LLM orchestration

- entender a intencao
- preencher o manifesto
- escolher backend por SO
- chamar helper pronto
- validar o resultado

### Camada 2 - References por SO

- `reference/windows.md`
- `reference/linux.md` no futuro
- `reference/macos.md` no futuro

Esses arquivos concentram as regras operacionais de cada plataforma.

### Camada 3 - Helpers por SO

Use scripts/helpers prontos para reduzir liberdade demais do LLM nas partes frageis.

Exemplo esperado:

```text
helpers/windows/register-task.ps1
helpers/windows/list-tasks.ps1
helpers/windows/inspect-task.ps1
helpers/windows/run-task-now.ps1
helpers/windows/remove-task.ps1
```

### Camada 4 - Templates por SO

Quando a tarefa exigir runner/script auxiliar, preencha templates seguros em vez de gerar scripts complexos do zero.

Exemplo esperado:

```text
templates/windows/runner.ps1.tpl
templates/windows/command-wrapper.cmd.tpl
```

## Regra Operacional Importante

Nem tudo deve ficar a cargo do LLM no momento da execucao.

Sempre que houver helper ou template pronto:

- use o helper
- preencha o template
- evite reinventar quoting, escaping e plumbing do SO

## Acoes Minimas

### `schedule.create`

Cria um novo job.

### `schedule.list`

Lista jobs conhecidos e seus estados.

No Windows, o comportamento esperado e:

- ler manifestos em `%USERPROFILE%\\.shadow_sentinel\\jobs\\`
- cruzar `runtime.task_name` com `Get-ScheduledTask` e `Get-ScheduledTaskInfo`
- mostrar pelo menos: `id`, `schedule`, `task_state`, `next_run`, `last_result`

### `schedule.inspect`

Mostra manifesto, backend do SO, output e log path de um job.

### `schedule.run_now`

Executa imediatamente o job sem esperar o horario.

### `schedule.pause`

Desabilita o job sem apagá-lo.

### `schedule.resume`

Reabilita um job pausado.

### `schedule.delete`

Remove job materializado e, se o usuario quiser, o manifesto associado.

## Fluxo Ideal de `schedule.create`

### Passo 1 - Entender a intencao

Converta a descricao do usuario em:

- o que deve acontecer
- quando deve acontecer
- qual agente deve rodar
- onde a saida deve ir

### Passo 2 - Montar o comando

Transforme a intencao em uma invocacao clara do comando que sera agendado.

Perguntas centrais:

- qual programa deve rodar?
- quais argumentos devem ser passados?
- qual diretorio de trabalho deve ser usado?
- para onde vao `stdout` e `stderr`?

So depois disso pense na materializacao do scheduler.

### Passo 3 - Inferir defaults fortes

Se o usuario nao especificar:

- `runtime.os_backend`: use `auto`
- `command.working_directory`: use o diretorio atual quando fizer sentido
- `output.stdout_path`: derive de `%USERPROFILE%\\.shadow_sentinel\\output\\<job-id>.stdout.txt`
- `output.stderr_path`: derive de `%USERPROFILE%\\.shadow_sentinel\\logs\\<job-id>.stderr.txt`

### Passo 4 - Propor a automacao

Responda em formato curto:

```text
Entendi esta automacao:
- ...

Proposta:
- horario/frequencia: ...
- comando: ...
- diretorio de trabalho: ...
- stdout: ...
- stderr: ...
```

### Passo 5 - Confirmar apenas o necessario

Pergunte somente o que estiver ambiguo ou for irreversivel.

Normalmente basta confirmar:

- horario/frequencia se estiver ambigua
- output se o usuario quiser algo especial
- instalacao do job

### Passo 6 - Materializar

Depois de confirmado:

1. gere o manifesto em `jobs/`
2. gere a chamada final do comando
3. carregue a referencia especifica do SO
4. use helper/template pronto quando existir
5. compile para o backend nativo do SO
6. instale o job
7. valide ponta a ponta
8. mostre o resultado

No Windows, o caminho preferido deve ser o modulo `ScheduledTasks` em PowerShell.
Evite usar `schtasks.exe` como primeira escolha quando a tarefa puder ser criada com cmdlets estruturados.
Evite tambem `powershell.exe -Command "..."` para fluxos ricos de criacao; prefira helpers e `-File`.

Importante:

- jobs ricos continuam validos
- o que deve ser evitado e uma invocacao inline rica atravessando shell intermediario
- quando houver payload rico, materialize esse payload em runner/script gerado e so depois registre a task
- quando o runner controlar o diretorio no Windows, nao duplique esse controle com `--dir`, `--cwd` ou equivalente na CLI

Formato sugerido:

```text
Job criado com sucesso.

- id: <job-id>
- backend do SO: <backend>
- comando final: <command>
- manifesto: <path>
- stdout: <path>
- stderr: <path>

Acoes uteis:
- testar agora
- pausar job
- listar jobs
- remover job
```

## Busca e Manutencao

Quando o usuario pedir `listar jobs`, priorize:

- jobs ativos
- ultima atualizacao conhecida
- horario/frequencia
- backend do SO

No Windows, a implementacao pode usar um helper como:

```text
%USERPROFILE%\.shadow_sentinel\skills\list-jobs.ps1
```

Quando houver artefatos auxiliares gerados para jobs Windows, use como padrao:

```text
%USERPROFILE%\.shadow_sentinel\skills\generated\
```

Para casos comuns de Windows, prefira partir de templates/exemplos oficiais da propria skill.

Exemplos importantes:

- `templates/windows/runner.ps1.tpl`
- `templates/windows/opencode-runner.ps1.tpl`
- `examples/windows/opencode-hello-world.yaml`

Quando pedir `inspecionar`, mostre:

- manifesto
- comando
- ultimo stdout conhecido
- ultimo stderr conhecido
- como rodar agora
- como pausar/remover

## Guardrails

- nao esconda o backend do SO escolhido depois da criacao
- nao escreva manifestos dentro de repositorios de codigo
- nao imponha `opencode-server` cedo demais
- nao faca perguntas avancadas desnecessarias
- sempre mostre como desfazer
- no Windows, prefira cmdlets `ScheduledTasks` para evitar fragilidade de quoting e parsing
- nao transforme a skill em um runtime proprio
- nao reimplemente o comportamento do executor dentro da skill
- no Windows, evite `-Command` longo quando houver alternativa via `-File`
- no Windows, evite inline commands complexos se a skill ja tiver helper/template pronto
- validar criacao da task nao basta; valide execucao imediata, stdout, stderr e `LastTaskResult`
- no Windows, nao aceite como sucesso um job apenas `Ready`; ele precisa rodar e produzir o artefato esperado

## Validacoes Minimas

- `id` valido e estavel
- agenda parseavel
- backend suportado pelo SO atual
- comando resolvivel
- stdout e stderr path resolviveis
- comando final materializavel

## Filosofia

Primeiro valide valor com:

- skill
- scheduler nativo do SO
- um executor CLI real

So proponha runtime proprio quando essa combinacao falhar de forma real e repetida.

Shadow Sentinel Schedule e, acima de tudo, uma skill que registra comandos no scheduler do sistema operacional.
