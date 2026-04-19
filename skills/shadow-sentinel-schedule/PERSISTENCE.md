# Shadow Sentinel Schedule - Persistencia Global

Esta skill usa a raiz global do ecossistema Shadow Sentinel.

## Raiz de Dados

- Windows: `%USERPROFILE%\.shadow_sentinel\`

## Estrutura Inicial

```text
%USERPROFILE%\.shadow_sentinel\
  skills\
  jobs\
  output\
  logs\
  state\
```

## Convencoes

- `skills/`: artefatos auxiliares especificos das skills do ecossistema
- `jobs/`: manifestos portaveis dos jobs
- `output/`: saidas uteis geradas pelas automacoes
- `logs/`: logs tecnicos de execucao
- `state/`: indices, caches e metadados operacionais

## Regra de Ouro

Os artefatos desta skill nao devem ser salvos dentro:

- do repo atual
- de `.sentinel`
- de `.idea-memory`

## Arquivo Fonte de Verdade

Cada job deve ter um manifesto em:

```text
%USERPROFILE%\.shadow_sentinel\jobs\<job-id>.yaml
```

## Evolucao Sugerida

Comece com manifestos YAML + arquivos simples em `state/`.

Se o volume crescer, evolua para um indice ou banco local em:

```text
%USERPROFILE%\.shadow_sentinel\state\shadow-sentinel.db
```

mantendo exportacao humana onde fizer sentido.
