import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth_family/auth_family.dart';
import '../../features/children/presentation/pages/child_edit_page.dart';
import '../../features/children/presentation/pages/children_page.dart';
import '../../features/rules/presentation/pages/rule_edit_page.dart';
import '../../features/rules/presentation/pages/rules_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import 'app_shell.dart';

const _loading = '/carregando';
const _welcome = '/boas-vindas';
const _signIn = '/entrar';
const _family = '/familia';
const _home = '/filhos';

/// Para onde a pessoa deve ir dado o ponto da entrada em que está (null = fica).
/// Guardas do design.md §3: sem login → boas-vindas; sem família → escolha.
@visibleForTesting
String? redirectFor(Gate gate, String location) {
  bool inFamilyFlow() =>
      location == _family || location.startsWith('$_family/');
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
      return inEntryFlow ? _home : null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(gateProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    initialLocation: _loading,
    refreshListenable: refresh,
    redirect: (context, state) =>
        redirectFor(ref.read(gateProvider), state.uri.path),
    routes: [
      GoRoute(path: _loading, builder: (_, _) => const GatePage()),
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
