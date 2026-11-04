import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Quantos erros seguidos fecham um ciclo e disparam a espera (design.md §4.11).
const attemptsPerCycle = 3;

/// Quanto tempo esperar depois do [cycle]-ésimo trio de erros: 30 s, 1, 2, 4 e
/// 8 minutos, com teto de 15 (design.md §4.11). Substitui o `exit(0)` do
/// legado (`imLoginVC.m:57-58`): o app nunca se fecha.
Duration lockoutFor(int cycle) {
  if (cycle <= 0) return Duration.zero;
  // 2^(cycle-1) estoura rápido; o teto entra antes.
  final seconds = cycle > 6 ? 900 : 30 * pow(2, cycle - 1).toInt();
  return Duration(seconds: min(seconds, 900));
}

/// Espera devida depois de [wrongAttempts] erros seguidos: zero enquanto o
/// trio não fecha.
Duration lockoutAfter(int wrongAttempts) =>
    lockoutFor(wrongAttempts ~/ attemptsPerCycle);

/// O PIN tem 4 dígitos (como no legado).
const pinLength = 4;

bool isValidPin(String pin) =>
    pin.length == pinLength && RegExp(r'^\d+$').hasMatch(pin);

/// Sal novo, em hexadecimal. `Random.secure` porque é o que existe de graça;
/// o PIN de 4 dígitos é fraco por natureza (ver ADR-0017).
String newPinSalt() {
  final random = Random.secure();
  return [
    for (var i = 0; i < 8; i++)
      random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
}

/// PIN novo aleatório, de [pinLength] dígitos, para o "esqueci o PIN".
String newRandomPin() {
  final value = Random.secure().nextInt(pow(10, pinLength).toInt());
  return value.toString().padLeft(pinLength, '0');
}

/// Identificador deste aparelho para o servidor de recuperação (16 bytes em
/// hexadecimal). Não é dado pessoal; só liga o e-mail registrado ao aparelho.
String newInstallId() {
  final random = Random.secure();
  return [
    for (var i = 0; i < 16; i++)
      random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
}

/// Idioma dos e-mails do servidor (ADR-0023): pt, pt_PT, en ou es. O que não
/// é nenhum deles recebe inglês.
String recoveryLocale(String languageCode, String? countryCode) {
  return switch (languageCode) {
    'pt' => countryCode == 'PT' ? 'pt_PT' : 'pt',
    'es' => 'es',
    _ => 'en',
  };
}

/// "ana@exemplo.com" vira "a**@exemplo.com": mostra para onde vai o PIN sem
/// escancarar o endereço na tela de bloqueio.
String maskEmail(String email) {
  final at = email.indexOf('@');
  if (at <= 0) return email;
  final local = email.substring(0, at);
  final hidden = local.length <= 1 ? '' : '*' * (local.length - 1);
  return '${local[0]}$hidden${email.substring(at)}';
}

/// SHA-256 de sal + PIN. Guardar o hash em vez do PIN evita que ele apareça
/// em texto num backup do aparelho; contra quem tem o aparelho na mão e
/// paciência, 10 mil combinações não param ninguém — e não é esse o alvo.
String hashPin(String pin, String salt) =>
    sha256.convert(utf8.encode('$salt:$pin')).toString();
