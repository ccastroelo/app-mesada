import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/app.dart';
import 'package:mesada/features/auth_family/data/providers.dart';
import 'package:mesada/features/children/data/providers.dart';
import 'package:mesada/features/ledger/data/providers.dart';
import 'package:mesada/features/rules/data/providers.dart';

import 'fakes.dart';

/// Abre o app inteiro com repositórios falsos (nada do Firebase é tocado).
Future<void> pumpApp(
  WidgetTester tester, {
  required FakeAuthRepository auth,
  required FakeFamilyRepository family,
  FakeRulesRepository? rules,
  FakeChildrenRepository? children,
  FakeLedgerRepository? ledger,
  FakePhotoStore? photoStore,
  FakePhotoPicker? photoPicker,
  Locale locale = const Locale('pt', 'BR'),
}) async {
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        familyRepositoryProvider.overrideWithValue(family),
        rulesRepositoryProvider.overrideWithValue(
          rules ?? FakeRulesRepository(),
        ),
        childrenRepositoryProvider.overrideWithValue(
          children ?? FakeChildrenRepository(),
        ),
        ledgerRepositoryProvider.overrideWithValue(
          ledger ?? FakeLedgerRepository(),
        ),
        childPhotoStoreProvider.overrideWithValue(
          photoStore ?? FakePhotoStore(),
        ),
        photoPickerProvider.overrideWithValue(photoPicker ?? FakePhotoPicker()),
      ],
      child: const MesadaApp(),
    ),
  );
  await tester.pumpAndSettle();
}
