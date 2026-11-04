<?php
// POST /recuperar.php  {"email","installId","token","pin","idioma"}
// Repassa o PIN novo (gerado pelo app) ao e-mail registrado. Só envia se o
// token provar que este servidor registrou este e-mail para este aparelho.
// O PIN não é guardado nem registrado em log. ADR-0023.

declare(strict_types=1);

require __DIR__ . '/lib.php';

$config = carregar_config();
$dados = ler_corpo();

$email = validar_email($dados['email'] ?? null);
$installId = validar_install_id($dados['installId'] ?? null);
$pin = validar_pin($dados['pin'] ?? null);
$idioma = validar_idioma($dados['idioma'] ?? null);
$token = is_string($dados['token'] ?? null) ? $dados['token'] : '';

if (!hash_equals(gerar_token($config, $installId, $email), $token)) {
    responder(403, 'token_invalido');
}

exigir_limite($config, 'recuperar:ip:' . ip_do_cliente($config), 10, 3600);
exigir_limite($config, 'recuperar:instalacao:' . $installId, 3, 3600);
exigir_limite($config, 'recuperar:email:' . strtolower($email), 5, 86400);

$texto = textos($idioma);
$corpo = sprintf($texto['pin_corpo'], $pin);
if (!enviar_email($config, $email, $texto['pin_assunto'], $corpo)) {
    responder(502, 'falha_no_envio');
}

responder(200);
