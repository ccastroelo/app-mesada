import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/usecases/evaluate_access.dart';
import '../state/entitlement_state.dart';

/// Faixa que explica a situação do acesso (ADR-0021, design §17):
/// - **durante o teste**, os dias que faltam e um atalho para comprar
///   (só quando [showTrial]; a aba Filhos mostra, as outras telas não);
/// - **só leitura**, por que não dá para lançar nem editar.
/// Quem comprou ou veio do app antigo não vê nada.
class AccessBanner extends ConsumerWidget {
  const AccessBanner({super.key, this.showTrial = true});

  final bool showTrial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final access = ref.watch(accessProvider).value;

    return switch (access) {
      FullAccess(source: AccessSource.trial, :final trialDaysLeft?)
          when showTrial =>
        _Banner(
          icon: Icons.hourglass_bottom,
          text: l10n.accessTrialBanner(trialDaysLeft),
          // Nos últimos dias a faixa chama mais atenção; nada bloqueia.
          urgent: trialDaysLeft <= 3,
        ),
      ReadOnlyAccess() => _Banner(
        icon: Icons.lock_outline,
        text: l10n.accessReadOnlyBanner,
        urgent: true,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.text, required this.urgent});

  final IconData icon;
  final String text;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final background = urgent
        ? scheme.errorContainer
        : scheme.secondaryContainer;
    final large = MediaQuery.textScalerOf(context).scale(1) >= 1.3;
    final button = TextButton(
      onPressed: () => context.push('/comprar'),
      child: Text(l10n.accessBuyAction),
    );
    final foreground = urgent
        ? scheme.onErrorContainer
        : scheme.onSecondaryContainer;

    return Semantics(
      container: true,
      liveRegion: true,
      child: Material(
        color: background,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.lg,
            vertical: Space.sm,
          ),
          // Em fonte grande o botão desce para baixo do texto, como o stepper
          // das linhas: lado a lado o texto ficaria numa coluna estreita.
          child: large
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExcludeSemantics(
                          child: Icon(icon, color: foreground, size: 20),
                        ),
                        const SizedBox(width: Space.md),
                        Expanded(
                          child: Text(
                            text,
                            style: TextStyle(color: foreground),
                          ),
                        ),
                      ],
                    ),
                    Align(alignment: Alignment.centerRight, child: button),
                  ],
                )
              : Row(
                  children: [
                    ExcludeSemantics(
                      child: Icon(icon, color: foreground, size: 20),
                    ),
                    const SizedBox(width: Space.md),
                    Expanded(
                      child: Text(text, style: TextStyle(color: foreground)),
                    ),
                    button,
                  ],
                ),
        ),
      ),
    );
  }
}
