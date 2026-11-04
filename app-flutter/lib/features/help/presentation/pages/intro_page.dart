import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../state/help_state.dart';

/// Introdução em 4 cartões (design.md §4.9): aparece uma vez no primeiro uso e
/// é reabrível em Ajustes › Ajuda. Só texto e ícone — as telas do app antigo
/// eram imagens, que não dava para traduzir.
class IntroPage extends ConsumerStatefulWidget {
  const IntroPage({super.key});

  @override
  ConsumerState<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends ConsumerState<IntroPage> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await markIntroSeen(ref);
    if (mounted) context.go('/filhos');
  }

  void _next(int total) {
    if (_page >= total - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cards = [
      (
        icon: Icons.child_care_outlined,
        title: l10n.intro1Title,
        body: l10n.intro1Body,
      ),
      (
        icon: Icons.rule_outlined,
        title: l10n.intro2Title,
        body: l10n.intro2Body,
      ),
      (
        icon: Icons.add_circle_outline,
        title: l10n.intro3Title,
        body: l10n.intro3Body,
      ),
      (
        icon: Icons.family_restroom_outlined,
        title: l10n.intro4Title,
        body: l10n.intro4Body,
      ),
    ];
    final last = _page >= cards.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (page) => setState(() => _page = page),
                children: [
                  for (final card in cards)
                    _Card(icon: card.icon, title: card.title, body: card.body),
                ],
              ),
            ),
            Semantics(
              label: l10n.introProgress(_page + 1, cards.length),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < cards.length; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: Space.xs),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _page
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _finish,
                    child: Text(l10n.introSkipAction),
                  ),
                  FilledButton(
                    onPressed: () => _next(cards.length),
                    child: Text(
                      last ? l10n.introStartAction : l10n.introNextAction,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Rolável: em fonte grande o cartão cresce em vez de cortar.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Space.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: Space.xxl),
          ExcludeSemantics(
            child: Icon(icon, size: 72, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: Space.xl),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: Space.md),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
