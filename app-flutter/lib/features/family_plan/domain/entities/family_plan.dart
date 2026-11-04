/// De onde vem o direito ao compartilhamento.
///
/// Guardar o **tipo** (e não um "pagou: sim/não") é o que permite trocar o
/// modelo de cobrança um dia sem cobrar de novo de quem já pagou: um
/// `subscription` entraria ao lado, e [PlanKind.lifetime] continua valendo
/// para sempre (ADR-0020).
enum PlanKind {
  /// Ninguém pagou: o app roda só neste aparelho.
  none,

  /// Compra única, o modelo de hoje. Não expira.
  lifetime,
}

/// O direito da família ao compartilhamento, com a marca de onde veio.
class FamilyPlan {
  const FamilyPlan({
    required this.kind,
    this.productId = '',
    this.since,
    this.modelVersion = currentModelVersion,
  });

  /// Nada comprado.
  const FamilyPlan.none() : this(kind: PlanKind.none);

  /// Versão do modelo de cobrança vigente. É por ela que uma regra futura diz
  /// "quem entrou no modelo 1 é vitalício e não se cobra de novo".
  static const currentModelVersion = 1;

  /// O produto da compra única, igual nas duas lojas (ADR-0020). Nunca
  /// remover das lojas: é o que o "Restaurar compras" procura.
  static const lifetimeProductId = 'mesada_familia';

  final PlanKind kind;
  final String productId;
  final DateTime? since;
  final int modelVersion;

  bool get shares => kind != PlanKind.none;

  /// A compra única de hoje, feita agora.
  factory FamilyPlan.lifetime({required DateTime since}) => FamilyPlan(
    kind: PlanKind.lifetime,
    productId: lifetimeProductId,
    since: since,
  );

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'productId': productId,
    'since': since?.toIso8601String(),
    'modelVersion': modelVersion,
  };

  /// Borda (arquivo ou Firestore): o que não der para ler vira "ninguém
  /// pagou", que é o lado seguro — o app segue local em vez de prometer
  /// compartilhamento que não existe.
  static FamilyPlan fromJson(Map<String, Object?> json) {
    final kind = PlanKind.values.firstWhere(
      (value) => value.name == json['kind'],
      orElse: () => PlanKind.none,
    );
    if (kind == PlanKind.none) return const FamilyPlan.none();
    final since = json['since'];
    return FamilyPlan(
      kind: kind,
      productId: json['productId'] as String? ?? '',
      since: since is String ? DateTime.tryParse(since) : null,
      modelVersion:
          (json['modelVersion'] as num?)?.toInt() ?? currentModelVersion,
    );
  }
}
