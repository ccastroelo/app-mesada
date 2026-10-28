import 'dart:math';

/// Letras e números sem 0/O/1/I, para ninguém confundir ao ditar o código.
const inviteCodeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

const inviteCodeLength = 6;

String generateInviteCode([Random? random]) {
  final rng = random ?? Random.secure();
  return String.fromCharCodes([
    for (var i = 0; i < inviteCodeLength; i++)
      inviteCodeAlphabet.codeUnitAt(rng.nextInt(inviteCodeAlphabet.length)),
  ]);
}

/// Aceita o que a pessoa digitou ou colou ("abc-123", " ABC 123 ") e devolve o
/// código em maiúsculas, ou null se não for um código válido.
String? normalizeInviteCode(String input) {
  final code = input.toUpperCase().replaceAll(RegExp(r'[\s\-]'), '');
  if (code.length != inviteCodeLength) return null;
  for (final unit in code.codeUnits) {
    if (!inviteCodeAlphabet.codeUnits.contains(unit)) return null;
  }
  return code;
}
