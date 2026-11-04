# Flutter — Mesada

Comandos e baseline do projeto Flutter em `app-flutter/` (rode tudo a partir dessa pasta).

## Ambiente do baseline (2026-10-28)

- Flutter 3.44.4 (stable) · Dart 3.12.2
- Plataformas criadas: Android e iOS
- `applicationId` / bundle id: `br.eti.claudiocastro.mesada` (ADR-0007)
- Estado: Riverpod · rotas: `go_router` · l10n: `gen-l10n` (pt, pt_PT, en, es; `lib/l10n/`)
- Relatório: `pdf` (Dart puro) gerando o documento e `share_plus` entregando ao sistema (ADR-0016)
- Compra e assinatura (ADR-0021): `in_app_purchase` (^3.3.1) com dois produtos, `mesada_app` (não-consumível) e `mesada_compartilhar` (assinatura). Os ids têm de existir nas duas lojas. **Nunca exercitado contra a loja**; nos testes entra um `FakeStoreGateway`.
- Bloqueio: `local_auth` (biometria) com o PIN do app como reserva (ADR-0018); o PIN é `crypto` (SHA-256 com sal) num arquivo do aparelho, sem `flutter_secure_storage` (ADR-0017)
- "Esqueci o PIN" (ADR-0023): o app fala com o servidor PHP de `servidor/` pelo `HttpClient` do Dart (sem pacote novo). A URL entra com `--dart-define=RECOVERY_URL=https://.../pin` (ou no arquivo de `--dart-define-from-file`, fora do Git). Sem ela o recurso não aparece.
- Configuração de plataforma da biometria: Android usa `FlutterFragmentActivity` e declara `USE_BIOMETRIC`; iOS tem `NSFaceIDUsageDescription`. **Não exercitada em aparelho** (`tech-debt.md`)

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
| `flutter test` | **390 testes passando** (os 178 do M5 mais 48 do M6: espera crescente, hash e sal do PIN, `DeviceSettings`, controlador com relógio controlado — inclusive os 30 s fora do app —, biometria com falso e os fluxos da tela de bloqueio e de Ajustes › Segurança; mais 9 do M7 (introdução, Ajuda e a marca no `device.json`) e 21 do M4.5 (a marca do direito, a cópia local, os estados da tela da Família, o modo guardado no aparelho e a família nascendo com os dados locais)) — atualizado em 2026-11-04; mais 29 do M4.5b: produtos e cópia local das compras, só leitura nas telas e na escrita, faixa de teste, compra/restauração com loja falsa e a assinatura exigida para compartilhar; mais 16 do M4.5c: o retrato local e o maior instante visto; mais 22 dos acabamentos: saída do arquivo ilegível, nome da família local, seções recolhíveis, animação do saldo e filho excluído com a tela aberta; mais 47 do "esqueci o PIN": regras puras, `PinStoreImpl`, o cliente HTTP contra um servidor local, o controlador e as telas de bloqueio e Segurança) |
| `flutter build apk --debug` | compilava em 2026-10-28; **não refeito** depois de tirar o Firebase do `main.dart` (Gradle precisa rodar fora do sandbox no Windows: "Unable to establish loopback connection") |
| CI/CD (Codemagic, ADR-0019) | `codemagic.yaml` na raiz, workflow `verificacao`: `flutter pub get`, `analyze` e `test` em `app-flutter/`, Flutter 3.44.4, máquina Linux. **Não dispara sozinho**: o repositório precisa ser conectado no Codemagic e o webhook criado lá. **Nenhuma execução vista ainda.** O workflow do GitHub Actions foi removido. Build de release depende de versão, assinatura e contas das lojas. |
| Aviso do build | `firebase_auth` e `firebase_core` ainda aplicam o Kotlin Gradle Plugin; o Flutter avisa que versões futuras vão exigir "Built-in Kotlin". Acompanhar atualizações dos plugins. |
| Executado em aparelho/emulador | **sim, em 2026-11-03** (primeira execução fora dos testes, pelo usuário; sem relato de problema). A conferência tela por tela em 1,0×/1,3×/2,0×, claro e escuro (`flutter-preview`) segue pendente. |
| Firebase | projeto `mesada-proj`; apps Android e iOS registrados. **Não é mais inicializado** no `main.dart`: o modo local não usa Firebase (ADR-0014). Auth e Firestore seguem desabilitados no console — passam a ser pré-requisito do M4.5. |

## Testes das regras do Firestore (emulador local)

Pasta `app-flutter/firebase-tests/` (Node 22, Java 21, `firebase` CLI). Baseline (2026-10-28): **28 testes passando**. Em 2026-11-04 entraram **6 testes do campo `plan`** (ADR-0020) que **nunca foram executados** — o emulador precisa do terminal do usuário. Não toca a nuvem (projeto `demo-mesada`).

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
