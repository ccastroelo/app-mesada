import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/features/entitlement/entitlement.dart';

void main() {
  final firstUse = DateTime(2026, 11, 4);

  AppEntitlement fresh() => AppEntitlement(since: firstUse);

  AppEntitlement legacy() =>
      AppEntitlement(since: firstUse, origin: EntitlementOrigin.legacyUpdate);

  AppAccess access({
    AppEntitlement? entitlement,
    bool ownsApp = false,
    required DateTime now,
  }) => evaluateAccess(
    entitlement: entitlement ?? fresh(),
    ownsApp: ownsApp,
    now: now,
  );

  /// `FullAccess` com a fonte esperada, ou falha com o que veio.
  void expectFull(AppAccess result, AccessSource source, {int? daysLeft}) {
    expect(result, isA<FullAccess>());
    final full = result as FullAccess;
    expect(full.source, source);
    expect(full.trialDaysLeft, daysLeft);
    expect(result.canWrite, isTrue);
  }

  group('teste de 15 dias', () {
    test('o teste dura 15 dias', () {
      expect(trialDays, 15);
    });

    test('no primeiro instante faltam os 15 dias inteiros', () {
      expectFull(access(now: firstUse), AccessSource.trial, daysLeft: 15);
    });

    test('conta o dia corrente: no último dia falta 1', () {
      expectFull(
        access(now: DateTime(2026, 11, 18, 23, 59)),
        AccessSource.trial,
        daysLeft: 1,
      );
    });

    test('no meio do teste', () {
      expectFull(
        access(now: DateTime(2026, 11, 9, 12)),
        AccessSource.trial,
        daysLeft: 10,
      );
    });

    test('exatamente 15 dias depois o teste acabou: só leitura', () {
      final result = access(now: DateTime(2026, 11, 19));

      expect(result, isA<ReadOnlyAccess>());
      expect(result.canWrite, isFalse);
    });

    test('muito depois continua só leitura', () {
      expect(access(now: DateTime(2027, 3, 1)), isA<ReadOnlyAccess>());
    });

    test(
      'relógio atrasado em relação ao primeiro uso não promete mais que 15',
      () {
        expectFull(
          access(now: DateTime(2026, 10, 1)),
          AccessSource.trial,
          daysLeft: 15,
        );
      },
    );
  });

  group('depois do teste', () {
    final later = DateTime(2027, 1, 10);

    test('quem comprou o app usa para sempre', () {
      expectFull(access(ownsApp: true, now: later), AccessSource.purchased);
    });

    test('sem compra, só leitura: a família não dá acesso ao app', () {
      // Cada pessoa precisa do próprio acesso, o convidado inclusive. A
      // assinatura de compartilhar nem entra nesta regra.
      expect(access(now: later), isA<ReadOnlyAccess>());
    });
  });

  group('app antigo', () {
    final later = DateTime(2030, 1, 1);

    test(
      'quem veio do app antigo usa local para sempre, sem teste nem compra',
      () {
        expectFull(
          access(entitlement: legacy(), now: later),
          AccessSource.legacy,
        );
      },
    );

    test('vale mesmo no primeiro dia', () {
      expectFull(
        access(entitlement: legacy(), now: firstUse),
        AccessSource.legacy,
      );
    });
  });

  group('precedência (ADR-0021)', () {
    final later = DateTime(2027, 1, 10);

    test('app antigo vence a compra', () {
      expectFull(
        access(entitlement: legacy(), ownsApp: true, now: later),
        AccessSource.legacy,
      );
    });

    test('compra vence o teste ainda em andamento', () {
      expectFull(
        access(ownsApp: true, now: DateTime(2026, 11, 5)),
        AccessSource.purchased,
      );
    });
  });
}
