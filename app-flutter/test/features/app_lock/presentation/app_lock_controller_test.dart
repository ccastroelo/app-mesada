import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/features/app_lock/app_lock.dart';
import 'package:mesada/features/app_lock/app_lock_providers.dart';
import 'package:mesada/features/app_lock/data/providers.dart';

import '../../../support/fakes.dart';

void main() {
  late FakePinStore store;
  late FakeBiometricAuth biometrics;
  late DateTime now;
  late ProviderContainer container;

  /// Abre o controlador com o relógio nas mãos do teste.
  Future<AppLockController> open({
    String? pin,
    bool biometricsOn = false,
    bool biometricsAvailable = true,
    bool biometricsRecognizes = true,
  }) async {
    store = FakePinStore();
    if (pin != null) {
      final salt = newPinSalt();
      await store.save(PinCredential(salt: salt, hash: hashPin(pin, salt)));
    }
    store.biometricsEnabled = biometricsOn;
    biometrics = FakeBiometricAuth(
      available: biometricsAvailable,
      recognizes: biometricsRecognizes,
    );
    now = DateTime(2026, 11, 3, 20);
    container = ProviderContainer(
      overrides: [
        pinStoreProvider.overrideWithValue(store),
        biometricAuthProvider.overrideWithValue(biometrics),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(appLockProvider.notifier);
    // A credencial é lida do disco: o estado só sai de "carregando" depois.
    expect(container.read(appLockProvider), isA<LockLoading>());
    await pumpEventQueue();
    return controller;
  }

  LockState state() => container.read(appLockProvider);

  test('sem PIN guardado, o bloqueio não existe', () async {
    await open();

    expect(state(), isA<LockOff>());
  });

  test('com PIN guardado, abrir o app pede o PIN', () async {
    await open(pin: '1234');

    expect(state(), isA<LockClosed>());
  });

  test('o PIN certo destrava', () async {
    final controller = await open(pin: '1234');

    expect(controller.unlock('1234'), isTrue);
    expect(state(), isA<LockOpen>());
  });

  test('o PIN errado conta a tentativa e não destrava', () async {
    final controller = await open(pin: '1234');

    expect(controller.unlock('9999'), isFalse);
    expect(state(), isA<LockClosed>());
    expect((state() as LockClosed).wrongAttempts, 1);
    expect(controller.waiting, isFalse);
  });

  test('3 erros seguram as tentativas por 30 s, e o app não fecha', () async {
    final controller = await open(pin: '1234');

    for (var i = 0; i < 3; i++) {
      controller.unlock('9999');
    }

    expect(controller.waiting, isTrue);
    expect(controller.remainingWait, const Duration(seconds: 30));
    // Durante a espera, nem o PIN certo passa.
    expect(controller.unlock('1234'), isFalse);
    expect(state(), isA<LockClosed>());

    now = now.add(const Duration(seconds: 31));
    expect(controller.waiting, isFalse);
    expect(controller.remainingWait, Duration.zero);
    expect(controller.unlock('1234'), isTrue);
  });

  test('o segundo trio de erros espera o dobro', () async {
    final controller = await open(pin: '1234');

    for (var i = 0; i < 6; i++) {
      now = now.add(const Duration(seconds: 61));
      controller.unlock('9999');
    }

    expect(controller.remainingWait, const Duration(minutes: 1));
  });

  group('trava depois de 30 s fora do app', () {
    test('volta rápido não pede o PIN de novo', () async {
      final controller = await open(pin: '1234');
      controller.unlock('1234');

      controller.onAway();
      now = now.add(const Duration(seconds: 29));
      controller.onBack();

      expect(state(), isA<LockOpen>());
    });

    test('passar de 30 s pede o PIN', () async {
      final controller = await open(pin: '1234');
      controller.unlock('1234');

      controller.onAway();
      now = now.add(const Duration(seconds: 30));
      controller.onBack();

      expect(state(), isA<LockClosed>());
    });

    test('avisos repetidos de "saiu" não zeram o tempo fora', () async {
      final controller = await open(pin: '1234');
      controller.unlock('1234');

      // hidden e paused chegam em sequência, e na volta pode vir outro aviso.
      controller.onAway();
      now = now.add(const Duration(seconds: 40));
      controller.onAway();
      controller.onBack();

      expect(state(), isA<LockClosed>());
    });

    test('sem PIN, nada acontece', () async {
      final controller = await open();

      controller.onAway();
      now = now.add(const Duration(minutes: 5));
      controller.onBack();

      expect(state(), isA<LockOff>());
    });
  });

  group('biometria', () {
    test('ligada, a biometria destrava sem PIN digitado', () async {
      final controller = await open(pin: '1234', biometricsOn: true);

      expect(controller.biometricsEnabled, isTrue);
      expect(await controller.unlockWithBiometrics('Desbloqueie'), isTrue);
      expect(state(), isA<LockOpen>());
      expect(biometrics.reasons, ['Desbloqueie']);
    });

    test('não reconheceu: continua pedindo, e o PIN ainda vale', () async {
      final controller = await open(
        pin: '1234',
        biometricsOn: true,
        biometricsRecognizes: false,
      );

      expect(await controller.unlockWithBiometrics('Desbloqueie'), isFalse);
      expect(state(), isA<LockClosed>());
      // O erro da biometria não conta como tentativa de PIN.
      expect((state() as LockClosed).wrongAttempts, 0);
      expect(controller.unlock('1234'), isTrue);
    });

    test('desligada, nem tenta', () async {
      final controller = await open(pin: '1234');

      expect(await controller.unlockWithBiometrics('Desbloqueie'), isFalse);
      expect(biometrics.reasons, isEmpty);
    });

    test('durante a espera por erros, a biometria não passa', () async {
      final controller = await open(pin: '1234', biometricsOn: true);
      for (var i = 0; i < 3; i++) {
        controller.unlock('9999');
      }

      expect(await controller.unlockWithBiometrics('Desbloqueie'), isFalse);
      expect(biometrics.reasons, isEmpty);
      expect(state(), isA<LockClosed>());
    });

    test('ligar exige PIN ativo e biometria que funcione', () async {
      final semPin = await open();
      expect(await semPin.enableBiometrics('Desbloqueie'), isFalse);

      final semAparelho = await open(pin: '1234', biometricsAvailable: false);
      expect(await semAparelho.enableBiometrics('Desbloqueie'), isFalse);
      expect(store.biometricsEnabled, isFalse);

      final controller = await open(pin: '1234');
      expect(await controller.enableBiometrics('Desbloqueie'), isTrue);
      expect(controller.biometricsEnabled, isTrue);
      expect(store.biometricsEnabled, isTrue);
    });

    test('desligar o PIN desliga a biometria: sem reserva, não dá', () async {
      final controller = await open(pin: '1234', biometricsOn: true);

      await controller.disablePin('1234');

      expect(controller.biometricsEnabled, isFalse);
      expect(store.biometricsEnabled, isFalse);
    });
  });

  group('ativar, alterar e desativar', () {
    test('ativar guarda o hash e deixa destravado', () async {
      final controller = await open();

      await controller.enablePin('1234');

      expect(state(), isA<LockOpen>());
      expect(controller.enabled, isTrue);
      expect(controller.matches('1234'), isTrue);
      expect(store.credential?.hash, isNot(contains('1234')));
    });

    test('desativar exige o PIN atual', () async {
      final controller = await open(pin: '1234');

      expect(await controller.disablePin('9999'), isFalse);
      expect(state(), isA<LockClosed>());

      expect(await controller.disablePin('1234'), isTrue);
      expect(state(), isA<LockOff>());
      expect(await store.read(), isNull);
    });

    test('alterar exige o atual e passa a valer o novo', () async {
      final controller = await open(pin: '1234');

      expect(
        await controller.changePin(current: '9999', next: '5678'),
        isFalse,
      );
      expect(await controller.changePin(current: '1234', next: '5678'), isTrue);
      expect(controller.matches('5678'), isTrue);
      expect(controller.matches('1234'), isFalse);
    });
  });
}
