# Servidor do "Esqueci o PIN" (ADR-0023)

Serviço PHP mínimo que **só repassa e-mail** para o app Mesada. Não guarda e-mail nem PIN: valida um token (HMAC), manda a mensagem e esquece. O que fica em disco são contadores de limite de uso.

> **Estado**: escrito em 2026-11-04 e **nunca executado**: a máquina de desenvolvimento não tem PHP. Antes de apontar o app para ele, rode os testes de `curl` abaixo no servidor de verdade.

## Requisitos

- PHP 7.4 ou mais novo, com `mail()` funcionando (ou um relé SMTP configurado no PHP da hospedagem).
- **HTTPS** obrigatório: o PIN novo viaja no corpo da requisição.
- SPF e DKIM do domínio do remetente, senão os e-mails caem no spam.
- A pasta `pin/data/` precisa ser gravável pelo PHP. O melhor é apontar `pasta_dados` para uma pasta **fora** da raiz pública do site.

## Instalação

1. Copie a pasta `pin/` para o site (por exemplo `https://synapsesolucoes.ia.br/mesada/pin/`).
2. Copie `config.example.php` para `config.php` e preencha. Gere o segredo com `php -r "echo bin2hex(random_bytes(32)), PHP_EOL;"`. O `config.php` **não vai para o Git** (`.gitignore`).
3. Confirme que `config.php`, `lib.php` e `data/` dão 403 no navegador (o `.htaccess` cuida disso no Apache; em Nginx bloqueie à mão).
4. No app, compile com `--dart-define=RECOVERY_URL=https://synapsesolucoes.ia.br/mesada/pin` (ou no arquivo de `--dart-define-from-file`, fora do Git). Sem essa URL o recurso não aparece no app.

## Contrato

Todas as rotas: `POST`, corpo JSON em UTF-8 de até 2 KB, resposta JSON `{"ok": true, ...}` ou `{"ok": false, "erro": "<código>"}`.

### `POST registrar.php`

Corpo: `{"email": "...", "installId": "<16 a 64 hex>", "idioma": "pt|pt_PT|en|es"}`.
Manda ao e-mail uma mensagem de confirmação **sem PIN** e devolve `{"ok": true, "token": "<hex>"}`. O token é `HMAC-SHA256(segredo, installId + "|" + email em minúsculas)`.

### `POST recuperar.php`

Corpo: `{"email", "installId", "token", "pin": "<4 dígitos>", "idioma"}`.
Se o token confere, manda o PIN ao e-mail e devolve `{"ok": true}`. O PIN é gerado pelo **app**; o servidor só o repassa.

### Erros

| HTTP | `erro` | Quando |
|---|---|---|
| 400 | `dados_invalidos`, `email_invalido` | corpo, `installId`, PIN ou e-mail fora do formato |
| 403 | `token_invalido` | o token não confere com `installId` + e-mail |
| 405 | `metodo_invalido` | não é POST |
| 429 | `muitas_tentativas` | passou do limite (cabeçalho `Retry-After`, em segundos) |
| 500 | `servidor_sem_configuracao`, `servidor_sem_armazenamento` | `config.php` ausente/fraco ou pasta de dados sem escrita |
| 502 | `falha_no_envio` | o `mail()` recusou |

### Limites

| Rota | Por IP | Por instalação | Por e-mail |
|---|---|---|---|
| `registrar.php` | 10 / hora | 5 / dia | 3 / dia |
| `recuperar.php` | 10 / hora | 3 / hora | 5 / dia |

Os contadores guardam só instantes, em arquivos nomeados por hash da chave. Atrás de proxy, configure `cabecalho_ip`; senão todos os pedidos parecem vir do IP do proxy.

## Testar no servidor

```bash
BASE=https://synapsesolucoes.ia.br/mesada/pin
ID=0123456789abcdef0123456789abcdef

# 1) registrar: deve chegar o e-mail de confirmação e voltar um token
curl -s -X POST "$BASE/registrar.php" -H 'Content-Type: application/json' \
  -d "{\"email\":\"voce@exemplo.com\",\"installId\":\"$ID\",\"idioma\":\"pt\"}"

# 2) recuperar com o token devolvido: deve chegar o e-mail com o PIN
curl -s -X POST "$BASE/recuperar.php" -H 'Content-Type: application/json' \
  -d "{\"email\":\"voce@exemplo.com\",\"installId\":\"$ID\",\"token\":\"<TOKEN>\",\"pin\":\"4821\",\"idioma\":\"pt\"}"

# 3) token errado: deve dar 403 token_invalido
curl -s -i -X POST "$BASE/recuperar.php" -H 'Content-Type: application/json' \
  -d "{\"email\":\"voce@exemplo.com\",\"installId\":\"$ID\",\"token\":\"x\",\"pin\":\"4821\"}"

# 4) GET: deve dar 405
curl -s -i "$BASE/registrar.php"
```

Repita o passo 2 quatro vezes seguidas: a quarta deve dar 429 (limite por instalação).

## Segurança, em resumo

- O endpoint é público. O token só prova que **este servidor** registrou aquele e-mail para aquele aparelho; não prova que quem chama é o app. Por isso os limites existem, e o modelo de e-mail é fixo.
- Nunca registre o corpo das requisições em log (o PIN novo está nele).
- Trocar o `segredo` invalida todos os tokens.
- Se o filho abre o e-mail do responsável no mesmo aparelho, lê o PIN novo. Isso é do e-mail, não do servidor.
