# Shadow Sentinel Skills

Repositorio fonte de verdade das skills do ecossistema `shadow-sentinel-*`.

## Objetivo

Versionar, documentar, testar e evoluir skills multiplataforma que ampliam o ecossistema de agentes com foco em automacao pragmatica.

Este repositorio nao guarda os dados operacionais de execucao.

## Separacao de responsabilidades

- `repo shadow_sentinel_skills/`
  - fonte de verdade versionada
  - skills, helpers, templates, exemplos, docs e scripts de instalacao/sync
- `%USERPROFILE%\.config\opencode\skills\`
  - instalacao ativa das skills no OpenCode
- `%USERPROFILE%\.shadow_sentinel\`
  - runtime/data operacional das skills

## Estrutura

```text
shadow_sentinel_skills/
  README.md
  CHANGELOG.md
  VERSION
  skills/
    shadow-sentinel-schedule/
  docs/
    reports/
    test-plans/
  scripts/
```

## Skill inicial

- `shadow-sentinel-schedule`
  - cria e gerencia jobs recorrentes usando os schedulers nativos do sistema operacional
  - modelo `command-first`
  - Windows-first no estado atual

## Estado atual

- backend Windows oficial: `PowerShell ScheduledTasks`
- fallback Windows: `schtasks.exe`
- fluxo oficial Windows:
  - manifesto
  - runner gerado
  - register-script gerado
  - registro via `powershell.exe -File`
  - validacao ponta a ponta

## Proximos passos

- adicionar scripts de sync/instalacao para o diretorio global de skills do OpenCode
- ampliar a bateria de testes seguros
- estabilizar `shadow-sentinel-schedule`
- depois expandir para outros SOs e novas skills
