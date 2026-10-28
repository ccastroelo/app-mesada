import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth_family/auth_family.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final gate = ref.watch(gateProvider);
    final ready = gate is GateReady ? gate : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        children: [
          _Section(l10n.settingsFamilySection),
          if (ready != null)
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: Text(ready.family.name),
            ),
          ListTile(
            leading: const Icon(Icons.person_add_alt_outlined),
            title: Text(l10n.settingsInviteTile),
            onTap: ready == null ? null : () => showInviteDialog(context),
          ),
          _Section(l10n.settingsAccountSection),
          if (ready != null)
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: Text(ready.user.email),
            ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.signOutAction),
            onTap: () => ref.read(signOutControllerProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
