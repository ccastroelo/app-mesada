# Plano de modernização — Mesada

> **Status: RASCUNHO para aprovação. Nenhum código Flutter foi escrito.**

- **Modo**: reescrita
- **Alvo**: arquitetura-alvo do kit + ADR-0004 (Riverpod), ADR-0002 (Firebase), ADR-0003 (família com convite), ADR-0006 (foto local)
- **Visual/comportamento**: redesenho de visual **e** fluxo (ADR-0005). Escopo do desenho: pendente → `design.md` (marco D)
- **Onde vive o código novo**: `app-flutter/` na raiz do repositório
- **Rede de segurança**: tag `legacy/1.2` no estado atual (**aguarda OK do usuário**); baseline `analyze`/`test` não se aplica (ainda não há projeto Flutter) — será registrado no M0 em `flutter.md`
- **Inventário**: `docs/agents/behavior-inventory.md`
- **Upgrade de SDK/dependências**: fora da reescrita. Ambiente atual: Flutter 3.44.4 / Dart 3.12.2 (stable).
- **Plataformas**: iOS e Android (padrão do Flutter; confirmar).
- **Dados do legado**: não importados (aprovado 2026-10-28); portanto não há marco de migração de dados.

## Modelo de dados proposto (Firestore) — a aprovar

Valores em centavos inteiros. IDs gerados pelo Firestore (acaba a colisão do `maiorId+1`).

```
users/{uid}                          familyId
families/{familyId}                  name, memberUids[], createdAt
families/{familyId}/children/{id}    name, email, allowanceCents, order
families/{familyId}/rules/{id}       description, valueCents, order      (valueCents < 0 = desconto)
families/{familyId}/entries/{childId}_{ruleId}
                                     childId, ruleId, quantity, enabled          (um por par filho×regra; ordem = ordem da regra, ver design.md §10)
invites/{code}                       familyId, createdBy, expiresAt
```

- Saldo = `allowanceCents + Σ(quantity × rule.valueCents)`, calculado no domínio (Dart puro, testado).
- +1 usa `FieldValue.increment(1)`; −1 usa transação com piso 0 → dois pais tocando ao mesmo tempo não perdem toque.
- Excluir filho/regra apaga os `entries` correspondentes (em lote). Zerar = `quantity = 0` em lote.
- Regras de segurança: só `memberUids` leem/escrevem `families/{id}/**`. **Precisam de aprovação antes de publicar.**
- A foto **não** entra no Firestore (ADR-0006): arquivo local por `childId`.

## Estrutura (arquitetura-alvo)

```
app-flutter/lib/
  core/ {theme, router, error, storage, widgets, utils}
  features/
    auth_family/   login, criar família, convite (entrar por código)
    rules/         "faltas" (CRUD, ordem, regras-padrão por idioma)
    children/      "mesadeiros" (CRUD, ordem, foto local)
    ledger/        lançamentos, saldo, zerar, relatório por e-mail
    app_lock/      PIN local (flutter_secure_storage)
    help/          tutorial e contato
```

## Marcos

| # | Marco | Pronto quando | Status |
|---|---|---|---|
| P0 | Pré-requisitos: OK para tag `legacy/1.2`; projeto Firebase criado pelo usuário; confirmar se o legado está publicado na loja (impacto do ADR-0007); chaves do Dropbox/Flurry (legado) revogadas | itens marcados pelo usuário | pendente |
| D | **Design**: `design.md` com navegação, telas, gestos, paleta, textos, fluxo de convite — proposta do Claude, aprovação do usuário | usuário aprovou | **aprovado em 2026-10-28** |
| M0 | Bootstrap `app-flutter/`: `flutter create`, `core/` (tema por tokens, rotas `go_router`, `Failure/Result`), l10n pt-BR/pt-PT/en/es, lints, Firebase init, CI `analyze`+`test` | app abre, `analyze` limpo, baseline em `flutter.md` | **parcial (2026-10-28)**: feito tema, rotas (3 abas), erro, dinheiro, l10n, lints e testes; falta Firebase init, CI e ícone |
| M1 | **Fatia-piloto**: `auth_family` ponta a ponta (login, criar família, convidar o 2º pai, entrar por código) | dois aparelhos/contas na mesma família; vira modelo no `architecture.md` | pendente |
| M2 | `rules` (CRUD, ordem, regras-padrão por idioma, máscara monetária) | paridade §2 ligada a regras | pendente |
| M3 | `children` (CRUD, ordem, foto local, e-mail) | idem | pendente |
| M4 | `ledger`: lançamentos ±1 com som/feedback, saldo, zerar um/todos, cascatas, tempo real entre os pais, teste de concorrência | idem; dois pais lançando ao mesmo tempo sem perda | pendente |
| M5 | Relatório por e-mail (HTML equivalente) | idem | pendente |
| M6 | `app_lock`: PIN 4 dígitos ao voltar ao app, bloqueio temporário em vez de `exit(0)` | idem | pendente |
| M7 | `help`: tutorial (4 idiomas) e contato | idem | pendente |
| M8 | Corte: beta/lado a lado, inventário todo `portado`/`descartado (aprovado)`; publicar regras finais do Firestore; só então proponho arquivar o legado em `legacy/1.2` e remover `mesada/` da árvore | **decisão do usuário** | pendente |

M2–M7 são independentes entre si depois do M1 (podem ir em sessões paralelas, cada uma na sua worktree, sem duas mexerem em `core/`).

## Regras da reescrita

- O código antigo em `mesada/` fica intocado e **somente leitura**; é a referência.
- Não apagar o antigo: arquivar em `legacy/1.2` e remover da árvore só no marco de corte, com OK do usuário.
- `applicationId`/bundle id = `br.eti.claudiocastro.mesada`, o mesmo do legado (ADR-0007). Versão do novo app > 1.2 (build > 9).
- Nenhum segredo no repositório; nenhum valor das chaves do legado copiado.

## Checklist de paridade (por feature)

- [ ] Todos os itens do inventário ligados à feature estão `portado` ou `descartado (aprovado)`
- [ ] Comportamento conferido contra o inventário (a UI é redesenhada: conferir **regras**, não pixels); telas conferidas com `flutter-preview` também com fonte 1.3× e 2.0× (`flutter-ui`)
- [ ] Repositório coberto por teste com datasource falso; regras de saldo/cascata em testes de domínio
- [ ] Estados carregando / vazio / erro / **offline** conferidos
- [ ] `flutter analyze` sem avisos novos · testes da feature passando
- [ ] `docs/agents/*` atualizados

## Riscos e perguntas em aberto

1. **Firebase**: quem cria o projeto (console)? Login decidido: e-mail/senha + Google + Apple (ADR-0008). Telemetria decidida: só Crashlytics (ADR-0008).
2. ~~`applicationId`~~: decidido, mesmo do legado (ADR-0007).
3. ~~Regra oculta por filho~~: decidido, ativar/desativar por filho (ADR-0008).
4. ~~PIN após 3 erros~~: decidido, bloqueio temporário (ADR-0008).
5. **Revogar** a chave/secret do app Dropbox e a chave do Flurry citadas em `imAppDelegate.m:28` e `:50` (estão no histórico do git).
6. **Perda de foto ao trocar de aparelho** (consequência do ADR-0006): aceitável?
7. ~~Regras-padrão~~: decidido, mesmas 20 por idioma do aparelho (ADR-0008).
8. ~~Nome e ícone~~: decidido, "Mesada" com ícone novo (ADR-0008); o desenho do ícone sai no `design.md`.
9. **Legado publicado** (confirmado): quem atualizar perde os dados locais (ADR-0007). Texto de versão e, se quiser, um aviso dentro do app na primeira abertura — a decidir no `design.md`.
