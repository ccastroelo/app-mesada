<?php
// Copie para config.php (que NÃO vai para o Git) e preencha.
// Gere o segredo com: php -r "echo bin2hex(random_bytes(32)), PHP_EOL;"
// Trocar o segredo invalida todos os tokens: cada pessoa precisará
// cadastrar o e-mail de recuperação de novo.

return [
    // Obrigatório, 32 caracteres ou mais. Assina os tokens (HMAC-SHA256).
    'segredo' => 'TROQUE-POR-UM-SEGREDO-ALEATORIO-DE-PELO-MENOS-32-CARACTERES',

    // Remetente dos e-mails. Configure SPF e DKIM do domínio, senão cai no spam.
    'remetente_email' => 'nao-responda@synapsesolucoes.ia.br',
    'remetente_nome' => 'Mesada',

    // Onde ficam os contadores de limite. O padrão é a pasta data/ ao lado
    // destes arquivos (protegida pelo .htaccess); o melhor é uma pasta fora
    // da raiz pública do site.
    // 'pasta_dados' => '/home/usuario/mesada-dados',

    // Atrás de proxy ou CDN, o IP real vem num cabeçalho. Use só se o proxy
    // for seu; senão qualquer um forja o IP e fura o limite.
    // 'cabecalho_ip' => 'HTTP_X_FORWARDED_FOR',

    // Algumas hospedagens exigem o parâmetro -f no mail().
    // 'usar_envelope_f' => true,
];
