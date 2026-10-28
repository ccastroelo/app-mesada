import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/page_body.dart';
import '../../../../l10n/app_localizations.dart';
import '../state/controllers.dart';

class FamilyChoicePage extends ConsumerWidget {
  const FamilyChoicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.familyChoiceTitle),
        actions: [
          IconButton(
            tooltip: l10n.signOutAction,
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(signOutControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: PageBody(
        children: [
          Text(l10n.familyChoiceSubtitle, style: theme.textTheme.bodyLarge),
          const SizedBox(height: Space.xl),
          _ChoiceCard(
            icon: Icons.add_home_outlined,
            label: l10n.createFamilyOption,
            onTap: () => context.push('/familia/nova'),
          ),
          const SizedBox(height: Space.md),
          _ChoiceCard(
            icon: Icons.pin_outlined,
            label: l10n.haveCodeOption,
            onTap: () => context.push('/familia/entrar'),
          ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        minVerticalPadding: Space.lg,
        leading: Icon(icon),
        title: Text(label, style: Theme.of(context).textTheme.titleMedium),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
