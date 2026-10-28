import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/features/children/children.dart';
import 'package:mesada/features/ledger/domain/entities/entry.dart';
import 'package:mesada/features/ledger/domain/usecases/calculate_balance.dart';
import 'package:mesada/features/rules/rules.dart';

void main() {
  const lucas = Child(id: 'c1', name: 'Lucas', allowanceCents: 10000);
  const bed = Rule(id: 'r1', description: 'Arrumar a cama', valueCents: 50);
  const light = Rule(id: 'r2', description: 'Luz acesa', valueCents: -50);

  int balance(List<Rule> rules, List<Entry> entries, {Child child = lucas}) =>
      calculateBalanceCents(child: child, rules: rules, entries: entries);

  group('calculateBalanceCents', () {
    test('sem lançamentos, o saldo é a mesada inicial', () {
      expect(balance([bed, light], []), 10000);
    });

    test('soma recompensas e subtrai descontos pela quantidade', () {
      final entries = [
        const Entry(childId: 'c1', ruleId: 'r1', quantity: 3),
        const Entry(childId: 'c1', ruleId: 'r2', quantity: 2),
      ];
      expect(balance([bed, light], entries), 10000 + 3 * 50 - 2 * 50);
    });

    test('saldo pode ficar negativo', () {
      const poor = Child(id: 'c1', name: 'Ana', allowanceCents: 100);
      const entries = [Entry(childId: 'c1', ruleId: 'r2', quantity: 5)];
      expect(balance([light], entries, child: poor), 100 - 250);
    });

    test('ignora lançamentos de outro filho', () {
      const entries = [Entry(childId: 'c2', ruleId: 'r1', quantity: 9)];
      expect(balance([bed], entries), 10000);
    });

    test('regra desativada para o filho não conta, mas a quantidade fica', () {
      const entry = Entry(
        childId: 'c1',
        ruleId: 'r1',
        quantity: 4,
        enabled: false,
      );
      expect(balance([bed], [entry]), 10000);
      expect(entry.copyWith(enabled: true).quantity, 4);
    });

    test('ignora lançamento de regra que não existe mais', () {
      const entries = [Entry(childId: 'c1', ruleId: 'apagada', quantity: 7)];
      expect(balance([bed], entries), 10000);
    });

    test('regra de valor zero não altera o saldo', () {
      const free = Rule(id: 'r3', description: 'Neutra', valueCents: 0);
      const entries = [Entry(childId: 'c1', ruleId: 'r3', quantity: 10)];
      expect(balance([free], entries), 10000);
    });
  });

  group('Entry', () {
    const entry = Entry(childId: 'c1', ruleId: 'r1');

    test('o id junta filho e regra', () {
      expect(entry.id, 'c1_r1');
    });

    test('incrementa sem limite e decrementa até 0', () {
      expect(entry.increment().increment().quantity, 2);
      expect(entry.decrement().quantity, 0);
      expect(entry.increment().increment().decrement().quantity, 1);
    });

    test('zerar não muda o resto', () {
      final zeroed = entry.copyWith(quantity: 5, enabled: false).zeroed();
      expect(zeroed.quantity, 0);
      expect(zeroed.enabled, isFalse);
    });
  });

  group('Rule', () {
    test('zero é desconto, como no legado', () {
      expect(
        const Rule(id: 'x', description: 'x', valueCents: 0).isDiscount,
        isTrue,
      );
      expect(
        const Rule(id: 'x', description: 'x', valueCents: 1).isReward,
        isTrue,
      );
      expect(
        const Rule(id: 'x', description: 'x', valueCents: -1).isDiscount,
        isTrue,
      );
    });
  });
}
