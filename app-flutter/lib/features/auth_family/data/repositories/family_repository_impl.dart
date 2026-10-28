import 'dart:math';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/firebase/firebase_failures.dart';
import '../../../rules/rules.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/family.dart';
import '../../domain/repositories/family_repository.dart';
import '../../domain/usecases/invite_code.dart';
import '../datasources/family_firestore_datasource.dart';

/// Validade pedida ao banco. As regras aceitam até 48 h; ficamos 1 h abaixo
/// para absorver relógio adiantado do aparelho.
const inviteValidity = Duration(hours: 47);

class FamilyRepositoryImpl implements FamilyRepository {
  FamilyRepositoryImpl(this._remote, {this._random, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final FamilyFirestoreDataSource _remote;
  final Random? _random;
  final DateTime Function() _clock;

  @override
  Stream<String?> watchFamilyId(String uid) => _remote.watchFamilyId(uid);

  @override
  Stream<Family?> watchFamily(String familyId) =>
      _remote.watchFamily(familyId).map((dto) => dto?.toEntity());

  @override
  Future<Result<void>> createFamily({
    required AppUser user,
    required String name,
    required List<RuleSeed> rules,
  }) async {
    try {
      await _remote.createFamily(
        uid: user.uid,
        email: user.email,
        name: name.trim(),
        rules: rules,
      );
      return const Ok(null);
    } catch (error) {
      return Err(failureFromFirebase(error));
    }
  }

  @override
  Future<Result<String>> createInvite({
    required AppUser user,
    required Family family,
  }) async {
    // Colisão de código aparece como permission-denied (o convite já existe).
    for (var attempt = 0; attempt < 3; attempt++) {
      final code = generateInviteCode(_random);
      try {
        await _remote.createInvite(
          code: code,
          familyId: family.id,
          uid: user.uid,
          expiresAt: _clock().add(inviteValidity),
        );
        return Ok(code);
      } catch (error) {
        final failure = failureFromFirebase(error);
        if (failure is! PermissionDenied) return Err(failure);
      }
    }
    return const Err(PermissionDenied());
  }

  @override
  Future<Result<void>> joinWithCode({
    required AppUser user,
    required String code,
  }) async {
    final normalized = normalizeInviteCode(code);
    if (normalized == null) return const Err(InvalidInvite());
    try {
      final invite = await _remote.getInvite(normalized);
      if (invite == null || !invite.isUsableAt(_clock())) {
        return const Err(InvalidInvite());
      }
      await _remote.joinFamily(
        uid: user.uid,
        email: user.email,
        code: normalized,
        familyId: invite.familyId,
      );
      return const Ok(null);
    } catch (error) {
      final failure = failureFromFirebase(error);
      // Corrida: outro aparelho usou o código entre a leitura e o lote.
      return Err(failure is PermissionDenied ? const InvalidInvite() : failure);
    }
  }
}
