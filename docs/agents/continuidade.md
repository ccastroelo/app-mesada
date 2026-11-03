# Continuidade entre computadores

> Este arquivo é lido no início de toda sessão. **Atualize-o ao fim de cada sessão** (estado, próximo passo, pendências) e commite junto com o trabalho. Sem caminhos absolutos nem comandos exclusivos de um sistema.

## Estado atual (atualizado em 2026-11-03)

- **Mudança de requisito (2026-11-03)**: o app guarda os dados **no aparelho** por padrão, sem conta e sem Firebase; compartilhar com o outro responsável é a assinatura **Família**, que é da família (o convidado não paga) e só então pede conta. ADR-0014 e ADR-0015; `design.md` §13. Preço e período seguem em aberto.
- **M1.5 (modo local) pronto no código (2026-11-03)**: `LocalStore` grava um `mesada.json` atômico na pasta do app e publica cada mudança; `RulesLocalRepository`, `ChildrenLocalRepository` e `LedgerLocalRepository` servem as abas sem rede; a família nasce local (sem nome, a tela mostra "Minha família"); o portão (`gateProvider`) tem caminho local e caminho nuvem, com `GateReady.user` nulo no local; `main.dart` **não** inicializa o Firebase; Ajustes esconde conta, sair e convidar sem conta. `analyze` limpo e **142 testes**. Telas de login/convite seguem no código, desligadas, para o M4.5. **Nunca rodou em aparelho/emulador.**
- **M4 (ledger) pronto no código (2026-11-03)**: a tela do filho (toque no cartão) com linhas `− qtd +` em Recompensas/Descontos, chip do último lançamento junto ao saldo, retorno tátil, "Regras deste filho" com switches (desativar guarda a quantidade), zerar um filho ou todos com "Desfazer" por 8 s. Escritas novas no `LedgerRepository` (local e Firestore, este com `FieldValue.increment`). 168 testes, `analyze` limpo. Pendências de propósito (som, seções recolhíveis, animação do saldo): `tech-debt.md`. **Não validado em aparelho.**
- Modo: **reescrita**. Design **aprovado** (ADR-0009). Marco **M0 parcial**: tema, rotas das 3 abas, `Result/Failure`, dinheiro em centavos, l10n (4 idiomas), lints e 6 testes. `analyze` limpo. Nunca rodou em aparelho/emulador.
- Falta do M0: CI (`analyze` + `test`) e ícone. A inicialização do Firebase saiu do M0 e virou parte do M4.5 (ADR-0014).
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

Resultado esperado: `analyze` sem problemas e 168 testes passando (mais os 28 das regras do Firestore, em `firebase-tests/`, que só valem para o modo nuvem). Se divergir, registre o baseline em `flutter.md` antes de mexer.

## Próximos passos (ordem)

> Desde 2026-11-03 o app é local por padrão e a nuvem é da assinatura (ADR-0014/0015). M1.5 e M4 com código pronto.

1. **Rodar em aparelho/emulador** (`flutter-preview`): o app nunca abriu fora dos testes, e agora dá para abrir **sem nenhuma configuração de Firebase**. É o passo mais barato antes de empilhar mais telas — e a tela de lançamentos é de uso diário, vale sentir o toque, o chip e o retorno tátil.
2. **M0 restante**: CI mínima (`analyze` + `test`) e ícone.
3. **M5 relatório por e-mail** (a barra inferior da tela do filho nasce aqui, com "Enviar relatório"), depois **M6 PIN** e **M7 ajuda**.
4. **M4.5 Família (assinatura)**: tela do recurso, `in_app_purchase`, restaurar compras, conta no momento de compartilhar, envio inicial do local para o Firestore e troca do `appModeProvider`. **Só aqui** voltam a ser necessários o Auth e o Firestore habilitados no console, e só aqui dá para exercitar de verdade dois responsáveis lançando ao mesmo tempo.
5. M8 (corte) é decisão do usuário.
6. **Do usuário, quando quiser**: revogar a chave/secret do Dropbox e a do Flurry do app antigo (estão no histórico do git; ver `behavior-inventory.md` §5); definir versão/build de release (> 1.2, build > 9); **definir preço e período da Família**.

## Cuidados

- `mesada/` (app iOS antigo) é só leitura. Não copie para lugar nenhum as chaves hardcoded de `mesada/mesada/imAppDelegate.m:28` e `:50`.
- Antes de qualquer tela nova, releia os itens do inventário (`behavior-inventory.md` §1–2) e o `design.md`.
- Pergunte antes de: Firebase/regras do Firestore, `applicationId`, versão/build, assinatura, commit/tag/push, apagar o legado.
- Dinheiro sempre em centavos inteiros; foto do filho só local (ADR-0006).

## Prompt para iniciar a sessão em casa

> Continue a reescrita do Mesada. Leia `CLAUDE.md` e `docs/agents/continuidade.md`, confira `git status`, rode `flutter analyze` e `flutter test` em `app-flutter/` para o baseline e me diga o estado e o próximo passo antes de editar.
