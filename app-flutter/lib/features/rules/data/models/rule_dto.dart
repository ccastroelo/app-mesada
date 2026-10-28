import '../../domain/entities/rule.dart';

class RuleDto {
  const RuleDto({
    required this.id,
    required this.description,
    required this.valueCents,
  });

  factory RuleDto.fromMap(String id, Map<String, dynamic> map) {
    return RuleDto(
      id: id,
      description: map['description'] as String? ?? '',
      valueCents: (map['valueCents'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String description;
  final int valueCents;

  Rule toEntity() =>
      Rule(id: id, description: description, valueCents: valueCents);
}
