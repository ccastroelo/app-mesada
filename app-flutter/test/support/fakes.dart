import 'dart:async';

import 'package:mesada/core/error/failure.dart';
import 'package:mesada/core/error/result.dart';
import 'package:mesada/features/auth_family/domain/entities/app_user.dart';
import 'package:mesada/features/auth_family/domain/entities/family.dart';
import 'package:mesada/features/auth_family/domain/repositories/auth_repository.dart';
import 'package:mesada/features/auth_family/domain/repositories/family_repository.dart';
import 'package:mesada/features/auth_family/domain/usecases/invite_code.dart';
import 'package:mesada/features/children/children.dart';
import 'package:mesada/features/ledger/ledger.dart';
import 'package:mesada/features/rules/rules.dart';

const testUser = AppUser(uid: 'u1', email: 'ana@example.com');

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this._user});

  AppUser? _user;
  final _changes = StreamController<AppUser?>.broadcast();

  /// Resultado devolvido pelas próximas chamadas.
  Result<void> nextResult = const Ok(null);
  final calls = <String>[];

  void _emit(AppUser? user) {
    _user = user;
    _changes.add(user);
  }

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _user;
    yield* _changes.stream;
  }

  Future<Result<void>> _signedIn(String call, String email) async {
    calls.add(call);
    if (nextResult is Ok) _emit(AppUser(uid: 'u1', email: email));
    return nextResult;
  }

  @override
  Future<Result<void>> signInWithEmail(String email, String password) =>
      _signedIn('signIn:$email', email);

  @override
  Future<Result<void>> signUpWithEmail(String email, String password) =>
      _signedIn('signUp:$email', email);

  @override
  Future<Result<void>> signInWithGoogle() =>
      _signedIn('google', 'google@example.com');

  @override
  Future<Result<void>> sendPasswordReset(String email) async {
    calls.add('reset:$email');
    return nextResult;
  }

  @override
  Future<Result<void>> signOut() async {
    calls.add('signOut');
    _emit(null);
    return const Ok(null);
  }
}

class FakeFamilyRepository implements FamilyRepository {
  FakeFamilyRepository({this._family, this.validCodes = const {}});

  Family? _family;
  final Set<String> validCodes;
  final _idChanges = StreamController<String?>.broadcast();
  final _familyChanges = StreamController<Family?>.broadcast();

  String? lastName;
  List<RuleSeed>? lastSeeds;
  Result<void>? createError;

  void _set(Family? family) {
    _family = family;
    _familyChanges.add(family);
    _idChanges.add(family?.id);
  }

  @override
  Stream<String?> watchFamilyId(String uid) async* {
    yield _family?.id;
    yield* _idChanges.stream;
  }

  @override
  Stream<Family?> watchFamily(String familyId) async* {
    yield _family;
    yield* _familyChanges.stream;
  }

  @override
  Future<Result<void>> createFamily({
    required AppUser user,
    required String name,
    required List<RuleSeed> rules,
  }) async {
    lastName = name;
    lastSeeds = rules;
    final error = createError;
    if (error != null) return error;
    _set(Family(id: 'f1', name: name));
    return const Ok(null);
  }

  @override
  Future<Result<String>> createInvite({
    required AppUser user,
    required Family family,
  }) async => const Ok('ABC234');

  @override
  Future<Result<void>> joinWithCode({
    required AppUser user,
    required String code,
  }) async {
    final normalized = normalizeInviteCode(code);
    if (normalized == null || !validCodes.contains(normalized)) {
      return const Err(InvalidInvite());
    }
    _set(const Family(id: 'f1', name: 'Família Castro'));
    return const Ok(null);
  }
}

/// Regras em memória, na ordem da lista; cada mudança é emitida no stream.
class FakeRulesRepository implements RulesRepository {
  FakeRulesRepository({List<Rule> rules = const []}) : _rules = [...rules];

  final List<Rule> _rules;
  final _changes = StreamController<List<Rule>>.broadcast();
  int _nextId = 1;

  /// Resultado devolvido por todas as escritas (para simular falha).
  Result<void> nextResult = const Ok(null);
  List<String>? lastReorder;
  int deleteCalls = 0;

  List<Rule> get rules => List.unmodifiable(_rules);

  void _emit() => _changes.add(List.unmodifiable(_rules));

  @override
  Stream<List<Rule>> watchRules(String familyId) async* {
    yield List.unmodifiable(_rules);
    yield* _changes.stream;
  }

  @override
  Future<Result<void>> addRule(
    String familyId, {
    required String description,
    required int valueCents,
  }) async {
    if (nextResult is Err) return nextResult;
    _rules.add(
      Rule(
        id: 'n${_nextId++}',
        description: description.trim(),
        valueCents: valueCents,
      ),
    );
    _emit();
    return nextResult;
  }

  @override
  Future<Result<void>> updateRule(String familyId, Rule rule) async {
    if (nextResult is Err) return nextResult;
    final index = _rules.indexWhere((r) => r.id == rule.id);
    if (index >= 0) _rules[index] = rule;
    _emit();
    return nextResult;
  }

  @override
  Future<Result<void>> deleteRule(String familyId, String ruleId) async {
    deleteCalls++;
    if (nextResult is Err) return nextResult;
    _rules.removeWhere((r) => r.id == ruleId);
    _emit();
    return nextResult;
  }

  @override
  Future<Result<void>> reorder(String familyId, List<String> orderedIds) async {
    lastReorder = orderedIds;
    if (nextResult is Err) return nextResult;
    final byId = {for (final r in _rules) r.id: r};
    _rules
      ..clear()
      ..addAll([for (final id in orderedIds) byId[id]!]);
    _emit();
    return nextResult;
  }

  @override
  Future<Result<void>> addSuggestions(
    String familyId,
    List<RuleSeed> seeds,
  ) async {
    if (nextResult is Err) return nextResult;
    for (final seed in seeds) {
      _rules.add(
        Rule(
          id: 'n${_nextId++}',
          description: seed.description,
          valueCents: seed.valueCents,
        ),
      );
    }
    _emit();
    return nextResult;
  }
}

/// Filhos em memória, na ordem da lista; cada mudança é emitida no stream.
class FakeChildrenRepository implements ChildrenRepository {
  FakeChildrenRepository({List<Child> children = const []})
    : _children = [...children];

  final List<Child> _children;
  final _changes = StreamController<List<Child>>.broadcast();
  int _nextId = 1;

  Result<void> nextResult = const Ok(null);
  List<String>? lastReorder;
  int deleteCalls = 0;

  List<Child> get children => List.unmodifiable(_children);

  void _emit() => _changes.add(List.unmodifiable(_children));

  @override
  Stream<List<Child>> watchChildren(String familyId) async* {
    yield List.unmodifiable(_children);
    yield* _changes.stream;
  }

  @override
  Future<Result<String>> addChild(
    String familyId, {
    required String name,
    required String email,
    required int allowanceCents,
  }) async {
    final failed = nextResult;
    if (failed is Err) return Err(failed.failure);
    final id = 'c${_nextId++}';
    _children.add(
      Child(
        id: id,
        name: name.trim(),
        email: email.trim(),
        allowanceCents: allowanceCents,
      ),
    );
    _emit();
    return Ok(id);
  }

  @override
  Future<Result<void>> updateChild(String familyId, Child child) async {
    if (nextResult is Err) return nextResult;
    final index = _children.indexWhere((c) => c.id == child.id);
    if (index >= 0) _children[index] = child;
    _emit();
    return nextResult;
  }

  @override
  Future<Result<void>> deleteChild(String familyId, String childId) async {
    deleteCalls++;
    if (nextResult is Err) return nextResult;
    _children.removeWhere((c) => c.id == childId);
    _emit();
    return nextResult;
  }

  @override
  Future<Result<void>> reorder(String familyId, List<String> orderedIds) async {
    lastReorder = orderedIds;
    if (nextResult is Err) return nextResult;
    final byId = {for (final c in _children) c.id: c};
    _children
      ..clear()
      ..addAll([for (final id in orderedIds) byId[id]!]);
    _emit();
    return nextResult;
  }
}

class FakeLedgerRepository implements LedgerRepository {
  FakeLedgerRepository({List<Entry> entries = const []})
    : _entries = [...entries];

  List<Entry> _entries;
  final _changes = StreamController<List<Entry>>.broadcast();

  set entries(List<Entry> value) {
    _entries = [...value];
    _changes.add(List.unmodifiable(_entries));
  }

  @override
  Stream<List<Entry>> watchEntries(String familyId) async* {
    yield List.unmodifiable(_entries);
    yield* _changes.stream;
  }
}

class FakePhotoStore implements ChildPhotoStore {
  FakePhotoStore({Map<String, String>? paths}) : paths = {...?paths};

  final Map<String, String> paths;
  final saved = <({String childId, String source})>[];
  final deleted = <String>[];

  @override
  Future<String?> photoPath(String childId) async => paths[childId];

  @override
  Future<void> savePhoto(String childId, String sourcePath) async {
    saved.add((childId: childId, source: sourcePath));
    paths[childId] = sourcePath;
  }

  @override
  Future<void> deletePhoto(String childId) async {
    deleted.add(childId);
    paths.remove(childId);
  }
}

class FakePhotoPicker implements PhotoPicker {
  /// O que a galeria "devolve" na próxima escolha (null = cancelou).
  String? next;

  @override
  Future<String?> pickFromGallery() async => next;
}
