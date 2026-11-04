import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/app_lock/app_lock_providers.dart';
import 'features/entitlement/entitlement_providers.dart';
import 'l10n/app_localizations.dart';

class MesadaApp extends ConsumerStatefulWidget {
  const MesadaApp({super.key});

  @override
  ConsumerState<MesadaApp> createState() => _MesadaAppState();
}

class _MesadaAppState extends ConsumerState<MesadaApp> {
  AppLifecycleListener? _lifecycle;

  @override
  void initState() {
    super.initState();
    // Conta o tempo fora do app para o PIN travar depois de 30 s
    // (design.md §10). `hidden` e `paused` chegam em sequência; quem manda é
    // o primeiro aviso, tratado no controlador.
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        final lock = ref.read(appLockProvider.notifier);
        switch (state) {
          case AppLifecycleState.hidden || AppLifecycleState.paused:
            lock.onAway();
          case AppLifecycleState.resumed:
            lock.onBack();
            // O teste pode ter acabado enquanto o app estava em segundo plano.
            ref.invalidate(accessProvider);
          case AppLifecycleState.inactive || AppLifecycleState.detached:
            break;
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Grava a marca do app no primeiro uso (ADR-0021); o valor não é usado aqui.
    ref.watch(entitlementProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: ref.watch(routerProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
