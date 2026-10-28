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
| `flutter test` | 17 testes passando (dinheiro, casca de navegação em 4 idiomas, saldo e lançamentos) — atualizado em 2026-10-28 |
| Executado em aparelho/emulador | **não** — só testes de widget |
| Firebase | projeto `mesada-proj`; apps Android e iOS registrados; `firebase_core` inicializado no `main.dart`. Auth e Firestore ainda não habilitados. Não rodado em aparelho. |

## Pendências que o código ainda não resolve

- `pubspec.yaml` está em `version: 1.0.0+1` (padrão do `flutter create`). Como o app **substitui** o publicado (ADR-0007, legado 1.2 build 9), a versão de release precisa ser **maior que 1.2 e build > 9**. Definição de versão/build é decisão do usuário; não alterar sem pedir.
- Assinatura iOS/Android e perfis: não tocados.
- Ícone, launch screen e nome exibido ainda são os padrões do Flutter.
