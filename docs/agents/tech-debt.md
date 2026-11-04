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

## Pendências que o M4 deixou de propósito

Só o som sobrou (seções recolhíveis, animação do saldo e o filho excluído com a tela aberta foram feitos em 2026-11-04). Nada aqui bloqueia o uso da tela de lançamentos.

- **Som do lançamento** (design §2 e §4.8): não existe. Tocar um som curto pede uma dependência nova (`audioplayers` ou similar) e a opção de ligar/desligar vive em Ajustes › Preferências, que é de outro marco. Hoje há só o retorno tátil (`HapticFeedback`, sem dependência).

## O PDF do relatório usa a fonte Helvetica embutida (Latin-1)

- **Onde**: `ledger/data/report/child_report_pdf.dart` (M5). A fonte que vem no pacote `pdf` cobre Latin-1, o que atende pt/en/es. O gerador já troca o "−" (U+2212) do formato de moeda por hífen.
- **O que dói**: nome de filho ou descrição de regra com caractere fora do Latin-1 (alfabeto cirílico, japonês, emoji) sai vazio ou errado **no documento** — na tela está certo.
- **O que fazer**: embutir uma fonte TrueType (Roboto, ~170 KB como asset) e usá-la no `pw.ThemeData`. Só vale quando aparecer um caso real.

## "Esqueci o PIN" por e-mail existe no código, mas o servidor nunca rodou

- **O que há**: o fluxo do app (cadastro do e-mail, "Esqueci o PIN", limites) e o servidor PHP em `servidor/` (ADR-0023). 390 testes cobrem o app, inclusive o cliente HTTP contra um servidor local. **O PHP nunca foi executado**: a máquina de desenvolvimento não tem PHP. O README de `servidor/` traz os testes de `curl` para rodar no servidor de verdade.
- **Passos do usuário**: publicar `servidor/pin/` por HTTPS, criar o `config.php` (segredo de 32+ caracteres, remetente), configurar SPF e DKIM do domínio, e compilar o app com `--dart-define=RECOVERY_URL=...`. Sem a URL o recurso fica escondido.
- **Limites do desenho**: quem lê o e-mail do responsável descobre o PIN novo (o filho, se abre essa caixa no mesmo aparelho); sem e-mail registrado, ou sem acesso a ele, a saída continua sendo reinstalar e perder os dados do modo local. O endpoint é público e só se defende por limites e pelo token. O e-mail passa a sair do aparelho: **declarar nas lojas e na política de privacidade**.
- **Pontas soltas**: o app só troca o PIN depois da resposta do servidor, mas se o app fechar entre a resposta e a gravação, o e-mail chega com um PIN que o app não adotou (a pessoa pede de novo; o limite é 3 por hora). O PIN novo não é mostrado em lugar nenhum do app.
- **Ainda não feito**: backup/exportação dos dados (caminho 2 discutido; precisa de aprovação, o ADR-0001 descartou importação) e código de recuperação sem servidor.

## A biometria não foi exercitada em aparelho

- **Onde**: `app_lock/data/repositories/local_auth_biometrics.dart` (ADR-0018). `local_auth` é canal de plataforma, então nos testes o contrato `BiometricAuth` é trocado por um falso: o que está coberto é a **decisão** (quando pedir, o que fazer ao falhar), não o diálogo do sistema.
- **O que falta ver no aparelho**: o Face ID aparecendo ao abrir, o cancelamento caindo no PIN, o aparelho sem digital cadastrada (o interruptor deve recusar), e o Android com `FlutterFragmentActivity` — se essa troca estiver errada, o app quebra ao chamar a biometria.
- Enquanto isso não for feito, a biometria é **código que compila e passa nos testes**, não funcionalidade confirmada.

## Sobre não mostra a versão, e o contato só copia

- **Sobre** (M7): sem `package_info_plus` não dá para ler a versão em tempo de execução, e a versão de release ainda não foi definida (> 1.2, build > 9 — ADR-0007). Quando ela for decidida, entra a dependência (ou uma constante gerada no build) e a linha aparece.
- **Falar com a gente** (M7): copia `contato@synapsesolucoes.ia.br` para a área de transferência. Abrir o compositor de e-mail já preenchido exigiria `url_launcher`. O local-part (`contato@`) veio do app antigo; confirmar se é essa a caixa certa no domínio novo.

## A compra e a assinatura existem no código, mas nunca falaram com uma loja

- O M4.5b entregou o gateway (`in_app_purchase`), a cópia local, a faixa do teste, o só leitura e a assinatura exigida para compartilhar (`architecture.md`). Nos testes a loja é um `FakeStoreGateway`: o que está coberto é a **decisão**, não o canal de plataforma. Comprar, restaurar, o fluxo de confirmação e o `purchaseStream` só se provam em aparelho, com os produtos `mesada_app` e `mesada_compartilhar` criados nas duas lojas (passo do usuário).
- **A assinatura não é validada**: a cópia local não sabe quando ela vence, e nada impede um aparelho adulterado de afirmar que assinou. Também não chega ao convidado (falta o campo no documento da família e as regras do Firestore). Validar o recibo no servidor é decisão a tomar **antes de vender** (`migration-plan.md`, risco 11).
- **Antes de vender**: (1) o teste de 15 dias é um contador do próprio app: o maior instante já visto **já é guardado** (`lastSeen`) e resolve o relógio atrasado; no iOS o Keychain (e talvez a compra gratuita de $0) ajuda com a reinstalação; no Android só o Auto Backup e o Block Store, sem garantia — o furo residual é aceito (detalhes na ADR-0021). (2) A assinatura chega ao convidado por um campo no documento da família, forjável sem validação no servidor (Cloud Functions no plano Blaze, ou RevenueCat). (3) Revisão das lojas: o convidado sincroniza por causa da assinatura de outra pessoa; fallback, cada um assina. (4) A detecção do app antigo só enxerga quem salvou algo nele (o app antigo só gravava os `.plist` ao salvar). (5) O "retrato local" ao vencer a assinatura (ADR-0014) ainda não existe.
- **Retrato local**: existe a operação (`BackToLocalController`) e o gatilho manual em Ajustes. **Não dispara sozinho ao vencer**, porque o app não detecta o vencimento (falta o RevenueCat, ADR-0022). Também nunca baixou de um Firestore real: a leitura é coberta por um datasource falso.

## A virada para a nuvem nunca rodou de verdade

- **Onde**: `createFamilyFromLocal` (datasource da `auth_family`), o modo guardado em `core/storage/app_mode_state.dart` e a tela de Ajustes › Família (ADR-0014). Os testes usam repositório falso e pasta temporária: cobrem a **decisão** (quando virar, o que subir, o que preservar), não o Firestore.
- **Pré-requisitos do usuário**: habilitar Authentication no `mesada-proj` (o Firestore já existe); **rodar os testes das regras no emulador** (`firebase-tests`, precisa do terminal dele). As regras publicadas são as do ADR-0011; **elas ainda não conhecem a assinatura**.
- **O que falta ver rodando**: subir um aparelho com dados, entrar, criar a família e confirmar que filhos, regras e lançamentos chegaram com os **mesmos ids** (senão os lançamentos apontam para o vazio); depois convidar o segundo responsável e ver os dois lançando.

