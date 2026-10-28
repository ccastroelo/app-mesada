import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/section_header.dart';
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
          SectionHeader(l10n.settingsFamilySection),
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
          SectionHeader(l10n.settingsAccountSection),
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
