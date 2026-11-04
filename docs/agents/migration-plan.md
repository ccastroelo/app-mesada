# Plano de modernização — Mesada

> **Status: em execução.** M0 (parcial), M1, M2 e M3 com código pronto. O modelo mudou em 2026-11-03: dados locais por padrão e nuvem só com assinatura (ADR-0014 e ADR-0015).

- **Modo**: reescrita
- **Alvo**: arquitetura-alvo do kit + ADR-0004 (Riverpod), ADR-0014 (dados locais; nuvem só com assinatura), ADR-0015 (conta só ao assinar, assinatura por família), ADR-0003 (família com convite), ADR-0006 (foto local)
- **Visual/comportamento**: redesenho de visual **e** fluxo (ADR-0005). Escopo do desenho: pendente → `design.md` (marco D)
- **Onde vive o código novo**: `app-flutter/` na raiz do repositório
- **Rede de segurança**: tag `legacy/1.2` no estado atual (**aguarda OK do usuário**); baseline `analyze`/`test` não se aplica (ainda não há projeto Flutter) — será registrado no M0 em `flutter.md`
- **Inventário**: `docs/agents/behavior-inventory.md`
- **Upgrade de SDK/dependências**: fora da reescrita. Ambiente atual: Flutter 3.44.4 / Dart 3.12.2 (stable).
- **Plataformas**: iOS e Android (padrão do Flutter; confirmar).
- **Dados do legado**: não importados (aprovado 2026-10-28); portanto não há marco de migração de dados.
- **Armazenamento**: arquivo local JSON por padrão, sem conta e sem Firebase; o Firestore serve só quem assina a **Família** (ADR-0014). A assinatura é da família e a conta só é pedida ao compartilhar (ADR-0015).

## Modelo de dados do Firestore (só assinantes, ADR-0014)

Valores em centavos inteiros. IDs gerados pelo Firestore (acaba a colisão do `maiorId+1`).

```
users/{uid}                          familyId
families/{familyId}                  name, createdBy, createdAt,
                                     plan: {kind, productId, since, modelVersion}   ← o direito da família (ADR-0020); ainda não gravado
families/{familyId}/members/{uid}    email, joinedAt, code (só se entrou por convite)   ← define quem é membro (ADR-0011)
families/{familyId}/children/{id}    name, email, allowanceCents, order
families/{familyId}/rules/{id}       description, valueCents, order      (valueCents < 0 = desconto)
families/{familyId}/entries/{childId}_{ruleId}
                                     childId, ruleId, quantity, enabled          (um por par filho×regra; ordem = ordem da regra, ver design.md §10)
invites/{code}                       familyId, createdBy, expiresAt, usedBy (null até usar)
```

- Saldo = `allowanceCents + Σ(quantity × rule.valueCents)`, calculado no domínio (Dart puro, testado).
- +1 usa `FieldValue.increment(1)`; −1 usa transação com piso 0 → dois pais tocando ao mesmo tempo não perdem toque.
- Excluir filho/regra apaga os `entries` correspondentes (em lote). Zerar = `quantity = 0` em lote.
- Regras de segurança: só `memberUids` leem/escrevem `families/{id}/**`. **Precisam de aprovação antes de publicar.**
- A foto **não** entra no Firestore (ADR-0006): arquivo local por `childId`.

### Modelo local (padrão, sem conta — ADR-0014)

Um arquivo só, `<pasta do app>/mesada.json`, com escrita atômica (`.tmp` + renomear):

```
{ "schemaVersion": 1,
  "family":   { "id": "local", "name": "..." },
  "children": [ { "id", "name", "email", "allowanceCents", "order" } ],
  "rules":    [ { "id", "description", "valueCents", "order" } ],
  "entries":  [ { "childId", "ruleId", "quantity", "enabled" } ] }
```

Mesmos campos do Firestore, para o envio ao assinar ser uma tradução direta. Ids gerados no aparelho (UUID v4). A foto do filho segue fora do arquivo (ADR-0006).

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
| M0 | Bootstrap `app-flutter/`: `flutter create`, `core/` (tema por tokens, rotas `go_router`, `Failure/Result`), l10n pt-BR/pt-PT/en/es, lints, Firebase init, CI `analyze`+`test` | app abre, `analyze` limpo, baseline em `flutter.md` | **parcial (2026-11-03)**: feito tema, rotas, erro, dinheiro, l10n, lints, testes e a CI mínima (`codemagic.yaml`, ADR-0019); falta **só o ícone**. O Firebase init saiu do M0 e virou parte do M4.5 (ADR-0014) |
| M1 | **Fatia-piloto**: `auth_family` ponta a ponta (login, criar família, convidar o 2º pai, entrar por código) | dois aparelhos/contas na mesma família; vira modelo no `architecture.md` | **código pronto (2026-10-28)**, 58 testes + 28 das regras; `architecture.md` criado; **falta validar com Firebase real em aparelho** |
| M1.5 | **Armazenamento local e entrada sem conta** (ADR-0014/0015): repositórios locais com o arquivo JSON, família local no primeiro uso, `redirectFor` sem exigir login, Firebase não inicializado no grátis | app completo sem conta e sem rede; os testes de M2/M3 passam contra o repositório local | **código pronto (2026-11-03)**, 142 testes; falta rodar em aparelho/emulador |
| M2 | `rules` (CRUD, ordem, regras-padrão por idioma, máscara monetária) | paridade §2 ligada a regras | **código pronto (2026-10-28)**, 89 testes no total; falta validar com Firestore real em aparelho |
| M3 | `children` (CRUD, ordem, foto local, e-mail) | idem | **código pronto (2026-10-28)**, 120 testes no total; falta validar com Firestore real em aparelho |
| M4 | `ledger`: lançamentos ±1 com feedback, saldo, zerar um/todos, cascatas, tempo real entre os pais | idem; dois pais lançando ao mesmo tempo sem perda | **código pronto (2026-11-03)**, 168 testes; som e seções recolhíveis ficaram para depois (`tech-debt.md`); concorrência real só dá para exercitar no M4.5 |
 **Acesso e compartilhamento** (ADR-0021): teste de 15 dias, compra única do app (`mesada_app`, de cada pessoa), assinatura por família para sincronizar (`mesada_compartilhar`), conta no momento de compartilhar, envio inicial do local para o Firestore e troca da fonte de verdade | dois aparelhos, cada um com seu acesso ao app, sincronizando enquanto a família tem assinatura | **parcial (2026-11-04)**. Pronto no código: a virada para a nuvem levando os dados locais, a marca do aparelho (`entitlement`: início do teste, modelo, origem "app antigo") e a regra `evaluateAccess` (pura, testada). **Pronto também (M4.5b, 2026-11-04)**: gateway de compra com os dois produtos, aviso dos dias de teste, só leitura nas telas e na escrita, assinatura exigida para compartilhar. **Falta (M4.5c)**: a assinatura (gravada no documento da família e lida pelo convidado, com as regras do Firestore), o retrato local ao vencer, e a validação de recibo no servidor antes de vender. 305 testes. **Nada exercitado contra loja ou Firebase de verdade** |
| M5 | Relatório: **PDF compartilhado** com resumo em texto, no lugar do corpo em HTML (ADR-0016) | idem | **código pronto (2026-11-03)**, 178 testes; sem destinatário preenchido (ADR-0016) |
| M6 | `app_lock`: PIN de 4 dígitos após 30 s fora do app, bloqueio temporário em vez de `exit(0)` | idem | **código pronto (2026-11-03)**, 226 testes; biometria como caminho normal e PIN de reserva (ADR-0018), PIN em hash num arquivo do aparelho (ADR-0017); biometria não exercitada em aparelho e sem saída para "esqueci o PIN" (`tech-debt.md`) |
| M7 | `help`: introdução em 4 cartões (4 idiomas), contato e Sobre | idem | **código pronto (2026-11-03)**, 235 testes; contato **copia** o e-mail em vez de abrir o compositor (pediria `url_launcher`) e o Sobre ainda não mostra versão (`tech-debt.md`) |
| M8 | Corte: beta/lado a lado, inventário todo `portado`/`descartado (aprovado)`; publicar regras finais do Firestore; só então proponho arquivar o legado em `legacy/1.2` e remover `mesada/` da árvore | **decisão do usuário** | pendente |

M2–M7 são independentes entre si **depois do M1.5** (podem ir em sessões paralelas, cada uma na sua worktree, sem duas mexerem em `core/`). O M4.5 depende do M1.5 e do M1.

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
10. ~~Preço e período~~: decidido (ADR-0021). App grátis para baixar, 15 dias de teste, compra única do app e assinatura para compartilhar. **Valores e período da assinatura (mensal ou anual) ainda a definir pelo usuário**, nos consoles das lojas.
11. **A assinatura chega ao convidado por um campo no documento da família**, gravado pelo aparelho de quem assina. Sem servidor conferindo o recibo, dá para forjar e compartilhar de graça. **Resolver antes do lançamento**: Cloud Functions (plano Blaze) ou um serviço como o RevenueCat. O teste de 15 dias tem a sua própria fraqueza (relógio e reinstalação) e o que fazer sobre ela está na ADR-0021.
13. **Revisão das lojas**: o convidado sincroniza por causa da assinatura de outra pessoa (o dono da família), embora tenha comprado o app. É uma situação de plano de família ou equipe; não achei regra explícita das lojas sobre ela. Plano: notas ao revisor e teste no TestFlight e no teste interno do Google Play. Fallback se recusarem: cada responsável assina o próprio compartilhamento. Também confirmar que um app já publicado como grátis na App Store pode ganhar compras dentro do app sem trocar a listagem (é o caso do iOS).
14. **Quem baixou o app antigo de graça** recebe o mesmo uso local sem custo de quem o comprou (decisão do usuário, ADR-0021). Reavaliar se virar problema.
12. ~~Importação dos dados do legado~~: segue descartada (ADR-0001, reconfirmado em 2026-11-03), mesmo com o armazenamento local.
