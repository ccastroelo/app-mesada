import 'dart:math';

final _random = Random();

/// Id de documento criado no aparelho (modo local, ADR-0014): o relógio em
/// base 36 mais 4 caracteres sorteados. Cresce com o tempo, então serve
/// também para desempatar, e a colisão num só aparelho é desprezível.
String newLocalId() {
  final now = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final suffix = [
    for (var i = 0; i < 4; i++) _random.nextInt(36).toRadixString(36),
  ].join();
  return '$now$suffix';
}
