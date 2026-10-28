# Decisões — Mesada

Registro leve de decisões de arquitetura e produto que devem guiar trabalhos futuros. Mais recente primeiro. Não reabra uma decisão *aceita* sem pedido do usuário; para mudar, crie uma nova que a *substitui*.

## Decisões

### ADR-0012 — Login com Google pelo fluxo OAuth do Firebase; uma família por conta
- Data: 2026-10-28 · Status: aceita · Escopo: feature `auth_family`
- Contexto: o login com Google nativo (`google_sign_in`) exige SHA-1 por computador no Android e configuração extra no iOS.
- Decisão: usar `FirebaseAuth.signInWithProvider(GoogleAuthProvider())` (abre o navegador do sistema; sem SHA-1, sem pacote extra). Cada conta pertence a **uma** família (`users/{uid}.familyId`). "Entrar com a Apple" fica para quando houver conta Apple Developer. O Riverpod roda **sem retentativa automática** (`ProviderScope(retry: null)`): erro de permissão não melhora tentando de novo; a tela de espera oferece "Tentar de novo".
- Alternativas descartadas: `google_sign_in` nativo (mais rápido para o usuário, mais configuração por máquina).
- Consequências: o login com Google tem uma troca de contexto para o navegador. **Não foi exercitado em aparelho** (iOS pode exigir esquema de URL no `Info.plist`). Sair da família e trocar de família ainda não existem na UI.

### ADR-0011 — Regras do Firestore: membros em subcoleção, convite consumido em lote
- Data: 2026-10-28 · Status: aceita e **publicada em `mesada-proj` em 2026-10-28** (ruleset `fdb8f084-e893-46cb-9749-47715765167a`; antes: regras padrão de produção que bloqueavam tudo) — regras em `app-flutter/firestore.rules`, **testadas no emulador (28 testes passando)** · Escopo: Firestore de `mesada-proj`
- Contexto: no plano Spark não há Cloud Functions, então as regras precisam permitir que quem tem um código de convite entre na família, sem abrir a base a qualquer usuário logado.
- Decisão proposta: membro = existência de `families/{fid}/members/{uid}` (em vez de array `memberUids` no documento da família). Criador grava a família e depois o próprio documento de membro. Convidado grava, **no mesmo lote**, `members/{uid}` (com o `code`), `invites/{code}.usedBy = uid` e `users/{uid}`; as regras exigem convite da mesma família, não usado, não expirado (48 h) e consumido nesse lote. Convites podem ser lidos por `get` (quem tem o código), nunca listados. Dados validados por tipo e limites (centavos inteiros, quantidade ≥ 0). Sair da família = apagar o próprio documento de membro. Famílias não podem ser apagadas.
- Alternativas descartadas: array `memberUids` (não dá para validar o convite no update sem informar o código); Cloud Function para entrar (exige plano Blaze).
- Consequências: cada requisição paga uma leitura extra (`exists` do membro). Código de 6 caracteres tem ~887 milhões de combinações: aceitável com validade de 48 h e uso único, mas é um risco residual de adivinhação; App Check e limite de tentativas ficam como melhoria. Famílias sem membros ficam órfãs (sem limpeza automática). Testes (`app-flutter/firebase-tests/`) cobrem: sem login, família, convite (uso único, expirado, de outra família, em nome de outro), dados e limites, `increment` atômico com piso 0 e sair da família. Qualquer mudança nas regras: ajustar `firestore.rules`, rodar os testes e só então publicar, com OK do usuário. A cópia local do comentário de cabeçalho foi corrigida depois do deploy (o conteúdo das regras é o mesmo).

### ADR-0010 — Arquivos de configuração do Firebase entram no Git
- Data: 2026-10-28 · Status: aceita · Escopo: `app-flutter/`
- Contexto: `flutterfire configure` gera `lib/firebase_options.dart`, `android/app/google-services.json` e `firebase.json`, com identificadores e chaves de API **de cliente** do projeto `mesada-proj`. O repositório no GitHub é privado.
- Decisão: versionar os três arquivos. As chaves de cliente do Firebase não são segredo; a proteção está nas regras do Firestore e na restrição das chaves no console do Google Cloud. Vantagem: em outro computador basta `git pull` e `flutter pub get`.
- Alternativas: ignorar no Git e rodar `flutterfire configure` em cada computador (mais seguro se o repositório virar público, mais um passo por máquina).
- Consequências: se o repositório um dia ficar público, restringir as chaves por app no Google Cloud antes. Chaves de servidor, contas de serviço e `.env` nunca entram no Git.

### ADR-0009 — Design aprovado (`design.md`)
- Data: 2026-10-28 · Status: aceita · Escopo: toda a UI
- Contexto: marco D do plano.
- Decisão: aprovada a proposta de `design.md` sem alterações: 3 destinos (Filhos · Regras · Ajustes), botões −/+ no lugar do deslizar, paleta petróleo `#0E5A6B` + moeda dourada, ordem dos lançamentos por filho = ordem das regras, PIN trava após 30 s fora do app, convite por código (6 caracteres, 48 h, uso único), "Desfazer" ao zerar, ícone de moeda com ±.
- Alternativas descartadas: manter o vinho do legado como semente; reordenar lançamentos por filho.
- Consequências: o tema em `core/theme` nasce dos tokens do §6; mudanças visuais futuras passam por nova ADR.

### ADR-0008 — Decisões de produto: login, regra por filho, PIN, telemetria, regras-padrão, nome
- Data: 2026-10-28 · Status: aceita · Escopo: features `auth_family`, `ledger`, `app_lock`
- Contexto: três pontos de produto em aberto no plano.
- Decisão:
  1. **Login**: e-mail/senha, Google e Apple (Apple é exigida no iOS por oferecer Google).
  2. **Regra por filho**: cada regra pode ser **ativada/desativada por filho** (reversível). Substitui o "remover linha" do legado (`imLanVC.m:193-208`); desativar mantém a quantidade guardada, mas a regra não conta no saldo nem aparece nos lançamentos do filho. Confirmado em 2026-10-28: desativar **preserva** a quantidade, fora do saldo.
  4. **Telemetria**: Firebase Crashlytics (só falhas, sem Analytics) no lugar do Flurry.
  5. **Regras-padrão**: as 20 do legado, semeadas ao criar a família conforme o idioma do aparelho (pt-BR, pt-PT, en, es), editáveis depois.
  6. **Nome e ícone**: nome "Mesada"; ícone novo (proposto no `design.md`).
  3. **PIN**: após 3 erros, bloqueio temporário de 30 s, crescendo a cada novo ciclo de erros; o app não se fecha (substitui `exit(0)`, `imLoginVC.m:57-58`).
- Alternativas descartadas: descartar a regra por filho; manter remoção irreversível; PIN sem limite de tentativas.
- Consequências: modelo de dados ganha `entries.enabled` (bool); exige configurar Apple e Google no console Firebase e na conta de desenvolvedor.

### ADR-0007 — Mesmo `applicationId`/bundle id do app antigo
- Data: 2026-10-28 · Status: aceita · Escopo: iOS e Android
- Contexto: o plano previa identificador novo; o usuário decidiu reutilizar o do app iOS antigo.
- Decisão: `br.eti.claudiocastro.mesada` (valor de `mesada-Info.plist:12`) no iOS e no Android. Substitui a parte "identificador novo" do ADR-0001.
- Alternativas descartadas: identificador novo (app separado na loja).
- Consequências: se o app antigo estiver publicado, o Flutter sai como **atualização dele** e quem atualiza **perde os dados locais** (sem importação, ADR-0001) — precisa constar no texto de versão. Assinatura/perfis do iOS são os da conta que publicou o legado (não lidos). Versão do novo app deve ser maior que 1.2 (build > 9). O Keychain antigo (`senha2`) pode sobreviver à atualização; o novo app usa outra chave e não o lê.

### ADR-0006 — Foto do filho só local, sem dados de menores no Storage
- Data: 2026-10-28 · Status: aceita · Escopo: projeto todo
- Contexto: no app antigo a foto nunca foi sincronizada (campo `foto` comentado no Dropbox). No compartilhamento novo cabia enviá-la ao Cloud Storage.
- Decisão: a foto fica **apenas no aparelho** de cada pai (galeria → arquivo local reduzido, chave = id do filho). Nada de imagem de criança na nuvem. Sem Firebase Storage no projeto.
- Alternativas descartadas: Storage com imagem reduzida (compartilha a foto, mas coloca imagem de menores na nuvem e exige regras e custo extras).
- Consequências: cada pai escolhe a foto no próprio aparelho; sem foto, usa o avatar padrão. Trocar de aparelho perde as fotos. Reabrir se isso incomodar.

### ADR-0005 — Redesenho de visual **e** fluxo
- Data: 2026-10-28 · Status: aceita (escopo do desenho pendente de aprovação) · Escopo: toda a UI
- Contexto: o usuário quer uma reescrita, não uma cópia fiel do app de 2013.
- Decisão: visual e fluxo novos. O comportamento de negócio do inventário (`behavior-inventory.md` §2) é preservado; a **proposta de design** (`design.md`: navegação, telas, gestos, paleta) é aprovada **antes** de qualquer tela ser implementada.
- Alternativas descartadas: visual novo com o mesmo fluxo (descartado pelo usuário).
- Consequências: itens de UI do inventário (§1) viram "portado (redesenhado)"; a conferência de paridade é de **comportamento**, não de pixel.

### ADR-0004 — Estado: Riverpod
- Data: 2026-10-28 · Status: aceita · Escopo: projeto todo
- Contexto: arquitetura-alvo exige um único mecanismo de estado.
- Decisão: Riverpod (também faz injeção de dependência). Streams do Firestore expostos como `StreamProvider`/`AsyncNotifier`.
- Alternativas descartadas: Bloc/Cubit (mais cerimônia); ChangeNotifier (ruim com streams em tempo real e testes).
- Consequências: `presentation/state` usa providers; repositórios entram por provider, sem singleton global.

### ADR-0003 — Compartilhamento: conta por pai + família com convite
- Data: 2026-10-28 · Status: aceita · Escopo: projeto todo
- Contexto: os dois pais precisam enxergar e alterar a mesma base.
- Decisão: cada pai tem login próprio (Firebase Auth). Um cria a **família**; o outro entra por **código/link de convite**. Todos os dados vivem sob `families/{familyId}`. Regras de segurança do Firestore restringem leitura/escrita aos membros.
- Alternativas descartadas: login único compartilhado (não identifica quem lançou, não revoga acesso individual).
- Consequências: dá para registrar quem fez cada lançamento (opcional). Regras do Firestore e criação do projeto Firebase exigem aprovação do usuário (toca produção).

### ADR-0002 — Backend: Firebase Auth + Cloud Firestore
- Data: 2026-10-28 · Status: aceita · Escopo: projeto todo
- Contexto: o Dropbox Datastore usado no legado foi descontinuado em 2016; é preciso base compartilhada entre os pais, com offline.
- Decisão: Firebase Auth + Cloud Firestore (persistência offline nativa, tempo real). Lançamentos usam `FieldValue.increment` / transação para não perder toque de dois pais ao mesmo tempo.
- Alternativas descartadas: Supabase (relacional, mas offline exige trabalho próprio).
- Consequências: SDK Firebase só em `data/datasources`; domínio Dart puro. Valores monetários em **centavos inteiros** (o legado usava `float`).

### ADR-0001 — Reescrita em Flutter, código em `app-flutter/`, legado congelado
- Data: 2026-10-28 · Status: aceita · Escopo: projeto todo
- Contexto: app iOS em Objective-C (~4,6 mil linhas, v1.2) a ser refeito em Flutter, sem importar dados antigos. (Identificador: ver ADR-0007.)
- Decisão: **reescrita** na pasta `app-flutter/` na raiz do repositório. O código iOS antigo em `mesada/` fica **somente leitura** até o corte, quando é arquivado na tag `legacy/1.2` e removido da árvore (com OK do usuário).
- Alternativas descartadas: migração incremental (não há como plugar Flutter no app Objective-C de 2013 e os dados não migram); raiz do repositório (escolhido pelo usuário `app-flutter/`).
- Consequências: estrutura `lib/core` + `lib/features/*` da arquitetura-alvo; `docs/agents/` fica na raiz do repositório.
