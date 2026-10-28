import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/features/rules/rules.dart';

void main() {
  Rule rule(String id, int cents) =>
      Rule(id: id, description: id, valueCents: cents);

  test('separa recompensas e descontos mantendo a ordem de cada grupo', () {
    final groups = splitRules([
      rule('a', -50),
      rule('b', 150),
      rule('c', -100),
      rule('d', 50),
    ]);
    expect(groups.rewards.map((r) => r.id), ['b', 'd']);
    expect(groups.discounts.map((r) => r.id), ['a', 'c']);
  });

  test('valor zero cai em descontos, como no legado', () {
    final groups = splitRules([rule('zero', 0)]);
    expect(groups.rewards, isEmpty);
    expect(groups.discounts.single.id, 'zero');
  });

  test('lista vazia', () {
    expect(splitRules(const []).isEmpty, isTrue);
  });
}
