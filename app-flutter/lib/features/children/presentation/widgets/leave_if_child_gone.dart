import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../state/child_ledger_state.dart';

/// Se o filho some com a tela aberta (o outro responsável o excluiu, só
/// acontece com assinatura), volta para a lista e avisa, em vez de ficar num
/// erro sem saída. Chamar no `build` das telas do filho.
///
/// Usa `go` e não `pop`: a tela do filho e a das regras dele escutam as duas, e
/// cada uma só pode mandar para o mesmo lugar sem empilhar nem desempilhar o
/// que a outra já resolveu.
void leaveIfChildGone(BuildContext context, WidgetRef ref, String childId) {
  ref.listen(childLedgerProvider(childId), (_, next) {
    if (next.error is! ChildNotFound) return;
    final message = AppLocalizations.of(context).childRemovedNotice;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
    context.go('/filhos');
  });
}
