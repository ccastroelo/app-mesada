import 'dart:async';

import 'package:mesada/core/error/failure.dart';
import 'package:mesada/core/error/result.dart';
import 'package:mesada/features/app_lock/app_lock.dart';
import 'package:mesada/features/auth_family/domain/entities/app_user.dart';
import 'package:mesada/features/auth_family/domain/entities/family.dart';
import 'package:mesada/features/auth_family/domain/entities/family_snapshot.dart';
import 'package:mesada/features/auth_family/domain/repositories/auth_repository.dart';
import 'package:mesada/features/auth_family/domain/repositories/family_repository.dart';
import 'package:mesada/features/auth_family/domain/usecases/invite_code.dart';
import 'package:mesada/features/children/children.dart';
import 'package:mesada/features/entitlement/entitlement.dart';
import 'package:mesada/features/help/help.dart';
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

  /// O que a virada para a nuvem mandou subir (ADR-0014).
  ({
    List<Map<String, dynamic>> children,
    List<Map<String, dynamic>> rules,
    List<Map<String, dynamic>> entries,
  })?
  uploaded;

  @override
  Future<Result<void>> createFamilyFromLocal({
    required AppUser user,
    required String name,
    required List<Map<String, dynamic>> children,
    required List<Map<String, dynamic>> rules,
    required List<Map<String, dynamic>> entries,
  }) async {
    lastName = name;
    uploaded = (children: children, rules: rules, entries: entries);
    final error = createError;
    if (error != null) return error;
    _set(Family(id: 'f1', name: name));
    return const Ok(null);
  }

  /// O retrato que a "nuvem" devolve; o teste troca por outro se quiser.
  FamilySnapshot snapshot = const FamilySnapshot(
    name: '',
    children: [],
    rules: [],
    entries: [],
  );
  Failure? snapshotFailure;
  final downloads = <String>[];

  @override
  Future<Result<FamilySnapshot>> downloadSnapshot(String familyId) async {
    downloads.add(familyId);
    final failure = snapshotFailure;
    return failure == null ? Ok(snapshot) : Err(failure);
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

/// Lançamentos em memória, com as mesmas regras do repositório de verdade:
/// o par filho × regra nasce no primeiro toque e a quantidade tem piso 0.
class FakeLedgerRepository implements LedgerRepository {
  FakeLedgerRepository({List<Entry> entries = const []})
    : _entries = [...entries];

  List<Entry> _entries;
  final _changes = StreamController<List<Entry>>.broadcast();

  /// Resultado devolvido por todas as escritas (para simular falha).
  Result<void> nextResult = const Ok(null);
  final calls = <String>[];

  List<Entry> get entries => List.unmodifiable(_entries);

  set entries(List<Entry> value) {
    _entries = [...value];
    _emit();
  }

  void _emit() => _changes.add(List.unmodifiable(_entries));

  @override
  Stream<List<Entry>> watchEntries(String familyId) async* {
    yield List.unmodifiable(_entries);
    yield* _changes.stream;
  }

  Future<Result<void>> _change(
    String call,
    String childId,
    String ruleId,
    Entry Function(Entry) change,
  ) async {
    calls.add(call);
    if (nextResult is Err) return nextResult;
    final index = _entries.indexWhere(
      (entry) => entry.childId == childId && entry.ruleId == ruleId,
    );
    final current = index >= 0
        ? _entries[index]
        : Entry(childId: childId, ruleId: ruleId);
    final next = change(current);
    if (index >= 0) {
      _entries[index] = next;
    } else {
      _entries.add(next);
    }
    _emit();
    return nextResult;
  }

  @override
  Future<Result<void>> increment(
    String familyId, {
    required String childId,
    required String ruleId,
  }) => _change(
    'increment:${childId}_$ruleId',
    childId,
    ruleId,
    (entry) => entry.increment(),
  );

  @override
  Future<Result<void>> decrement(
    String familyId, {
    required String childId,
    required String ruleId,
  }) => _change(
    'decrement:${childId}_$ruleId',
    childId,
    ruleId,
    (entry) => entry.decrement(),
  );

  @override
  Future<Result<void>> setEnabled(
    String familyId, {
    required String childId,
    required String ruleId,
    required bool enabled,
  }) => _change(
    'setEnabled:${childId}_$ruleId:$enabled',
    childId,
    ruleId,
    (entry) => entry.copyWith(enabled: enabled),
  );

  @override
  Future<Result<void>> zero(String familyId, {String? childId}) async {
    calls.add('zero:${childId ?? 'todos'}');
    if (nextResult is Err) return nextResult;
    _entries = [
      for (final entry in _entries)
        if (childId == null || entry.childId == childId)
          entry.zeroed()
        else
          entry,
    ];
    _emit();
    return nextResult;
  }

  @override
  Future<Result<void>> restore(String familyId, Iterable<Entry> entries) async {
    calls.add('restore:${entries.length}');
    if (nextResult is Err) return nextResult;
    final byId = {for (final entry in entries) entry.id: entry};
    _entries = [
      for (final entry in _entries)
        if (byId[entry.id] case final previous?)
          entry.copyWith(quantity: previous.quantity)
        else
          entry,
    ];
    _emit();
    return nextResult;
  }
}

/// Guarda o documento em vez de gerar PDF e abrir a folha do sistema.
class FakeReportSharer implements ReportSharer {
  final shared = <ReportDocument>[];
  Result<void> nextResult = const Ok(null);

  ReportDocument get last => shared.last;

  @override
  Future<Result<void>> share(ReportDocument document) async {
    shared.add(document);
    return nextResult;
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

/// PIN e biometria em memória, com acesso ao que foi guardado.
class FakePinStore implements PinStore {
  PinCredential? credential;
  bool biometricsEnabled = false;
  PinRecovery? recovery;
  String? installId;

  @override
  Future<PinCredential?> read() async => credential;

  @override
  Future<void> save(PinCredential value) async => credential = value;

  @override
  Future<void> clear() async {
    credential = null;
    biometricsEnabled = false;
    recovery = null;
  }

  @override
  Future<PinRecovery?> readRecovery() async => recovery;

  @override
  Future<void> saveRecovery(PinRecovery value) async => recovery = value;

  @override
  Future<String> readOrCreateInstallId() async =>
      installId ??= '0123456789abcdef0123456789abcdef';

  @override
  Future<bool> readBiometricsEnabled() async => biometricsEnabled;

  @override
  Future<void> saveBiometricsEnabled(bool enabled) async =>
      biometricsEnabled = enabled;
}

/// O servidor do "esqueci o PIN" em memória: o teste diz se há servidor, se o
/// envio passa e guarda o que seria enviado.
class FakePinRecoveryService implements PinRecoveryService {
  FakePinRecoveryService({this.available = true});

  @override
  bool available;

  /// Falha devolvida pelas próximas chamadas (null = tudo certo).
  Failure? failure;

  final registered = <({String email, String installId, String locale})>[];
  final sent = <({String email, String token, String pin, String locale})>[];

  @override
  Future<Result<String>> register({
    required String email,
    required String installId,
    required String locale,
  }) async {
    final error = failure;
    if (error != null) return Err(error);
    registered.add((email: email, installId: installId, locale: locale));
    return const Ok('token-de-teste');
  }

  @override
  Future<Result<void>> sendNewPin({
    required String email,
    required String installId,
    required String token,
    required String pin,
    required String locale,
  }) async {
    final error = failure;
    if (error != null) return Err(error);
    sent.add((email: email, token: token, pin: pin, locale: locale));
    return const Ok(null);
  }
}

/// Biometria falsa: o teste diz se o aparelho tem e se reconhece.
class FakeBiometricAuth implements BiometricAuth {
  FakeBiometricAuth({this.available = true, this.recognizes = true});

  bool available;
  bool recognizes;
  final reasons = <String>[];

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate(String reason) async {
    reasons.add(reason);
    return recognizes;
  }
}

/// Marca da introdução em memória.
class FakeIntroStore implements IntroStore {
  FakeIntroStore({this.wasSeen = true});

  bool wasSeen;

  @override
  Future<bool> seen() async => wasSeen;

  @override
  Future<void> markSeen() async => wasSeen = true;
}

/// Marca do app em memória (ADR-0021).
class FakeEntitlementStore implements EntitlementStore {
  FakeEntitlementStore({this.entitlement});

  AppEntitlement? entitlement;
  int saves = 0;

  @override
  Future<AppEntitlement?> read() async => entitlement;

  @override
  Future<void> save(AppEntitlement value) async {
    saves++;
    entitlement = value;
  }
}

/// Detector do app antigo: o teste diz se havia rastro dele no aparelho.
class FakeLegacyDetector implements LegacyAppDetector {
  FakeLegacyDetector({this.found = false});

  bool found;

  @override
  Future<bool> existed() async => found;
}

/// A loja em memória: o teste diz o preço, se a compra passa e o que
/// "restaurar" encontra.
class FakeStoreGateway implements StoreGateway {
  FakeStoreGateway({
    this.prices = const {
      StoreProduct.app: 'R\$ 19,90',
      StoreProduct.sharing: 'R\$ 9,90',
    },
    this.buyResult = true,
    this.restorable = const {},
  });

  /// Produtos que a loja tem à venda, com o preço já formatado.
  Map<StoreProduct, String> prices;

  /// O que acontece quando a pessoa confirma a compra.
  bool buyResult;

  /// O que a conta da loja já tem (devolvido por "Restaurar compras").
  Set<StoreProduct> restorable;

  final bought = <StoreProduct>[];
  int restores = 0;

  @override
  Future<StoreOffer?> offer(StoreProduct product) async {
    final price = prices[product];
    return price == null ? null : StoreOffer(product: product, price: price);
  }

  @override
  Future<bool> buy(StoreProduct product) async {
    bought.add(product);
    return buyResult;
  }

  @override
  Future<Set<StoreProduct>> restore() async {
    restores++;
    return restorable;
  }

  /// O que o validador reconhece agora. **Null é "não sei"** (ADR-0022), e é
  /// o padrão: a maioria dos testes não fala de assinatura.
  Set<StoreProduct>? activeNow;

  /// Em nome de quem o validador foi consultado, na ordem.
  final owners = <String?>[];

  @override
  Future<Set<StoreProduct>?> active() async => activeNow;

  @override
  Future<void> useFamily(String? familyId) async => owners.add(familyId);
}

/// A cópia local das compras, em memória.
class FakePurchaseStore implements PurchaseStore {
  FakePurchaseStore({Iterable<PurchaseRecord> records = const []})
    : records = {for (final record in records) record.product: record};

  /// O aparelho de quem já comprou o app: padrão do `pumpApp`, para a faixa
  /// de teste não entrar no caminho dos outros testes.
  factory FakePurchaseStore.ownsApp() => FakePurchaseStore(
    records: [
      PurchaseRecord(product: StoreProduct.app, since: DateTime(2026, 1, 1)),
    ],
  );

  final Map<StoreProduct, PurchaseRecord> records;

  @override
  Future<Map<StoreProduct, PurchaseRecord>> read() async => {...records};

  @override
  Future<void> save(PurchaseRecord record) async {
    records[record.product] = record;
  }

  /// A marca de que a volta ao local foi por vencimento da assinatura.
  bool lapsed = false;

  @override
  Future<bool> sharingLapsed() async => lapsed;

  @override
  Future<void> setSharingLapsed(bool value) async => lapsed = value;
}
