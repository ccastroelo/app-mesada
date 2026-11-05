import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/features/entitlement/data/providers.dart';
import 'package:mesada/features/entitlement/entitlement.dart';
import 'package:mesada/features/entitlement/entitlement_providers.dart';

import '../../support/fakes.dart';

void main() {
  group('sharingActiveProvider (ADR-0022)', () {
    ProviderContainer open(FakeStoreGateway gateway, FakePurchaseStore store) {
      final container = ProviderContainer(
        overrides: [
          storeGatewayProvider.overrideWithValue(gateway),
          purchaseStoreProvider.overrideWithValue(store),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    FakePurchaseStore withSubscription() => FakePurchaseStore(
      records: [
        PurchaseRecord(
          product: StoreProduct.sharing,
          since: DateTime(2026, 11, 4),
        ),
      ],
    );

    test('o validador manda: direito ativo libera', () async {
      final gateway = FakeStoreGateway()..activeNow = {StoreProduct.sharing};
      final container = open(gateway, FakePurchaseStore());

      await expectLater(
        container.read(sharingActiveProvider('fam1').future),
        completion(isTrue),
      );
      // Consultado em nome da família: é assim que o convidado vê a
      // assinatura que o outro responsável pagou.
      expect(gateway.owners, ['fam1']);
    });

    test('validador sem o direito recusa, mesmo com cópia local', () async {
      final gateway = FakeStoreGateway()..activeNow = {StoreProduct.app};
      final container = open(gateway, withSubscription());

      await expectLater(
        container.read(sharingActiveProvider('fam1').future),
        completion(isFalse),
      );
    });

    test('validador calado ("não sei") vale a cópia local', () async {
      final container = open(FakeStoreGateway(), withSubscription());

      await expectLater(
        container.read(sharingActiveProvider(null).future),
        completion(isTrue),
      );
    });

    test('validador calado e sem cópia local: não libera', () async {
      final gateway = FakeStoreGateway();
      final container = open(gateway, FakePurchaseStore());

      await expectLater(
        container.read(sharingActiveProvider(null).future),
        completion(isFalse),
      );
      expect(gateway.owners, [null]);
    });
  });
}
