import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/storage/device_settings.dart';
import 'package:mesada/features/family_plan/data/repositories/plan_store_impl.dart';
import 'package:mesada/features/family_plan/family_plan.dart';

void main() {
  group('o direito guarda de onde veio (ADR-0020)', () {
    test('sem compra, nada compartilha', () {
      const plan = FamilyPlan.none();

      expect(plan.kind, PlanKind.none);
      expect(plan.shares, isFalse);
    });

    test('a compra única leva tipo, produto, data e versão do modelo', () {
      final since = DateTime(2026, 11, 3);
      final plan = FamilyPlan.lifetime(since: since);

      expect(plan.kind, PlanKind.lifetime);
      expect(plan.shares, isTrue);
      expect(plan.productId, 'mesada_familia');
      expect(plan.since, since);
      // É esta marca que permite trocar para assinatura um dia sem cobrar de
      // novo de quem já pagou.
      expect(plan.modelVersion, 1);
    });

    test('ida e volta por JSON preserva a marca', () {
      final plan = FamilyPlan.lifetime(since: DateTime(2026, 11, 3));

      final back = FamilyPlan.fromJson(plan.toJson());

      expect(back.kind, PlanKind.lifetime);
      expect(back.productId, 'mesada_familia');
      expect(back.since, DateTime(2026, 11, 3));
      expect(back.modelVersion, 1);
    });

    test('JSON estranho vira "ninguém pagou", que é o lado seguro', () {
      expect(FamilyPlan.fromJson({}).shares, isFalse);
      expect(FamilyPlan.fromJson({'kind': 'coisa'}).shares, isFalse);
      expect(FamilyPlan.fromJson({'kind': 'none'}).shares, isFalse);
    });

    test('modelo antigo sem versão assume a versão atual', () {
      final plan = FamilyPlan.fromJson({
        'kind': 'lifetime',
        'productId': 'mesada_familia',
      });

      expect(plan.shares, isTrue);
      expect(plan.modelVersion, 1);
      expect(plan.since, isNull);
    });
  });

  group('cópia local', () {
    test('fica no device.json sem apagar o PIN nem a introdução', () async {
      final base = Directory.systemTemp.createTempSync('mesada_plan_');
      addTearDown(() => base.deleteSync(recursive: true));
      final settings = DeviceSettings(() async => base);
      await settings.merge({'pinHash': 'abc', 'introSeen': true});
      final store = PlanStoreImpl(settings);

      expect((await store.read()).shares, isFalse);
      await store.save(FamilyPlan.lifetime(since: DateTime(2026, 11, 3)));

      final saved = await store.read();
      expect(saved.kind, PlanKind.lifetime);
      expect(saved.since, DateTime(2026, 11, 3));
      final json = await settings.read();
      expect(json['pinHash'], 'abc');
      expect(json['introSeen'], true);
    });
  });
}
