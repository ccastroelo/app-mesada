# Dívida técnica e armadilhas — Mesada

Lista viva de armadilhas conhecidas. Cada item diz onde dói e o que fazer; nada aqui é decisão tomada sem ADR.

## Escritas dos formulários esperam o servidor (offline fica "carregando")

- **Onde**: `await` em escritas do Firestore nos repositórios de `rules` e `children` (e na criação de família/entrada por convite, onde a rede é mesmo necessária). O Future de uma escrita do Firestore só completa quando o **servidor** confirma; offline o botão Salvar fica girando até a rede voltar, embora o dado já apareça na lista (cache local).
- **Por que importa**: o design (`design.md` §1 princípio 4 e §5 "Lançar") promete escrita imediata e fila offline.
- **O que fazer**: com o ADR-0014 isso **desaparece no grátis** (escrita em arquivo local é imediata) e passa a valer só para assinantes. Nesse modo, no M4 os lançamentos **não** aguardam o servidor: `FieldValue.increment(±1)` com `merge`, piso 0 garantido pela UI e pelas regras, e rejeição tratada pelo erro assíncrono (o stream reverte sozinho). Os formulários de regras e filhos continuam aguardando.
- **Como testar**: modo avião com o app aberto, criar uma regra.

## Plugins do Firebase ainda usam o Kotlin Gradle Plugin antigo

- `firebase_auth` e `firebase_core` aplicam o KGP; o build avisa que versões futuras do Flutter vão exigir "Built-in Kotlin". Acompanhar as versões dos plugins; não é erro hoje.

## Gradle e emulador no Windows precisam rodar fora do sandbox

- No shell com sandbox o Gradle falha com "Unable to establish loopback connection" e o emulador do Firestore com "failed to open a new selector". Rodar no terminal do app/da máquina. Ver `flutter.md`.

## Hero de botões flutuantes nas abas

- As 3 abas vivem num `IndexedStack`, então todas as telas existem ao mesmo tempo. Todo `FloatingActionButton` de aba precisa de `heroTag: null`; sem isso, empilhar uma tela de edição lança "multiple heroes that share the same tag". (Pego pelos testes de widget.)

## Foto do filho só local

- ADR-0006: trocar de aparelho perde as fotos. A foto é copiada para `<pasta do app>/child_photos/<childId>.jpg` (JPEG 512 px). Se o app for desinstalado, a foto some.

## Texto do legado

- As 20 regras-padrão vêm do `faltas.plist` com só correções de ortografia. O pt-PT usa a lista em português do Brasil (o legado tinha a mesma lista nos dois), e o inglês/espanhol mantêm frases desajeitadas do original ("Delay to school"). Vale revisar com falante nativo.

## Arquivo local ilegível deixa o app na tela de erro, sem saída

- **Onde**: `LocalStore._readOrCreate` (M1.5). Se `mesada.json` não for JSON válido, o erro sai no stream e o portão mostra a tela de erro; "Tentar de novo" vai falhar de novo.
- **Por que é assim**: começar vazio esconderia a perda dos dados. Avisar é melhor que fingir.
- **O que fazer**: oferecer nessa tela "começar de novo" (renomeia o arquivo ruim para `.bak` e cria um vazio), com aviso claro. A gravação é atômica, então isso só deve acontecer por corrupção de disco ou edição manual.

## Nome da família não dá para editar no modo local

- No grátis a família nasce sem nome e a tela mostra o padrão do idioma ("Minha família"). O campo de nome só aparece ao criar a família **com conta** (fluxo da assinatura).
- Se incomodar antes do M4.5, basta um campo de edição em Ajustes › Família gravando `family['name']` pelo `LocalStore`.

## Pendências que o M4 deixou de propósito

Nada aqui bloqueia o uso da tela de lançamentos; são itens do `design.md` que ficaram para depois, para não inflar o marco.

- **Som do lançamento** (design §2 e §4.8): não existe. Tocar um som curto pede uma dependência nova (`audioplayers` ou similar) e a opção de ligar/desligar vive em Ajustes › Preferências, que é de outro marco. Hoje há só o retorno tátil (`HapticFeedback`, sem dependência).
- **Seções recolhíveis** (design §4.4): Recompensas e Descontos aparecem sempre abertas.
- **Animação do saldo** (design §6): o chip do último lançamento aparece e some, mas o número do saldo troca sem transição.
- **Filho excluído com a tela aberta** (só acontece com assinatura, quando o outro responsável exclui): a tela do filho mostra o estado de erro em vez de voltar sozinha para a lista.

## O PDF do relatório usa a fonte Helvetica embutida (Latin-1)

- **Onde**: `ledger/data/report/child_report_pdf.dart` (M5). A fonte que vem no pacote `pdf` cobre Latin-1, o que atende pt/en/es. O gerador já troca o "−" (U+2212) do formato de moeda por hífen.
- **O que dói**: nome de filho ou descrição de regra com caractere fora do Latin-1 (alfabeto cirílico, japonês, emoji) sai vazio ou errado **no documento** — na tela está certo.
- **O que fazer**: embutir uma fonte TrueType (Roboto, ~170 KB como asset) e usá-la no `pw.ThemeData`. Só vale quando aparecer um caso real.

## Esquecer o PIN não tem saída dentro do app

- **Onde**: feature `app_lock` (M6, ADR-0017). A tela de bloqueio só aceita o PIN certo; não há "esqueci o PIN".
- **Por que dói mais aqui**: com os dados no aparelho (ADR-0014), reinstalar o app para destravar **apaga a mesada da família**. No modo assinante o dado volta da nuvem; no grátis, não volta.
- **O que fazer**: decidir um caminho de saída e implementar — por exemplo, um aviso claro na tela de bloqueio ("esqueceu? reinstalar apaga os dados deste aparelho") e, melhor ainda, exportar/compartilhar os dados antes. Enquanto não houver, vale avisar no texto de Ajustes › Segurança ao ativar o PIN.
- O gatilho de 30 s fora do app usa `AppLifecycleListener` e **não foi exercitado em aparelho**: os testes chamam `onAway`/`onBack` direto no controlador.

## A biometria não foi exercitada em aparelho

- **Onde**: `app_lock/data/repositories/local_auth_biometrics.dart` (ADR-0018). `local_auth` é canal de plataforma, então nos testes o contrato `BiometricAuth` é trocado por um falso: o que está coberto é a **decisão** (quando pedir, o que fazer ao falhar), não o diálogo do sistema.
- **O que falta ver no aparelho**: o Face ID aparecendo ao abrir, o cancelamento caindo no PIN, o aparelho sem digital cadastrada (o interruptor deve recusar), e o Android com `FlutterFragmentActivity` — se essa troca estiver errada, o app quebra ao chamar a biometria.
- Enquanto isso não for feito, a biometria é **código que compila e passa nos testes**, não funcionalidade confirmada.

## Sobre não mostra a versão, e o contato só copia

- **Sobre** (M7): sem `package_info_plus` não dá para ler a versão em tempo de execução, e a versão de release ainda não foi definida (> 1.2, build > 9 — ADR-0007). Quando ela for decidida, entra a dependência (ou uma constante gerada no build) e a linha aparece.
- **Falar com a gente** (M7): copia `contato@synapsesolucoes.ia.br` para a área de transferência. Abrir o compositor de e-mail já preenchido exigiria `url_launcher`. O local-part (`contato@`) veio do app antigo; confirmar se é essa a caixa certa no domínio novo.

## A compra da Família não foi exercitada contra loja de verdade

- **Onde**: `family_plan/data/repositories/in_app_purchase_plan_gateway.dart` (ADR-0020). Como a biometria, é canal de plataforma: nos testes o `PlanGateway` é um falso, então o que está coberto é a decisão (o que gravar, o que mostrar), não o diálogo de pagamento.
- **Pré-requisito do usuário**: criar o produto **`mesada_familia`** (não-consumível) no App Store Connect e no Google Play, com o mesmo id. Sem isso a oferta volta nula e a tela mostra "a loja não respondeu" — que é exatamente o que acontece hoje.
- **O que falta ver em aparelho**: compra em ambiente de teste (sandbox/teste interno), compra cancelada, "Restaurar compras" em aparelho novo e a compra pendente de aprovação (cartão em análise).
- **E falta a outra metade do M4.5**: o direito gravado em `families/{id}`, as regras do Firestore conhecendo o plano, e a virada de fonte de verdade (subir o local e trocar o `appModeProvider`). Sem isso, comprar hoje não compartilha nada.

## A virada para a nuvem nunca rodou de verdade

- **Onde**: `createFamilyFromLocal` (datasource da `auth_family`), o modo guardado em `core/storage/app_mode_state.dart` e a tela da Família (M4.5, ADR-0014/0020). Os testes usam repositório falso e pasta temporária: cobrem a **decisão** (quando virar, o que subir, o que preservar), não o Firestore.
- **Pré-requisitos do usuário**: habilitar Authentication e Firestore no `mesada-proj`; criar o produto `mesada_familia` nas duas lojas; **rodar os testes das regras no emulador** (`firebase-tests`, precisa do terminal dele) e **publicar as regras** (`firebase deploy --only firestore:rules`) — nada disso o Claude faz sozinho.
- **O que falta ver rodando**: subir um aparelho com dados, comprar, entrar, criar a família e confirmar que filhos, regras e lançamentos chegaram com os **mesmos ids** (senão os lançamentos apontam para o vazio); depois convidar o segundo responsável e ver os dois lançando.
- **Lacuna conhecida**: nada **lê** o `plan` do documento da família para decidir se compartilha. Hoje quem manda é a cópia local do direito, e o único caminho para a nuvem passa por ela. Se um dia o segundo aparelho precisar conferir o plano, a leitura é o que falta.
