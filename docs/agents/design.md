# Design — Mesada (proposta para aprovação)

> **Status: APROVADO em 2026-10-28** (os 7 itens da §12 como propostos, paleta petróleo). Marco D concluído; as telas entram a partir do M0/M1. Regras de negócio não mudam: valem `behavior-inventory.md` §2 e os ADRs (`decisions.md`).
> Escopo do redesenho: visual **e** fluxo (ADR-0005). O app é de uso diário, em pé, com uma mão: a ação mais frequente (lançar ±1) precisa ser a mais fácil.

## 1. Princípios

1. **Lançar é a tela principal.** O pai abre o app para somar ou tirar um item de um filho; tudo o mais é apoio.
2. **Sem gesto escondido.** O legado exigia deslizar a linha (direita +1, esquerda −1). No novo, botões **−** e **+** visíveis (alvo ≥ 48 dp); funciona com leitor de tela e com fonte grande.
3. **Dinheiro sempre com sinal e ícone**, nunca só cor (vale para daltônicos e modo escuro).
4. **Dois pais, uma base**: mudanças do outro aparecem sozinhas; o app diz claramente quando está offline e quando já sincronizou.
5. **Reversível**: ações destrutivas pedem confirmação **e** oferecem "Desfazer".
6. Texto em pt-BR como base; pt-PT, en e es por ARB (`gen-l10n`). Fonte do sistema, escalável até 2,0× (skill `flutter-ui`).

## 2. O que muda em relação ao legado

| Legado (2013) | Novo | Por quê |
|---|---|---|
| 5 abas: Mesadas, Regras, Senha, Nuvem, Ajuda | **3 destinos**: Filhos · Regras · Ajustes | Senha, Nuvem e Ajuda viram itens de Ajustes; Nuvem some (Dropbox morreu; entra login + família). |
| Deslizar linha: +1 / −1, com som e piscada | **Botões − qtd +** em cada linha; feedback tátil, chip animado "+R$ 0,50" junto ao saldo; som opcional | Descobrível, acessível. Som do legado vira opção em Ajustes (ligado por padrão). |
| Deslizar linha do filho: 4 ações escondidas (editar, zerar, e-mail, excluir) | Cartão do filho abre a tela do filho; menu **⋮** com Editar, Zerar lançamentos, Enviar relatório, Excluir | Mesmas ações, visíveis. |
| Editar → reordenar/excluir (modo de edição da tabela) | **Reordenar** por alça de arrastar dentro de "Reordenar" (botão na barra); excluir pelo menu da linha | Menos modos escondidos. |
| Remover linha em Lançamentos esconde a regra do filho | **Ativar/desativar regra por filho** (switches) | ADR-0008. |
| Senha: aba própria, pede em toda volta ao app | Ajustes › Segurança; trava após **30 s** fora do app (ver §10) | Evita pedir PIN ao voltar do seletor de foto ou do compartilhamento. |
| Tutorial em imagens de tela (4 idiomas) | Introdução em 4 cartões ilustrados, só texto localizado + ícones; reabrível em Ajustes › Ajuda | Imagens do app antigo não valem mais; texto é traduzível. |
| Sem modo escuro | Segue o sistema (claro/escuro) | Padrão atual. |

## 3. Navegação

`go_router` com `StatefulShellRoute` (3 abas mantêm seu estado). Barra inferior `NavigationBar` (Material 3).

```
/boas-vindas            sem conta
/entrar                 e-mail+senha · Google · Apple
/familia/nova           criar família
/familia/entrar         digitar código de convite
/filhos                 [aba 1] lista de filhos (início)
/filhos/novo, /filhos/:id/editar
/filhos/:id             lançamentos do filho
/filhos/:id/regras      ativar/desativar regras do filho
/regras                 [aba 2] regras
/regras/nova, /regras/:id/editar
/ajustes                [aba 3]
/ajustes/familia        membros e convite
/ajustes/seguranca      PIN
/ajustes/ajuda          introdução, contato, sobre
/bloqueio               tela do PIN (cobre tudo)
```

Guardas (redirect): sem login → `/boas-vindas`; logado sem família → `/familia/nova`; PIN ativo e expirado → `/bloqueio`.

## 4. Telas

Estados obrigatórios em toda tela de dados: **carregando · dado · vazio · erro**; mais indicador **offline** (faixa fina "Sem conexão — alterações serão enviadas quando voltar").

### 4.1 Boas-vindas e entrada
- Logotipo + frase ("A mesada dos seus filhos, em dia, com os dois responsáveis.").
- Botões: **Continuar com a Apple**, **Continuar com o Google**, **Entrar com e-mail** (e "Criar conta"). Apple e Google em iOS; no Android, Google e e-mail (Apple só onde a plataforma permitir).
- E-mail/senha: validação inline, "Esqueci a senha" (e-mail de redefinição do Firebase).
- Erros (senha errada, sem rede, conta existente com outro método) em texto abaixo do campo, nunca só em snackbar.

### 4.2 Família
- **Nova**: campo "Nome da família" (ex.: "Família Castro"). Ao criar: semeia as 20 regras-padrão conforme o idioma (ADR-0008). Segue para a introdução (§4.9) e depois para Filhos.
- **Entrar com código**: 6 caracteres (maiúsculas e números, sem 0/O/1/I), cola automática do texto copiado. Sucesso → Filhos; código inválido/expirado → mensagem clara.
- Na tela de escolha, os dois caminhos lado a lado: **Criar uma família** / **Tenho um código**.

### 4.3 Filhos (aba 1 — início)
- Lista de **cartões**: avatar (foto local ou inicial em círculo colorido), nome, "Mesada R$ 100,00" (secundário) e **saldo grande** (destaque, vermelho com "−" se negativo).
- Toque no cartão → tela do filho. Menu ⋮ do cartão: Editar, Zerar lançamentos, Enviar relatório, Excluir.
- Barra superior: título "Filhos", ação **Reordenar**, menu com **Zerar lançamentos de todos**.
- FAB estendido "Adicionar filho".
- **Vazio**: ilustração + "Adicione o primeiro filho para começar" + botão.

### 4.4 Filho — lançamentos (tela mais importante)
- Cabeçalho fixo: avatar pequeno, nome, "Mesada R$ …", **Saldo** grande. Ao lançar, o saldo anima e aparece um chip "+R$ 0,50"/"−R$ 0,50" que some em 1 s.
- Corpo em duas seções recolhíveis: **Recompensas** (valor > 0) e **Descontos** (valor ≤ 0). Cada linha:
  `descrição · valor da regra  [ − ]  qtd  [ + ]`
  O **−** fica desabilitado em 0 (regra do legado, `imLanVC.m:119`). Regras desativadas para o filho não aparecem.
- Barra inferior da tela: **Enviar relatório** e menu (Zerar lançamentos, Regras deste filho).
- "Regras deste filho": lista com **switch** por regra (padrão: todas ativas). Desativar preserva a quantidade, fora do saldo (ADR-0008).
- Ordem das linhas = ordem da aba Regras (sem reordenar por filho; ver §12, item 3).
- Em fonte grande (≥ 1,3×) o stepper desce para uma segunda linha sob a descrição.

### 4.5 Cadastro/edição de filho
- Campos: **Foto** (círculo com câmera/galeria; fica só no aparelho, ADR-0006), **Nome** (obrigatório), **E-mail** (opcional; usado no relatório), **Mesada** (máscara monetária; teto 999.999,99).
- Salvar fica desabilitado até haver nome. Excluir (em edição) → diálogo "Excluir Fulano e todos os lançamentos?".
- Teclado sem sobrepor campos (rolagem automática; substitui os cálculos manuais do legado).

### 4.6 Regras (aba 2)
- Lista: descrição + valor com ícone (▲ verde "Recompensa" / ▼ vermelho "Desconto"). Seções iguais às dos lançamentos.
- Ação **Reordenar** na barra; FAB "Nova regra". Toque abre a edição; excluir pelo menu ⋮ com confirmação ("remove os lançamentos de todos os filhos").
- **Vazio**: "Nenhuma regra ainda" + botão "Usar sugestões" (re-semeia as 20 do idioma).

### 4.7 Cadastro/edição de regra
- **Descrição**, **Tipo** (`SegmentedButton`: Desconto | Recompensa) e **Valor** (máscara; digita só números; sinal vem do tipo; teto 999,99).
- Valor 0 permitido, como no legado, e rotulado "Desconto".

### 4.8 Ajustes (aba 3)
Lista simples agrupada:
- **Família**: nome, membros (nome/e-mail), **Convidar outro responsável**, **Sair da família**.
- **Segurança**: PIN (ativar/desativar/alterar).
- **Preferências**: som dos lançamentos (liga/desliga), tema (sistema/claro/escuro).
- **Ajuda**: Ver introdução, Falar com a gente (e-mail de contato), Sobre (versão).
- **Conta**: e-mail da conta, Sair.

### 4.9 Introdução (4 cartões, reabrível)
1. "Cadastre seus filhos e a mesada de cada um."
2. "Defina as regras: o que ganha e o que desconta."
3. "Toque em + ou − para lançar. O saldo se atualiza na hora."
4. "Convide o outro responsável: os dois veem os mesmos números."
Botões: Próximo / Pular / Começar. Mostra uma vez após criar a família; também em Ajustes › Ajuda.

### 4.10 Relatório por e-mail
- Abre o compositor do e-mail com destinatário = e-mail do filho (se vazio, sem destinatário) e assunto "Mesada". Corpo em HTML com a mesma tabela do legado (nome, mesada, saldo e, por regra: "descrição (valor)", qtd, total). Falta de cliente de e-mail → mensagem + opção de copiar o texto.

### 4.11 Bloqueio por PIN
- Teclado numérico próprio, 4 pontos preenchendo; valida sozinho ao 4º dígito. Erro: vibra e mostra "PIN incorreto". **3 erros → bloqueio de 30 s** (contagem regressiva visível), dobrando a cada novo ciclo (30 s, 1 min, 2 min…, teto 15 min). O app **não** fecha.
- Ativar: digitar + confirmar. Desativar: digitar o PIN atual.
- O PIN é **local ao aparelho** (cada pai tem o seu).

## 5. Fluxos principais

**Primeiro uso (quem cria)**: Boas-vindas → Entrar → Criar família → Introdução → Filhos (vazio) → Adicionar filho → Lançar.

**Convidar o outro responsável**: Ajustes › Família › *Convidar* → gera código de 6 caracteres válido por 48 h, uso único → folha de compartilhamento do sistema com o texto "Entre na família … no app Mesada com o código ABC123". O outro: Boas-vindas → Entrar → *Tenho um código* → Filhos (já com os dados).
- Sem link direto (o Firebase Dynamic Links foi encerrado e não há domínio próprio): o convite é por **código**. Link por domínio próprio fica como evolução.

**Lançar**: Filhos → cartão → **+** (ou **−**) na linha. Escrita imediata na UI; envio ao Firestore em segundo plano; se offline, fica na fila.

**Zerar**: menu do filho (ou de "todos") → diálogo "Zerar lançamentos de Fulano?" → **Zerar** → snackbar "Lançamentos zerados · **Desfazer**" por 8 s (restaura as quantidades anteriores). Não altera a mesada.

**Atualização do legado**: ao abrir, se existir `Documents/mesadeiros.plist` do app antigo no aparelho, mostra **uma vez** o aviso "Esta é a nova versão do Mesada. Os dados da versão antiga não foram trazidos; cadastre sua família para continuar." (detecção só pelo arquivo, sem ler dados; ADR-0007.)

## 6. Tokens (`core/theme`) — única fonte de cor/fonte/espaço

**Cores** (Material 3; `ColorScheme.fromSeed` com a semente abaixo, claro e escuro):

| Token | Claro | Escuro | Uso |
|---|---|---|---|
| `seed` / primary | `#0E5A6B` (petróleo) | gerado | botões, FAB, itens ativos |
| `accent` (moeda) | `#E0A526` | `#F2C14E` | ícone do app, detalhes pontuais |
| `positive` | `#1F7A3E` | `#7AD99A` | recompensa, saldo ≥ 0 |
| `negative` | `#B3261E` | `#F2B8B5` | desconto, saldo < 0 |
| `surface` / `onSurface` | do esquema | do esquema | fundo e texto |

- Contraste mínimo 4,5:1 (texto) e 3:1 (componentes); conferir no M0 com a ferramenta de acessibilidade.
- **Alternativa**: manter o vinho do legado (`#8F0002`) como semente. Não recomendo: ficaria colado ao vermelho de "desconto". Escolha na aprovação (§12).

**Tipografia**: fonte do sistema (Roboto/SF) via `TextTheme` do M3; valores monetários com `FontFeature.tabularFigures()`; saldo em `headlineMedium` semibold.
**Espaçamento**: grade de 4 dp (4/8/12/16/24/32); margem lateral 16 dp; cantos 12 dp (cartões), 28 dp (FAB/botões principais).
**Largura máxima**: conteúdo centralizado em até 600 dp (tablets e dobráveis); celular em retrato (como no legado); tablets podem girar.
**Movimento**: transições padrão do M3; animação do saldo 250 ms; respeitar "reduzir movimento".

## 7. Componentes compartilhados (`core/widgets`)

`MoneyText` (formata com `intl` e sinal/ícone), `MoneyField` (máscara dos centavos, teto configurável), `Avatar` (foto local ou inicial; 6 cores tonais fixas derivadas do id), `QuantityStepper`, `SyncBanner` (offline/sincronizando), `EmptyState`, `ErrorState` (mensagem + "Tentar de novo"), `ConfirmDialog`, `UndoSnackBar`.

Moeda: símbolo e formato vêm do **idioma/região do aparelho** (como no legado); o valor guardado é só em centavos. Dois pais com regiões diferentes veriam símbolos diferentes — aceito (família no mesmo país).

## 8. Acessibilidade e robustez (skill `flutter-ui`)

- Alvos ≥ 48×48 dp; foco e ordem de leitura lógicos.
- `Semantics` nos steppers: "Aumentar Arrumar a cama, quantidade 2"; saldo anunciado após cada lançamento ("Saldo R$ 98,50").
- Texto escala até 2,0× sem corte nem sobreposição: linhas quebram, steppers descem, cartões crescem.
- Teclado nunca cobre o campo em foco; rolagem automática nos formulários.
- Cor nunca é o único indicador (sinal ± e ícone ▲▼).
- Telas verificadas com `flutter-preview` em 1,0×, 1,3× e 2,0×, claro e escuro, antes de fechar cada marco.

## 9. Ícone do app

Conceito recomendado: quadrado arredondado petróleo com uma **moeda dourada** ao centro, trazendo "+" e "−" empilhados (lançar e descontar). Sem texto. Entregue em SVG → `flutter_launcher_icons` (iOS e Android adaptive, claro e monocromático). O desenho final é produzido no M0 e passa por você antes de entrar na loja.

## 10. Decisões de comportamento que mudam algo do legado (precisam de OK)

- PIN trava após **30 s fora do app**, não a cada volta ao primeiro plano (o seletor de foto e a folha de compartilhar não devem travar).
- Reordenar lançamentos **por filho** deixa de existir; a ordem de cada filho segue a aba Regras. (No legado, `imLanVC.m:161-176`, mexia numa lista global confusa.)
- **Desfazer** ao zerar é novo (não existia).
- Sem som por padrão? **Não**: som continua ligado por padrão, com opção de desligar.

## 11. Fora do escopo desta fase

Histórico de quem lançou o quê; biometria no lugar do PIN; vários grupos de famílias por conta; link de convite por domínio próprio; relatório em PDF; widgets/notificações; importar dados do legado (os arquivos continuam no aparelho, então seria possível depois sem mudar este plano).

## 12. Para aprovar

1. Navegação em 3 destinos (Filhos · Regras · Ajustes) e botões −/+ no lugar do deslizar.
2. Paleta **petróleo + moeda dourada** (recomendada) ou manter o vinho do legado.
3. Fim da reordenação por filho dos lançamentos (§10).
4. PIN: travar após 30 s fora do app (§10).
5. Convite por código de 6 caracteres, 48 h, uso único (sem link).
6. Desfazer ao zerar (§5).
7. Conceito do ícone (§9).
