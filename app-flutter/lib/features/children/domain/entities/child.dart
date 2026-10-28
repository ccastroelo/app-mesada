/// Filho que recebe a mesada (o "mesadeiro" do app antigo).
///
/// [allowanceCents] é a mesada inicial em centavos. A foto não faz parte da
/// entidade: fica só no aparelho (ADR-0006).
class Child {
  const Child({
    required this.id,
    required this.name,
    required this.allowanceCents,
    this.email = '',
  });

  final String id;
  final String name;
  final int allowanceCents;
  final String email;

  Child copyWith({String? name, int? allowanceCents, String? email}) {
    return Child(
      id: id,
      name: name ?? this.name,
      allowanceCents: allowanceCents ?? this.allowanceCents,
      email: email ?? this.email,
    );
  }
}
