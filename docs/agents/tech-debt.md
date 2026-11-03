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
