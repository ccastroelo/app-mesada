import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
    Locale('pt', 'PT'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mesada'**
  String get appTitle;

  /// No description provided for @navChildren.
  ///
  /// In pt, this message translates to:
  /// **'Filhos'**
  String get navChildren;

  /// No description provided for @navRules.
  ///
  /// In pt, this message translates to:
  /// **'Regras'**
  String get navRules;

  /// No description provided for @navSettings.
  ///
  /// In pt, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// No description provided for @welcomeTitle.
  ///
  /// In pt, this message translates to:
  /// **'A mesada dos seus filhos, em dia, com os dois responsáveis.'**
  String get welcomeTitle;

  /// No description provided for @continueWithGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com o Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithEmail.
  ///
  /// In pt, this message translates to:
  /// **'Entrar com e-mail'**
  String get continueWithEmail;

  /// No description provided for @signInTitle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get signInTitle;

  /// No description provided for @signUpTitle.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get signUpTitle;

  /// No description provided for @emailLabel.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get passwordLabel;

  /// No description provided for @signInAction.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get signInAction;

  /// No description provided for @signUpAction.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get signUpAction;

  /// No description provided for @switchToSignUp.
  ///
  /// In pt, this message translates to:
  /// **'Não tem conta? Criar conta'**
  String get switchToSignUp;

  /// No description provided for @switchToSignIn.
  ///
  /// In pt, this message translates to:
  /// **'Já tem conta? Entrar'**
  String get switchToSignIn;

  /// No description provided for @forgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueci a senha'**
  String get forgotPassword;

  /// No description provided for @passwordResetSent.
  ///
  /// In pt, this message translates to:
  /// **'Enviamos um e-mail para você redefinir a senha.'**
  String get passwordResetSent;

  /// No description provided for @emailInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Digite um e-mail válido.'**
  String get emailInvalid;

  /// No description provided for @passwordTooShort.
  ///
  /// In pt, this message translates to:
  /// **'A senha precisa ter pelo menos 6 caracteres.'**
  String get passwordTooShort;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In pt, this message translates to:
  /// **'E-mail ou senha incorretos.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In pt, this message translates to:
  /// **'Esse e-mail não parece válido.'**
  String get errorInvalidEmail;

  /// No description provided for @errorEmailInUse.
  ///
  /// In pt, this message translates to:
  /// **'Já existe uma conta com esse e-mail.'**
  String get errorEmailInUse;

  /// No description provided for @errorWeakPassword.
  ///
  /// In pt, this message translates to:
  /// **'Escolha uma senha com pelo menos 6 caracteres.'**
  String get errorWeakPassword;

  /// No description provided for @errorNoConnection.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão. Tente de novo.'**
  String get errorNoConnection;

  /// No description provided for @errorInvalidInvite.
  ///
  /// In pt, this message translates to:
  /// **'Código inválido, expirado ou já usado.'**
  String get errorInvalidInvite;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In pt, this message translates to:
  /// **'Você não tem permissão para isso.'**
  String get errorPermissionDenied;

  /// No description provided for @errorUnexpected.
  ///
  /// In pt, this message translates to:
  /// **'Algo deu errado. Tente de novo.'**
  String get errorUnexpected;

  /// No description provided for @familyChoiceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sua família'**
  String get familyChoiceTitle;

  /// No description provided for @familyChoiceSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Crie uma família nova ou entre na que o outro responsável já criou.'**
  String get familyChoiceSubtitle;

  /// No description provided for @createFamilyOption.
  ///
  /// In pt, this message translates to:
  /// **'Criar uma família'**
  String get createFamilyOption;

  /// No description provided for @haveCodeOption.
  ///
  /// In pt, this message translates to:
  /// **'Tenho um código'**
  String get haveCodeOption;

  /// No description provided for @createFamilyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nova família'**
  String get createFamilyTitle;

  /// No description provided for @familyNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome da família'**
  String get familyNameLabel;

  /// No description provided for @familyNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Família Castro'**
  String get familyNameHint;

  /// No description provided for @familyNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Digite um nome.'**
  String get familyNameRequired;

  /// No description provided for @createFamilyAction.
  ///
  /// In pt, this message translates to:
  /// **'Criar família'**
  String get createFamilyAction;

  /// No description provided for @joinFamilyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar com código'**
  String get joinFamilyTitle;

  /// No description provided for @inviteCodeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Código de convite'**
  String get inviteCodeLabel;

  /// No description provided for @joinFamilyAction.
  ///
  /// In pt, this message translates to:
  /// **'Entrar na família'**
  String get joinFamilyAction;

  /// No description provided for @tryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get tryAgain;

  /// No description provided for @signOutAction.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get signOutAction;

  /// No description provided for @settingsFamilySection.
  ///
  /// In pt, this message translates to:
  /// **'Família'**
  String get settingsFamilySection;

  /// No description provided for @settingsInviteTile.
  ///
  /// In pt, this message translates to:
  /// **'Convidar outro responsável'**
  String get settingsInviteTile;

  /// No description provided for @settingsAccountSection.
  ///
  /// In pt, this message translates to:
  /// **'Conta'**
  String get settingsAccountSection;

  /// No description provided for @inviteDialogTitle.
  ///
  /// In pt, this message translates to:
  /// **'Código de convite'**
  String get inviteDialogTitle;

  /// No description provided for @inviteDialogBody.
  ///
  /// In pt, this message translates to:
  /// **'Peça para o outro responsável escolher “Tenho um código” e digitar este código. Vale por 2 dias e só pode ser usado uma vez.'**
  String get inviteDialogBody;

  /// No description provided for @inviteCopy.
  ///
  /// In pt, this message translates to:
  /// **'Copiar'**
  String get inviteCopy;

  /// No description provided for @inviteShare.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar'**
  String get inviteShare;

  /// No description provided for @inviteCopied.
  ///
  /// In pt, this message translates to:
  /// **'Código copiado'**
  String get inviteCopied;

  /// No description provided for @inviteShareText.
  ///
  /// In pt, this message translates to:
  /// **'Entre na nossa família no app Mesada com o código {code}.'**
  String inviteShareText(String code);

  /// No description provided for @close.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'PT':
            return AppLocalizationsPtPt();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
