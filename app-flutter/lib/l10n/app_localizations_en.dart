// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mesada';

  @override
  String get navChildren => 'Children';

  @override
  String get navRules => 'Rules';

  @override
  String get navSettings => 'Settings';

  @override
  String get welcomeTitle =>
      'Your children\'s allowance, up to date, with both parents.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithEmail => 'Sign in with email';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signUpTitle => 'Create account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signInAction => 'Sign in';

  @override
  String get signUpAction => 'Create account';

  @override
  String get switchToSignUp => 'No account? Create one';

  @override
  String get switchToSignIn => 'Already have an account? Sign in';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get passwordResetSent =>
      'We sent you an email to reset your password.';

  @override
  String get emailInvalid => 'Enter a valid email.';

  @override
  String get passwordTooShort => 'The password needs at least 6 characters.';

  @override
  String get errorInvalidCredentials => 'Wrong email or password.';

  @override
  String get errorInvalidEmail => 'That email doesn\'t look valid.';

  @override
  String get errorEmailInUse => 'An account with that email already exists.';

  @override
  String get errorWeakPassword =>
      'Choose a password with at least 6 characters.';

  @override
  String get errorNoConnection => 'No connection. Try again.';

  @override
  String get errorInvalidInvite =>
      'The code is invalid, expired or already used.';

  @override
  String get errorPermissionDenied => 'You don\'t have permission to do that.';

  @override
  String get errorUnexpected => 'Something went wrong. Try again.';

  @override
  String get familyChoiceTitle => 'Your family';

  @override
  String get familyChoiceSubtitle =>
      'Create a new family or join the one the other parent already created.';

  @override
  String get createFamilyOption => 'Create a family';

  @override
  String get haveCodeOption => 'I have a code';

  @override
  String get createFamilyTitle => 'New family';

  @override
  String get familyNameLabel => 'Family name';

  @override
  String get familyNameHint => 'The Smith family';

  @override
  String get familyNameRequired => 'Enter a name.';

  @override
  String get createFamilyAction => 'Create family';

  @override
  String get joinFamilyTitle => 'Join with a code';

  @override
  String get inviteCodeLabel => 'Invite code';

  @override
  String get joinFamilyAction => 'Join family';

  @override
  String get tryAgain => 'Try again';

  @override
  String get signOutAction => 'Sign out';

  @override
  String get settingsFamilySection => 'Family';

  @override
  String get settingsInviteTile => 'Invite the other parent';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get inviteDialogTitle => 'Invite code';

  @override
  String get inviteDialogBody =>
      'Ask the other parent to choose “I have a code” and enter this code. It\'s valid for 2 days and can be used once.';

  @override
  String get inviteCopy => 'Copy';

  @override
  String get inviteShare => 'Share';

  @override
  String get inviteCopied => 'Code copied';

  @override
  String inviteShareText(String code) {
    return 'Join our family in the Mesada app with the code $code.';
  }

  @override
  String get close => 'Close';
}
