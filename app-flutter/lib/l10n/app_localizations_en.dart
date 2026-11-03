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
  String get familyDefaultName => 'My family';

  @override
  String get settingsFamilyLocalOnly => 'On this device only';

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

  @override
  String get cancelAction => 'Cancel';

  @override
  String get saveAction => 'Save';

  @override
  String get editAction => 'Edit';

  @override
  String get deleteAction => 'Delete';

  @override
  String get reorderAction => 'Reorder';

  @override
  String get doneAction => 'Done';

  @override
  String get rulesRewardsSection => 'Rewards';

  @override
  String get rulesDiscountsSection => 'Deductions';

  @override
  String get ruleRewardLabel => 'Reward';

  @override
  String get ruleDiscountLabel => 'Deduction';

  @override
  String ruleSubtitleReward(String value) {
    return 'Reward · $value';
  }

  @override
  String ruleSubtitleDiscount(String value) {
    return 'Deduction · $value';
  }

  @override
  String get newRuleAction => 'New rule';

  @override
  String get newRuleTitle => 'New rule';

  @override
  String get editRuleTitle => 'Edit rule';

  @override
  String get ruleDescriptionLabel => 'Description';

  @override
  String get ruleDescriptionRequired => 'Enter a description.';

  @override
  String get ruleValueLabel => 'Amount';

  @override
  String get rulesEmptyTitle => 'No rules yet';

  @override
  String get rulesEmptyBody => 'Use the suggestions or create your first rule.';

  @override
  String get useSuggestionsAction => 'Use suggestions';

  @override
  String deleteRuleTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get deleteRuleBody =>
      'This removes this rule\'s entries from all children.';

  @override
  String get ruleDeleted => 'Rule deleted';

  @override
  String get childrenEmptyTitle => 'Add your first child to get started';

  @override
  String get addChildAction => 'Add child';

  @override
  String get newChildTitle => 'New child';

  @override
  String get editChildTitle => 'Edit child';

  @override
  String get childNameLabel => 'Name';

  @override
  String get childNameRequired => 'Enter a name.';

  @override
  String get childEmailLabel => 'Email (optional)';

  @override
  String get childEmailInvalid => 'Enter a valid email or leave it blank.';

  @override
  String get childAllowanceLabel => 'Allowance';

  @override
  String get childPhotoAction => 'Choose photo';

  @override
  String get childPhotoRemove => 'Remove photo';

  @override
  String childAllowanceSubtitle(String value) {
    return 'Allowance $value';
  }

  @override
  String get balanceLabel => 'Balance';

  @override
  String balanceSemantics(String value) {
    return 'Balance $value';
  }

  @override
  String deleteChildTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get deleteChildBody => 'This also removes all of their entries.';

  @override
  String get childDeleted => 'Child deleted';

  @override
  String get childLedgerZeroMenu => 'Reset entries';

  @override
  String get childLedgerZeroAllMenu => 'Reset everyone\'s entries';

  @override
  String get childRulesMenu => 'Rules for this child';

  @override
  String get childRulesSubtitle =>
      'Turning a rule off keeps its quantity, out of the balance.';

  @override
  String zeroChildTitle(String name) {
    return 'Reset $name\'s entries?';
  }

  @override
  String get zeroAllTitle => 'Reset the entries of every child?';

  @override
  String get zeroBody =>
      'Quantities go back to zero. The allowance stays the same.';

  @override
  String get zeroAction => 'Reset';

  @override
  String get entriesZeroed => 'Entries reset';

  @override
  String get undoAction => 'Undo';

  @override
  String increaseSemantics(String description, int quantity) {
    return 'Increase $description, quantity $quantity';
  }

  @override
  String decreaseSemantics(String description, int quantity) {
    return 'Decrease $description, quantity $quantity';
  }

  @override
  String get childLedgerEmptyTitle => 'No rules to use yet';

  @override
  String get childLedgerEmptyBody =>
      'Create rules on the Rules tab to start adding entries.';

  @override
  String childLedgerAllOffTitle(String name) {
    return 'Every rule is off for $name';
  }

  @override
  String get sendReportAction => 'Send report';

  @override
  String reportTitle(String name) {
    return '$name\'s allowance';
  }

  @override
  String reportGeneratedAt(String date) {
    return 'Generated on $date';
  }

  @override
  String get reportRuleColumn => 'Rule';

  @override
  String get reportValueColumn => 'Value';

  @override
  String get reportQuantityColumn => 'Qty';

  @override
  String get reportTotalColumn => 'Total';

  @override
  String get reportEmpty => 'No entries yet.';

  @override
  String reportSummary(String name, String allowance, String balance) {
    return '$name — allowance $allowance, balance $balance.';
  }

  @override
  String get settingsSecuritySection => 'Security';

  @override
  String get securityExplanation =>
      'The PIN stays on this device only, and is asked for when the app has been closed for 30 seconds.';

  @override
  String get pinSectionTitle => 'PIN';

  @override
  String get pinStatusOn => 'PIN on';

  @override
  String get pinStatusOff => 'PIN off';

  @override
  String get pinEnableAction => 'Turn on PIN';

  @override
  String get pinChangeAction => 'Change PIN';

  @override
  String get pinDisableAction => 'Turn off PIN';

  @override
  String get pinEnterCurrent => 'Enter the current PIN';

  @override
  String get pinEnterNew => 'Pick a 4-digit PIN';

  @override
  String get pinConfirmNew => 'Enter the PIN again';

  @override
  String get pinMismatch => 'The PINs don\'t match. Try again.';

  @override
  String get pinWrong => 'Wrong PIN';

  @override
  String get pinLockMessage => 'Enter your PIN';

  @override
  String pinWaitMessage(String time) {
    return 'Try again in $time';
  }

  @override
  String get pinEraseAction => 'Delete';

  @override
  String pinDotsSemantics(int typed, int total) {
    return '$typed of $total digits';
  }
}
