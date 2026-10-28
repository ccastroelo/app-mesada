class InviteDto {
  const InviteDto({
    required this.familyId,
    required this.usedBy,
    required this.expiresAt,
  });

  final String familyId;
  final String? usedBy;
  final DateTime expiresAt;

  bool isUsableAt(DateTime now) => usedBy == null && expiresAt.isAfter(now);
}
