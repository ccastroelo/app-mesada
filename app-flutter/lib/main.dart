import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Modo local (ADR-0014): os dados ficam no aparelho e o Firebase **não** é
  // inicializado. `Firebase.initializeApp` volta no M4.5, quando a assinatura
  // Família liga a nuvem (a configuração gerada segue versionada, ADR-0010).
  runApp(
    // Sem retentativa automática: erro de permissão não melhora tentando de
    // novo; a tela de espera oferece "Tentar de novo".
    ProviderScope(retry: (_, _) => null, child: const MesadaApp()),
  );
}
