import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/usecases/pin_lock_rules.dart';

/// Os 4 pontos e o teclado numérico próprio (design.md §4.11). Chama
/// [onCompleted] no quarto dígito e limpa os pontos; quem usa decide o que
/// mostrar depois.
class PinPad extends StatefulWidget {
  const PinPad({
    super.key,
    required this.onCompleted,
    this.message,
    this.errorText,
    this.enabled = true,
  });

  final void Function(String pin) onCompleted;

  /// O que pedir ("Digite o PIN atual", "Escolha um PIN de 4 dígitos"...).
  final String? message;

  final String? errorText;

  /// Falso durante a espera por erros seguidos.
  final bool enabled;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String _typed = '';

  void _press(String digit) {
    if (!widget.enabled || _typed.length >= pinLength) return;
    setState(() => _typed += digit);
    if (_typed.length == pinLength) {
      final pin = _typed;
      // Limpa antes de avisar: a tela volta pronta para a próxima tentativa.
      setState(() => _typed = '');
      widget.onCompleted(pin);
    }
  }

  void _erase() {
    if (!widget.enabled || _typed.isEmpty) return;
    setState(() => _typed = _typed.substring(0, _typed.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.message != null)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.lg),
            child: Text(
              widget.message!,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ),
        Semantics(
          label: l10n.pinDotsSemantics(_typed.length, pinLength),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < pinLength; i++)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: Space.sm),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _typed.length
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                ),
            ],
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: Space.md),
            child: Text(
              widget.errorText!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        const SizedBox(height: Space.xl),
        // Wrap em vez de grade fixa: em fonte grande as teclas crescem e
        // reorganizam em vez de cortar o número.
        Wrap(
          alignment: WrapAlignment.center,
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (var digit = 1; digit <= 9; digit++)
              _Key(
                label: '$digit',
                onPressed: widget.enabled ? () => _press('$digit') : null,
              ),
            const _KeyGap(),
            _Key(
              label: '0',
              onPressed: widget.enabled ? () => _press('0') : null,
            ),
            _Key(
              icon: Icons.backspace_outlined,
              tooltip: l10n.pinEraseAction,
              onPressed: widget.enabled ? _erase : null,
            ),
          ],
        ),
      ],
    );
  }
}

/// Tecla de 88 dp de largura e altura mínima de 56: alvo bem acima dos 48 dp
/// pedidos, porque é digitação com uma mão.
class _Key extends StatelessWidget {
  const _Key({this.label, this.icon, this.tooltip, this.onPressed});

  final String? label;
  final IconData? icon;
  final String? tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 88,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(88, 56),
          padding: const EdgeInsets.symmetric(vertical: Space.md),
        ),
        child: icon != null
            ? Icon(icon, semanticLabel: tooltip)
            : Text(label!, style: theme.textTheme.headlineSmall),
      ),
    );
  }
}

class _KeyGap extends StatelessWidget {
  const _KeyGap();

  @override
  Widget build(BuildContext context) => const SizedBox(width: 88);
}
