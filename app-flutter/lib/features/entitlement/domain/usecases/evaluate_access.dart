import 'dart:math';

import '../entities/app_entitlement.dart';

/// Dias de teste a partir do primeiro uso (ADR-0021).
const trialDays = 15;

/// De onde vem o acesso completo ao app.
enum AccessSource { legacy, purchased, trial }

/// O que o app pode fazer agora, dado o que a pessoa tem.
sealed class AppAccess {
  const AppAccess();

  /// Pode lançar e editar. Só leitura não pode.
  bool get canWrite => this is FullAccess;
}

final class FullAccess extends AppAccess {
  const FullAccess(this.source, {this.trialDaysLeft});

  final AccessSource source;

  /// Dias que faltam, só quando [source] é [AccessSource.trial] (conta o dia
  /// corrente: 1 quer dizer "acaba hoje").
  final int? trialDaysLeft;
}

/// Teste acabou e não há compra: vê tudo, não altera nada.
final class ReadOnlyAccess extends AppAccess {
  const ReadOnlyAccess();
}

/// A regra de acesso **ao app**, pura. Precedência (ADR-0021): veio do app
/// antigo > comprou o app > dentro dos 15 dias > só leitura.
///
/// A assinatura de compartilhar **não entra aqui**: ela libera só a
/// sincronização e nunca dá acesso a quem não tem o app. Cada pessoa, o
/// convidado inclusive, precisa do próprio acesso.
///
/// [ownsApp] vem da loja; esta função não sabe de onde.
AppAccess evaluateAccess({
  required AppEntitlement entitlement,
  required bool ownsApp,
  required DateTime now,
}) {
  if (entitlement.origin == EntitlementOrigin.legacyUpdate) {
    return const FullAccess(AccessSource.legacy);
  }
  if (ownsApp) return const FullAccess(AccessSource.purchased);

  final end = entitlement.since.add(const Duration(days: trialDays));
  if (now.isBefore(end)) {
    final days = (end.difference(now).inMinutes / Duration.minutesPerDay)
        .ceil();
    // Relógio atrasado em relação ao primeiro uso: nunca promete mais que o
    // teste inteiro.
    return FullAccess(AccessSource.trial, trialDaysLeft: min(days, trialDays));
  }
  return const ReadOnlyAccess();
}
