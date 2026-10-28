import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/rule.dart';
import '../../domain/usecases/split_rules.dart';
import '../state/rules_state.dart';

enum _RuleMenu { edit, delete }

class RulesPage extends ConsumerStatefulWidget {
  const RulesPage({super.key});

  @override
  ConsumerState<RulesPage> createState() => _RulesPageState();
}

class _RulesPageState extends ConsumerState<RulesPage> {
  /// Lista em edição quando está no modo Reordenar; null fora dele.
  List<Rule>? _working;

  bool get _reordering => _working != null;

  Future<void> _finishReorder(List<Rule> original) async {
    final working = _working!;
    final changed =
        working.length != original.length ||
        [for (final r in working) r.id].join() !=
            [for (final r in original) r.id].join();
    if (changed) {
      final ok = await ref.read(rulesActionsProvider.notifier).reorder([
        for (final r in working) r.id,
      ]);
      if (!ok) return;
    }
    if (mounted) setState(() => _working = null);
  }

  Future<void> _confirmDelete(Rule rule) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRuleTitle(rule.description)),
        content: Text(l10n.deleteRuleBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ok = await ref.read(rulesActionsProvider.notifier).delete(rule.id);
    if (ok && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.ruleDeleted)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rules = ref.watch(rulesProvider);
    final action = ref.watch(rulesActionsProvider);
    final list = rules.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navRules),
        actions: [
          if (list != null && list.length > 1)
            _reordering
                ? TextButton(
                    onPressed: action.loading
                        ? null
                        : () => _finishReorder(list),
                    child: Text(l10n.doneAction),
                  )
                : IconButton(
                    tooltip: l10n.reorderAction,
                    icon: const Icon(Icons.swap_vert),
                    onPressed: () => setState(() => _working = [...list]),
                  ),
        ],
      ),
      floatingActionButton: _reordering
          ? null
          : FloatingActionButton.extended(
              // As abas ficam vivas juntas (IndexedStack): sem tag única para
              // não colidir com o botão da aba Filhos na transição de tela.
              heroTag: null,
              onPressed: () => context.push('/regras/nova'),
              icon: const Icon(Icons.add),
              label: Text(l10n.newRuleAction),
            ),
      body: rules.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            ErrorState(onRetry: () => ref.invalidate(rulesProvider)),
        data: (data) {
          if (data.isEmpty) return const _EmptyRules();
          return Column(
            children: [
              if (action.failure != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.lg),
                  child: FailureText(action.failure),
                ),
              Expanded(
                child: _reordering
                    ? _ReorderList(
                        rules: _working!,
                        onChanged: (next) => setState(() => _working = next),
                      )
                    : _GroupedList(
                        rules: data,
                        onEdit: (rule) =>
                            context.push('/regras/${rule.id}/editar'),
                        onDelete: _confirmDelete,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyRules extends ConsumerWidget {
  const _EmptyRules();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final action = ref.watch(rulesActionsProvider);
    return Column(
      children: [
        Expanded(
          child: EmptyState(
            icon: Icons.checklist_outlined,
            title: l10n.rulesEmptyTitle,
            body: l10n.rulesEmptyBody,
            actionLabel: l10n.useSuggestionsAction,
            onAction: action.loading
                ? null
                : () => ref
                      .read(rulesActionsProvider.notifier)
                      .addSuggestions(
                        Localizations.localeOf(context).languageCode,
                      ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(Space.lg),
          child: FailureText(action.failure),
        ),
      ],
    );
  }
}

class _GroupedList extends StatelessWidget {
  const _GroupedList({
    required this.rules,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Rule> rules;
  final void Function(Rule) onEdit;
  final void Function(Rule) onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groups = splitRules(rules);
    return ListView(
      // Folga para o botão flutuante não cobrir a última linha.
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        if (groups.rewards.isNotEmpty) ...[
          SectionHeader(l10n.rulesRewardsSection),
          for (final rule in groups.rewards)
            _RuleTile(rule: rule, onEdit: onEdit, onDelete: onDelete),
        ],
        if (groups.discounts.isNotEmpty) ...[
          SectionHeader(l10n.rulesDiscountsSection),
          for (final rule in groups.discounts)
            _RuleTile(rule: rule, onEdit: onEdit, onDelete: onDelete),
        ],
      ],
    );
  }
}

class _RuleTile extends StatelessWidget {
  const _RuleTile({
    required this.rule,
    required this.onEdit,
    required this.onDelete,
  });

  final Rule rule;
  final void Function(Rule) onEdit;
  final void Function(Rule) onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: RuleKindIcon(rule: rule),
      title: Text(rule.description),
      subtitle: Text(ruleSubtitle(context, rule)),
      trailing: PopupMenuButton<_RuleMenu>(
        onSelected: (item) => switch (item) {
          _RuleMenu.edit => onEdit(rule),
          _RuleMenu.delete => onDelete(rule),
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: _RuleMenu.edit, child: Text(l10n.editAction)),
          PopupMenuItem(
            value: _RuleMenu.delete,
            child: Text(l10n.deleteAction),
          ),
        ],
      ),
      onTap: () => onEdit(rule),
    );
  }
}

class _ReorderList extends StatelessWidget {
  const _ReorderList({required this.rules, required this.onChanged});

  final List<Rule> rules;
  final ValueChanged<List<Rule>> onChanged;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.only(bottom: Space.xl),
      itemCount: rules.length,
      onReorderItem: (oldIndex, newIndex) {
        final next = [...rules];
        next.insert(newIndex, next.removeAt(oldIndex));
        onChanged(next);
      },
      itemBuilder: (context, index) {
        final rule = rules[index];
        return ListTile(
          key: ValueKey(rule.id),
          leading: RuleKindIcon(rule: rule),
          title: Text(rule.description),
          subtitle: Text(ruleSubtitle(context, rule)),
          trailing: ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.all(Space.md),
              child: Icon(Icons.drag_handle),
            ),
          ),
        );
      },
    );
  }
}

/// Seta para cima (recompensa, verde) ou para baixo (desconto, vermelho):
/// a cor nunca é o único sinal (design.md §1).
class RuleKindIcon extends StatelessWidget {
  const RuleKindIcon({super.key, required this.rule});

  final Rule rule;

  @override
  Widget build(BuildContext context) {
    final colors = context.mesadaColors;
    return ExcludeSemantics(
      child: Icon(
        rule.isReward ? Icons.trending_up : Icons.trending_down,
        color: rule.isReward ? colors.positive : colors.negative,
      ),
    );
  }
}

/// "Recompensa · +R$ 0,50" / "Desconto · −R$ 0,50".
String ruleSubtitle(BuildContext context, Rule rule) {
  final l10n = AppLocalizations.of(context);
  final value = formatCents(
    rule.valueCents,
    locale: Localizations.localeOf(context).toString(),
    signed: true,
  );
  return rule.isReward
      ? l10n.ruleSubtitleReward(value)
      : l10n.ruleSubtitleDiscount(value);
}
