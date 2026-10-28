import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/features/children/presentation/widgets/child_avatar.dart';

void main() {
  test('a cor do avatar é estável e fica dentro da paleta', () {
    for (final id in ['c1', 'c2', 'abc123', 'ZwG0kq9', '']) {
      final first = stableIndex(id, 6);
      expect(first, inInclusiveRange(0, 5));
      expect(stableIndex(id, 6), first);
    }
  });

  test('ids diferentes usam mais de uma cor', () {
    final indexes = {for (var i = 0; i < 30; i++) stableIndex('filho-$i', 6)};
    expect(indexes.length, greaterThan(2));
  });
}
