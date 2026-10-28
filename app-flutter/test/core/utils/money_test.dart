import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/utils/money.dart';

void main() {
  group('formatCents', () {
    test('formata centavos na região do aparelho', () {
      expect(formatCents(150, locale: 'pt_BR'), 'R\$ 1,50');
      expect(formatCents(150, locale: 'en_US'), '\$1.50');
    });

    test('negativo usa o sinal de menos tipográfico', () {
      expect(formatCents(-300, locale: 'pt_BR'), '−R\$ 3,00');
    });

    test('signed mostra + só nos positivos', () {
      expect(formatCents(50, locale: 'pt_BR', signed: true), '+R\$ 0,50');
      expect(formatCents(0, locale: 'pt_BR', signed: true), 'R\$ 0,00');
    });

    test('não perde centavos por ponto flutuante', () {
      expect(formatCents(10, locale: 'en_US'), '\$0.10');
      expect(formatCents(99999999, locale: 'en_US'), '\$999,999.99');
    });
  });
}
