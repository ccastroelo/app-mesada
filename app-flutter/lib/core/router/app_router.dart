import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/app_lock/app_lock_providers.dart';
import '../../features/app_lock/presentation/pages/lock_page.dart';
import '../../features/app_lock/presentation/pages/security_page.dart';
import '../../features/auth_family/auth_family.dart';
import '../../features/children/presentation/pages/child_edit_page.dart';
import '../../features/children/presentation/pages/child_ledger_page.dart';
import '../../features/children/presentation/pages/child_rules_page.dart';
import '../../features/children/presentation/pages/children_page.dart';
import '../../features/family_plan/presentation/pages/family_plan_page.dart';
import '../../features/help/help_providers.dart';
import '../../features/help/presentation/pages/help_page.dart';
import '../../features/help/presentation/pages/intro_page.dart';
import '../../features/rules/presentation/pages/rule_edit_page.dart';
import '../../features/rules/presentation/pages/rules_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import 'app_shell.dart';

const _loading = '/carregando';
const _welcome = '/boas-vindas';
const _signIn = '/entrar';
const _family = '/familia';
const _home = '/filhos';
const _lock = '/bloqueio';
const _intro = '/introducao';

/// Para onde a pessoa deve ir dado o ponto da entrada em que está (null = fica).
/// Guardas do design.md §3: sem login → boas-vindas; sem família → escolha;
/// PIN pedido → bloqueio; introdução não vista → introdução.
///
/// [introSeen] é nulo enquanto o arquivo do aparelho não respondeu.
@visibleForTesting
String? redirectFor(
  Gate gate,
  String location, {
  LockState lock = const LockOff(),
  bool? introSeen = true,
}) {
  bool inFamilyFlow() =>
      location == _family || location.startsWith('$_family/');

  // O PIN vem antes de tudo: enquanto não se sabe se existe, nem o conteúdo
  // nem a tela de entrada aparecem (design.md §4.11).
  switch (lock) {
    case LockLoading():
      return location == _loading ? null : _loading;
    case LockClosed():
      return location == _lock ? null : _lock;
    case LockOff() || LockOpen():
      // Acabou de destravar: a tela do PIN não é lugar para ficar.
      if (location == _lock) return _home;
  }

  switch (gate) {
    case GateLoading() || GateError():
      return location == _loading ? null : _loading;
    case GateSignedOut():
      return location == _welcome || location == _signIn ? null : _welcome;
    case GateNeedsFamily():
      return inFamilyFlow() ? null : _family;
    case GateReady():
      final inEntryFlow =
          location == '/' ||
          location == _loading ||
          location == _welcome ||
          location == _signIn ||
          inFamilyFlow();
      // Introdução: mostrada uma vez (design.md §4.9). Enquanto não se sabe,
      // espera — melhor que abrir o app e a introdução pular na frente.
      if (introSeen == null) return location == _loading ? null : _loading;
      if (!introSeen && location != _intro) return _intro;
      // Quem já viu pode reabrir por Ajustes › Ajuda, então ficar na
      // introdução é permitido; o que não há é ir para lá sozinho.
      if (location == _intro) return null;
      return inEntryFlow ? _home : null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(gateProvider, (_, _) => refresh.value++);
  ref.listen(appLockProvider, (_, _) => refresh.value++);
  ref.listen(introSeenProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    initialLocation: _loading,
    refreshListenable: refresh,
    redirect: (context, state) => redirectFor(
      ref.read(gateProvider),
      state.uri.path,
      lock: ref.read(appLockProvider),
      introSeen: ref.read(introSeenProvider).value,
    ),
    routes: [
      GoRoute(path: _loading, builder: (_, _) => const GatePage()),
      GoRoute(path: _lock, builder: (_, _) => const LockPage()),
      GoRoute(path: _intro, builder: (_, _) => const IntroPage()),
      GoRoute(
        path: '/ajustes/seguranca',
        builder: (_, _) => const SecurityPage(),
      ),
      GoRoute(path: '/ajustes/ajuda', builder: (_, _) => const HelpPage()),
      GoRoute(
        path: '/ajustes/familia',
        builder: (_, _) => const FamilyPlanPage(),
      ),
      GoRoute(path: _welcome, builder: (_, _) => const WelcomePage()),
      GoRoute(path: _signIn, builder: (_, _) => const SignInPage()),
      GoRoute(
        path: _family,
        builder: (_, _) => const FamilyChoicePage(),
        routes: [
          GoRoute(path: 'nova', builder: (_, _) => const CreateFamilyPage()),
          GoRoute(path: 'entrar', builder: (_, _) => const JoinFamilyPage()),
        ],
      ),
      GoRoute(path: '/filhos/novo', builder: (_, _) => const ChildEditPage()),
      GoRoute(
        path: '/filhos/:id/editar',
        builder: (_, state) =>
            ChildEditPage(childId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/filhos/:id/regras',
        builder: (_, state) =>
            ChildRulesPage(childId: state.pathParameters['id']!),
      ),
      // Depois das rotas mais específicas: `:id` casaria com "novo".
      GoRoute(
        path: '/filhos/:id',
        builder: (_, state) =>
            ChildLedgerPage(childId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/regras/nova', builder: (_, _) => const RuleEditPage()),
      GoRoute(
        path: '/regras/:id/editar',
        builder: (_, state) => RuleEditPage(ruleId: state.pathParameters['id']),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: _home, builder: (_, _) => const ChildrenPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/regras', builder: (_, _) => const RulesPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ajustes',
                builder: (_, _) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
