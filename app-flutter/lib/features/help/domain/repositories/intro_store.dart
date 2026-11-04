/// Se a introdução já foi vista. É ajuste **do aparelho**: cada responsável
/// vê a sua uma vez (design.md §4.9).
abstract class IntroStore {
  Future<bool> seen();

  Future<void> markSeen();
}
