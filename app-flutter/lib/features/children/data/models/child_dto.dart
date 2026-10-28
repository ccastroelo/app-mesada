import '../../domain/entities/child.dart';

class ChildDto {
  const ChildDto({
    required this.id,
    required this.name,
    required this.email,
    required this.allowanceCents,
  });

  factory ChildDto.fromMap(String id, Map<String, dynamic> map) {
    return ChildDto(
      id: id,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      allowanceCents: (map['allowanceCents'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String name;
  final String email;
  final int allowanceCents;

  Child toEntity() =>
      Child(id: id, name: name, email: email, allowanceCents: allowanceCents);
}
