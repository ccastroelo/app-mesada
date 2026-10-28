# Arquitetura — Mesada (app-flutter)

Descreve o que **existe** em `app-flutter/lib`. Regras completas e justificativas: `~/.claude/skills/project-docs/reference/target-architecture.md` (feature-first `data / domain / presentation`). Estado: Riverpod (ADR-0004). Backend: Firebase Auth + Firestore (ADR-0002, ADR-0011).

## Estrutura

```
lib/
  main.dart            Firebase.initializeApp + ProviderScope (sem retentativa automática)
  app.dart             MaterialApp.router, tema, l10n
  firebase_options.dart  gerado pelo flutterfire (versionado, ADR-0010)
  core/
    theme/             tokens (Space, Radii) + AppTheme + MesadaColors (positivo/negativo/moeda)
    router/            go_router + guardas (redirectFor) + casca de 3 abas
    error/             Failure (selada) e Result<T> = Ok | Err
    firebase/          failureFromFirebase: exceção do SDK -> Failure (só a camada data usa)
    state/             ActionState + ActionController (base das ações de tela: carregando/falha)
    widgets/           PageBody, FailureText/failureMessage, EmptyState, ErrorState,
                       SectionHeader, MoneyField (máscara de centavos)
    utils/             formatCents / formatCentsPlain / centsFromMaskedText (dinheiro em centavos)
  features/
    auth_family/       login, família, convite  (fatia-piloto, M1)
    rules/             Regras: lista, criar/editar, excluir, reordenar, sugestões (M2)
    children/          entidade Child; tela ainda é casca
    ledger/            Entry + calculateBalanceCents; sem telas ainda
    settings/          Ajustes (família, convite, conta/sair)
  l10n/                .arb (pt, pt_PT, en, es) + arquivos gerados versionados
test/                  espelha lib/; test/support tem fakes e pumpApp
```

Regras que valem aqui: `domain` é Dart puro; só `data/datasources` toca Firebase; entity ≠ DTO; uma feature só usa outra pelo arquivo-barril (`rules/rules.dart`, `children/children.dart`, `auth_family/auth_family.dart`); dinheiro sempre em centavos inteiros.

## Fluxo de exemplo: entrar com código de convite

```
JoinFamilyPage (presentation/pages)
  └─ joinFamilyControllerProvider.notifier.join(code)         presentation/state/controllers.dart
       └─ familyRepositoryProvider.joinWithCode(user, code)    contrato: domain/repositories/family_repository.dart
            └─ FamilyRepositoryImpl.joinWithCode               data/repositories
                 ├─ normalizeInviteCode(code)                  domain/usecases/invite_code.dart (regra pura)
                 ├─ FamilyFirestoreDataSource.getInvite        data/datasources (único que toca o Firestore)
                 └─ FamilyFirestoreDataSource.joinFamily       um lote: membro + convite usado + vínculo
```

- O resultado volta como `Result<void>`: `Ok`, ou `Err(Failure)`. O repositório converte exceção do SDK em `Failure` (`failureFromFirebase`); a UI converte `Failure` em texto (`failureMessage`, usa o `.arb`).
- `ActionController.run` guarda `ActionState(loading, failure)`; a tela mostra carregando, o erro abaixo do botão e desabilita o botão.
- Quando o lote grava, o stream `users/{uid}` muda e o `gateProvider` passa de `GateNeedsFamily` para `GateReady`; o `redirectFor` do roteador leva a `/filhos`. A tela não navega sozinha.

## Segundo exemplo: Regras (M2), uma feature que depende da família

- `rulesProvider` (StreamProvider) lê o `familyId` do `gateProvider` da `auth_family` pelo barrel e assina `RulesRepository.watchRules`. As telas só desenham os estados: carregando, erro (`ErrorState` com "Tentar de novo"), vazio (`EmptyState` + "Usar sugestões") e dado (lista em seções Recompensas/Descontos, por `splitRules`).
- Escritas passam por um `RulesActions` (`ActionController`): `add`, `update`, `delete`, `reorder`, `addSuggestions`. O modo Reordenar trabalha numa cópia local da lista e só grava ao tocar em Concluir.
- O barrel `rules/rules.dart` expõe só **domínio** (entidade, contrato, `splitRules`, regras-padrão). O estado fica fora dele de propósito: depende de `auth_family`, que importa esse barrel (evita ciclo).
- Lançamentos nascem sob demanda e a ordem usa inteiros crescentes: ADR-0013.

## O portão de entrada (`gateProvider`)

`authUserProvider` → `familyIdProvider` → `familyProvider` compõem um `Gate` selado: `GateLoading | GateError | GateSignedOut | GateNeedsFamily | GateReady`. O roteador usa só isso (`redirectFor(gate, location)`, função pura testada). Logado sem família só alcança `/familia/*`; com família sai das telas de entrada.

## Composição e testes

- `auth_family/data/providers.dart` é a raiz de composição: `authRepositoryProvider` e `familyRepositoryProvider` criam as implementações com `FirebaseAuth.instance` / `FirebaseFirestore.instance`.
- Testes substituem esses dois providers por `FakeAuthRepository` / `FakeFamilyRepository` (`test/support/fakes.dart`) e abrem o app inteiro com `pumpApp`. Os repositórios são testados com datasource falso; as regras de segurança, no emulador (`app-flutter/firebase-tests`).

## Convenções

- Tela de dados trata carregando, dado, vazio e erro. Erro de ação aparece em texto abaixo do controle (`FailureText`), nunca só em snackbar.
- Texto de UI só em `.arb`; as 4 línguas na mesma mudança. Regras-padrão por idioma ficam em `rules/domain/default_rules.dart`.
- Mudou a estrutura de um módulo? Atualize este arquivo no mesmo diff.
