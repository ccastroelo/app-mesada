import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/app.dart';
import 'package:mesada/core/storage/app_mode_state.dart';
import 'package:mesada/core/storage/device_settings.dart';
import 'package:mesada/core/storage/local_store.dart';
import 'package:mesada/core/storage/providers.dart';
import 'package:mesada/features/app_lock/app_lock_providers.dart';
import 'package:mesada/features/app_lock/data/providers.dart';
import 'package:mesada/features/auth_family/data/providers.dart';
import 'package:mesada/features/children/data/providers.dart';
import 'package:mesada/features/entitlement/data/providers.dart';
import 'package:mesada/features/help/data/providers.dart';
import 'package:mesada/features/ledger/data/providers.dart';
import 'package:mesada/features/rules/data/providers.dart';

import 'fakes.dart';

/// Abre o app inteiro sem tocar no Firebase.
///
/// [mode] escolhe o portão: `cloud` (padrão aqui) exercita a composição da
/// compartilhamento, com conta e família falsas. `local` é o padrão do app de
/// verdade (ADR-0014): aí os repositórios que **não** receberem um falso são
/// os de verdade, sobre um arquivo numa pasta temporária.
Future<void> pumpApp(
  WidgetTester tester, {
  AppMode mode = AppMode.cloud,
  FakeAuthRepository? auth,
  FakeFamilyRepository? family,
  FakeRulesRepository? rules,
  FakeChildrenRepository? children,
  FakeLedgerRepository? ledger,
  FakePhotoStore? photoStore,
  FakePhotoPicker? photoPicker,
  FakeReportSharer? reportSharer,
  FakePinStore? pinStore,
  FakeBiometricAuth? biometrics,
  FakePinRecoveryService? recovery,
  FakeIntroStore? introStore,
  FakeEntitlementStore? entitlementStore,
  FakeLegacyDetector? legacyDetector,
  FakeStoreGateway? storeGateway,
  FakePurchaseStore? purchaseStore,
  DateTime Function()? clock,
  LocalStore? store,
  DeviceSettings? deviceSettings,
  Locale locale = const Locale('pt', 'BR'),
}) async {
  final local = mode == AppMode.local;
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appModeProvider.overrideWithValue(mode),
        // O portão espera o modo guardado; nos testes ele já vem resolvido.
        savedModeProvider.overrideWith((ref) async => mode),
        // Ajustes do aparelho numa pasta temporária: trocar o modo e gravar
        // o PIN não podem falar com o path_provider num teste.
        deviceSettingsProvider.overrideWithValue(
          deviceSettings ?? temporaryDeviceSettings(),
        ),
        // Sem PIN por padrão: o bloqueio não entra no caminho dos outros testes.
        pinStoreProvider.overrideWithValue(pinStore ?? FakePinStore()),
        biometricAuthProvider.overrideWithValue(
          biometrics ?? FakeBiometricAuth(),
        ),
        // Sem servidor por padrão: o "esqueci o PIN" não entra no caminho dos
        // outros testes (nem há rede num teste).
        pinRecoveryServiceProvider.overrideWithValue(
          recovery ?? FakePinRecoveryService(available: false),
        ),
        if (clock != null) clockProvider.overrideWithValue(clock),
        // Introdução já vista por padrão: ela não entra no caminho dos
        // outros testes.
        introStoreProvider.overrideWithValue(introStore ?? FakeIntroStore()),
        // A marca do aparelho em memória: nenhum teste grava no disco por ela.
        entitlementStoreProvider.overrideWithValue(
          entitlementStore ?? FakeEntitlementStore(),
        ),
        legacyAppDetectorProvider.overrideWithValue(
          legacyDetector ?? FakeLegacyDetector(),
        ),
        // A loja e a cópia das compras em memória. Por padrão o app já está
        // comprado: a faixa de teste e o só leitura não entram no caminho dos
        // outros testes (os de acesso passam o próprio `purchaseStore`).
        storeGatewayProvider.overrideWithValue(
          storeGateway ?? FakeStoreGateway(),
        ),
        purchaseStoreProvider.overrideWithValue(
          purchaseStore ?? FakePurchaseStore.ownsApp(),
        ),
        localStoreProvider.overrideWithValue(store ?? temporaryStore()),
        authRepositoryProvider.overrideWithValue(auth ?? FakeAuthRepository()),
        familyRepositoryProvider.overrideWithValue(
          family ?? FakeFamilyRepository(),
        ),
        childPhotoStoreProvider.overrideWithValue(
          photoStore ?? FakePhotoStore(),
        ),
        photoPickerProvider.overrideWithValue(photoPicker ?? FakePhotoPicker()),
        // Nunca gerar PDF nem abrir a folha do sistema num teste.
        reportSharerProvider.overrideWithValue(
          reportSharer ?? FakeReportSharer(),
        ),
        if (rules != null || !local)
          rulesRepositoryProvider.overrideWithValue(
            rules ?? FakeRulesRepository(),
          ),
        if (children != null || !local)
          childrenRepositoryProvider.overrideWithValue(
            children ?? FakeChildrenRepository(),
          ),
        if (ledger != null || !local)
          ledgerRepositoryProvider.overrideWithValue(
            ledger ?? FakeLedgerRepository(),
          ),
      ],
      child: const MesadaApp(),
    ),
  );
  await tester.pumpAndSettle();
}

/// Armazenamento local sobre uma pasta temporária, apagada no fim do teste.
LocalStore temporaryStore() {
  final directory = Directory.systemTemp.createTempSync('mesada_store_');
  addTearDown(() => directory.deleteSync(recursive: true));
  return LocalStore(() async => directory);
}

/// Ajustes do aparelho sobre uma pasta temporária, apagada no fim do teste.
DeviceSettings temporaryDeviceSettings() {
  final directory = Directory.systemTemp.createTempSync('mesada_device_');
  addTearDown(() => directory.deleteSync(recursive: true));
  return DeviceSettings(() async => directory);
}
