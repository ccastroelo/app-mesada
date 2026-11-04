<?php
// Funções comuns dos dois endpoints do "esqueci o PIN" (ADR-0023).
// Este servidor só repassa e-mail: não guarda e-mail nem PIN. Guarda apenas
// contadores de limite de uso. Nunca registre o corpo das requisições (o PIN
// novo viaja nele).

declare(strict_types=1);

const IDIOMAS = ['pt', 'pt_PT', 'en', 'es'];

/** Responde em JSON e encerra. $erro nulo = sucesso. */
function responder(int $status, ?string $erro = null, array $extra = []): void
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store');
    $corpo = $erro === null ? ['ok' => true] : ['ok' => false, 'erro' => $erro];
    echo json_encode($corpo + $extra);
    exit;
}

function carregar_config(): array
{
    $arquivo = __DIR__ . '/config.php';
    if (!is_file($arquivo)) {
        responder(500, 'servidor_sem_configuracao');
    }
    $config = require $arquivo;
    if (
        !is_array($config)
        || !isset($config['segredo'], $config['remetente_email'])
        || strlen((string) $config['segredo']) < 32
    ) {
        responder(500, 'servidor_sem_configuracao');
    }
    return $config;
}

/** Só POST com JSON pequeno; devolve o objeto decodificado. */
function ler_corpo(): array
{
    if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
        header('Allow: POST');
        responder(405, 'metodo_invalido');
    }
    $bruto = file_get_contents('php://input', false, null, 0, 2049);
    if ($bruto === false || $bruto === '' || strlen($bruto) > 2048) {
        responder(400, 'dados_invalidos');
    }
    $dados = json_decode($bruto, true);
    if (!is_array($dados)) {
        responder(400, 'dados_invalidos');
    }
    return $dados;
}

function validar_email($valor): string
{
    $email = is_string($valor) ? trim($valor) : '';
    if (
        $email === ''
        || strlen($email) > 254
        || preg_match('/[\r\n]/', $email) === 1
        || filter_var($email, FILTER_VALIDATE_EMAIL) === false
    ) {
        responder(400, 'email_invalido');
    }
    return $email;
}

function validar_install_id($valor): string
{
    $id = is_string($valor) ? $valor : '';
    if (preg_match('/^[a-f0-9]{16,64}$/', $id) !== 1) {
        responder(400, 'dados_invalidos');
    }
    return $id;
}

function validar_pin($valor): string
{
    $pin = is_string($valor) ? $valor : '';
    if (preg_match('/^[0-9]{4}$/', $pin) !== 1) {
        responder(400, 'dados_invalidos');
    }
    return $pin;
}

function validar_idioma($valor): string
{
    return is_string($valor) && in_array($valor, IDIOMAS, true) ? $valor : 'pt';
}

/** Prova de que o servidor registrou este e-mail para este aparelho. */
function gerar_token(array $config, string $installId, string $email): string
{
    return hash_hmac(
        'sha256',
        $installId . '|' . strtolower($email),
        (string) $config['segredo']
    );
}

function ip_do_cliente(array $config): string
{
    $cabecalho = $config['cabecalho_ip'] ?? null; // ex.: 'HTTP_X_FORWARDED_FOR'
    if (is_string($cabecalho) && !empty($_SERVER[$cabecalho])) {
        $primeiro = trim(explode(',', (string) $_SERVER[$cabecalho])[0]);
        if ($primeiro !== '') {
            return $primeiro;
        }
    }
    return (string) ($_SERVER['REMOTE_ADDR'] ?? 'desconhecido');
}

/**
 * Conta mais um uso de $chave e diz se passou de $max dentro de $janela
 * segundos. Guarda só instantes, em um arquivo por chave (hash da chave).
 */
function limite_excedido(array $config, string $chave, int $max, int $janela): bool
{
    $pasta = (string) ($config['pasta_dados'] ?? (__DIR__ . '/data'));
    if (!is_dir($pasta) && !@mkdir($pasta, 0700, true) && !is_dir($pasta)) {
        responder(500, 'servidor_sem_armazenamento');
    }
    // De vez em quando limpa o que já não vale mais.
    if (random_int(1, 100) === 1) {
        foreach (glob($pasta . '/*.json') ?: [] as $velho) {
            if (filemtime($velho) < time() - 2 * 86400) {
                @unlink($velho);
            }
        }
    }

    $arquivo = $pasta . '/' . hash('sha256', $chave) . '.json';
    $fp = @fopen($arquivo, 'c+');
    if ($fp === false) {
        responder(500, 'servidor_sem_armazenamento');
    }
    flock($fp, LOCK_EX);
    $agora = time();
    $conteudo = stream_get_contents($fp);
    $instantes = json_decode($conteudo === false ? '' : $conteudo, true);
    $instantes = is_array($instantes) ? $instantes : [];
    $instantes = array_values(array_filter(
        $instantes,
        static fn($t) => is_int($t) && $t > $agora - $janela
    ));

    $excedeu = count($instantes) >= $max;
    if (!$excedeu) {
        $instantes[] = $agora;
        ftruncate($fp, 0);
        rewind($fp);
        fwrite($fp, json_encode($instantes));
    }
    flock($fp, LOCK_UN);
    fclose($fp);
    return $excedeu;
}

function exigir_limite(array $config, string $chave, int $max, int $janela): void
{
    if (limite_excedido($config, $chave, $max, $janela)) {
        header('Retry-After: ' . $janela);
        responder(429, 'muitas_tentativas');
    }
}

function codificar_cabecalho(string $texto): string
{
    return '=?UTF-8?B?' . base64_encode($texto) . '?=';
}

/** Envia texto simples em UTF-8. Devolve false se o servidor de e-mail recusar. */
function enviar_email(array $config, string $para, string $assunto, string $texto): bool
{
    $remetente = (string) $config['remetente_email'];
    $nome = (string) ($config['remetente_nome'] ?? 'Mesada');
    $cabecalhos = [
        'From' => codificar_cabecalho($nome) . ' <' . $remetente . '>',
        'MIME-Version' => '1.0',
        'Content-Type' => 'text/plain; charset=UTF-8',
        'Content-Transfer-Encoding' => 'base64',
        'X-Auto-Response-Suppress' => 'All',
    ];
    $corpo = chunk_split(base64_encode($texto));
    $parametros = !empty($config['usar_envelope_f']) ? '-f' . $remetente : '';
    return @mail(
        $para,
        codificar_cabecalho($assunto),
        $corpo,
        $cabecalhos,
        $parametros
    );
}

/** Textos dos e-mails, por idioma. %s no texto do PIN recebe o PIN novo. */
function textos(string $idioma): array
{
    $todos = [
        'pt' => [
            'registro_assunto' => 'Mesada: e-mail de recuperação do PIN cadastrado',
            'registro_corpo' => "Este endereço foi cadastrado como e-mail de recuperação do PIN do app Mesada.\n\nSe você esqueceu o PIN, toque em \"Esqueci o PIN\" na tela de bloqueio e enviaremos um PIN novo para cá.\n\nSe não foi você, pode ignorar esta mensagem.",
            'pin_assunto' => 'Mesada: seu PIN novo',
            'pin_corpo' => "Seu PIN novo do Mesada é: %s\n\nO PIN anterior deixou de valer. Para trocá-lo, abra Ajustes › Segurança no app.\n\nSe você não pediu isso, alguém tocou em \"Esqueci o PIN\" no aparelho.",
        ],
        'pt_PT' => [
            'registro_assunto' => 'Mesada: e-mail de recuperação do PIN registado',
            'registro_corpo' => "Este endereço foi registado como e-mail de recuperação do PIN da app Mesada.\n\nSe se esqueceu do PIN, toque em \"Esqueci o PIN\" no ecrã de bloqueio e enviaremos um PIN novo para aqui.\n\nSe não foi você, pode ignorar esta mensagem.",
            'pin_assunto' => 'Mesada: o seu PIN novo',
            'pin_corpo' => "O seu PIN novo do Mesada é: %s\n\nO PIN anterior deixou de valer. Para o trocar, abra Definições › Segurança na app.\n\nSe não pediu isto, alguém tocou em \"Esqueci o PIN\" no aparelho.",
        ],
        'en' => [
            'registro_assunto' => 'Mesada: PIN recovery email registered',
            'registro_corpo' => "This address was registered as the PIN recovery email for the Mesada app.\n\nIf you forget the PIN, tap \"Forgot PIN\" on the lock screen and we'll send a new PIN here.\n\nIf this wasn't you, you can ignore this message.",
            'pin_assunto' => 'Mesada: your new PIN',
            'pin_corpo' => "Your new Mesada PIN is: %s\n\nThe previous PIN no longer works. To change it, open Settings › Security in the app.\n\nIf you didn't ask for this, someone tapped \"Forgot PIN\" on the device.",
        ],
        'es' => [
            'registro_assunto' => 'Mesada: correo de recuperación del PIN registrado',
            'registro_corpo' => "Esta dirección se registró como correo de recuperación del PIN de la app Mesada.\n\nSi olvidas el PIN, toca \"Olvidé el PIN\" en la pantalla de bloqueo y te enviaremos un PIN nuevo aquí.\n\nSi no fuiste tú, puedes ignorar este mensaje.",
            'pin_assunto' => 'Mesada: tu PIN nuevo',
            'pin_corpo' => "Tu PIN nuevo de Mesada es: %s\n\nEl PIN anterior ya no vale. Para cambiarlo, abre Ajustes › Seguridad en la app.\n\nSi no lo pediste, alguien tocó \"Olvidé el PIN\" en el dispositivo.",
        ],
    ];
    return $todos[$idioma] ?? $todos['pt'];
}
