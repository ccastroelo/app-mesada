import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../app_lock/app_lock_providers.dart';
import '../../../auth_family/auth_family.dart';
import '../../../entitlement/entitlement.dart';
import '../../../entitlement/entitlement_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final gate = ref.watch(gateProvider);
    final ready = gate is GateReady ? gate : null;
    // Sem conta = modo local (ADR-0014): convidar e sair só aparecem com
    // conta, que a pessoa cria ao escolher compartilhar (ADR-0021).
    final user = ready?.user;
    final family = ready?.family;
    // Só quem ainda está no teste ou ficou em só leitura vê o atalho de compra.
    final access = ref.watch(accessProvider).value;
    final purchaseSubtitle = switch (access) {
      FullAccess(source: AccessSource.trial, :final trialDaysLeft?) =>
        l10n.accessTrialBanner(trialDaysLeft),
      ReadOnlyAccess() => l10n.settingsPurchaseReadOnly,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        children: [
          if (purchaseSubtitle != null)
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: Text(l10n.settingsPurchaseTile),
              subtitle: Text(purchaseSubtitle),
              onTap: () => context.push('/comprar'),
            ),
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
          // Sem conta, o caminho é começar a compartilhar; com conta, o
          // convite já funciona.
          if (user == null)
            ListTile(
              leading: const Icon(Icons.group_add_outlined),
              title: Text(l10n.settingsFamilySection),
              subtitle: Text(l10n.settingsFamilySharingSubtitle),
              onTap: () => context.push('/ajustes/familia'),
            ),
          if (user != null)
            ListTile(
              leading: const Icon(Icons.person_add_alt_outlined),
              title: Text(l10n.settingsInviteTile),
              onTap: () => showInviteDialog(context),
            ),
          if (user != null)
            ListTile(
              leading: const Icon(Icons.phone_iphone_outlined),
              title: Text(l10n.settingsBackToLocalTile),
              onTap: () => showBackToLocalDialog(context),
            ),
          SectionHeader(l10n.settingsSecuritySection),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l10n.pinSectionTitle),
            subtitle: Text(
              ref.watch(appLockProvider) is LockOff
                  ? l10n.pinStatusOff
                  : l10n.pinStatusOn,
            ),
            onTap: () => context.push('/ajustes/seguranca'),
          ),
          SectionHeader(l10n.settingsHelpSection),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(l10n.settingsHelpSection),
            subtitle: Text(l10n.settingsHelpSubtitle),
            onTap: () => context.push('/ajustes/ajuda'),
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
