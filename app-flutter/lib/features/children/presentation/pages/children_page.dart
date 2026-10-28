import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/child.dart';
import '../state/children_state.dart';
import '../widgets/child_avatar.dart';

enum _ChildMenu { edit, delete }

class ChildrenPage extends ConsumerStatefulWidget {
  const ChildrenPage({super.key});

  @override
  ConsumerState<ChildrenPage> createState() => _ChildrenPageState();
}

class _ChildrenPageState extends ConsumerState<ChildrenPage> {
  /// Lista em edição quando está no modo Reordenar; null fora dele.
  List<Child>? _working;

  bool get _reordering => _working != null;

  Future<void> _finishReorder(List<Child> original) async {
    final working = _working!;
    final changed =
        [for (final c in working) c.id].join(',') !=
        [for (final c in original) c.id].join(',');
    if (changed) {
      final ok = await ref.read(childrenActionsProvider.notifier).reorder([
        for (final c in working) c.id,
      ]);
      if (!ok) return;
    }
    if (mounted) setState(() => _working = null);
  }

  Future<void> _confirmDelete(Child child) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteChildTitle(child.name)),
        content: Text(l10n.deleteChildBody),
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
    final ok = await ref
        .read(childrenActionsProvider.notifier)
        .delete(child.id);
    if (ok && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.childDeleted)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summaries = ref.watch(childSummariesProvider);
    final action = ref.watch(childrenActionsProvider);
    final list = summaries.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navChildren),
        actions: [
          if (list != null && list.length > 1)
            _reordering
                ? TextButton(
                    onPressed: action.loading
                        ? null
                        : () => _finishReorder([for (final s in list) s.child]),
                    child: Text(l10n.doneAction),
                  )
                : IconButton(
                    tooltip: l10n.reorderAction,
                    icon: const Icon(Icons.swap_vert),
                    onPressed: () => setState(
                      () => _working = [for (final s in list) s.child],
                    ),
                  ),
        ],
      ),
      floatingActionButton: _reordering
          ? null
          : FloatingActionButton.extended(
              // As abas ficam vivas juntas (IndexedStack): sem tag única para
              // não colidir com o botão da aba Regras na transição de tela.
              heroTag: null,
              onPressed: () => context.push('/filhos/novo'),
              icon: const Icon(Icons.add),
              label: Text(l10n.addChildAction),
            ),
      body: summaries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => ErrorState(
          onRetry: () {
            ref.invalidate(childrenProvider);
            ref.invalidate(childSummariesProvider);
          },
        ),
        data: (data) {
          if (data.isEmpty) {
            return EmptyState(
              icon: Icons.child_care_outlined,
              title: l10n.childrenEmptyTitle,
              actionLabel: l10n.addChildAction,
              onAction: () => context.push('/filhos/novo'),
            );
          }
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
                        children: _working!,
                        onChanged: (next) => setState(() => _working = next),
                      )
                    : ListView.builder(
                        // Folga para o botão flutuante não cobrir o último cartão.
                        padding: const EdgeInsets.fromLTRB(
                          Space.lg,
                          Space.sm,
                          Space.lg,
                          88,
                        ),
                        itemCount: data.length,
                        itemBuilder: (context, index) => _ChildCard(
                          summary: data[index],
                          onEdit: (child) =>
                              context.push('/filhos/${child.id}/editar'),
                          onDelete: _confirmDelete,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({
    required this.summary,
    required this.onEdit,
    required this.onDelete,
  });

  final ChildSummary summary;
  final void Function(Child) onEdit;
  final void Function(Child) onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.mesadaColors;
    final locale = Localizations.localeOf(context).toString();
    final child = summary.child;
    final negative = summary.balanceCents < 0;
    final balance = formatCents(summary.balanceCents, locale: locale);
    final allowance = formatCents(child.allowanceCents, locale: locale);

    return Card(
      margin: const EdgeInsets.only(bottom: Space.md),
      child: Padding(
        padding: const EdgeInsets.all(Space.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChildAvatar(childId: child.id, name: child.name, radius: 28),
            const SizedBox(width: Space.md),
            Expanded(
              // Um só item para o leitor de tela: nome, mesada e saldo.
              child: Semantics(
                container: true,
                label:
                    '${child.name}, ${l10n.childAllowanceSubtitle(allowance)}, '
                    '${l10n.balanceSemantics(balance)}',
                excludeSemantics: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(child.name, style: theme.textTheme.titleMedium),
                    Text(
                      l10n.childAllowanceSubtitle(allowance),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Space.sm),
                    Text(
                      l10n.balanceLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          negative ? Icons.trending_down : Icons.trending_up,
                          size: 20,
                          color: negative ? colors.negative : colors.positive,
                        ),
                        const SizedBox(width: Space.xs),
                        Flexible(
                          child: Text(
                            balance,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: negative
                                  ? colors.negative
                                  : colors.positive,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            PopupMenuButton<_ChildMenu>(
              onSelected: (item) => switch (item) {
                _ChildMenu.edit => onEdit(child),
                _ChildMenu.delete => onDelete(child),
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _ChildMenu.edit,
                  child: Text(l10n.editAction),
                ),
                PopupMenuItem(
                  value: _ChildMenu.delete,
                  child: Text(l10n.deleteAction),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReorderList extends StatelessWidget {
  const _ReorderList({required this.children, required this.onChanged});

  final List<Child> children;
  final ValueChanged<List<Child>> onChanged;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.only(bottom: Space.xl),
      itemCount: children.length,
      onReorderItem: (oldIndex, newIndex) {
        final next = [...children];
        next.insert(newIndex, next.removeAt(oldIndex));
        onChanged(next);
      },
      itemBuilder: (context, index) {
        final child = children[index];
        return ListTile(
          key: ValueKey(child.id),
          leading: ChildAvatar(childId: child.id, name: child.name),
          title: Text(child.name),
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
