# Continuidade entre computadores

> Este arquivo é lido no início de toda sessão. **Atualize-o ao fim de cada sessão** (estado, próximo passo, pendências) e commite junto com o trabalho. Sem caminhos absolutos nem comandos exclusivos de um sistema.

## Estado atual (atualizado em 2026-10-28)

- Modo: **reescrita**. Design **aprovado** (ADR-0009). Marco **M0 parcial**: tema, rotas das 3 abas, `Result/Failure`, dinheiro em centavos, l10n (4 idiomas), lints e 6 testes. `analyze` limpo. Nunca rodou em aparelho/emulador.
- Falta do M0: inicialização do Firebase, CI (`analyze` + `test`) e ícone.
- Tag `legacy/1.2` marca o app iOS antigo (commit `a61a69e`).
- Telas são só casca (título na AppBar).
- **Domínio puro feito (2026-10-28)**: `Rule`, `Child`, `Entry` (incrementa, decrementa com piso 0, zera, ativa/desativa) e `calculateBalanceCents`, com 11 testes (`features/{rules,children,ledger}/domain`). Falta: contratos de repositório, datasources, estado e telas.
- **Firebase `mesada-proj`** (criado no Google Cloud pelo usuário; Firebase ativado via CLI em 2026-10-28). `flutterfire configure` rodado para Android e iOS (`br.eti.claudiocastro.mesada`); `Firebase.initializeApp` está no `main.dart`. **Ainda não habilitados**: Authentication (e-mail/senha, Google, Apple) e o banco Firestore — passos do usuário no console, e as regras de segurança só são publicadas com aprovação.
- Ferramentas: `firebase` CLI (logar com `firebase login`), `dart pub global activate flutterfire_cli`; o `bin` do pub cache pode não estar no PATH (usar `dart pub global run flutterfire_cli:flutterfire`). Para refazer a configuração: `flutterfire configure --project=mesada-proj --platforms=android,ios --android-package-name=br.eti.claudiocastro.mesada --ios-bundle-id=br.eti.claudiocastro.mesada`.
- Arquivos gerados do Firebase (`lib/firebase_options.dart`, `android/app/google-services.json`, `firebase.json`): **versionados** no Git (ADR-0010); em outro computador basta `git pull` e `flutter pub get`.

## Como retomar em outro computador

Pré-requisitos: Git, Flutter **3.44.4** stable (Dart 3.12.2) e Android SDK. Build/execução de iOS exige macOS com Xcode (no Windows/Linux, testar via Android e `flutter test`).

```bash
git clone https://github.com/ccastroelo/mesada.git
cd mesada
git fetch --tags
cd app-flutter
flutter pub get
flutter analyze
flutter test
```

Já tendo o clone: `git pull --tags` na raiz e depois `flutter pub get`. Os arquivos de localização gerados (`app-flutter/lib/l10n/app_localizations*.dart`) são versionados; rode `flutter gen-l10n` só depois de editar um `.arb`.

Resultado esperado: `analyze` sem problemas e 6 testes passando. Se divergir, registre o baseline em `flutter.md` antes de mexer.

## Próximos passos (ordem)

1. **P0** (do usuário): criar o projeto Firebase (Auth com e-mail/senha, Google e Apple; Firestore) e decidir versão/build de release (> 1.2, build > 9). Revogar a chave/secret do Dropbox e a do Flurry do app antigo (estão no histórico do git; ver `behavior-inventory.md` §5).
2. ~~Domínio de entidades e saldo~~ (feito). Resta sem Firebase: contratos de repositório e casos de uso com regra (zerar com desfazer, semear as 20 regras-padrão por idioma, ativar/desativar regra por filho), usando repositórios falsos nos testes.
3. **M0 restante**: Firebase init (config fora do repositório quando for segredo; ver `working-agreement.md`), CI mínima, ícone.
4. **M1** — fatia-piloto `auth_family` (login, criar família, convite por código). Ao terminá-lo, criar `docs/agents/architecture.md` com o fluxo real e importá-lo no `CLAUDE.md`.
5. M2–M7 conforme `migration-plan.md`. M8 (corte) é decisão do usuário.

## Cuidados

- `mesada/` (app iOS antigo) é só leitura. Não copie para lugar nenhum as chaves hardcoded de `mesada/mesada/imAppDelegate.m:28` e `:50`.
- Antes de qualquer tela nova, releia os itens do inventário (`behavior-inventory.md` §1–2) e o `design.md`.
- Pergunte antes de: Firebase/regras do Firestore, `applicationId`, versão/build, assinatura, commit/tag/push, apagar o legado.
- Dinheiro sempre em centavos inteiros; foto do filho só local (ADR-0006).

## Prompt para iniciar a sessão em casa

> Continue a reescrita do Mesada. Leia `CLAUDE.md` e `docs/agents/continuidade.md`, confira `git status`, rode `flutter analyze` e `flutter test` em `app-flutter/` para o baseline e me diga o estado e o próximo passo antes de editar.
