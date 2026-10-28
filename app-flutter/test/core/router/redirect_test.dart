import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/router/app_router.dart';
import 'package:mesada/features/auth_family/auth_family.dart';

import '../../support/fakes.dart';

void main() {
  const family = Family(id: 'f1', name: 'Família');
  final loading = const GateLoading();
  final error = GateError(StateError('x'));
  const signedOut = GateSignedOut();
  const needsFamily = GateNeedsFamily(testUser);
  const ready = GateReady(testUser, family);

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
}
