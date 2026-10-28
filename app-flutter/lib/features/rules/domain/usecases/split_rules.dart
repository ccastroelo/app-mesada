import '../entities/rule.dart';

/// Regras separadas em recompensas (valor > 0) e descontos (valor ≤ 0), cada
/// grupo na ordem original da lista.
class RuleGroups {
  const RuleGroups({required this.rewards, required this.discounts});

  final List<Rule> rewards;
  final List<Rule> discounts;

  bool get isEmpty => rewards.isEmpty && discounts.isEmpty;
}

RuleGroups splitRules(Iterable<Rule> rules) {
  return RuleGroups(
    rewards: [
      for (final rule in rules)
        if (rule.isReward) rule,
    ],
    discounts: [
      for (final rule in rules)
        if (rule.isDiscount) rule,
    ],
  );
}
