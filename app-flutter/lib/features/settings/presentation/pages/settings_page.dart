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
    // Sem conta = modo local (ADR-0015): compartilhar e sair só aparecem com
    // conta, que chega com a assinatura Família.
    final user = ready?.user;
    final family = ready?.family;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        children: [
          SectionHeader(l10n.settingsFamilySection),
          if (family != null)
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: Text(
                family.name.isEmpty ? l10n.familyDefaultName : family.name,
              ),
              subtitle: user == null
                  ? Text(l10n.settingsFamilyLocalOnly)
                  : null,
            ),
          if (user != null)
            ListTile(
              leading: const Icon(Icons.person_add_alt_outlined),
              title: Text(l10n.settingsInviteTile),
              onTap: () => showInviteDialog(context),
            ),
          if (user != null) ...[
            SectionHeader(l10n.settingsAccountSection),
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: Text(user.email),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l10n.signOutAction),
              onTap: () =>
                  ref.read(signOutControllerProvider.notifier).signOut(),
            ),
          ],
        ],
      ),
    );
  }
}
