# Continuidade entre computadores

> Este arquivo é lido no início de toda sessão. **Atualize-o ao fim de cada sessão** (estado, próximo passo, pendências) e commite junto com o trabalho. Sem caminhos absolutos nem comandos exclusivos de um sistema.

## Estado atual (atualizado em 2026-10-28)

- Modo: **reescrita**. Design **aprovado** (ADR-0009). Marco **M0 parcial**: tema, rotas das 3 abas, `Result/Failure`, dinheiro em centavos, l10n (4 idiomas), lints e 6 testes. `analyze` limpo. Nunca rodou em aparelho/emulador.
- Falta do M0: inicialização do Firebase, CI (`analyze` + `test`) e ícone.
- Tag `legacy/1.2` marca o app iOS antigo (commit `a61a69e`).
- **M1 (auth_family) com código completo (2026-10-28)**: boas-vindas, entrar/criar conta por e-mail, Google (OAuth do Firebase), escolha de família, criar família (semeia as 20 regras no idioma), entrar com código, convite em Ajustes (copiar/compartilhar), sair. Roteador com guardas (`redirectFor`). `architecture.md` descreve o fluxo. **Falta validar em aparelho/emulador com o Firebase real**: criar conta, criar família, convidar e entrar com a segunda conta, Google. O APK de debug compila.
- Fora do M1 (ainda não existe): "Entrar com a Apple", sair/trocar de família, tela de introdução (4 cartões), banner offline, redefinição de senha só testada com fake.
- **M2 (rules) com código completo (2026-10-28)**: aba Regras com lista em Recompensas/Descontos (ícone ▲▼ + sinal), criar/editar (descrição, tipo, valor com máscara de centavos, teto 999,99), excluir com confirmação (apaga também os lançamentos da regra), reordenar (alça de arrastar + Concluir) e "Usar sugestões" quando vazio. Testado com repositório falso, inclusive fonte 1,3× e 2,0× em tela de 360 dp. **Não validado com Firestore real em aparelho.** Sem "Desfazer" ao excluir (o design só prevê desfazer ao zerar).
- **M3 (children) com código completo (2026-10-28)**: aba Filhos com cartões (foto local ou inicial, nome, mesada, **saldo** calculado ao vivo com regras + lançamentos), criar/editar (nome, e-mail opcional, mesada com máscara, teto 999.999,99, foto da galeria só no aparelho), excluir com confirmação (apaga lançamentos e foto local) e reordenar. 120 testes. O toque no cartão **ainda não abre** os lançamentos (M4); o menu ⋮ só tem Editar e Excluir (Zerar vem no M4, Enviar relatório no M5). Também adicionado `NSPhotoLibraryUsageDescription` no `Info.plist`. Os testes acharam e corrigi um bug de Hero entre os FABs das abas (ver `tech-debt.md`).
- **Dívida conhecida**: escritas de formulário esperam o servidor (offline o botão fica girando) — `tech-debt.md`.
- **Domínio puro feito (2026-10-28)**: `Rule`, `Child`, `Entry` (incrementa, decrementa com piso 0, zera, ativa/desativa) e `calculateBalanceCents`, com 11 testes (`features/{rules,children,ledger}/domain`). Falta: contratos de repositório, datasources, estado e telas.
- **Firebase `mesada-proj`** (criado no Google Cloud pelo usuário; Firebase ativado via CLI em 2026-10-28). `flutterfire configure` rodado para Android e iOS (`br.eti.claudiocastro.mesada`); `Firebase.initializeApp` está no `main.dart`. **Ainda não habilitados**: Authentication (e-mail/senha, Google, Apple) e o banco Firestore — passos do usuário no console, e as regras de segurança só são publicadas com aprovação.
- **Regras do Firestore** (`app-flutter/firestore.rules`, ADR-0011): escritas, **testadas no emulador (28 testes)** e **publicadas em `mesada-proj` (2026-10-28)**. Mudar as regras = editar, testar e só então `firebase deploy --only firestore:rules`, com OK do usuário. Como rodar os testes: `flutter.md`.
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

Resultado esperado: `analyze` sem problemas e 120 testes passando (mais os 28 das regras do Firestore, em `firebase-tests/`). Se divergir, registre o baseline em `flutter.md` antes de mexer.

## Próximos passos (ordem)

1. **P0** (do usuário): criar o projeto Firebase (Auth com e-mail/senha, Google e Apple; Firestore) e decidir versão/build de release (> 1.2, build > 9). Revogar a chave/secret do Dropbox e a do Flurry do app antigo (estão no histórico do git; ver `behavior-inventory.md` §5).
2. ~~Domínio de entidades e saldo~~ (feito). Resta sem Firebase: contratos de repositório e casos de uso com regra (zerar com desfazer, semear as 20 regras-padrão por idioma, ativar/desativar regra por filho), usando repositórios falsos nos testes.
3. **M0 restante**: Firebase init (config fora do repositório quando for segredo; ver `working-agreement.md`), CI mínima, ícone.
4. ~~M1~~ código pronto; **validar com o Firebase real** (emulador/aparelho Android; ver `flutter-preview`). Criar contas de teste no `mesada-proj` é decisão do usuário.
5. ~~M2 `rules`~~ e ~~M3 `children`~~ com código pronto (ver acima). **Próximo: M4 `ledger`** — a tela do filho (toque no cartão): linhas − qtd + por regra em Recompensas/Descontos, chip animado do saldo, ativar/desativar regra por filho, zerar um/todos com "Desfazer" por 8 s. **Decidir antes** como gravar sem esperar o servidor (`tech-debt.md`, vira ADR). Depois M5 relatório, M6 PIN, M7 ajuda. M8 (corte) é decisão do usuário.
6. **Validar M1–M3 com o Firebase real** em emulador/aparelho (cria contas de teste no `mesada-proj`, decisão do usuário). Quanto mais telas sem isso, mais caro achar erro de configuração.

## Cuidados

- `mesada/` (app iOS antigo) é só leitura. Não copie para lugar nenhum as chaves hardcoded de `mesada/mesada/imAppDelegate.m:28` e `:50`.
- Antes de qualquer tela nova, releia os itens do inventário (`behavior-inventory.md` §1–2) e o `design.md`.
- Pergunte antes de: Firebase/regras do Firestore, `applicationId`, versão/build, assinatura, commit/tag/push, apagar o legado.
- Dinheiro sempre em centavos inteiros; foto do filho só local (ADR-0006).

## Prompt para iniciar a sessão em casa

> Continue a reescrita do Mesada. Leia `CLAUDE.md` e `docs/agents/continuidade.md`, confira `git status`, rode `flutter analyze` e `flutter test` em `app-flutter/` para o baseline e me diga o estado e o próximo passo antes de editar.
