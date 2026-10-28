import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/features/rules/rules.dart';

void main() {
  group('defaultRulesFor', () {
    test('cada idioma tem as 20 regras do app antigo', () {
      for (final language in ['pt', 'en', 'es']) {
        expect(defaultRulesFor(language), hasLength(20), reason: language);
      }
    });

    test('os valores são os mesmos em todos os idiomas, em centavos', () {
      final pt = defaultRulesFor('pt').map((r) => r.valueCents).toList();
      expect(defaultRulesFor('en').map((r) => r.valueCents), pt);
      expect(defaultRulesFor('es').map((r) => r.valueCents), pt);
      expect(pt.first, 50); // Arrumar a cama: +0,50
      expect(pt[1], 150); // Tirar nota 10: +1,50
      expect(pt[9], -75); // Não almoçar ou jantar: -0,75
      expect(pt[14], -200); // Nota baixa: -2,00
      expect(pt.last, -100); // Mentir: -1,00
      expect(pt.where((v) => v > 0), hasLength(2));
    });

    test('idioma desconhecido e pt usam a lista em português', () {
      expect(defaultRulesFor('fr').first.description, 'Arrumar a cama');
      expect(defaultRulesFor('pt').first.description, 'Arrumar a cama');
      expect(defaultRulesFor('en').first.description, 'Make the bed');
    });

    test('nenhuma descrição vazia ou com espaço sobrando', () {
      for (final language in ['pt', 'en', 'es']) {
        for (final rule in defaultRulesFor(language)) {
          expect(rule.description, isNotEmpty);
          expect(rule.description, rule.description.trim());
          expect(rule.description.contains('  '), isFalse);
        }
      }
    });
  });
}
