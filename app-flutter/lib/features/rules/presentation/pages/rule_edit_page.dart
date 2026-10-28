import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../core/widgets/money_field.dart';
import '../../../../core/widgets/page_body.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/rule.dart';
import '../state/rules_state.dart';

/// Teto de valor de uma regra: 999,99 (as regras do Firestore aceitam até
/// 99.999 centavos).
const maxRuleCents = 99999;

/// Cria (ruleId == null) ou edita uma regra.
class RuleEditPage extends ConsumerStatefulWidget {
  const RuleEditPage({super.key, this.ruleId});

  final String? ruleId;

  @override
  ConsumerState<RuleEditPage> createState() => _RuleEditPageState();
}

class _RuleEditPageState extends ConsumerState<RuleEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _value = TextEditingController();
  bool _isReward = false;
  bool _filled = false;

  @override
  void dispose() {
    _description.dispose();
    _value.dispose();
    super.dispose();
  }

  void _fill(Rule? rule) {
    final locale = Localizations.localeOf(context).toString();
    _description.text = rule?.description ?? '';
    _value.text = formatCentsPlain(rule?.valueCents ?? 0, locale: locale);
    _isReward = rule?.isReward ?? false;
    _filled = true;
  }

  Future<void> _save(Rule? existing) async {
    if (!_formKey.currentState!.validate()) return;
    final cents = centsFromMaskedText(_value.text);
    final valueCents = _isReward ? cents : -cents;
    final actions = ref.read(rulesActionsProvider.notifier);
    final ok = existing == null
        ? await actions.add(
            description: _description.text,
            valueCents: valueCents,
          )
        : await actions.update(
            existing.copyWith(
              description: _description.text,
              valueCents: valueCents,
            ),
          );
    if (ok && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final action = ref.watch(rulesActionsProvider);
    final editing = widget.ruleId != null;
    final rules = ref.watch(rulesProvider);

    Rule? existing;
    if (editing) {
      if (!rules.hasValue) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.editRuleTitle)),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      existing = rules.value!.where((r) => r.id == widget.ruleId).firstOrNull;
      if (existing == null) {
        // Outro responsável apagou esta regra enquanto a tela estava aberta.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.pop();
        });
        return const Scaffold(body: SizedBox.shrink());
      }
    }
    if (!_filled) _fill(existing);

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? l10n.editRuleTitle : l10n.newRuleTitle),
      ),
      body: PageBody(
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _description,
                  autofocus: !editing,
                  maxLength: 120,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.ruleDescriptionLabel,
                  ),
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? l10n.ruleDescriptionRequired
                      : null,
                ),
                const SizedBox(height: Space.md),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: false,
                      icon: const Icon(Icons.trending_down),
                      label: Text(l10n.ruleDiscountLabel),
                    ),
                    ButtonSegment(
                      value: true,
                      icon: const Icon(Icons.trending_up),
                      label: Text(l10n.ruleRewardLabel),
                    ),
                  ],
                  selected: {_isReward},
                  onSelectionChanged: (selection) =>
                      setState(() => _isReward = selection.first),
                ),
                const SizedBox(height: Space.md),
                MoneyField(
                  controller: _value,
                  label: l10n.ruleValueLabel,
                  maxCents: maxRuleCents,
                  onSubmitted: (_) => _save(existing),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.lg),
          FilledButton(
            onPressed: action.loading ? null : () => _save(existing),
            child: Text(l10n.saveAction),
          ),
          if (action.loading)
            const Padding(
              padding: EdgeInsets.only(top: Space.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
          FailureText(action.failure),
        ],
      ),
    );
  }
}
