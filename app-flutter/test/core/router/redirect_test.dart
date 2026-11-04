import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/router/app_router.dart';
import 'package:mesada/features/app_lock/app_lock_providers.dart';
import 'package:mesada/features/auth_family/auth_family.dart';

import '../../support/fakes.dart';

void main() {
  const family = Family(id: 'f1', name: 'Família');
  final loading = const GateLoading();
  final error = GateError(StateError('x'));
  const signedOut = GateSignedOut();
  const needsFamily = GateNeedsFamily(testUser);
  const ready = GateReady(family, user: testUser);

  test('carregando ou com erro: tela de espera', () {
    expect(redirectFor(loading, '/filhos'), '/carregando');
    expect(redirectFor(error, '/entrar'), '/carregando');
    expect(redirectFor(loading, '/carregando'), isNull);
  });

  test('sem login: só boas-vindas e entrar', () {
    expect(redirectFor(signedOut, '/filhos'), '/boas-vindas');
    expect(redirectFor(signedOut, '/carregando'), '/boas-vindas');
    expect(redirectFor(signedOut, '/familia/nova'), '/boas-vindas');
    expect(redirectFor(signedOut, '/boas-vindas'), isNull);
    expect(redirectFor(signedOut, '/entrar'), isNull);
  });

  test('logado sem família: só o fluxo de família', () {
    expect(redirectFor(needsFamily, '/filhos'), '/familia');
    expect(redirectFor(needsFamily, '/ajustes'), '/familia');
    expect(redirectFor(needsFamily, '/entrar'), '/familia');
    expect(redirectFor(needsFamily, '/familia'), isNull);
    expect(redirectFor(needsFamily, '/familia/nova'), isNull);
    expect(redirectFor(needsFamily, '/familia/entrar'), isNull);
  });

  test('com família: sai da entrada e fica no app', () {
    expect(redirectFor(ready, '/carregando'), '/filhos');
    expect(redirectFor(ready, '/boas-vindas'), '/filhos');
    expect(redirectFor(ready, '/entrar'), '/filhos');
    expect(redirectFor(ready, '/familia'), '/filhos');
    expect(redirectFor(ready, '/familia/nova'), '/filhos');
    expect(redirectFor(ready, '/'), '/filhos');
    expect(redirectFor(ready, '/filhos'), isNull);
    expect(redirectFor(ready, '/regras'), isNull);
    expect(redirectFor(ready, '/ajustes'), isNull);
  });

  group('bloqueio por PIN', () {
    test('enquanto não se sabe se há PIN, só a tela de espera', () {
      expect(
        redirectFor(ready, '/filhos', lock: const LockLoading()),
        '/carregando',
      );
      expect(
        redirectFor(ready, '/carregando', lock: const LockLoading()),
        isNull,
      );
    });

    test('PIN pedido: nada além do bloqueio, nem a entrada', () {
      const closed = LockClosed();
      expect(redirectFor(ready, '/filhos', lock: closed), '/bloqueio');
      expect(redirectFor(ready, '/ajustes', lock: closed), '/bloqueio');
      expect(redirectFor(signedOut, '/boas-vindas', lock: closed), '/bloqueio');
      expect(redirectFor(loading, '/carregando', lock: closed), '/bloqueio');
      expect(redirectFor(ready, '/bloqueio', lock: closed), isNull);
    });

    test('introdução: aparece uma vez e dá para rever', () {
      // Enquanto o arquivo do aparelho não respondeu, espera.
      expect(redirectFor(ready, '/filhos', introSeen: null), '/carregando');
      // Não vista: vai para a introdução e fica nela.
      expect(redirectFor(ready, '/filhos', introSeen: false), '/introducao');
      expect(redirectFor(ready, '/introducao', introSeen: false), isNull);
      // Vista: ninguém é levado para lá, mas rever é permitido.
      expect(redirectFor(ready, '/filhos', introSeen: true), isNull);
      expect(redirectFor(ready, '/introducao', introSeen: true), isNull);
      // O PIN continua vindo antes da introdução.
      expect(
        redirectFor(
          ready,
          '/filhos',
          lock: const LockClosed(),
          introSeen: false,
        ),
        '/bloqueio',
      );
    });

    test('destravado, a tela do PIN não é lugar para ficar', () {
      expect(
        redirectFor(ready, '/bloqueio', lock: const LockOpen()),
        '/filhos',
      );
      expect(redirectFor(ready, '/bloqueio'), '/filhos');
      expect(redirectFor(ready, '/filhos', lock: const LockOpen()), isNull);
    });
  });
}
