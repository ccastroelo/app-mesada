/// Superfície pública da feature `auth_family` para o roteador e outras features.
library;

export 'domain/entities/app_user.dart';
export 'domain/entities/family.dart';
export 'presentation/pages/create_family_page.dart';
export 'presentation/pages/family_choice_page.dart';
export 'presentation/pages/gate_page.dart';
export 'presentation/pages/join_family_page.dart';
export 'presentation/pages/sign_in_page.dart';
export 'presentation/pages/welcome_page.dart';
export 'presentation/state/controllers.dart'
    show ActionState, signOutControllerProvider;
export 'presentation/state/gate.dart';
export 'presentation/widgets/invite_dialog.dart';
