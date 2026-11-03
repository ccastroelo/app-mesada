# Decisões — Mesada

Registro leve de decisões de arquitetura e produto que devem guiar trabalhos futuros. Mais recente primeiro. Não reabra uma decisão *aceita* sem pedido do usuário; para mudar, crie uma nova que a *substitui*.

## Decisões

### ADR-0018 — Biometria para desbloquear, com o PIN do app como reserva
- Data: 2026-11-03 · Status: aceita · Escopo: feature `app_lock`; muda o `design.md` §11
- Contexto: o PIN de 4 dígitos (ADR-0017) é chato de digitar todo dia e fraco por natureza. O usuário pediu Face ID em 2026-11-03. O `design.md` §11 punha "biometria no lugar do PIN" fora de escopo.
- Decisão: **biometria é o caminho normal** (`local_auth`: Face ID/Touch ID no iOS, BiometricPrompt no Android) e o **PIN do app fica como reserva**, não como igual: a tela de bloqueio pede a biometria sozinha ao aparecer e mantém o teclado do PIN atrás, com um botão "Usar biometria" para tentar de novo.
  - `biometricOnly: true`: o **código do aparelho não serve de reserva**. O filho normalmente sabe o código do celular do pai, e é dele que o bloqueio protege — a reserva tem de ser o PIN do app.
  - Ligar a biometria exige **PIN ativo** e uma autenticação bem-sucedida ali na hora (prova que funciona no aparelho). Desligar o PIN desliga a biometria: sem reserva, uma falha de leitura trancaria o app.
  - Durante a espera por erros de PIN (ADR-0017), nem a biometria passa — senão a espera não valeria nada.
  - Qualquer erro da plataforma conta como "não reconheceu" e cai no PIN.
- Alternativas descartadas: biometria substituindo o PIN de vez (sem reserva, um aparelho sem digital cadastrada ou um sensor sujo tranca o app); `biometricOnly: false`, aceitando o código do aparelho (fura o propósito); `flutter_secure_storage` junto (ver ADR-0017, segue sem).
- Consequências: dependência nova (`local_auth`) e configuração de plataforma — Android passa a usar `FlutterFragmentActivity` (exigência do BiometricPrompt) e declara `USE_BIOMETRIC`; iOS ganha `NSFaceIDUsageDescription`. O `minSdk` padrão do Flutter (24) já atende os 23 que o plugin pede. **Nada disso foi exercitado em aparelho**: nos testes a biometria é um falso, porque é canal de plataforma (ver `tech-debt.md`).

### ADR-0017 — PIN guardado no aparelho como hash, sem armazenamento seguro
- Data: 2026-11-03 · Status: aceita · Escopo: feature `app_lock` (M6)
- Contexto: o legado guardava o PIN no Keychain do iOS (serviço `senha2`). A alternativa em Flutter seria `flutter_secure_storage` (Keychain/Keystore), uma dependência nova. O usuário definiu o alvo em 2026-11-03: **"é só para evitar que o filho pegue e mexa"** — proteção fraca basta, não é defesa contra atacante.
- Decisão: o PIN mora em `<pasta do app>/device.json`, **separado do `mesada.json`**, como **SHA-256 com sal** (pacote `crypto`, que já estava na árvore como transitiva). Sem `flutter_secure_storage`. Dois motivos para o arquivo próprio: é ajuste **do aparelho**, não da família (cada responsável tem o seu PIN), e assim ele nunca sobe junto com os dados no envio da assinatura (M4.5). Arquivo ilegível, ausente ou sem as chaves conta como **sem PIN**: trancar o app sem poder destravar seria pior que não trancar.
- Alternativas descartadas: `flutter_secure_storage` (mais forte, mas dependência nova para um segredo de 10 mil combinações); PIN em texto puro no arquivo (apareceria legível num backup do aparelho, e gente reusa o PIN do cartão); PIN dentro do `mesada.json` (iria para a nuvem na assinatura).
- Consequências: contra quem tem o aparelho desbloqueado e paciência, 4 dígitos não param ninguém — e não é esse o alvo. Reabrir se o app passar a guardar algo mais sensível. Trocar de aparelho perde o PIN (basta ativar de novo). **Esquecer o PIN não tem saída dentro do app** — ver `tech-debt.md`.

### ADR-0016 — Relatório em PDF compartilhado, no lugar do corpo em HTML
- Data: 2026-11-03 · Status: aceita · Escopo: feature `ledger` (M5); muda `design.md` §4.10 e §11
- Contexto: o design previa o corpo do e-mail em HTML, como no legado (que usava o `MFMailComposeViewController` do iOS com `isHTML`). Em Flutter, `mailto:` (via `url_launcher`) carrega **só texto puro**, por especificação; HTML no corpo exigiria `flutter_email_sender` ou código nativo em cada plataforma.
- Decisão: o relatório é um **PDF gerado no aparelho** (pacote `pdf`, Dart puro) e sai pela folha de compartilhamento do sistema (`share_plus`, que já serve o convite), junto com um **resumo em texto** (nome, mesada, saldo) para quem recebe bater o olho sem abrir o anexo. O documento lista só as regras com quantidade > 0. O **destinatário não vem preenchido**: a folha do sistema não aceita destinatário, então o e-mail do filho entra no texto compartilhado, a um "colar" de distância.
- Alternativas descartadas: texto puro no `mailto:` (perde a tabela e quebra em fonte grande); `flutter_email_sender` para anexar com destinatário e assunto prontos (mais uma dependência, e depende de app de e-mail configurado) — **reabrir se o destinatário preenchido fizer falta**; gerar o relatório num servidor (não há servidor, ADR-0015).
- Consequências: uma dependência nova (`pdf`); por ser Dart puro, a geração entra nos testes de unidade. O PDF usa a Helvetica embutida (Latin-1), que não tem o sinal "−" (U+2212) usado pelo `formatCents`: o gerador troca por "-" no documento. O relatório funciona no modo local, sem conta e sem rede.

### ADR-0015 — Conta só ao assinar; assinatura por família
- Data: 2026-11-03 · Status: aceita · Escopo: feature `auth_family`, nova feature de assinatura, roteador
- Contexto: com os dados locais (ADR-0014), exigir login na primeira abertura só adiciona atrito e cria usuários no Auth sem receita. Compartilhar, porém, exige identidade: as regras do Firestore (ADR-0011) precisam de um `uid` para saber quem é membro.
- Decisão:
  1. **No grátis não existe conta**: a primeira abertura cria uma família **local** (só o nome) e vai direto para Filhos. O roteador deixa de exigir login (`redirectFor` muda).
  2. **A conta aparece no momento de compartilhar**: Ajustes › Família → tela da assinatura → compra na loja → **então** entrar/criar conta (e-mail/senha, Google, Apple — ADR-0008). O M1 continua como está; muda **quando** é chamado.
  3. **A assinatura é da família, não da pessoa**: o direito fica em `families/{id}`, gravado por quem comprou. O segundo responsável entra com conta própria e **não paga**. O convite por código de 6 caracteres (ADR-0003) segue sendo o mecanismo.
  4. **Nome do recurso: "Família"** (escolhido pelo usuário em 2026-11-03), nas 4 línguas.
  5. **A compra pertence à conta da loja** (Apple ID / Google Play), não ao login do app: "Restaurar compras" é obrigatório e o vínculo correto é compra → família.
  6. **Assinatura vencida não tranca nada**: para de sincronizar; nada é apagado nem fica somente-leitura.
  7. **Acesso do filho fica fora da v1**: o relatório por e-mail (M5) cobre mostrar o saldo. Depois, se quiser, convite de leitura com papel `child` (a subcoleção de membros do ADR-0011 já suporta) — evita conta de menor e o que vem com ela (LGPD/COPPA).
  8. **Cobrança com `in_app_purchase`**, sem servidor: quem tem o direito é afirmado pelo aparelho e as regras do Firestore confiam nesse campo.
- Alternativas descartadas: login na primeira abertura (atrito e usuários sem receita); sincronizar por código com login anônimo (perder o aparelho perde o acesso; amarrar a compra fica frágil); assinatura por pessoa (cobraria do convidado justamente o recurso vendido); RevenueCat (mais uma dependência e mais uma conta); validar recibo em Cloud Functions (exige o plano Blaze antes da primeira venda).
- Consequências: quem burlar o cliente sincroniza de graça — não vaza dado de ninguém, e endurecer exige servidor. Preço e período (mensal, anual ou compra única) seguem **em aberto**. Importação dos dados do legado segue descartada (ADR-0001, reconfirmado em 2026-11-03).

### ADR-0014 — Dados locais por padrão; nuvem só com a assinatura "Família"
- Data: 2026-11-03 · Status: aceita · Escopo: projeto todo — **substitui em parte o ADR-0002**
- Contexto: o ADR-0002 punha o Firestore como base de todo mundo, o que gera custo desde o primeiro usuário, sem receita. Um responsável num aparelho não precisa de nuvem nenhuma; compartilhar com o outro responsável é o que vale ser pago.
- Decisão: **uma fonte de verdade por vez**, nunca as duas.
  - **Grátis**: um único arquivo JSON na pasta do app (escrita atômica — grava `.tmp` e renomeia — e campo `schemaVersion`), carregado em memória e publicado por streams. O Firebase **não** é inicializado.
  - **Assinante**: o Firestore é a fonte de verdade naquele aparelho, aproveitando o cache offline e a fila de escrita do próprio SDK.
  - A troca acontece **uma vez e em mão única**: ao assinar, sobe o conteúdo local num lote; ao cancelar, baixa um retrato para o arquivo local. Nunca se escreve nos dois.
- Alternativas descartadas: escrever nos dois lados e casar as versões (exigiria um motor de sincronização próprio, com relógio e conflito, para um app de dezenas de documentos); `sqflite`/`drift` (não há consulta a fazer e o volume é de ~200 documentos no pior caso); só nuvem (ADR-0002: custo sem receita).
- Consequências: `RulesRepository`, `ChildrenRepository` e `LedgerRepository` ganham implementação local com `familyId` fixo (`"local"`); domínio, telas e os testes com repositório falso não mudam. A dívida "escritas esperam o servidor" (`tech-debt.md`) deixa de existir no grátis. O Firestore e as regras do ADR-0011 passam a servir **só assinantes**. Sem assinatura, trocar de aparelho perde os dados (como no legado) — e nenhum dado sai do aparelho.

### ADR-0013 — Lançamentos criados sob demanda; ordem das regras por inteiro crescente
- Data: 2026-10-28 · Status: aceita · Escopo: Firestore (`entries`, `rules`), features `rules` e `ledger`
- Contexto: o legado criava um lançamento para cada par filho × regra ao cadastrar filho ou regra (`imGrupoLancamentos.m:114-135`). Isso exige escrever em vários documentos a cada cadastro e dá corrida entre dois responsáveis.
- Decisão: um `entries/{childId}_{ruleId}` **ausente equivale a quantidade 0 e regra ativada**. O documento só é criado no primeiro toque em +, ou ao desativar a regra para o filho. Criar filho ou regra **não** escreve lançamentos; excluir uma regra apaga os lançamentos dela (`deleteRule`). A ordem de exibição é o campo `order` da regra: a semeadura e "Reordenar" gravam 0..n-1; regra nova usa o relógio em milissegundos (sempre maior), então entra no fim sem ler a lista (funciona offline).
- Alternativas descartadas: criar todos os pares (mais escrita e corrida); `order = max+1` (exige leitura antes de gravar).
- Consequências: a tela do filho (M4) monta as linhas a partir das **regras** e junta com os lançamentos existentes; `calculateBalanceCents` já só soma lançamentos existentes. Dois aparelhos criando regras ao mesmo tempo podem empatar no `order` só se no mesmo milissegundo (desempate indefinido, aceitável). Reordenar sobrescreve para 0..n-1.

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

### ADR-0002 — Backend: Firebase Auth + Cloud Firestore (substituído em parte pelo ADR-0014)
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
