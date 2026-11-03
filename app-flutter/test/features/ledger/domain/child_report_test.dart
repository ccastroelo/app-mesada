import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/features/children/children.dart';
import 'package:mesada/features/ledger/ledger.dart';
import 'package:mesada/features/rules/rules.dart';

void main() {
  const lucas = Child(
    id: 'c1',
    name: 'Lucas',
    allowanceCents: 10000,
    email: 'lucas@example.com',
  );
  const bed = Rule(id: 'r1', description: 'Arrumar a cama', valueCents: 50);
  const grade = Rule(id: 'r2', description: 'Tirar nota 10', valueCents: 150);
  const light = Rule(id: 'r3', description: 'Luz acesa', valueCents: -50);

  ChildReport report(List<Entry> entries) => buildChildReport(
    child: lucas,
    rules: const [bed, grade, light],
    entries: entries,
  );

  test('leva nome, e-mail, mesada e saldo do filho', () {
    final result = report(const [
      Entry(childId: 'c1', ruleId: 'r1', quantity: 2),
    ]);

    expect(result.childName, 'Lucas');
    expect(result.childEmail, 'lucas@example.com');
    expect(result.allowanceCents, 10000);
    expect(result.balanceCents, 10100);
  });

  test('entram só as regras lançadas, na ordem da aba Regras', () {
    final result = report(const [
      Entry(childId: 'c1', ruleId: 'r3', quantity: 1),
      Entry(childId: 'c1', ruleId: 'r1', quantity: 2),
    ]);

    expect(
      [for (final row in result.rows) row.description],
      ['Arrumar a cama', 'Luz acesa'],
    );
    expect(result.rows.first.totalCents, 100);
    expect(result.rows.last.totalCents, -50);
  });

  test('quantidade 0 não vira linha', () {
    final result = report(const [
      Entry(childId: 'c1', ruleId: 'r1', quantity: 0),
    ]);

    expect(result.rows, isEmpty);
  });

  test('regra desativada para o filho fica fora, como no saldo', () {
    final result = report(const [
      Entry(childId: 'c1', ruleId: 'r1', quantity: 2, enabled: false),
      Entry(childId: 'c1', ruleId: 'r2', quantity: 1),
    ]);

    expect([for (final row in result.rows) row.description], ['Tirar nota 10']);
    expect(result.balanceCents, 10150);
  });

  test('lançamento de outro filho não entra', () {
    final result = report(const [
      Entry(childId: 'c2', ruleId: 'r1', quantity: 5),
    ]);

    expect(result.rows, isEmpty);
    expect(result.balanceCents, 10000);
  });
}
