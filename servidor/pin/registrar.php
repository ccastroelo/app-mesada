<?php
// POST /registrar.php  {"email","installId","idioma"}
// Manda uma mensagem de confirmação (sem PIN) ao e-mail e devolve o token que
// o app guarda para pedir o PIN novo depois. ADR-0023.

declare(strict_types=1);

require __DIR__ . '/lib.php';

$config = carregar_config();
$dados = ler_corpo();

$email = validar_email($dados['email'] ?? null);
$installId = validar_install_id($dados['installId'] ?? null);
$idioma = validar_idioma($dados['idioma'] ?? null);

exigir_limite($config, 'registrar:ip:' . ip_do_cliente($config), 10, 3600);
exigir_limite($config, 'registrar:instalacao:' . $installId, 5, 86400);
exigir_limite($config, 'registrar:email:' . strtolower($email), 3, 86400);

$texto = textos($idioma);
if (!enviar_email($config, $email, $texto['registro_assunto'], $texto['registro_corpo'])) {
    responder(502, 'falha_no_envio');
}

responder(200, null, ['token' => gerar_token($config, $installId, $email)]);
