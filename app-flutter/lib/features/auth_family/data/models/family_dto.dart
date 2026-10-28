import '../../domain/entities/family.dart';

class FamilyDto {
  const FamilyDto({required this.id, required this.name});

  factory FamilyDto.fromMap(String id, Map<String, dynamic> map) {
    return FamilyDto(id: id, name: map['name'] as String? ?? '');
  }

  final String id;
  final String name;

  Family toEntity() => Family(id: id, name: name);
}
