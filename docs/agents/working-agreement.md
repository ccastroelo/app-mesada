# Acordo de trabalho — Mesada

Vale para todos os agentes e computadores. O pedido atual do usuário define o trabalho autorizado. Complementa `~/.claude/CLAUDE.md`.

## Modo do projeto

**Modo atual: reescrita** <!-- manutenção | migração | reescrita | novo -->

- Destino: arquitetura-alvo do kit (`~/.claude/skills/project-docs/reference/target-architecture.md`), código novo em `app-flutter/`.
- Seguir `docs/agents/migration-plan.md` e `docs/agents/behavior-inventory.md` (skill `modernize`).
- O app iOS antigo em `mesada/` é **somente leitura**: referência, não se edita.
- Ao concluir a reescrita, o modo volta a *manutenção* (registrar em `version-history.md`).

## Decisões de produto vigentes (não "melhorar")

- **Sem importação** de dados do legado (ADR-0001); mesmo `applicationId` `br.eti.claudiocastro.mesada` (ADR-0007).
- Foto do filho só no aparelho; nada de imagem de menor na nuvem (ADR-0006).
- Dinheiro em centavos inteiros, nunca `double` (ADR-0002).
- Visual e fluxo são novos, mas as regras de negócio do inventário §2 são preservadas (ADR-0005).

## Sempre perguntar antes de

- Criar projeto Firebase, mudar regras do Firestore/Auth, qualquer coisa que toque produção.
- Definir ou mudar `applicationId`/bundle id, assinatura, versão ou build de release.
- Criar tag/branch/commit, `git push`, apagar ou arquivar o legado `mesada/`.
- Mudar o mecanismo de estado ou subir major de Flutter/dependências.
- Implementar tela antes de `design.md` aprovado.

## Pode fazer sem perguntar

- Código e testes de `app-flutter/` dentro do plano aprovado, `flutter analyze`/`flutter test`, atualizar o inventário e a documentação.

## Segredos

- Há chaves hardcoded no legado (`mesada/mesada/imAppDelegate.m:28` e `:50`). **Não copiar** para o app novo nem para documentos. Configuração do novo app vai em `--dart-define-from-file` / arquivos fora do git.

## Verificar o estado atual

- Antes de atuar, confira branch, alterações locais e a doc da área; preserve trabalho de outras sessões.
- Distinga: requisito aprovado, comportamento observado no código, validado localmente, publicado em produção.
