/// Quantidade lançada para o par filho × regra (o "lançamento" do app antigo).
///
/// [enabled] é falso quando a regra foi desativada para o filho (ADR-0008):
/// a quantidade fica guardada, mas não conta no saldo.
class Entry {
  const Entry({
    required this.childId,
    required this.ruleId,
    this.quantity = 0,
    this.enabled = true,
  }) : assert(quantity >= 0, 'quantidade nunca é negativa');

  final String childId;
  final String ruleId;
  final int quantity;
  final bool enabled;

  /// Identificador do documento: um por par filho × regra.
  String get id => '${childId}_$ruleId';

  Entry increment() => copyWith(quantity: quantity + 1);

  /// Nunca desce de 0 (`imLanVC.m:119`).
  Entry decrement() => quantity == 0 ? this : copyWith(quantity: quantity - 1);

  Entry zeroed() => copyWith(quantity: 0);

  Entry copyWith({int? quantity, bool? enabled}) {
    return Entry(
      childId: childId,
      ruleId: ruleId,
      quantity: quantity ?? this.quantity,
      enabled: enabled ?? this.enabled,
    );
  }
}
