# Arquitetura — Mesada (app-flutter)

Descreve o que **existe** em `app-flutter/lib`. Regras completas e justificativas: `~/.claude/skills/project-docs/reference/target-architecture.md` (feature-first `data / domain / presentation`). Estado: Riverpod (ADR-0004). Armazenamento: **arquivo local por padrão**; Firebase Auth + Firestore só com a assinatura Família (ADR-0014, ADR-0015, ADR-0011).

> **Modo local em uso desde o M1.5 (2026-11-03)**: o app roda sem conta e sem Firebase, com os dados num arquivo JSON do aparelho (ADR-0014). A nuvem (login, convite, Firestore) continua no código, desligada, à espera da assinatura Família no M4.5 (ADR-0015).

## Estrutura

```
lib/
  main.dart            ProviderScope (sem retentativa automática); sem Firebase no modo local
  app.dart             MaterialApp.router, tema, l10n
  firebase_options.dart  gerado pelo flutterfire (versionado, ADR-0010)
  core/
    theme/             tokens (Space, Radii) + AppTheme + MesadaColors (positivo/negativo/moeda)
    router/            go_router + guardas (redirectFor) + casca de 3 abas
    error/             Failure (selada) e Result<T> = Ok | Err
    firebase/          failureFromFirebase: exceção do SDK -> Failure (só a camada data usa)
    storage/           LocalStore (mesada.json atômico) + LocalDocument + AppMode/providers
                       + DeviceSettings (device.json: ajustes do aparelho)
    state/             ActionState + ActionController (base das ações de tela: carregando/falha)
    widgets/           PageBody, FailureText/failureMessage, EmptyState, ErrorState,
                       SectionHeader, MoneyField (máscara de centavos)
    utils/             formatCents / formatCentsPlain / centsFromMaskedText (dinheiro em centavos),
                       newLocalId (id de documento criado no aparelho)
  features/
    auth_family/       login, família, convite  (fatia-piloto, M1)
    rules/             Regras: lista, criar/editar, excluir, reordenar, sugestões (M2)
    children/          Filhos: cartões com saldo, CRUD, foto local (M3); tela do filho com os
                       lançamentos ± e as regras do filho (M4)
    ledger/            Lançamentos: Entry, saldo, escritas (±, ativar/desativar, zerar) (M4)
                       e o relatório em PDF compartilhado (M5)
    app_lock/          Bloqueio: biometria com PIN de reserva, Ajustes › Segurança (M6)
    help/              Introdução em 4 cartões e Ajustes › Ajuda (M7)
    entitlement/       Acesso ao app: marca do aparelho (início do teste, origem) e regra de acesso (M4.5)
    settings/          Ajustes (família, convite, segurança, conta/sair)
  l10n/                .arb (pt, pt_PT, en, es) + arquivos gerados versionados
test/                  espelha lib/; test/support tem fakes e pumpApp
```

Regras que valem aqui: `domain` é Dart puro; só `data/datasources` toca Firebase; entity ≠ DTO; uma feature só usa outra pelo arquivo-barril (`rules/rules.dart`, `children/children.dart`, `auth_family/auth_family.dart`); dinheiro sempre em centavos inteiros.

## Dois modos, uma fonte de verdade por vez (ADR-0014)

`core/storage/providers.dart` tem o `appModeProvider` (`AppMode.local` | `AppMode.cloud`). Hoje ele é fixo em `local`; a assinatura Família vai trocá-lo no M4.5. Cada raiz de composição escolhe pela mesma chave:

```
rulesRepositoryProvider      local -> RulesLocalRepository(LocalStore)
                             cloud -> RulesRepositoryImpl(RulesFirestoreDataSource)
childrenRepositoryProvider   idem (ChildrenLocalRepository)
ledgerRepositoryProvider     idem (LedgerLocalRepository)
```

- `LocalStore` é o único ponto que toca o disco — o papel que o datasource do Firestore tem na nuvem. Guarda **um** arquivo (`<pasta do app>/mesada.json`), publica cada mudança por stream e grava de forma atômica (escreve `.tmp` e renomeia). A mudança vale **em memória antes do disco**, então a tela reage no mesmo quadro; falha de gravação volta como `Err(Unexpected)` e o que está na tela continua valendo. Escritas disparadas juntas entram numa fila, na ordem de chegada.
- `LocalDocument` guarda as fatias (`family`, `children`, `rules`, `entries`) em JSON cru, com **os mesmos campos do Firestore**, para o envio na assinatura ser tradução direta. Quem traduz para entidade é a camada `data` de cada feature, pelos DTOs que já existiam (`RuleDto`, `ChildDto`, `FamilyDto`). Arquivo é borda: campo ausente ou com tipo errado cai no padrão.
- A ordem de exibição continua no campo `order` (ADR-0013). O que no Firestore era `orderBy('order')` é ordenação no repositório local, com o id desempatando (dois itens podem cair no mesmo milissegundo e `List.sort` não é estável).
- Ids de documento criados no aparelho vêm de `newLocalId()` (relógio em base 36 + 4 caracteres sorteados).
- Arquivo ilegível vira **erro no stream** (o portão mostra a tela de erro) em vez de começar vazio: melhor avisar que dar os dados por perdidos. Ainda não há saída dessa tela — ver `tech-debt.md`.

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

## Terceiro exemplo: Filhos (M3), uma tela que junta três features

- `childSummariesProvider` combina `childrenProvider` (própria), `rulesProvider` (`rules/rules_providers.dart`) e `entriesProvider` (`ledger/ledger_providers.dart`) e calcula o saldo de cada filho com `calculateBalanceCents` (`ledger/ledger.dart`). Fica em carregando até os três chegarem e em erro se qualquer um falhar. O saldo muda sozinho quando o outro responsável lança.
- **Dois barris por feature quando há estado**: `x.dart` (só domínio, sem Riverpod) e `x_providers.dart` (estado, depende de `auth_family`). Assim `auth_family` pode importar o domínio de `rules` sem formar ciclo.
- **Foto local** (ADR-0006): contratos `ChildPhotoStore` e `PhotoPicker` no `domain`; `ChildPhotoStoreImpl` (arquivos em `<pasta do app>/child_photos/<childId>.jpg`) e `ImagePickerPhotoPicker` (galeria, 512 px, JPEG 80) na `data`. O `ChildrenActions` copia a foto depois de criar o filho (precisa do id), remove ao excluir e invalida `childPhotoPathProvider`; a imagem em cache é expulsa com `FileImage.evict`.
- `ChildAvatar` mostra a foto ou a inicial num círculo de 6 cores fixas (índice estável por id, não `hashCode`).
- Cada aba tem seu `FloatingActionButton` com `heroTag: null` (ver `tech-debt.md`).


## Quarto exemplo: lançar ± (M4), e por que a tela do filho vive em `children`

- As telas são `children/presentation/pages/child_ledger_page.dart` (a mais usada do app) e `child_rules_page.dart`; o estado é o `childLedgerProvider` (`children/presentation/state/child_ledger_state.dart`), que junta **filho + regras + lançamentos** e monta `ChildLedger` com uma `LedgerRow` por regra (quantidade e `enabled`) e o saldo.
- **Por que em `children` e não em `ledger`**: a tela precisa de `childrenProvider`, `rulesProvider` e `entriesProvider`. A feature `children` já depende de `rules` e de `ledger` (M3); o caminho contrário faria ciclo. A `ledger` fica com domínio, dados e as **escritas**.
- As escritas são o `ledgerActionsProvider` (`ledger/presentation/state/ledger_state.dart`, exposto por `ledger_providers.dart`): `increment`, `decrement`, `setEnabled`, `zero` e `restore`. `zero` devolve as quantidades que havia (nulo se falhar), e é a tela que as guarda para o "Desfazer" de 8 s.
- O lançamento **nasce no primeiro toque** (ADR-0013). No modo local a conta é feita no arquivo, com piso 0. Na nuvem, ± vira `FieldValue.increment(±1)` com `merge`: a soma acontece no servidor, então dois responsáveis lançando junto não perdem toque e a fila do SDK cobre o offline. O piso 0 do − fica com a tela (botão desabilitado em 0) e com as regras de segurança, que rejeitam negativo.
- Zerar não mexe em `enabled` nem na mesada. Desativar uma regra para o filho preserva a quantidade e só a tira do saldo (ADR-0008); a linha desativada não aparece nos lançamentos.
- Acessibilidade da linha: o `tooltip` do botão é o rótulo do leitor de tela ("Aumentar Arrumar a cama, quantidade 2"), o saldo é anunciado após cada lançamento (`SemanticsService.sendAnnouncement`) e, a partir de 1,3× de escala de texto, o stepper desce para uma segunda linha.
- **Relatório (M5, ADR-0016)**: `buildChildReport` (domínio puro) escolhe as linhas — só regras ativas com quantidade > 0 — e o saldo. A tela monta um `ReportDocument` com **tudo já em texto** (`children/presentation/state/child_report_state.dart`), porque moeda, data e idioma vivem na presentation. O `ReportSharer` (contrato no domínio) é implementado por `SharePlusReportSharer`, que chama `buildReportPdf` (Dart puro, pacote `pdf`), grava na pasta temporária e abre a folha do sistema. Nos testes o contrato é trocado por um falso, então nenhum teste gera PDF nem abre a folha.

## O portão de entrada (`gateProvider`)

O roteador decide a tela só pelo `Gate` selado (`GateLoading | GateError | GateSignedOut | GateNeedsFamily | GateReady`), por `redirectFor(gate, location)` — função pura testada. Quem monta o `Gate` depende do modo:

- **local**: `localFamilyProvider` (a família do arquivo, via `LocalFamilySource`) → carregando, erro, ou `GateReady` **sem usuário**. Não há login a esperar, então a primeira abertura cai direto em `/filhos`.
- **nuvem**: `authUserProvider` → `familyIdProvider` → `familyProvider`, como antes. Logado sem família só alcança `/familia/*`; com família sai das telas de entrada.

`GateReady.user` é **nulo no modo local** (ADR-0015): quem precisa de identidade confere (o convite devolve `Err` sem conta, e Ajustes esconde conta, sair e convidar). O `redirectFor` não mudou: no modo local o portão simplesmente nunca fica em `GateSignedOut`.


## O bloqueio por PIN (M6, ADR-0017)

- `appLockProvider` (`app_lock/presentation/state/app_lock_state.dart`) é um `LockState` selado: `LockLoading | LockOff | LockOpen | LockClosed(wrongAttempts, waitUntil)`. O roteador recebe isso em `redirectFor(gate, location, lock:)` e o PIN vem **antes do portão**: enquanto não se sabe se existe PIN, nem o conteúdo nem a tela de entrada aparecem — é a tela de espera.
- O PIN e o interruptor da biometria moram em `device.json`, **fora do `mesada.json`** (ADR-0017): são ajustes do aparelho e não podem subir com os dados da família no M4.5. Quem escreve é o `DeviceSettings` (`core/storage`), que grava **por junção** — ligar a biometria não apaga o PIN. Do PIN guarda-se sal + SHA-256, nunca o PIN.
- **Biometria** (ADR-0018): contrato `BiometricAuth` no domínio, `LocalAuthBiometrics` (`local_auth`) na `data`. A tela de bloqueio pede a biometria ao aparecer e o PIN fica como reserva; `biometricOnly: true`, porque o código do aparelho não serve de reserva. Ligar exige PIN ativo e uma autenticação na hora; desativar o PIN desliga a biometria. Nos testes o contrato é um falso.
- As regras puras ficam em `domain/usecases/pin_lock_rules.dart`: 4 dígitos, sal novo, hash, e a espera que dobra a cada 3 erros (30 s → 15 min de teto). O app **não** se fecha, ao contrário do `exit(0)` do legado.
- O relógio é injetado (`clockProvider`), e é o que deixa os 30 s fora do app e a contagem regressiva testáveis sem esperar de verdade.
- O ciclo de vida é observado em `app.dart` com `AppLifecycleListener`: `hidden`/`paused` marcam a saída, `resumed` decide se pede o PIN. Vale o **primeiro** aviso de saída, porque a volta passa por estados intermediários e um segundo registro zeraria o tempo fora.
- `PinPad` (teclado, 4 pontos, mensagem e erro) é compartilhado pela tela de bloqueio e por Ajustes › Segurança, que usa o mesmo widget em três passos (PIN atual → novo → confirmar).


## A introdução (M7)

- `introSeenProvider` (`help/presentation/state/help_state.dart`) lê a marca do aparelho e entra no `redirectFor` como um `bool?`: **nulo = ainda lendo**, e aí o roteador espera na tela de carregando. Não vista leva para `/introducao` e deixa ficar; vista não leva ninguém para lá, mas **permite** ficar — é assim que Ajustes › Ajuda consegue reabrir a mesma rota.
- A marca mora no `device.json`, pelo mesmo `DeviceSettings` do PIN: a escrita é por junção, então marcar a introdução não mexe no bloqueio.
- A ordem das guardas é PIN → introdução → conteúdo. Quem tem PIN ativo digita antes de ver a introdução.
- Os 4 cartões são **só texto e ícone** (`design.md` §4.9). O app antigo usava imagens de tela por idioma, que envelheceram e não dava para traduzir.


## O acesso ao app: teste, compra e assinatura (M4.5, ADR-0021)

- **O que se vende**: app grátis para baixar; 15 dias de teste; depois a compra única do app (`mesada_app`); compartilhar é uma assinatura (`mesada_compartilhar`); o convidado não paga a compra única. **A compra e a assinatura são direitos que a loja guarda e confirma**; o app não inventa "pagou".
- `AppEntitlement` (`entitlement/domain`) é a **marca do aparelho** no `device.json`: `since` (primeiro uso = início do teste), `modelVersion` e `origin` (`newInstall` | `legacyUpdate`). Nunca é um booleano. É criada **uma só vez**, no primeiro uso, pelo `entitlementProvider` (observado em `app.dart`), e depois nunca é reescrita. A origem vem do `LegacyAppDetector`, que procura os `.plist` do app antigo em Documents (o bundle id é o mesmo, ADR-0007).
- `evaluateAccess` é a **regra de acesso**, pura e testada: app antigo > comprou > membro de família com assinatura ativa > dentro dos 15 dias > só leitura (`FullAccess` ou `ReadOnlyAccess`). Recebe `ownsApp` e `inActiveFamily` de fora; **ainda não há quem os forneça** (falta o gateway de compra), então nada consulta a regra e ninguém é bloqueado.
- **A virada para a nuvem** (ADR-0014) já funciona: o modo fica guardado no `device.json` (`savedModeProvider`) e o portão não mostra conteúdo antes de saber qual é. Em Ajustes › Família, "Entrar para compartilhar" troca o modo para `cloud`; o portão passa a pedir conta, e **criar a família leva o conteúdo deste aparelho** (`createFamilyFromLocal`, com os ids locais preservados para os lançamentos não apontarem para o vazio) em vez de semear as 20 regras-padrão. Quem desistir no meio tem a saída "Usar só neste aparelho" nas boas-vindas. Hoje essa tela **não exige assinatura**: o gate entra com a compra.
- **O que falta** (próximo passo, M4.5b): gateway de compra com os dois produtos; aviso dos dias de teste; modo só leitura nas telas de escrita; a assinatura gravada no documento da família e lida pelo convidado, com as regras do Firestore para isso; validação de recibo no servidor antes de vender.

## Composição e testes

- `auth_family/data/providers.dart` é a raiz de composição: `authRepositoryProvider` e `familyRepositoryProvider` criam as implementações com `FirebaseAuth.instance` / `FirebaseFirestore.instance`.
- Testes substituem esses dois providers por `FakeAuthRepository` / `FakeFamilyRepository` (`test/support/fakes.dart`) e abrem o app inteiro com `pumpApp`. Os repositórios são testados com datasource falso; as regras de segurança, no emulador (`app-flutter/firebase-tests`).
- `pumpApp` recebe o modo. O padrão nos testes é `cloud` (exercita a composição da assinatura, com conta e família falsas); em `local` os repositórios que **não** recebem falso são os de verdade, sobre um `LocalStore` numa pasta temporária — é assim que `local_entry_test.dart` cobre o caminho padrão do app.
- Cuidado em teste de widget: I/O começado fora de `tester.runAsync` **não** completa, então a gravação em disco se prova nos testes do `LocalStore` e dos repositórios locais, não no de fluxo.

## Convenções

- Tela de dados trata carregando, dado, vazio e erro. Erro de ação aparece em texto abaixo do controle (`FailureText`), nunca só em snackbar.
- **Nunca aguarde um canal de plataforma antes de atualizar a tela** (`HapticFeedback`, `Clipboard`, vibração): num teste de widget esse Future não completa, e a tela trava sem motivo. Use `unawaited(...)` e siga. Já tropeçamos nisso três vezes (M4, M6, M7).
- Texto de UI só em `.arb`; as 4 línguas na mesma mudança. Regras-padrão por idioma ficam em `rules/domain/default_rules.dart`.
- Mudou a estrutura de um módulo? Atualize este arquivo no mesmo diff.
