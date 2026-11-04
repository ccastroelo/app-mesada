import 'dart:math';

import '../entities/app_entitlement.dart';

/// Dias de teste a partir do primeiro uso (ADR-0021).
const trialDays = 15;

/// De onde vem o acesso completo.
enum AccessSource { legacy, purchased, familyMember, trial }

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

/// Teste acabou e não há compra nem família ativa: vê tudo, não altera nada.
final class ReadOnlyAccess extends AppAccess {
  const ReadOnlyAccess();
}

/// A regra de acesso, pura. Precedência (ADR-0021): veio do app antigo >
/// comprou o app > membro de família com assinatura ativa > dentro dos 15 dias
/// > só leitura.
///
/// [ownsApp] e [inActiveFamily] vêm da loja e do documento da família; esta
/// função não sabe de onde.
AppAccess evaluateAccess({
  required AppEntitlement entitlement,
  required bool ownsApp,
  required bool inActiveFamily,
  required DateTime now,
}) {
  if (entitlement.origin == EntitlementOrigin.legacyUpdate) {
    return const FullAccess(AccessSource.legacy);
  }
  if (ownsApp) return const FullAccess(AccessSource.purchased);
  if (inActiveFamily) return const FullAccess(AccessSource.familyMember);

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
