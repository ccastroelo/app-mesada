import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class ChildrenPage extends StatelessWidget {
  const ChildrenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).navChildren)),
    );
  }
}
