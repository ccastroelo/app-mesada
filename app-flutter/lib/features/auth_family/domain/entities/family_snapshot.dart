/// Uma cópia do conteúdo de uma família na nuvem, para virar o arquivo local
/// (o "retrato" do ADR-0014: ao deixar de compartilhar, baixa-se um retrato).
///
/// Só primitivos, com os mesmos campos do Firestore e do `mesada.json`, para
/// esta feature não depender das outras (como em `createFamilyFromLocal`).
/// Filhos e regras trazem o `id` do documento; lançamentos trazem `childId` e
/// `ruleId`.
class FamilySnapshot {
  const FamilySnapshot({
    required this.name,
    required this.children,
    required this.rules,
    required this.entries,
  });

  final String name;
  final List<Map<String, dynamic>> children;
  final List<Map<String, dynamic>> rules;
  final List<Map<String, dynamic>> entries;
}
