/// De onde veio este aparelho: instalação nova ou atualização do app antigo.
enum EntitlementOrigin { newInstall, legacyUpdate }

/// A marca do app neste aparelho (ADR-0021).
///
/// Guarda **de onde o aparelho veio**, e nunca um "pagou: sim/não". [since] é
/// o primeiro uso e, por isso, também o **início dos 15 dias de teste**. A
/// compra única e a assinatura são direitos que a **loja** guarda e confirma;
/// esta marca só permite, no futuro, mudar a cobrança sem cobrar de novo quem
/// já estava no modelo anterior.
class AppEntitlement {
  const AppEntitlement({
    required this.since,
    this.origin = EntitlementOrigin.newInstall,
    this.modelVersion = currentModelVersion,
    this.lastSeen,
  });

  /// Modelo 1: teste de 15 dias, compra única do app e assinatura para
  /// compartilhar. Uma regra futura pode dizer "modelo 1 não paga de novo".
  static const firstModel = 1;

  /// Modelo de venda vigente nesta versão do app. Subir este número é
  /// decisão de produto e exige uma ADR.
  static const currentModelVersion = firstModel;

  /// Primeiro uso do app neste aparelho = início do teste.
  final DateTime since;
  final EntitlementOrigin origin;
  final int modelVersion;

  /// O maior instante em que o app já esteve aberto neste aparelho. Serve só
  /// para o teste de 15 dias não voltar no tempo quando o relógio é atrasado
  /// (ADR-0021). Ausente numa marca que nunca foi atualizada.
  final DateTime? lastSeen;

  /// Quanto vale "agora" para o teste: nunca antes do maior instante já visto
  /// (nem antes do primeiro uso). Atrasar o relógio não devolve dias.
  DateTime effectiveNow(DateTime clock) {
    final floor = lastSeen ?? since;
    return clock.isBefore(floor) ? floor : clock;
  }

  /// A marca com o [clock] registrado como visto, ou ela mesma se o relógio
  /// não andou pelo menos [seenGranularity] desde o último registro (evita
  /// gravar em disco a cada abertura de tela).
  AppEntitlement markSeen(DateTime clock) {
    final floor = lastSeen ?? since;
    if (clock.difference(floor) < seenGranularity) return this;
    return AppEntitlement(
      since: since,
      origin: origin,
      modelVersion: modelVersion,
      lastSeen: clock,
    );
  }

  /// Passo mínimo entre dois registros de [lastSeen].
  static const seenGranularity = Duration(hours: 1);

  Map<String, Object?> toJson() => {
    'modelVersion': modelVersion,
    'since': since.toIso8601String(),
    'origin': origin.name,
    'lastSeen': ?lastSeen?.toIso8601String(),
  };

  /// Borda (arquivo): sem data legível não há marca — quem lê cria uma nova.
  /// Sem número de modelo vale o modelo 1, e sem origem vale instalação nova:
  /// o valor padrão de uma marca antiga não pode acompanhar
  /// [currentModelVersion], senão ela seria promovida sem ninguém decidir.
  static AppEntitlement? fromJson(Map<String, Object?> json) {
    final since = json['since'];
    final parsed = since is String ? DateTime.tryParse(since) : null;
    if (parsed == null) return null;
    return AppEntitlement(
      since: parsed,
      origin: EntitlementOrigin.values.firstWhere(
        (value) => value.name == json['origin'],
        orElse: () => EntitlementOrigin.newInstall,
      ),
      modelVersion: (json['modelVersion'] as num?)?.toInt() ?? firstModel,
      lastSeen: switch (json['lastSeen']) {
        final String value => DateTime.tryParse(value),
        _ => null,
      },
    );
  }
}
