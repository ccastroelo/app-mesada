import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/error/failure.dart';
import 'package:mesada/core/error/result.dart';
import 'package:mesada/core/storage/device_settings.dart';
import 'package:mesada/features/app_lock/app_lock.dart';
import 'package:mesada/features/app_lock/app_lock_providers.dart';
import 'package:mesada/features/app_lock/data/providers.dart';
import 'package:mesada/features/app_lock/data/repositories/http_pin_recovery_service.dart';
import 'package:mesada/features/app_lock/data/repositories/pin_store_impl.dart';
import 'package:mesada/features/auth_family/domain/entities/family.dart';

import '../../support/fakes.dart';
import '../../support/pump_app.dart';

/// "Esqueci o PIN" por e-mail (ADR-0023): regras puras, guardado no aparelho,
/// o cliente HTTP, o controlador e as telas.
void main() {
  group('regras puras', () {
    test('o PIN novo tem sempre 4 dígitos, inclusive com zeros à esquerda', () {
      final seen = <String>{};
      for (var i = 0; i < 2000; i++) {
        final pin = newRandomPin();
        expect(isValidPin(pin), isTrue, reason: pin);
        seen.add(pin);
      }
      // Não é constante.
      expect(seen.length, greaterThan(100));
    });

    test('o identificador do aparelho tem 32 hexadecimais e não se repete', () {
      final a = newInstallId();
      final b = newInstallId();

      expect(a, matches(RegExp(r'^[a-f0-9]{32}$')));
      expect(a, isNot(b));
    });

    test('mascarar o e-mail esconde o começo e deixa o domínio', () {
      expect(maskEmail('ana@exemplo.com'), 'a**@exemplo.com');
      expect(maskEmail('a@exemplo.com'), 'a@exemplo.com');
      expect(maskEmail('semarroba'), 'semarroba');
      expect(maskEmail('@exemplo.com'), '@exemplo.com');
    });

    test('idioma do e-mail: pt, pt_PT, es e o resto em inglês', () {
      expect(recoveryLocale('pt', 'BR'), 'pt');
      expect(recoveryLocale('pt', null), 'pt');
      expect(recoveryLocale('pt', 'PT'), 'pt_PT');
      expect(recoveryLocale('es', 'MX'), 'es');
      expect(recoveryLocale('en', 'US'), 'en');
      expect(recoveryLocale('fr', 'FR'), 'en');
    });
  });

  group('PinStoreImpl (device.json numa pasta temporária)', () {
    late Directory base;
    late DeviceSettings settings;
    late PinStoreImpl store;

    setUp(() {
      base = Directory.systemTemp.createTempSync('mesada_recovery_');
      settings = DeviceSettings(() async => base);
      store = PinStoreImpl(settings);
    });

    tearDown(() => base.deleteSync(recursive: true));

    test('sem e-mail registrado, lê nulo', () async {
      expect(await store.readRecovery(), isNull);
    });

    test('guarda e lê e-mail, token e identificador', () async {
      await store.saveRecovery(
        const PinRecovery(email: 'a@b.com', token: 't', installId: 'i'),
      );

      final back = await store.readRecovery();

      expect(back?.email, 'a@b.com');
      expect(back?.token, 't');
      expect(back?.installId, 'i');
    });

    test('o identificador nasce uma vez e fica', () async {
      final first = await store.readOrCreateInstallId();
      final second = await store.readOrCreateInstallId();

      expect(first, matches(RegExp(r'^[a-f0-9]{32}$')));
      expect(second, first);
    });

    test('guardar o e-mail não mexe no PIN nem na biometria', () async {
      await store.save(const PinCredential(salt: 's', hash: 'h'));
      await store.saveBiometricsEnabled(true);

      await store.saveRecovery(
        const PinRecovery(email: 'a@b.com', token: 't', installId: 'i'),
      );

      expect((await store.read())?.hash, 'h');
      expect(await store.readBiometricsEnabled(), isTrue);
    });

    test('desativar o PIN apaga o e-mail, mas o identificador fica', () async {
      final id = await store.readOrCreateInstallId();
      await store.saveRecovery(
        PinRecovery(email: 'a@b.com', token: 't', installId: id),
      );

      await store.clear();

      expect(await store.readRecovery(), isNull);
      expect(await store.readOrCreateInstallId(), id);
    });

    test('registro incompleto no arquivo conta como sem e-mail', () async {
      await settings.merge({'recoveryEmail': 'a@b.com', 'installId': 'i'});

      expect(await store.readRecovery(), isNull);
    });
  });

  group('HttpPinRecoveryService (servidor local de verdade)', () {
    late HttpServer server;
    late String base;
    final requests = <({String path, Map<String, dynamic> body})>[];
    late int status;
    late String responseBody;

    // O flutter_test troca o HttpClient por um que responde 400 a tudo; aqui
    // o servidor é local e de verdade.
    setUpAll(() => HttpOverrides.global = null);

    setUp(() async {
      requests.clear();
      status = 200;
      responseBody = '{"ok":true,"token":"abc123"}';
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      base = 'http://127.0.0.1:${server.port}/mesada/pin';
      server.listen((request) async {
        final text = await utf8.decoder.bind(request).join();
        requests.add((
          path: request.uri.path,
          body: jsonDecode(text) as Map<String, dynamic>,
        ));
        request.response
          ..statusCode = status
          ..headers.contentType = ContentType.json
          ..write(responseBody);
        await request.response.close();
      });
    });

    tearDown(() => server.close(force: true));

    test('sem URL configurada, não há servidor', () async {
      final service = HttpPinRecoveryService('');

      expect(service.available, isFalse);
      final result = await service.register(
        email: 'a@b.com',
        installId: 'i',
        locale: 'pt',
      );
      expect(result, isA<Err<String>>());
    });

    test('registrar manda o corpo certo e devolve o token', () async {
      final service = HttpPinRecoveryService('$base/');

      final result = await service.register(
        email: 'ana@exemplo.com',
        installId: 'abc',
        locale: 'pt_PT',
      );

      expect((result as Ok<String>).value, 'abc123');
      expect(requests.single.path, '/mesada/pin/registrar.php');
      expect(requests.single.body, {
        'email': 'ana@exemplo.com',
        'installId': 'abc',
        'idioma': 'pt_PT',
      });
    });

    test('recuperar manda token e PIN e dá Ok', () async {
      responseBody = '{"ok":true}';
      final service = HttpPinRecoveryService(base);

      final result = await service.sendNewPin(
        email: 'ana@exemplo.com',
        installId: 'abc',
        token: 'tok',
        pin: '4821',
        locale: 'en',
      );

      expect(result, isA<Ok<void>>());
      expect(requests.single.path, '/mesada/pin/recuperar.php');
      expect(requests.single.body['pin'], '4821');
      expect(requests.single.body['token'], 'tok');
    });

    test('resposta de sucesso sem token não vale como registro', () async {
      responseBody = '{"ok":true}';
      final result = await HttpPinRecoveryService(
        base,
      ).register(email: 'a@b.com', installId: 'i', locale: 'pt');

      expect(result, isA<Err<String>>());
    });

    Future<Failure> failureFor(int code, String body) async {
      status = code;
      responseBody = body;
      final result = await HttpPinRecoveryService(base).sendNewPin(
        email: 'a@b.com',
        installId: 'i',
        token: 't',
        pin: '1234',
        locale: 'pt',
      );
      return (result as Err<void>).failure;
    }

    test('429 vira excesso de pedidos', () async {
      expect(
        await failureFor(429, '{"ok":false,"erro":"muitas_tentativas"}'),
        isA<TooManyRequests>(),
      );
    });

    test('403 vira permissão negada', () async {
      expect(
        await failureFor(403, '{"ok":false,"erro":"token_invalido"}'),
        isA<PermissionDenied>(),
      );
    });

    test('400 com e-mail inválido vira e-mail inválido', () async {
      expect(
        await failureFor(400, '{"ok":false,"erro":"email_invalido"}'),
        isA<InvalidEmail>(),
      );
    });

    test('página de erro da hospedagem vira falha inesperada', () async {
      expect(
        await failureFor(500, '<html>Internal Server Error</html>'),
        isA<Unexpected>(),
      );
    });

    test('502 do envio vira falha inesperada', () async {
      expect(
        await failureFor(502, '{"ok":false,"erro":"falha_no_envio"}'),
        isA<Unexpected>(),
      );
    });

    test('servidor fora do ar vira falha de conexão', () async {
      await server.close(force: true);

      final result = await HttpPinRecoveryService(base).sendNewPin(
        email: 'a@b.com',
        installId: 'i',
        token: 't',
        pin: '1234',
        locale: 'pt',
      );

      expect((result as Err<void>).failure, isA<NoConnection>());
    });

    test('servidor que não responde estoura o tempo e vira conexão', () async {
      final silent = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => silent.close(force: true));
      silent.listen((_) {});
      final service = HttpPinRecoveryService(
        'http://127.0.0.1:${silent.port}',
        timeout: const Duration(milliseconds: 200),
      );

      final result = await service.sendNewPin(
        email: 'a@b.com',
        installId: 'i',
        token: 't',
        pin: '1234',
        locale: 'pt',
      );

      expect((result as Err<void>).failure, isA<NoConnection>());
    });
  });

  group('AppLockController', () {
    late FakePinStore store;
    late FakePinRecoveryService service;
    late ProviderContainer container;

    Future<AppLockController> open({
      String? pin = '1234',
      bool withRecovery = false,
      bool serviceAvailable = true,
    }) async {
      store = FakePinStore();
      service = FakePinRecoveryService(available: serviceAvailable);
      if (pin != null) {
        final salt = newPinSalt();
        await store.save(PinCredential(salt: salt, hash: hashPin(pin, salt)));
      }
      if (withRecovery) {
        store.recovery = const PinRecovery(
          email: 'ana@exemplo.com',
          token: 'tok',
          installId: 'iid',
        );
      }
      container = ProviderContainer(
        overrides: [
          pinStoreProvider.overrideWithValue(store),
          pinRecoveryServiceProvider.overrideWithValue(service),
          biometricAuthProvider.overrideWithValue(FakeBiometricAuth()),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(appLockProvider.notifier);
      await pumpEventQueue();
      return controller;
    }

    test('registrar guarda e-mail, token e identificador', () async {
      final controller = await open();

      final result = await controller.registerRecovery(
        '  ana@exemplo.com ',
        'pt',
      );

      expect(result, isA<Ok<void>>());
      expect(service.registered.single.email, 'ana@exemplo.com');
      expect(service.registered.single.locale, 'pt');
      expect(store.recovery?.token, 'token-de-teste');
      expect(controller.recoveryEmail, 'ana@exemplo.com');
      expect(controller.canRecover, isTrue);
    });

    test('registrar com falha não guarda nada', () async {
      final controller = await open();
      service.failure = const NoConnection();

      final result = await controller.registerRecovery('ana@exemplo.com', 'pt');

      expect((result as Err<void>).failure, isA<NoConnection>());
      expect(store.recovery, isNull);
      expect(controller.canRecover, isFalse);
    });

    test('sem servidor configurado, não há recuperação', () async {
      final controller = await open(
        withRecovery: true,
        serviceAvailable: false,
      );

      expect(controller.recoveryAvailable, isFalse);
      expect(controller.canRecover, isFalse);
    });

    test(
      'esqueci: o PIN novo vale, o antigo não, e o app segue trancado',
      () async {
        final controller = await open(withRecovery: true);

        final result = await controller.forgotPin('pt');

        expect(result, isA<Ok<void>>());
        final sent = service.sent.single;
        expect(sent.email, 'ana@exemplo.com');
        expect(sent.token, 'tok');
        expect(isValidPin(sent.pin), isTrue);
        expect(container.read(appLockProvider), isA<LockClosed>());
        expect(controller.unlock(sent.pin), isTrue);
        expect(container.read(appLockProvider), isA<LockOpen>());
      },
    );

    test('esqueci: o PIN antigo deixa de valer', () async {
      final controller = await open(withRecovery: true);
      // Garante que o PIN novo é diferente do antigo no teste.
      service.failure = null;
      await controller.forgotPin('pt');
      final fresh = service.sent.single.pin;
      if (fresh == '1234') return; // 1 chance em 10 mil: nada a provar

      expect(controller.unlock('1234'), isFalse);
    });

    test(
      'esqueci com falha do servidor: o PIN antigo continua valendo',
      () async {
        final controller = await open(withRecovery: true);
        service.failure = const NoConnection();

        final result = await controller.forgotPin('pt');

        expect((result as Err<void>).failure, isA<NoConnection>());
        expect(service.sent, isEmpty);
        expect(controller.unlock('1234'), isTrue);
      },
    );

    test('esqueci zera a espera por erros do PIN antigo', () async {
      final controller = await open(withRecovery: true);
      for (var i = 0; i < 3; i++) {
        controller.unlock('9999');
      }
      expect(controller.waiting, isTrue);

      await controller.forgotPin('pt');

      expect(controller.waiting, isFalse);
    });

    test('esqueci sem e-mail registrado não faz nada', () async {
      final controller = await open();

      final result = await controller.forgotPin('pt');

      expect(result, isA<Err<void>>());
      expect(service.sent, isEmpty);
    });

    test('esqueci com o app já destravado não faz nada', () async {
      final controller = await open(withRecovery: true);
      controller.unlock('1234');

      final result = await controller.forgotPin('pt');

      expect(result, isA<Err<void>>());
      expect(service.sent, isEmpty);
    });

    test('desativar o PIN apaga o e-mail de recuperação', () async {
      final controller = await open(withRecovery: true);
      controller.unlock('1234');

      await controller.disablePin('1234');

      expect(store.recovery, isNull);
      expect(controller.recoveryEmail, isNull);
    });
  });

  group('tela de bloqueio', () {
    late FakePinStore store;
    late FakePinRecoveryService service;

    Future<void> open(
      WidgetTester tester, {
      bool withRecovery = true,
      bool serviceAvailable = true,
    }) async {
      store = FakePinStore();
      service = FakePinRecoveryService(available: serviceAvailable);
      final salt = newPinSalt();
      store.credential = PinCredential(salt: salt, hash: hashPin('1234', salt));
      if (withRecovery) {
        store.recovery = const PinRecovery(
          email: 'ana@exemplo.com',
          token: 'tok',
          installId: 'iid',
        );
      }
      await pumpApp(
        tester,
        auth: FakeAuthRepository(user: testUser),
        family: FakeFamilyRepository(
          family: const Family(id: 'f1', name: 'Família Castro'),
        ),
        pinStore: store,
        recovery: service,
        clock: () => DateTime(2026, 11, 4, 20),
      );
    }

    final forgot = find.widgetWithText(TextButton, 'Esqueci o PIN');

    Future<void> type(WidgetTester tester, String pin) async {
      for (final digit in pin.split('')) {
        await tester.tap(find.widgetWithText(OutlinedButton, digit));
        await tester.pump();
      }
      await tester.pumpAndSettle();
    }

    testWidgets('com e-mail registrado, oferece "Esqueci o PIN"', (
      tester,
    ) async {
      await open(tester);

      expect(forgot, findsOneWidget);
    });

    testWidgets('sem e-mail registrado, não oferece', (tester) async {
      await open(tester, withRecovery: false);

      expect(forgot, findsNothing);
    });

    testWidgets('sem servidor neste build, não oferece', (tester) async {
      await open(tester, serviceAvailable: false);

      expect(forgot, findsNothing);
    });

    testWidgets('pede confirmação mostrando o e-mail mascarado', (
      tester,
    ) async {
      await open(tester);

      await tester.tap(forgot);
      await tester.pumpAndSettle();

      expect(find.text('Enviar um PIN novo?'), findsOneWidget);
      expect(find.textContaining('a**@exemplo.com'), findsOneWidget);
      expect(find.textContaining('ana@exemplo.com'), findsNothing);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(service.sent, isEmpty);
    });

    testWidgets('confirmar envia, avisa e o PIN novo destrava', (tester) async {
      await open(tester);

      await tester.tap(forgot);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enviar PIN novo'));
      await tester.pumpAndSettle();

      expect(service.sent, hasLength(1));
      expect(service.sent.single.locale, 'pt');
      expect(
        find.textContaining('Enviamos um PIN novo para a**@exemplo.com'),
        findsOneWidget,
      );
      // O PIN novo nunca aparece na tela.
      expect(find.textContaining(service.sent.single.pin), findsNothing);

      await type(tester, service.sent.single.pin);
      expect(find.text('Digite seu PIN'), findsNothing);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('falha do servidor: mostra o erro e o PIN antigo vale', (
      tester,
    ) async {
      await open(tester);
      service.failure = const TooManyRequests();

      await tester.tap(forgot);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enviar PIN novo'));
      await tester.pumpAndSettle();

      expect(
        find.text('Muitas tentativas. Tente de novo mais tarde.'),
        findsOneWidget,
      );
      expect(service.sent, isEmpty);

      await type(tester, '1234');
      expect(find.byType(NavigationBar), findsOneWidget);
    });
  });

  group('Ajustes › Segurança', () {
    late FakePinStore store;
    late FakePinRecoveryService service;

    Future<void> openSecurity(
      WidgetTester tester, {
      String? pin,
      bool withRecovery = false,
      bool serviceAvailable = true,
    }) async {
      store = FakePinStore();
      service = FakePinRecoveryService(available: serviceAvailable);
      if (pin != null) {
        final salt = newPinSalt();
        store.credential = PinCredential(salt: salt, hash: hashPin(pin, salt));
      }
      if (withRecovery) {
        store.recovery = const PinRecovery(
          email: 'ana@exemplo.com',
          token: 'tok',
          installId: 'iid',
        );
      }
      await pumpApp(
        tester,
        auth: FakeAuthRepository(user: testUser),
        family: FakeFamilyRepository(
          family: const Family(id: 'f1', name: 'Família Castro'),
        ),
        pinStore: store,
        recovery: service,
        clock: () => DateTime(2026, 11, 4, 20),
      );
      if (pin != null) {
        for (final digit in pin.split('')) {
          await tester.tap(find.widgetWithText(OutlinedButton, digit));
          await tester.pump();
        }
        await tester.pumpAndSettle();
      }
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Ajustes'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('PIN'));
      await tester.pumpAndSettle();
    }

    Future<void> typeDigits(WidgetTester tester, String pin) async {
      for (final digit in pin.split('')) {
        await tester.tap(find.widgetWithText(OutlinedButton, digit));
        await tester.pump();
      }
      await tester.pumpAndSettle();
    }

    Future<void> activate(WidgetTester tester) async {
      await tester.tap(find.text('Ativar PIN'));
      await tester.pumpAndSettle();
      await typeDigits(tester, '1234');
      await typeDigits(tester, '1234');
    }

    testWidgets('ativar o PIN oferece o e-mail de recuperação', (tester) async {
      await openSecurity(tester);

      await activate(tester);

      expect(find.text('E-mail de recuperação'), findsWidgets);
      expect(find.textContaining('descobre o PIN'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Agora não'), findsOneWidget);
    });

    testWidgets('sem servidor neste build, ativar termina no PIN', (
      tester,
    ) async {
      await openSecurity(tester, serviceAvailable: false);

      await activate(tester);

      expect(find.text('E-mail de recuperação'), findsNothing);
      expect(find.text('PIN ativado'), findsWidgets);
    });

    testWidgets('"Agora não" termina sem e-mail', (tester) async {
      await openSecurity(tester);
      await activate(tester);

      await tester.tap(find.text('Agora não'));
      await tester.pumpAndSettle();

      expect(find.text('PIN ativado'), findsWidgets);
      expect(store.recovery, isNull);
      expect(service.registered, isEmpty);
    });

    testWidgets('e-mail inválido avisa sem chamar o servidor', (tester) async {
      await openSecurity(tester);
      await activate(tester);

      await tester.enterText(find.byType(TextField), 'isso-nao-e-email');
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await tester.pumpAndSettle();

      expect(find.text('Esse e-mail não parece válido.'), findsOneWidget);
      expect(service.registered, isEmpty);
    });

    testWidgets('salvar registra o e-mail e confirma', (tester) async {
      await openSecurity(tester);
      await activate(tester);

      await tester.enterText(find.byType(TextField), 'ana@exemplo.com');
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await tester.pumpAndSettle();

      expect(service.registered.single.email, 'ana@exemplo.com');
      expect(store.recovery?.email, 'ana@exemplo.com');
      expect(
        find.textContaining('E-mail de recuperação salvo'),
        findsOneWidget,
      );
    });

    testWidgets(
      'erro do servidor aparece abaixo do campo e deixa tentar de novo',
      (tester) async {
        await openSecurity(tester);
        await activate(tester);
        service.failure = const NoConnection();

        await tester.enterText(find.byType(TextField), 'ana@exemplo.com');
        await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
        await tester.pumpAndSettle();

        expect(store.recovery, isNull);
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Sem conexão. Tente de novo.'), findsOneWidget);
      },
    );

    testWidgets('a linha do e-mail mostra o endereço mascarado', (
      tester,
    ) async {
      await openSecurity(tester, pin: '1234', withRecovery: true);

      expect(find.text('a**@exemplo.com'), findsOneWidget);
    });

    testWidgets('sem e-mail, a linha diz que não está configurado', (
      tester,
    ) async {
      await openSecurity(tester, pin: '1234');

      expect(find.text('Não configurado'), findsOneWidget);
    });

    testWidgets('trocar o e-mail exige o PIN atual primeiro', (tester) async {
      await openSecurity(tester, pin: '1234', withRecovery: true);

      await tester.tap(find.text('E-mail de recuperação'));
      await tester.pumpAndSettle();
      expect(find.text('Digite o PIN atual'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      await typeDigits(tester, '9999');
      expect(find.text('PIN incorreto'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      await typeDigits(tester, '1234');
      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'novo@exemplo.com');
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await tester.pumpAndSettle();
      expect(store.recovery?.email, 'novo@exemplo.com');
    });

    testWidgets('sem servidor neste build, a linha do e-mail não aparece', (
      tester,
    ) async {
      await openSecurity(tester, pin: '1234', serviceAvailable: false);

      expect(find.text('Não configurado'), findsNothing);
      expect(find.text('E-mail de recuperação'), findsNothing);
    });
  });
}
