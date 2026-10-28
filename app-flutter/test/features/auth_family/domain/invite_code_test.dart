import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/features/auth_family/domain/usecases/invite_code.dart';

void main() {
  group('generateInviteCode', () {
    test('gera 6 caracteres só do alfabeto sem 0/O/1/I', () {
      final random = Random(42);
      for (var i = 0; i < 500; i++) {
        final code = generateInviteCode(random);
        expect(code, hasLength(inviteCodeLength));
        expect(
          code.split('').every(inviteCodeAlphabet.contains),
          isTrue,
          reason: code,
        );
      }
      for (final confusing in ['0', 'O', '1', 'I']) {
        expect(inviteCodeAlphabet.contains(confusing), isFalse);
      }
    });

    test('é determinístico com a mesma semente', () {
      expect(generateInviteCode(Random(7)), generateInviteCode(Random(7)));
    });

    test('sem semente usa Random.secure e não repete de cara', () {
      expect(generateInviteCode(), isNot(generateInviteCode()));
    });
  });

  group('normalizeInviteCode', () {
    test('aceita minúsculas, espaços e hífen', () {
      expect(normalizeInviteCode('abc234'), 'ABC234');
      expect(normalizeInviteCode(' abc-234 '), 'ABC234');
      expect(normalizeInviteCode('AB C2 34'), 'ABC234');
    });

    test('rejeita tamanho errado e caracteres fora do alfabeto', () {
      expect(normalizeInviteCode(''), isNull);
      expect(normalizeInviteCode('ABC23'), isNull);
      expect(normalizeInviteCode('ABC2345'), isNull);
      expect(normalizeInviteCode('ABC230'), isNull);
      expect(normalizeInviteCode('ABCO34'), isNull);
      expect(normalizeInviteCode('ABC23!'), isNull);
    });
  });
}
