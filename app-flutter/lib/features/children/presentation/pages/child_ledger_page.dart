import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
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
import '../../../ledger/ledger.dart';
import '../../../ledger/ledger_providers.dart';
import '../../../rules/rules.dart';
import '../../../rules/rules_providers.dart';
import '../state/child_ledger_state.dart';
import '../state/children_state.dart';
import '../widgets/child_avatar.dart';

/// A partir desta escala de texto o stepper desce para uma segunda linha
/// (design.md §4.4).
const _stackedTextScale = 1.3;

enum _LedgerMenu { zero, rules }

/// Tela do filho: lançar ± por regra, ver o saldo mudar na hora e zerar.
/// A tela mais usada do app (design.md §4.4).
class ChildLedgerPage extends ConsumerStatefulWidget {
  const ChildLedgerPage({super.key, required this.childId});

  final String childId;

  @override
  ConsumerState<ChildLedgerPage> createState() => _ChildLedgerPageState();
}

class _ChildLedgerPageState extends ConsumerState<ChildLedgerPage> {
  /// Último lançamento, para o chip junto ao saldo; ele some em 1 s.
  int _lastDelta = 0;
  bool _chipVisible = false;
  Timer? _chipTimer;

  @override
  void dispose() {
    _chipTimer?.cancel();
    super.dispose();
  }

  Future<void> _launch(LedgerRow row, {required bool increase}) async {
    final actions = ref.read(ledgerActionsProvider.notifier);
    // Sem await: o retorno vem da plataforma e o lançamento não espera por ele.
    unawaited(HapticFeedback.selectionClick());
    final ok = increase
        ? await actions.increment(childId: widget.childId, ruleId: row.rule.id)
        : await actions.decrement(childId: widget.childId, ruleId: row.rule.id);
    if (!ok || !mounted) return;

    _chipTimer?.cancel();
    setState(() {
      _lastDelta = increase ? row.rule.valueCents : -row.rule.valueCents;
      _chipVisible = true;
    });
    _chipTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => _chipVisible = false);
    });
    _announceBalance();
  }

  /// O saldo é o que importa depois de lançar, e ele fica longe do botão.
  void _announceBalance() {
    final balanceCents = ref
        .read(childLedgerProvider(widget.childId))
        .value
        ?.balanceCents;
    if (balanceCents == null) return;
    final locale = Localizations.localeOf(context).toString();
    SemanticsService.sendAnnouncement(
      View.of(context),
      AppLocalizations.of(
        context,
      ).balanceSemantics(formatCents(balanceCents, locale: locale)),
      Directionality.of(context),
    );
  }

  Future<void> _confirmZero(ChildLedger ledger) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.zeroChildTitle(ledger.child.name)),
        content: Text(l10n.zeroBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.zeroAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final actions = ref.read(ledgerActionsProvider.notifier);
    final previous = await actions.zero(childId: widget.childId);
    // Nulo = falhou; o texto do erro aparece acima da lista.
    if (previous == null || !mounted) return;
    showZeroedSnackBar(context, previous: previous, actions: actions);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ledger = ref.watch(childLedgerProvider(widget.childId));
    final action = ref.watch(ledgerActionsProvider);
    final data = ledger.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(data?.child.name ?? ''),
        actions: [
          if (data != null)
            PopupMenuButton<_LedgerMenu>(
              onSelected: (item) => switch (item) {
                _LedgerMenu.zero => _confirmZero(data),
                _LedgerMenu.rules => context.push(
                  '/filhos/${widget.childId}/regras',
                ),
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _LedgerMenu.zero,
                  child: Text(l10n.childLedgerZeroMenu),
                ),
                PopupMenuItem(
                  value: _LedgerMenu.rules,
                  child: Text(l10n.childRulesMenu),
                ),
              ],
            ),
        ],
      ),
      body: ledger.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => ErrorState(
          onRetry: () {
            ref.invalidate(childrenProvider);
            ref.invalidate(rulesProvider);
            ref.invalidate(entriesProvider);
          },
        ),
        data: (data) => SafeArea(
          child: Column(
            children: [
              _Header(
                ledger: data,
                deltaCents: _lastDelta,
                chipVisible: _chipVisible,
              ),
              if (action.failure != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.lg),
                  child: FailureText(action.failure),
                ),
              Expanded(child: data.hasActiveRows ? _rows(data) : _empty(data)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rows(ChildLedger data) {
    final l10n = AppLocalizations.of(context);
    final rewards = data.rewards;
    final discounts = data.discounts;
    return ListView(
      padding: const EdgeInsets.only(bottom: Space.xl),
      children: [
        if (rewards.isNotEmpty) ...[
          SectionHeader(l10n.rulesRewardsSection),
          for (final row in rewards) _rowTile(row),
        ],
        if (discounts.isNotEmpty) ...[
          SectionHeader(l10n.rulesDiscountsSection),
          for (final row in discounts) _rowTile(row),
        ],
      ],
    );
  }

  Widget _rowTile(LedgerRow row) => _LedgerRowTile(
    key: ValueKey(row.rule.id),
    row: row,
    onIncrease: () => _launch(row, increase: true),
    onDecrease: () => _launch(row, increase: false),
  );

  Widget _empty(ChildLedger data) {
    final l10n = AppLocalizations.of(context);
    if (data.rows.isEmpty) {
      return EmptyState(
        icon: Icons.rule_outlined,
        title: l10n.childLedgerEmptyTitle,
        body: l10n.childLedgerEmptyBody,
      );
    }
    // Existem regras, mas todas desativadas para este filho (ADR-0008).
    return EmptyState(
      icon: Icons.toggle_off_outlined,
      title: l10n.childLedgerAllOffTitle(data.child.name),
      actionLabel: l10n.childRulesMenu,
      onAction: () => context.push('/filhos/${widget.childId}/regras'),
    );
  }
}

/// Snackbar "Lançamentos zerados · Desfazer" por 8 s (design.md §5).
/// Compartilhada com a aba Filhos, que zera os lançamentos de todos.
void showZeroedSnackBar(
  BuildContext context, {
  required List<Entry> previous,
  required LedgerActions actions,
}) {
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(l10n.entriesZeroed),
        duration: const Duration(seconds: 8),
        action: previous.isEmpty
            ? null
            : SnackBarAction(
                label: l10n.undoAction,
                onPressed: () => actions.restore(previous),
              ),
      ),
    );
}

/// Cabeçalho fixo: avatar, mesada e saldo grande, com o chip do último
/// lançamento ("+R$ 0,50") ao lado.
class _Header extends StatelessWidget {
  const _Header({
    required this.ledger,
    required this.deltaCents,
    required this.chipVisible,
  });

  final ChildLedger ledger;
  final int deltaCents;
  final bool chipVisible;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.mesadaColors;
    final locale = Localizations.localeOf(context).toString();
    final child = ledger.child;
    final negative = ledger.balanceCents < 0;
    final balance = formatCents(ledger.balanceCents, locale: locale);

    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.lg, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChildAvatar(childId: child.id, name: child.name, radius: 24),
          const SizedBox(width: Space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.childAllowanceSubtitle(
                    formatCents(child.allowanceCents, locale: locale),
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  l10n.balanceLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Wrap(
                  spacing: Space.sm,
                  runSpacing: Space.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Semantics(
                      label: l10n.balanceSemantics(balance),
                      excludeSemantics: true,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            negative ? Icons.trending_down : Icons.trending_up,
                            size: 20,
                            color: negative ? colors.negative : colors.positive,
                          ),
                          const SizedBox(width: Space.xs),
                          // Flexível: em fonte grande o saldo quebra em vez de
                          // estourar a linha.
                          Flexible(
                            child: Text(
                              balance,
                              style: theme.textTheme.headlineMedium?.copyWith(
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
                    ),
                    _DeltaChip(cents: deltaCents, visible: chipVisible),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.cents, required this.visible});

  final int cents;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.mesadaColors;
    final locale = Localizations.localeOf(context).toString();
    final positive = cents >= 0;
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        // "Reduzir movimento" do sistema desliga a transição (design.md §6).
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 250),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.sm,
            vertical: Space.xs,
          ),
          decoration: BoxDecoration(
            color: (positive ? colors.positive : colors.negative).withValues(
              alpha: 0.15,
            ),
            borderRadius: BorderRadius.circular(Radii.card),
          ),
          child: Text(
            formatCents(cents, locale: locale, signed: true),
            style: theme.textTheme.labelLarge?.copyWith(
              color: positive ? colors.positive : colors.negative,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

/// `descrição · valor  [ − ]  qtd  [ + ]`. Em fonte grande o stepper desce
/// para a linha de baixo, em vez de espremer o texto.
class _LedgerRowTile extends StatelessWidget {
  const _LedgerRowTile({
    super.key,
    required this.row,
    required this.onIncrease,
    required this.onDecrease,
  });

  final LedgerRow row;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(100) / 100;
    final stacked = scale >= _stackedTextScale;
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(row.rule.description, style: theme.textTheme.bodyLarge),
        Row(
          children: [
            _RuleKindIcon(rule: row.rule, size: 16),
            const SizedBox(width: Space.xs),
            Flexible(child: Text(_value(context, row.rule))),
          ],
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.lg,
        vertical: Space.sm,
      ),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text,
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: _Stepper(
                    row: row,
                    onIncrease: onIncrease,
                    onDecrease: onDecrease,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(child: text),
                _Stepper(
                  row: row,
                  onIncrease: onIncrease,
                  onDecrease: onDecrease,
                ),
              ],
            ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.row,
    required this.onIncrease,
    required this.onDecrease,
  });

  final LedgerRow row;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final description = row.rule.description;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          // Rótulo do leitor de tela e dica no toque longo.
          tooltip: l10n.decreaseSemantics(description, row.quantity),
          icon: const Icon(Icons.remove_circle_outline),
          // Piso 0, como no legado (`imLanVC.m:119`).
          onPressed: row.quantity == 0 ? null : onDecrease,
        ),
        Text(
          '${row.quantity}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        IconButton(
          tooltip: l10n.increaseSemantics(description, row.quantity),
          icon: const Icon(Icons.add_circle_outline),
          onPressed: onIncrease,
        ),
      ],
    );
  }
}

/// Gêmeo do `RuleKindIcon` da aba Regras: uma feature não importa a tela da
/// outra (só domínio e estado, pelos barris).
class _RuleKindIcon extends StatelessWidget {
  const _RuleKindIcon({required this.rule, this.size});

  final Rule rule;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final colors = context.mesadaColors;
    return ExcludeSemantics(
      child: Icon(
        rule.isReward ? Icons.trending_up : Icons.trending_down,
        size: size,
        color: rule.isReward ? colors.positive : colors.negative,
      ),
    );
  }
}

String _value(BuildContext context, Rule rule) => formatCents(
  rule.valueCents,
  locale: Localizations.localeOf(context).toString(),
  signed: true,
);
