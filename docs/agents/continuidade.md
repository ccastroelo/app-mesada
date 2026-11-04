# Continuidade entre computadores

> Este arquivo é lido no início de toda sessão. **Atualize-o ao fim de cada sessão** (estado, próximo passo, pendências) e commite junto com o trabalho. Sem caminhos absolutos nem comandos exclusivos de um sistema.

## Estado atual (atualizado em 2026-11-04)

- **Modelo de venda fechado (2026-11-04, ADR-0021)**: **app grátis para baixar; 15 dias de teste; depois a compra única do app (`mesada_app`), que cada pessoa paga, o convidado inclusive; compartilhar (sincronizar) é uma assinatura por família (`mesada_compartilhar`), paga por quem cria a família**. Acabou o teste sem comprar: **só leitura**. A assinatura libera só a sincronização, nunca o uso do app. Quem veio do app antigo usa local para sempre. Isto **substitui** a ideia anterior (Família como compra única, ADR-0020). Em 2026-11-03 já valia: dados no aparelho por padrão, conta só ao compartilhar (ADR-0014 e ADR-0015; `design.md` §13 e §17).
- **Feito do modelo novo (2026-11-04)**: a marca do aparelho em `device.json` (`entitlement`: `since` = primeiro uso = início do teste, `modelVersion`, `origin` = instalação nova ou atualização do app antigo, detectada pelos `.plist` em `Documents`) e `evaluateAccess` (regra pura do acesso **ao app**: app antigo > comprou > dentro dos 15 dias > só leitura; a assinatura não entra). O módulo de compra única da Família foi **apagado** (a compra volta com dois produtos). As regras do Firestore voltaram à versão publicada (o campo `plan` nunca foi publicado). **Ninguém é bloqueado ainda**: nada consulta `evaluateAccess`. 276 testes.
- **M4.5b feito no código (2026-11-04, sem commit até o usuário pedir)**: gateway de compra com os dois produtos (`in_app_purchase`) e cópia local das compras; `accessProvider`/`canWriteProvider`; faixa dos dias do teste em Filhos e aviso de só leitura; **só leitura de verdade** (controles desligados e escrita recusada com `Err(ReadOnly)` nos três controladores); tela `/comprar` (Comprar, Restaurar) e atalho em Ajustes; **compartilhar exige a assinatura** (`StartSharingPage`). Faixa vira coluna a partir de 1,3× de fonte. 305 testes, `analyze` limpo. **Não foi exercitado contra loja nem aparelho.** Falta o M4.5c (assinatura no documento da família, regras do Firestore, retrato local, recibo no servidor).
- **Mudança de requisito (2026-11-03)**
- **Rodou em aparelho/emulador (2026-11-03)**: o usuário abriu o app pela primeira vez fora dos testes, sem relato de problema. Falta a conferência tela por tela (1,0×/1,3×/2,0×, claro e escuro) com `flutter-preview`.
- **M1.5 (modo local) pronto no código (2026-11-03)**: `LocalStore` grava um `mesada.json` atômico na pasta do app e publica cada mudança; `RulesLocalRepository`, `ChildrenLocalRepository` e `LedgerLocalRepository` servem as abas sem rede; a família nasce local (sem nome, a tela mostra "Minha família"); o portão (`gateProvider`) tem caminho local e caminho nuvem, com `GateReady.user` nulo no local; `main.dart` **não** inicializa o Firebase; Ajustes esconde conta, sair e convidar sem conta. `analyze` limpo e **142 testes**. Telas de login/convite seguem no código, desligadas, para o M4.5.
- **M4 (ledger) pronto no código (2026-11-03)**: a tela do filho (toque no cartão) com linhas `− qtd +` em Recompensas/Descontos, chip do último lançamento junto ao saldo, retorno tátil, "Regras deste filho" com switches (desativar guarda a quantidade), zerar um filho ou todos com "Desfazer" por 8 s. Escritas novas no `LedgerRepository` (local e Firestore, este com `FieldValue.increment`). 168 testes, `analyze` limpo. Pendências de propósito (som, seções recolhíveis, animação do saldo): `tech-debt.md`.
- **M5 (relatório) pronto no código (2026-11-03)**: "Enviar relatório" na barra inferior da tela do filho e no menu ⋮ do cartão gera um **PDF** no aparelho (pacote `pdf`, Dart puro) e abre a folha de compartilhamento com um resumo em texto (ADR-0016, que substitui o corpo em HTML do design — `mailto:` não carrega HTML). Entram só as regras ativas com quantidade > 0. **O destinatário não vem preenchido**; o e-mail do filho vai no texto. 178 testes.
- **M6 (PIN) pronto no código (2026-11-03)**: Ajustes › Segurança com ativar (digitar + confirmar), alterar e desativar, todos exigindo o PIN atual; tela de bloqueio com teclado próprio, 4 pontos, vibração e contagem regressiva; trava depois de **30 s fora do app** (design §10) e, a cada 3 erros, espera que dobra (30 s → teto de 15 min), sem fechar o app. O PIN fica em `device.json`, separado do `mesada.json`, como hash com sal (ADR-0017) — sem `flutter_secure_storage`, porque o alvo é o filho curioso. **Biometria (ADR-0018)**: a tela de bloqueio pede Face ID/digital sozinha ao aparecer e o PIN fica como reserva (o código do aparelho **não** serve, porque o filho costuma saber); interruptor em Ajustes › Segurança, só com PIN ativo. 226 testes. **Esquecer o PIN não tem saída no app** e a **biometria nunca rodou em aparelho** (`tech-debt.md`).
- **M7 (ajuda) pronto no código (2026-11-03)**: introdução em 4 cartões (texto e ícone, 4 idiomas) na primeira abertura e reabrível em Ajustes › Ajuda; contato copiando `contato@synapsesolucoes.ia.br` e Sobre dizendo que os dados ficam no aparelho. A marca "já vi" fica no `device.json`, junto do PIN. 235 testes. Sem versão no Sobre e sem abrir o compositor de e-mail (`tech-debt.md`, `design.md` §16).
- **M4.5 (acesso e compartilhamento) em andamento**: a virada para a nuvem (2026-11-04) está pronta no código: o modo fica guardado no `device.json`, "Entrar para compartilhar" troca para nuvem e **criar a família leva os dados deste aparelho** (ids preservados), com a saída "Usar só neste aparelho". **Falta o resto do ADR-0021** (ver os próximos passos). **Nada foi exercitado contra loja nem Firebase de verdade.**
- Modo: **reescrita**. Design **aprovado** (ADR-0009). Marco **M0 parcial**: tema, rotas das 3 abas, `Result/Failure`, dinheiro em centavos, l10n (4 idiomas), lints e 6 testes. `analyze` limpo.
- Falta do M0: **só o ícone**. A CI é o **Codemagic** (ADR-0019): `codemagic.yaml` na raiz roda `analyze` + `test`; o workflow do GitHub Actions foi removido. **Nenhuma execução foi vista ainda**, e o Codemagic só dispara depois de o repositório ser conectado lá (passo do usuário). A inicialização do Firebase saiu do M0 e virou parte do M4.5 (ADR-0014).
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
git clone https://github.com/ccastroelo/app-mesada.git
cd app-mesada
git fetch --tags
cd app-flutter
flutter pub get
flutter analyze
flutter test
```

Já tendo o clone: `git pull --tags` na raiz e depois `flutter pub get`. Os arquivos de localização gerados (`app-flutter/lib/l10n/app_localizations*.dart`) são versionados; rode `flutter gen-l10n` só depois de editar um `.arb`.

Resultado esperado: `analyze` sem problemas e 276 testes passando (mais os 28 das regras do Firestore, em `firebase-tests/`, que só valem para o modo nuvem). Se divergir, registre o baseline em `flutter.md` antes de mexer.

## Próximos passos (ordem)

> Paridade com o legado alcançada (M1.5, M4, M5, M6, M7) e o M4.5 com código pronto. O que falta é tudo que depende de aparelho, loja e console — isto é, de você.

1. **Do usuário, para o M4.5 valer**: criar nas lojas os dois produtos, **`mesada_app`** (não-consumível) e **`mesada_compartilhar`** (assinatura auto-renovável), com o mesmo id no App Store Connect e no Google Play; definir preço e período da assinatura; habilitar Authentication no `mesada-proj`. As regras do Firestore atuais são as **publicadas** (28 testes); a assinatura vai pedir um campo novo, que exige editar, testar no emulador (`firebase-tests`, dois terminais — ver `flutter.md`) e **publicar com OK**.
1a. **Do Claude, a seguir (M4.5b)**: gateway de compra com os dois produtos (`in_app_purchase` volta ao `pubspec`); aviso dos dias de teste; modo só leitura (desligar +/−, editar e FABs quando `evaluateAccess` der `ReadOnlyAccess`); exigir a assinatura para **sincronizar** (em Ajustes › Família, antes de "Entrar para compartilhar"); a assinatura gravada no documento da família e lida pelo convidado; o **retrato local** ao vencer a assinatura (ADR-0014); e **decidir a validação de recibo no servidor antes de vender** (`migration-plan.md`, risco 11).
2. **Validar em aparelho** (`flutter-preview`): a virada para a nuvem de ponta a ponta (comprar, entrar, criar família e conferir que filhos, regras e lançamentos chegaram com os mesmos ids), biometria, PDF do relatório e as telas em 1,0×/1,3×/2,0×, claro e escuro. É o maior buraco do projeto (`tech-debt.md`).
3. **Conectar o repositório no Codemagic** (ADR-0019): o `codemagic.yaml` está pronto, mas nada dispara até o webhook existir — e o projeto está sem CI rodando desde que o GitHub Actions saiu.
4. **Ícone** (fecha o M0): `flutter_launcher_icons` e o desenho em PNG (`design.md` §9).
5. M8 (corte): inventário todo `portado`/`descartado`, beta, e só então arquivar o legado. Decisão do usuário.
6. **Pendências antigas**: saída para "esqueci o PIN" (reinstalar apaga os dados locais); versão/build de release (> 1.2, build > 9) — o Sobre depende disso; revogar a chave/secret do Dropbox e a do Flurry do app antigo (`behavior-inventory.md` §5); confirmar o e-mail de contato (`contato@synapsesolucoes.ia.br`).

## Cuidados

- `mesada/` (app iOS antigo) é só leitura. Não copie para lugar nenhum as chaves hardcoded de `mesada/mesada/imAppDelegate.m:28` e `:50`.
- Antes de qualquer tela nova, releia os itens do inventário (`behavior-inventory.md` §1–2) e o `design.md`.
- Pergunte antes de: Firebase/regras do Firestore, `applicationId`, versão/build, assinatura, commit/tag/push, apagar o legado.
- Dinheiro sempre em centavos inteiros; foto do filho só local (ADR-0006).

## Prompt para iniciar a sessão em casa

> Continue a reescrita do Mesada. Leia `CLAUDE.md` e `docs/agents/continuidade.md`, confira `git status`, rode `flutter analyze` e `flutter test` em `app-flutter/` para o baseline e me diga o estado e o próximo passo antes de editar.
