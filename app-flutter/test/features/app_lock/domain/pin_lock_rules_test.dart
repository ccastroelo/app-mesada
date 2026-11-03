import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/features/app_lock/app_lock.dart';

void main() {
  group('espera por erros seguidos', () {
    test('dobra a cada ciclo e para em 15 minutos', () {
      expect(lockoutFor(1), const Duration(seconds: 30));
      expect(lockoutFor(2), const Duration(minutes: 1));
      expect(lockoutFor(3), const Duration(minutes: 2));
      expect(lockoutFor(4), const Duration(minutes: 4));
      expect(lockoutFor(5), const Duration(minutes: 8));
      expect(lockoutFor(6), const Duration(minutes: 15));
      expect(lockoutFor(7), const Duration(minutes: 15));
      expect(lockoutFor(50), const Duration(minutes: 15));
    });

    test('só começa quando o trio de erros fecha', () {
      expect(lockoutAfter(0), Duration.zero);
      expect(lockoutAfter(1), Duration.zero);
      expect(lockoutAfter(2), Duration.zero);
      expect(lockoutAfter(3), const Duration(seconds: 30));
      expect(lockoutAfter(4), const Duration(seconds: 30));
      expect(lockoutAfter(6), const Duration(minutes: 1));
      expect(lockoutAfter(9), const Duration(minutes: 2));
    });
  });

  group('PIN', () {
    test('são 4 dígitos, nada de letra ou tamanho errado', () {
      expect(isValidPin('1234'), isTrue);
      expect(isValidPin('0000'), isTrue);
      expect(isValidPin('123'), isFalse);
      expect(isValidPin('12345'), isFalse);
      expect(isValidPin('12a4'), isFalse);
      expect(isValidPin(''), isFalse);
    });

    test('o hash não é o PIN e muda com o sal', () {
      final salt = newPinSalt();
      final hash = hashPin('1234', salt);

      expect(hash, isNot(contains('1234')));
      expect(hash.length, 64);
      expect(hashPin('1234', salt), hash);
      expect(hashPin('4321', salt), isNot(hash));
      expect(hashPin('1234', newPinSalt()), isNot(hash));
    });

    test('cada sal é diferente', () {
      final salts = {for (var i = 0; i < 20; i++) newPinSalt()};

      expect(salts.length, 20);
    });
  });
}
