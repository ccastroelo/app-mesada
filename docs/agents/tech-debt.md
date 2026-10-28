# Dívida técnica e armadilhas — Mesada

Lista viva de armadilhas conhecidas. Cada item diz onde dói e o que fazer; nada aqui é decisão tomada sem ADR.

## Escritas dos formulários esperam o servidor (offline fica "carregando")

- **Onde**: `await` em escritas do Firestore nos repositórios de `rules` e `children` (e na criação de família/entrada por convite, onde a rede é mesmo necessária). O Future de uma escrita do Firestore só completa quando o **servidor** confirma; offline o botão Salvar fica girando até a rede voltar, embora o dado já apareça na lista (cache local).
- **Por que importa**: o design (`design.md` §1 princípio 4 e §5 "Lançar") promete escrita imediata e fila offline.
- **O que fazer**: no M4 (lançamentos ± e zerar) **não** aguardar o servidor: gravar localmente e tratar a rejeição por stream/erro assíncrono. Decidir se os formulários de regras e filhos seguem o mesmo padrão (não aguardar, validar tudo antes). Exige ADR.
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
