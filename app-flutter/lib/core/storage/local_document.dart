/// O documento inteiro guardado no aparelho (ADR-0014).
///
/// As fatias ficam em JSON cru, com os **mesmos campos do Firestore**, para o
/// envio na assinatura (M4.5) ser uma tradução direta. Quem traduz para
/// entidade é a camada `data` de cada feature, pelos DTOs que já existem.
class LocalDocument {
  const LocalDocument({
    required this.family,
    this.children = const [],
    this.rules = const [],
    this.entries = const [],
  });

  /// Arquivo vindo do disco: é borda, então todo campo ausente ou com tipo
  /// errado cai no padrão em vez de derrubar o app.
  factory LocalDocument.fromJson(Map<String, dynamic> json) {
    return LocalDocument(
      family: _map(json['family']) ?? _initialFamily(),
      children: _mapList(json['children']),
      rules: _mapList(json['rules']),
      entries: _mapList(json['entries']),
    );
  }

  /// Primeira abertura: uma família local sem nome. O nome só é pedido ao
  /// assinar (ADR-0015); até lá a tela mostra o padrão do idioma.
  factory LocalDocument.initial() => LocalDocument(family: _initialFamily());

  /// Sobe junto no arquivo. A migração entra quando existir uma versão 2.
  static const schemaVersion = 1;

  /// Id da família enquanto os dados são só do aparelho.
  static const localFamilyId = 'local';

  final Map<String, dynamic> family;
  final List<Map<String, dynamic>> children;
  final List<Map<String, dynamic>> rules;
  final List<Map<String, dynamic>> entries;

  String get familyId => family['id'] as String? ?? localFamilyId;

  LocalDocument copyWith({
    Map<String, dynamic>? family,
    List<Map<String, dynamic>>? children,
    List<Map<String, dynamic>>? rules,
    List<Map<String, dynamic>>? entries,
  }) {
    return LocalDocument(
      family: family ?? this.family,
      children: children ?? this.children,
      rules: rules ?? this.rules,
      entries: entries ?? this.entries,
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'family': family,
    'children': children,
    'rules': rules,
    'entries': entries,
  };

  static Map<String, dynamic> _initialFamily() => {
    'id': localFamilyId,
    'name': '',
  };

  static Map<String, dynamic>? _map(Object? value) =>
      value is Map ? {...value.cast<String, dynamic>()} : null;

  static List<Map<String, dynamic>> _mapList(Object? value) {
    if (value is! List) return const [];
    return [for (final item in value) ?_map(item)];
  }
}
