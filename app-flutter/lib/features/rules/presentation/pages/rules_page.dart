import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).navRules)),
    );
  }
}
