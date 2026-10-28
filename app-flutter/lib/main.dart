import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    // Sem retentativa automática: erro de permissão não melhora tentando de
    // novo; a tela de espera oferece "Tentar de novo".
    ProviderScope(retry: (_, _) => null, child: const MesadaApp()),
  );
}
