/// Regra de recompensa ou desconto (a "falta" do app antigo).
///
/// [valueCents] é em centavos: positivo é recompensa, zero ou negativo é
/// desconto (zero cai em desconto, como no legado: `imLanVC.m:98-102`).
class Rule {
  const Rule({
    required this.id,
    required this.description,
    required this.valueCents,
  });

  final String id;
  final String description;
  final int valueCents;

  bool get isReward => valueCents > 0;

  bool get isDiscount => !isReward;

  Rule copyWith({String? description, int? valueCents}) {
    return Rule(
      id: id,
      description: description ?? this.description,
      valueCents: valueCents ?? this.valueCents,
    );
  }
}
