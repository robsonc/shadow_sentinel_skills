# Shadow Sentinel Schedule - Workflow

## Fluxo Real Desejado

### 1. Ativacao

Quando esta skill for ativada:

- assuma que o usuario quer criar ou operar automacoes recorrentes
- detecte o sistema operacional atual
- prepare-se para escolher o backend nativo correto
- carregue a referencia especifica do SO antes de materializar jobs nao triviais

### 2. Criacao rapida

Se o usuario descrever uma rotina em linguagem natural:

- entenda a automacao
- monte o comando que deve ser executado
- proponha defaults fortes
- confirme so o essencial
- gere manifesto
- gere runner/template auxiliar quando necessario
- para Windows, grave runners auxiliares em `%USERPROFILE%/.shadow_sentinel/skills/generated/`
- quando houver payload rico no Windows, gere tambem um script de registro em `skills/generated/` em vez de depender de invocacao inline rica
- instale o job

### 3. Listagem e manutencao

Se o usuario quiser gerenciar jobs:

- liste jobs conhecidos a partir de `jobs/`
- use `state/` para status auxiliar quando existir
- no Windows, cruze os manifestos com `Get-ScheduledTask` e `Get-ScheduledTaskInfo`
- use helpers em `helpers/windows/` quando possivel
- explique como pausar, retomar, testar e remover

### 4. Materializacao por SO

- Windows -> PowerShell `ScheduledTasks` sobre Task Scheduler; usar `reference/windows.md`, helpers e templates antes de improvisar; `schtasks.exe` so como fallback
- Linux -> systemd timer/service, com fallback para cron
- macOS -> launchd

### 5. Saida final

Toda operacao deve terminar com:

- id do job
- backend do SO usado
- comando final
- caminho do manifesto
- caminho de stdout
- caminho de stderr
- como desfazer

No Windows, a operacao so deve ser considerada bem-sucedida depois de uma validacao ponta a ponta:

- task registrada
- `run_now` executado
- settle curto antes da leitura final
- stdout presente
- stderr lido
- `LastTaskResult` consultado

## Frases Naturais Esperadas

- "agenda isso"
- "todo dia as 9h"
- "cria um job"
- "lista meus jobs"
- "roda isso agora"
- "pausa esse agendamento"
- "remove esse job"
