# Inventário de comportamento — Mesada (iOS, Objective-C v1.2 build 9)

> O código antigo é a **especificação**. Nada é descartado sem estar listado aqui e sem aprovação de "não portar". Cada linha cita a fonte e tem status: `pendente` · `portado` · `descartado (aprovado em AAAA-MM-DD)`.
>
> Caminho das fontes: `mesada/mesada/` (relativo à raiz do repositório). Alvo de implantação do legado: iOS 7.0, só iPhone retrato.
> Inventário feito em 2026-10-28 a partir da leitura do código; **nada foi executado** (não há como rodar o app antigo nesta máquina).

## 1. Fluxos e telas

App com `UITabBarController` de 5 abas (`Base.lproj/Main.storyboard:225-238`).

| Fluxo/tela | Fonte | Observações (estados, atalhos, gestos) | Status |
|---|---|---|---|
| Aba **Mesadas** — lista de filhos ("mesadeiros") | `imMesTableVC.m` | Célula: foto, nome, "Mesada: R$", "Saldo: R$". Botão Editar (reordenar/excluir). Toque abre Lançamentos. Deslizar a linha mostra 4 ações (editar, zerar, e-mail, excluir) via `MSCMoreOptionTableViewCell`. Botão "+" abre cadastro. Estado vazio: tabela vazia (sem mensagem). | pendente |
| Cadastro/edição de mesadeiro | `imMesCadVC.m` | Nome, e-mail, valor da mesada (máscara monetária, máx. 9 caracteres), foto da galeria (sem recorte). Ordem de foco: nome → e-mail → valor. | pendente |
| **Lançamentos** de um mesadeiro | `imLanVC.m` | Cabeçalho: nome, "Mesada: R$", "Saldo: R$". Uma linha por regra: descrição, quantidade, "Desconto/Recompensa: R$". **Deslizar p/ direita = +1** (pisca verde, som `clique.aiff`); **p/ esquerda = −1**, nunca abaixo de 0 (pisca vermelho, som). Há 2 linhas-guia com setas (primeira e última). Modo Editar: reordenar e remover a regra deste filho. | pendente |
| Aba **Regras** — lista de "faltas" | `imFalTableVC.m` | Descrição + "Desconto/Recompensa: R$". Editar (reordenar/excluir), "+" cadastra, toque edita. | portado, redesenhado (M2, 2026-10-28) |
| Cadastro/edição de regra | `imFalCadVC.m` | Descrição, valor com máscara (máx. 7 caracteres), segmento **Desconto / Recompensa** que força o sinal. Abre com foco na descrição. | portado, redesenhado (M2, 2026-10-28) |
| Aba **Senha** | `imSenhaVC.m`, `imSenCadVC.m` | Mostra ATIVADA/DESATIVADA e o texto do botão. Ativar: digita PIN de 4 dígitos + confirmação (rola para o 2º campo). Desativar: digita o PIN atual. Pontos "bola/traço" para os dígitos. Mensagens: "Senha incorreta", "As senhas não coincidem. Tente novamente." | pendente |
| Tela de bloqueio por PIN | `imLoginVC.m`, `imMesTableVC.m:38-52` | Aparece a cada `applicationDidBecomeActive` se há PIN (notificação `appativa`). 4 dígitos validam automaticamente. Ver §7 sobre o `exit(0)`. | pendente |
| Aba **Ajuda** | `imAjudaVC.m` | Botão "Iniciar tutorial" (páginas deslizantes `APPViewController`, imagens `tela1..4`, `tela41..44`, localizadas) e e-mail de contato. | pendente |
| Aba **Nuvem** | `imNuvemVC.m`, `imAppDelegate.m:59-150` | Botão "Linkar com drop box". Ver §5 e §7: serviço descontinuado; substituído pelo compartilhamento novo (decisão do usuário). | pendente (substituído) |
| Relatório por e-mail | `imMesTableVC.m:305-325`, `imGrupoLancamentos.m:277-310` | HTML (tabela) com nome, mesada, saldo e, por regra: "descrição (valor)", qtd, total. Assunto "Mesada". Destinatário = e-mail do filho. | pendente |

## 2. Regras de negócio

| Regra | Fonte | Status |
|---|---|---|
| **Saldo do filho = mesada inicial + Σ(quantidade × valor da regra)**. Descontos têm valor negativo. | `imMesadeiro.m:24-28`, `imGrupoLancamentos.m:238-248` | pendente |
| Valor ≤ 0 é rotulado "Desconto"; > 0 é "Recompensa" (zero cai em "Desconto"). | `imLanVC.m:98-102`, `imFalTableVC.m:76-80` | portado (M2, 2026-10-28) |
| Existe um **lançamento (quantidade) para cada par filho × regra**. Criar filho cria um lançamento por regra existente; criar regra cria um por filho. | `imGrupoLancamentos.m:114-135` | pendente |
| Excluir filho exclui todos os seus lançamentos; excluir regra exclui os lançamentos dela (em cascata). | `imGrupoMesadeiros.m:77-85`, `imGrupoFaltas.m:74-82` | pendente |
| Remover uma linha na tela de Lançamentos apaga só o lançamento daquele par (a regra "some" para aquele filho, sem sair das Regras). Não há como trazê-la de volta, exceto recriando. | `imLanVC.m:193-208`, `imGrupoLancamentos.m:196-201` | substituído por ativar/desativar por filho (aprovado em 2026-10-28, ADR-0008) |
| Quantidade mínima 0 ao decrementar; incremento sem limite. | `imLanVC.m:119` | pendente |
| "Zerar" coloca quantidade = 0 em todos os lançamentos do filho, ou de todos os filhos (alerta com Cancelar / OK / "Zerar todas Mesadas"). Não altera a mesada inicial. | `imMesTableVC.m:294-343`, `imGrupoLancamentos.m:94-111` | pendente |
| Máscara monetária: dígitos entram da direita; separador removido; nº de casas decimais vem do locale (`maximumFractionDigits`). Limites de tamanho: regra 7 caracteres, mesada 9. | `imFalCadVC.m:78-131`, `imMesCadVC.m:128-159` | regras portado (M2, teto 999,99); mesada pendente (M3) |
| Segmento Desconto/Recompensa alterna o sinal do valor digitado. | `imFalCadVC.m:134-142` | portado (M2, 2026-10-28) |
| PIN: 4 dígitos, exigido em toda volta ao primeiro plano; guardado no Keychain (serviço `senha2`). | `imSenCadVC.m`, `imLoginVC.m`, `imMesTableVC.m:38-45` | pendente |
| Moeda exibida com o símbolo do locale + espaço ("R$ 1,50"). | `imLanVC.m:33-35` e demais | pendente |
| Regras-padrão do primeiro uso (20 regras, por idioma: pt, pt-PT, en, es). Ex.: "Arrumar a cama" +0,50; "Tirar nota 10" +1,50; "Mentir" −1,00. Lista completa em `*/faltas.plist`. Não há filhos nem lançamentos de fábrica. | `*.lproj/faltas.plist`; `imGrupoFaltas.m:117-126` | portado (M1, 2026-10-28) |
| IDs: `maiorId + 1` por tabela (colisão possível com dois aparelhos escrevendo — o novo usa ID gerado). | `imGrupo*.m` | pendente |

## 3. Contratos de API

Não há API própria. Única integração remota era o **Dropbox Datastore** (ver §5), cujo contrato era:

| Operação | Request | Response | Fonte | Status |
|---|---|---|---|---|
| Tabela `mesadeiros` | campos `ID`("mes<n>"), `idMesadeiro`, `nome`, `valorMesadaInicial`, `email` | — | `imGrupoMesadeiros.m:289-294` | descartado (substituído por Firestore — a aprovar junto com o plano) |
| Tabela `faltas` | campos `ID`("fal<n>"), `idFalta`, `descricao`, `valor` | — | `imGrupoFaltas.m:268-273` | idem |
| Lançamentos | **nunca foram enviados ao Dropbox** — ficavam só no plist local | — | `imGrupoLancamentos.m` (sem código Dropbox) | o compartilhamento antigo era incompleto |

Sem fixtures de JSON para guardar. O novo contrato (Firestore) será definido no plano e coberto por testes com fakes.

## 4. Dados persistidos

Decisão do usuário (2026-10-28): **app novo, sem importar dados do legado**. Itens abaixo ficam documentados mas não migram.

| Onde | Formato | Quem grava | Novo app | Status |
|---|---|---|---|---|
| `Documents/mesadeiros.plist` | texto plist via `-description` (chaves `idMesadeiro`, `nome`, `valorMesadaInicial`, `email`) | `imGrupoMesadeiros.m:184-207` | não lê | descartado (aprovado em 2026-10-28, sem importação) |
| `Documents/faltas.plist` | idem (`idFalta`, `descricao`, `valor`) | `imGrupoFaltas.m:206-228` | não lê; usa as regras-padrão | idem |
| `Documents/lancamentos.plist` | idem (`idLancamento`, `idFalta`, `idMesadeiro`, `quantidade`) | `imGrupoLancamentos.m:251-275` | não lê | idem |
| `Library/imageInfo.plist` | `NSKeyedArchiver` de dicionário `idMesadeiro → UIImage` | `imGrupoMesadeiros.m:211-227` | não lê | idem |
| `NSUserDefaults["dataStoreID"]` | string (id do datastore Dropbox) | `imAppDelegate.m:81`, `:107` | — | idem |
| Keychain, usuário `br.eti.claudiocastro.mesada`, serviço `senha2` | PIN em texto | `imSenCadVC.m:86` | novo PIN, local ao aparelho | idem |

Observação: valores monetários eram `float` de 32 bits (ex.: `valorMesadaInicial`, `valor`). O novo usa centavos inteiros.

## 5. Integrações e plataforma

| Item | Valor/onde | Observação |
|---|---|---|
| Bundle id | `br.eti.claudiocastro.${PRODUCT_NAME}` → `br.eti.claudiocastro.mesada` (`mesada-Info.plist:12`); versão 1.2, build 9 | **Decidido: reutilizar o mesmo id no app novo** (ADR-0007). Não mudar sem nova decisão. |
| Esquemas de URL | `db-<appkey Dropbox>` e `mesada` (`mesada-Info.plist:23-41`) | `mesada://<id>` era o convite de datastore compartilhado. Novo convite: ver plano. |
| Dropbox Datastore SDK | `Dropbox.framework` embarcado; login/linkagem em `imAppDelegate.m:25-150` | API de Datastores descontinuada pela Dropbox em 2016 → o "compartilhamento" antigo não funciona mais. **Chave e secret do app Dropbox estão no código** (`imAppDelegate.m:28`) — **não copiar; considerar comprometidas/revogar no painel Dropbox**. |
| Flurry 6.2.0 (analytics/crash) | `Flurry/`, `imAppDelegate.m:48-50` | **Chave hardcoded em `imAppDelegate.m:50`**. Substituir por Firebase Crashlytics/Analytics (a confirmar). |
| `MSCMoreOptionTableViewCell` | pasta de terceiro | Swipe com 4 ações → equivalente Flutter (`Slidable`/`Dismissible` ou menu). |
| `SFHFKeychainUtils` | wrapper de Keychain | → `flutter_secure_storage`. |
| Permissões | Fotos (galeria) via `UIImagePickerController`; e-mail via `MFMailComposeViewController` | iOS 7: sem `NSPhotoLibraryUsageDescription` no plist. Novo app precisa declarar. |
| Orientação | só retrato | manter retrato |
| Ícone / launch | `Images.xcassets/AppIcon`, `LaunchImage`, `Icon-*.png`, `Default*.png` | redesenho do ícone depende do escopo de redesign |
| Nome exibido | "Mesada" | |
| Idiomas | Base/pt, pt-PT, en, es (23 strings cada) | manter os 4 (a confirmar) |

## 6. Textos e assets

- **Strings** (23): `*.lproj/Localizable.strings`; storyboards `Main.strings` por idioma. As chaves são o próprio texto em pt. Lista em `pt.lproj/Localizable.strings`.
- **Imagens**: ícones das abas (`user.png`, `polegar.png`, `lock.png`, `nuvem.png`, `help2.png`, `message.png`, `edituser.png`), `bola.png`/`traco` (PIN), `setas.png`, `fotoplaceholder.png`, `mascararedonda.png`, `imagemfundo.png`, `ideiasmoblogo.png`, tutorial `tela1..4` e `tela41..44` (4 idiomas). Total de ~154 PNGs em `mesada/mesada/images/` incluindo @2x e ícones.
- **Som**: `clique.aiff` (toque ao incrementar/decrementar).
- **Cores**: tint da tab bar `rgb(143, 0, 2)` (`imAppDelegate.m:53`); piscar verde/vermelho nos lançamentos.

## 7. Comportamento que NÃO deve ser portado (candidatos — só saem com OK)

| Item | Fonte | Decisão |
|---|---|---|
| `exit(0)` após 3 senhas erradas (iOS reprova app que se encerra sozinho; no Flutter vira bloqueio temporário) | `imLoginVC.m:57-58` | descartado (aprovado em 2026-10-28, ADR-0008) |
| `atualizacaoFaltas` — conserto único de dados invertendo o sinal de todas as regras; `chamaAtualizacao` **não é chamado em lugar nenhum** | `imGrupoFaltas.m:166-193`, `imGrupoLancamentos.m:312-315` | pendente (código morto) |
| `imGrupoMesadeirosx.m` — cópia do grupo de mesadeiros **fora do projeto Xcode** (0 referências no `.pbxproj`) | `imGrupoMesadeirosx.m` | pendente (código morto) |
| `converteMesadeiros`/`converteFaltas` — upload único dos dados locais para o Dropbox na primeira linkagem | `imAppDelegate.m:79`, `imGrupoFaltas.m:237` | pendente (substituído) |
| Fluxo Dropbox inteiro (aba Nuvem, URL `mesada://`, observer do datastore) | `imNuvemVC.m`, `imAppDelegate.m` | pendente (substituído pelo compartilhamento novo) |
| Foto **não** ia ao Dropbox (linha `foto` comentada): só local | `imGrupoMesadeiros.m:178`, `:292` | pendente — no novo, decidir se a foto é compartilhada (Storage) |
| Persistência salvando o `-description` do array (formato texto frágil) e singletons globais | `imGrupo*.m` | pendente (substituído pela arquitetura-alvo) |
| IDs por `maiorId+1` e `UIAlertView`/`UIImagePickerController` descontinuados | vários | pendente (substituído) |
| `Flurry` e chaves hardcoded | `imAppDelegate.m:28`, `:50` | pendente (substituído) |
| `mesadaTests.m` (template vazio) | `mesadaTests/` | sem conteúdo a portar |
