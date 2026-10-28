# CLAUDE.md

Guia para o Claude Code neste repositório. As preferências globais (idioma, git, segredos, verificação) vêm de `~/.claude/CLAUDE.md`; aqui fica o que é específico do Mesada.

## Sobre

Mesada é um app para pais lançarem, dia a dia, recompensas e descontos na mesada dos filhos (saldo = mesada inicial + Σ quantidade × valor da regra). O app original é iOS/Objective-C (v1.2, publicado); está sendo **reescrito em Flutter** com base compartilhada entre os dois responsáveis (Firebase Auth + Firestore). Idiomas: pt-BR, pt-PT, en, es.

**Modo do projeto: reescrita** (skill `modernize`).

## Layout do repositório

- `app-flutter/` — app Flutter novo. **Todos os comandos `flutter`/`dart` rodam a partir daqui.**
- `mesada/` — app iOS antigo (Objective-C). **Somente leitura**: é a especificação da reescrita. Arquivado na tag `legacy/1.2`; só sai da árvore no corte, com OK do usuário.
- `docs/agents/` — documentação viva para agentes (fonte de verdade).

## Acordo de trabalho

Decisões de produto, arquitetura e escopo são do usuário; as já tomadas estão em `decisions.md`. O Claude executa o que está no plano aprovado e pergunta antes de: Firebase/regras/produção, `applicationId`, versão/build, assinatura, commit/tag/push, apagar o legado. Detalhe em `working-agreement.md`.

### Módulos (importados automaticamente)

@docs/agents/working-agreement.md
@docs/agents/continuidade.md
@docs/agents/architecture.md
@docs/agents/design.md
@docs/agents/flutter.md

### Referência sob demanda (NÃO importada)

- [`docs/agents/decisions.md`](docs/agents/decisions.md) — ADRs vigentes (reescrita, Firebase, família com convite, Riverpod, foto local, design...). Leia antes de propor mudança de padrão.
- [`docs/agents/migration-plan.md`](docs/agents/migration-plan.md) — marcos, modelo de dados do Firestore e perguntas em aberto.
- [`docs/agents/behavior-inventory.md`](docs/agents/behavior-inventory.md) — o que o app antigo faz (telas, regras de negócio, dados). Leia antes de portar qualquer área.
- `~/.claude/skills/project-docs/reference/target-architecture.md` — regras completas da arquitetura-alvo (o `architecture.md` acima descreve o que existe de fato).
