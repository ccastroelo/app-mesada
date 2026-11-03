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

## Baseline (código novo, sem legado) — atualizado em 2026-11-03

| Verificação | Resultado |
|---|---|
| `flutter analyze` | sem problemas |
| `flutter test` | **168 testes passando** (os 142 do M1.5 mais 26 do M4: lançamentos no repositório local e no do Firestore com datasource falso, e a tela do filho — abrir pelo cartão, ±, piso 0, regra desativada, switches, zerar com Desfazer, zerar de todos e fonte 1,3×/2,0× em tela de 360 dp) — atualizado em 2026-11-03 |
| `flutter build apk --debug` | compilava em 2026-10-28; **não refeito** depois de tirar o Firebase do `main.dart` (Gradle precisa rodar fora do sandbox no Windows: "Unable to establish loopback connection") |
| Aviso do build | `firebase_auth` e `firebase_core` ainda aplicam o Kotlin Gradle Plugin; o Flutter avisa que versões futuras vão exigir "Built-in Kotlin". Acompanhar atualizações dos plugins. |
| Executado em aparelho/emulador | **não** — só testes de widget e compilação |
| Firebase | projeto `mesada-proj`; apps Android e iOS registrados. **Não é mais inicializado** no `main.dart`: o modo local não usa Firebase (ADR-0014). Auth e Firestore seguem desabilitados no console — passam a ser pré-requisito do M4.5. |

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
