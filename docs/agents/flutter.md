# Flutter — Mesada

Comandos e baseline do projeto Flutter em `app-flutter/` (rode tudo a partir dessa pasta).

## Ambiente do baseline (2026-10-28)

- Flutter 3.44.4 (stable) · Dart 3.12.2
- Plataformas criadas: Android e iOS
- `applicationId` / bundle id: `br.eti.claudiocastro.mesada` (ADR-0007)
- Estado: Riverpod · rotas: `go_router` · l10n: `gen-l10n` (pt, pt_PT, en, es; `lib/l10n/`)

## Comandos

```bash
flutter pub get
flutter gen-l10n          # depois de editar lib/l10n/*.arb (arquivos gerados ficam versionados)
flutter analyze
flutter test
```

## Baseline do M0 (código novo, sem legado)

| Verificação | Resultado |
|---|---|
| `flutter analyze` | sem problemas |
| `flutter test` | 58 testes passando (dinheiro, saldo, regras-padrão, código de convite, falhas do Firebase, repositório de família com datasource falso, redirecionamento, fluxo de entrada e casca em 4 idiomas) — atualizado em 2026-10-28 |
| `flutter build apk --debug` | compila (Gradle precisa rodar fora do sandbox no Windows: "Unable to establish loopback connection") |
| Aviso do build | `firebase_auth` e `firebase_core` ainda aplicam o Kotlin Gradle Plugin; o Flutter avisa que versões futuras vão exigir "Built-in Kotlin". Acompanhar atualizações dos plugins. |
| Executado em aparelho/emulador | **não** — só testes de widget e compilação |
| Firebase | projeto `mesada-proj`; apps Android e iOS registrados; `firebase_core` inicializado no `main.dart`. Auth e Firestore ainda não habilitados. Não rodado em aparelho. |

## Testes das regras do Firestore (emulador local)

Pasta `app-flutter/firebase-tests/` (Node 22, Java 21, `firebase` CLI). Baseline (2026-10-28): **28 testes passando**. Não toca a nuvem (projeto `demo-mesada`).

```bash
cd app-flutter/firebase-tests
npm install
```

Terminal 1 (deixe aberto): `npm run emulator`. Terminal 2: `npm test`.

Pegadinhas no Windows:
- Rode o emulador **no terminal do usuário**, não num shell com sandbox (o Java falha com "failed to open a new selector").
- Não use `firebase emulators:exec` com `node --test`: o `node` do CLI standalone não é o Node real. Por isso são dois terminais.
- Se uma execução cair, pode sobrar um `java.exe` segurando as portas 8080/9150 ("port taken"): finalize esse processo antes de tentar de novo.

## Pendências que o código ainda não resolve

- `pubspec.yaml` está em `version: 1.0.0+1` (padrão do `flutter create`). Como o app **substitui** o publicado (ADR-0007, legado 1.2 build 9), a versão de release precisa ser **maior que 1.2 e build > 9**. Definição de versão/build é decisão do usuário; não alterar sem pedir.
- Assinatura iOS/Android e perfis: não tocados.
- Ícone, launch screen e nome exibido ainda são os padrões do Flutter.
