import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/app_localizations.dart';

/// Endereço de contato. O app antigo usava `ideiasmob.com.br`
/// (`imAjudaVC.m:61`), que saiu do ar; o atual é este. Trocar aqui se mudar
/// de caixa de entrada.
const contactEmail = 'contato@synapsesolucoes.ia.br';

/// Ajustes › Ajuda (design.md §4.8): rever a introdução, falar com a gente e
/// Sobre.
class HelpPage extends ConsumerWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsHelpSection)),
      body: ListView(
        children: [
          SectionHeader(l10n.settingsHelpSection),
          ListTile(
            leading: const Icon(Icons.slideshow_outlined),
            title: Text(l10n.helpSeeIntroAction),
            onTap: () => context.go('/introducao'),
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: Text(l10n.helpContactAction),
            subtitle: const Text(contactEmail),
            trailing: const Icon(Icons.copy_outlined),
            // Copiar em vez de abrir o compositor: abrir exigiria
            // `url_launcher`, e o endereço resolve por enquanto.
            onTap: () {
              // Sem await: o retorno vem da plataforma e o aviso não espera
              // por ele (convenção em `architecture.md`).
              unawaited(
                Clipboard.setData(const ClipboardData(text: contactEmail)),
              );
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(l10n.helpContactCopied)));
            },
          ),
          SectionHeader(l10n.settingsAboutSection),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.appTitle),
            subtitle: Text(l10n.aboutDataLocal),
          ),
        ],
      ),
    );
  }
}
