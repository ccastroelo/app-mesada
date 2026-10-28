import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/utils/money.dart';
import 'package:mesada/core/widgets/money_field.dart';

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

  group('formatCentsPlain', () {
    test('duas casas e separadores da região, sem símbolo nem sinal', () {
      expect(formatCentsPlain(0, locale: 'pt_BR'), '0,00');
      expect(formatCentsPlain(123450, locale: 'pt_BR'), '1.234,50');
      expect(formatCentsPlain(123450, locale: 'en_US'), '1,234.50');
      expect(formatCentsPlain(-50, locale: 'pt_BR'), '0,50');
    });
  });

  group('centsFromMaskedText', () {
    test('lê só os dígitos', () {
      expect(centsFromMaskedText('1.234,50'), 123450);
      expect(centsFromMaskedText('0,05'), 5);
      expect(centsFromMaskedText(''), 0);
      expect(centsFromMaskedText('R\$ 0,00'), 0);
    });
  });

  group('CentsInputFormatter', () {
    final formatter = CentsInputFormatter(locale: 'pt_BR', maxCents: 99999);

    TextEditingValue type(String from, String to) => formatter.formatEditUpdate(
      TextEditingValue(text: from),
      TextEditingValue(text: to),
    );

    test('os dígitos entram pela direita', () {
      expect(type('0,00', '0,005').text, '0,05');
      expect(type('0,05', '0,055').text, '0,55');
      expect(type('0,55', '0,555').text, '5,55');
      expect(type('5,55', '5,555').text, '55,55');
    });

    test('apagar tira o último dígito', () {
      expect(type('5,55', '5,5').text, '0,55');
      expect(type('0,05', '0,0').text, '0,00');
    });

    test('o cursor fica no fim', () {
      final value = type('0,00', '0,001');
      expect(value.selection.baseOffset, value.text.length);
    });

    test('passar do teto rejeita a digitação', () {
      final old = const TextEditingValue(text: '999,99');
      final result = formatter.formatEditUpdate(
        old,
        const TextEditingValue(text: '999,999'),
      );
      expect(result.text, '999,99');
    });

    test('número gigante não estoura', () {
      const old = TextEditingValue(text: '0,00');
      final result = formatter.formatEditUpdate(
        old,
        const TextEditingValue(text: '123456789012345678'),
      );
      expect(result.text, '0,00');
    });
  });
}
