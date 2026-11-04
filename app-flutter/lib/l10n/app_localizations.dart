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

  /// No description provided for @familyDefaultName.
  ///
  /// In pt, this message translates to:
  /// **'Minha família'**
  String get familyDefaultName;

  /// No description provided for @settingsFamilyLocalOnly.
  ///
  /// In pt, this message translates to:
  /// **'Só neste aparelho'**
  String get settingsFamilyLocalOnly;

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

  /// No description provided for @cancelAction.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancelAction;

  /// No description provided for @saveAction.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get saveAction;

  /// No description provided for @editAction.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get editAction;

  /// No description provided for @deleteAction.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get deleteAction;

  /// No description provided for @reorderAction.
  ///
  /// In pt, this message translates to:
  /// **'Reordenar'**
  String get reorderAction;

  /// No description provided for @doneAction.
  ///
  /// In pt, this message translates to:
  /// **'Concluir'**
  String get doneAction;

  /// No description provided for @rulesRewardsSection.
  ///
  /// In pt, this message translates to:
  /// **'Recompensas'**
  String get rulesRewardsSection;

  /// No description provided for @rulesDiscountsSection.
  ///
  /// In pt, this message translates to:
  /// **'Descontos'**
  String get rulesDiscountsSection;

  /// No description provided for @ruleRewardLabel.
  ///
  /// In pt, this message translates to:
  /// **'Recompensa'**
  String get ruleRewardLabel;

  /// No description provided for @ruleDiscountLabel.
  ///
  /// In pt, this message translates to:
  /// **'Desconto'**
  String get ruleDiscountLabel;

  /// No description provided for @ruleSubtitleReward.
  ///
  /// In pt, this message translates to:
  /// **'Recompensa · {value}'**
  String ruleSubtitleReward(String value);

  /// No description provided for @ruleSubtitleDiscount.
  ///
  /// In pt, this message translates to:
  /// **'Desconto · {value}'**
  String ruleSubtitleDiscount(String value);

  /// No description provided for @newRuleAction.
  ///
  /// In pt, this message translates to:
  /// **'Nova regra'**
  String get newRuleAction;

  /// No description provided for @newRuleTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nova regra'**
  String get newRuleTitle;

  /// No description provided for @editRuleTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar regra'**
  String get editRuleTitle;

  /// No description provided for @ruleDescriptionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get ruleDescriptionLabel;

  /// No description provided for @ruleDescriptionRequired.
  ///
  /// In pt, this message translates to:
  /// **'Digite uma descrição.'**
  String get ruleDescriptionRequired;

  /// No description provided for @ruleValueLabel.
  ///
  /// In pt, this message translates to:
  /// **'Valor'**
  String get ruleValueLabel;

  /// No description provided for @rulesEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma regra ainda'**
  String get rulesEmptyTitle;

  /// No description provided for @rulesEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Use as sugestões ou crie a sua primeira regra.'**
  String get rulesEmptyBody;

  /// No description provided for @useSuggestionsAction.
  ///
  /// In pt, this message translates to:
  /// **'Usar sugestões'**
  String get useSuggestionsAction;

  /// No description provided for @deleteRuleTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir “{name}”?'**
  String deleteRuleTitle(String name);

  /// No description provided for @deleteRuleBody.
  ///
  /// In pt, this message translates to:
  /// **'Isso remove os lançamentos dessa regra de todos os filhos.'**
  String get deleteRuleBody;

  /// No description provided for @ruleDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Regra excluída'**
  String get ruleDeleted;

  /// No description provided for @childrenEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Adicione o primeiro filho para começar'**
  String get childrenEmptyTitle;

  /// No description provided for @addChildAction.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar filho'**
  String get addChildAction;

  /// No description provided for @newChildTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novo filho'**
  String get newChildTitle;

  /// No description provided for @editChildTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar filho'**
  String get editChildTitle;

  /// No description provided for @childNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get childNameLabel;

  /// No description provided for @childNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Digite o nome.'**
  String get childNameRequired;

  /// No description provided for @childEmailLabel.
  ///
  /// In pt, this message translates to:
  /// **'E-mail (opcional)'**
  String get childEmailLabel;

  /// No description provided for @childEmailInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Digite um e-mail válido ou deixe em branco.'**
  String get childEmailInvalid;

  /// No description provided for @childAllowanceLabel.
  ///
  /// In pt, this message translates to:
  /// **'Mesada'**
  String get childAllowanceLabel;

  /// No description provided for @childPhotoAction.
  ///
  /// In pt, this message translates to:
  /// **'Escolher foto'**
  String get childPhotoAction;

  /// No description provided for @childPhotoRemove.
  ///
  /// In pt, this message translates to:
  /// **'Remover foto'**
  String get childPhotoRemove;

  /// No description provided for @childAllowanceSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Mesada {value}'**
  String childAllowanceSubtitle(String value);

  /// No description provided for @balanceLabel.
  ///
  /// In pt, this message translates to:
  /// **'Saldo'**
  String get balanceLabel;

  /// No description provided for @balanceSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Saldo {value}'**
  String balanceSemantics(String value);

  /// No description provided for @deleteChildTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir {name}?'**
  String deleteChildTitle(String name);

  /// No description provided for @deleteChildBody.
  ///
  /// In pt, this message translates to:
  /// **'Isso remove também todos os lançamentos dele.'**
  String get deleteChildBody;

  /// No description provided for @childDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Filho excluído'**
  String get childDeleted;

  /// No description provided for @childLedgerZeroMenu.
  ///
  /// In pt, this message translates to:
  /// **'Zerar lançamentos'**
  String get childLedgerZeroMenu;

  /// No description provided for @childLedgerZeroAllMenu.
  ///
  /// In pt, this message translates to:
  /// **'Zerar lançamentos de todos'**
  String get childLedgerZeroAllMenu;

  /// No description provided for @childRulesMenu.
  ///
  /// In pt, this message translates to:
  /// **'Regras deste filho'**
  String get childRulesMenu;

  /// No description provided for @childRulesSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Desativar guarda a quantidade, fora do saldo.'**
  String get childRulesSubtitle;

  /// No description provided for @zeroChildTitle.
  ///
  /// In pt, this message translates to:
  /// **'Zerar lançamentos de {name}?'**
  String zeroChildTitle(String name);

  /// No description provided for @zeroAllTitle.
  ///
  /// In pt, this message translates to:
  /// **'Zerar lançamentos de todos os filhos?'**
  String get zeroAllTitle;

  /// No description provided for @zeroBody.
  ///
  /// In pt, this message translates to:
  /// **'As quantidades voltam a zero. A mesada não muda.'**
  String get zeroBody;

  /// No description provided for @zeroAction.
  ///
  /// In pt, this message translates to:
  /// **'Zerar'**
  String get zeroAction;

  /// No description provided for @entriesZeroed.
  ///
  /// In pt, this message translates to:
  /// **'Lançamentos zerados'**
  String get entriesZeroed;

  /// No description provided for @undoAction.
  ///
  /// In pt, this message translates to:
  /// **'Desfazer'**
  String get undoAction;

  /// No description provided for @increaseSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Aumentar {description}, quantidade {quantity}'**
  String increaseSemantics(String description, int quantity);

  /// No description provided for @decreaseSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Diminuir {description}, quantidade {quantity}'**
  String decreaseSemantics(String description, int quantity);

  /// No description provided for @childLedgerEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma regra para lançar'**
  String get childLedgerEmptyTitle;

  /// No description provided for @childLedgerEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Crie regras na aba Regras para começar a lançar.'**
  String get childLedgerEmptyBody;

  /// No description provided for @childLedgerAllOffTitle.
  ///
  /// In pt, this message translates to:
  /// **'Todas as regras estão desativadas para {name}'**
  String childLedgerAllOffTitle(String name);

  /// No description provided for @sendReportAction.
  ///
  /// In pt, this message translates to:
  /// **'Enviar relatório'**
  String get sendReportAction;

  /// No description provided for @reportTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mesada de {name}'**
  String reportTitle(String name);

  /// No description provided for @reportGeneratedAt.
  ///
  /// In pt, this message translates to:
  /// **'Gerado em {date}'**
  String reportGeneratedAt(String date);

  /// No description provided for @reportRuleColumn.
  ///
  /// In pt, this message translates to:
  /// **'Regra'**
  String get reportRuleColumn;

  /// No description provided for @reportValueColumn.
  ///
  /// In pt, this message translates to:
  /// **'Valor'**
  String get reportValueColumn;

  /// No description provided for @reportQuantityColumn.
  ///
  /// In pt, this message translates to:
  /// **'Qtd'**
  String get reportQuantityColumn;

  /// No description provided for @reportTotalColumn.
  ///
  /// In pt, this message translates to:
  /// **'Total'**
  String get reportTotalColumn;

  /// No description provided for @reportEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum lançamento até agora.'**
  String get reportEmpty;

  /// No description provided for @reportSummary.
  ///
  /// In pt, this message translates to:
  /// **'{name} — mesada {allowance}, saldo {balance}.'**
  String reportSummary(String name, String allowance, String balance);

  /// No description provided for @settingsSecuritySection.
  ///
  /// In pt, this message translates to:
  /// **'Segurança'**
  String get settingsSecuritySection;

  /// No description provided for @securityExplanation.
  ///
  /// In pt, this message translates to:
  /// **'O PIN fica só neste aparelho e é pedido quando o app passa 30 segundos fechado.'**
  String get securityExplanation;

  /// No description provided for @pinSectionTitle.
  ///
  /// In pt, this message translates to:
  /// **'PIN'**
  String get pinSectionTitle;

  /// No description provided for @pinStatusOn.
  ///
  /// In pt, this message translates to:
  /// **'PIN ativado'**
  String get pinStatusOn;

  /// No description provided for @pinStatusOff.
  ///
  /// In pt, this message translates to:
  /// **'PIN desativado'**
  String get pinStatusOff;

  /// No description provided for @pinEnableAction.
  ///
  /// In pt, this message translates to:
  /// **'Ativar PIN'**
  String get pinEnableAction;

  /// No description provided for @pinChangeAction.
  ///
  /// In pt, this message translates to:
  /// **'Alterar PIN'**
  String get pinChangeAction;

  /// No description provided for @pinDisableAction.
  ///
  /// In pt, this message translates to:
  /// **'Desativar PIN'**
  String get pinDisableAction;

  /// No description provided for @pinEnterCurrent.
  ///
  /// In pt, this message translates to:
  /// **'Digite o PIN atual'**
  String get pinEnterCurrent;

  /// No description provided for @pinEnterNew.
  ///
  /// In pt, this message translates to:
  /// **'Escolha um PIN de 4 dígitos'**
  String get pinEnterNew;

  /// No description provided for @pinConfirmNew.
  ///
  /// In pt, this message translates to:
  /// **'Digite o PIN de novo'**
  String get pinConfirmNew;

  /// No description provided for @pinMismatch.
  ///
  /// In pt, this message translates to:
  /// **'Os PINs não coincidem. Tente de novo.'**
  String get pinMismatch;

  /// No description provided for @pinWrong.
  ///
  /// In pt, this message translates to:
  /// **'PIN incorreto'**
  String get pinWrong;

  /// No description provided for @pinLockMessage.
  ///
  /// In pt, this message translates to:
  /// **'Digite seu PIN'**
  String get pinLockMessage;

  /// No description provided for @pinWaitMessage.
  ///
  /// In pt, this message translates to:
  /// **'Tente de novo em {time}'**
  String pinWaitMessage(String time);

  /// No description provided for @pinEraseAction.
  ///
  /// In pt, this message translates to:
  /// **'Apagar'**
  String get pinEraseAction;

  /// No description provided for @pinDotsSemantics.
  ///
  /// In pt, this message translates to:
  /// **'{typed} de {total} dígitos'**
  String pinDotsSemantics(int typed, int total);

  /// No description provided for @biometricsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Desbloquear com biometria'**
  String get biometricsTitle;

  /// No description provided for @biometricsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Face ID ou digital, conforme o aparelho. O PIN continua valendo como reserva.'**
  String get biometricsSubtitle;

  /// No description provided for @biometricsUseAction.
  ///
  /// In pt, this message translates to:
  /// **'Usar biometria'**
  String get biometricsUseAction;

  /// No description provided for @biometricsReason.
  ///
  /// In pt, this message translates to:
  /// **'Desbloqueie o Mesada'**
  String get biometricsReason;

  /// No description provided for @biometricsUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Não deu para ligar a biometria neste aparelho.'**
  String get biometricsUnavailable;

  /// No description provided for @settingsHelpSection.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda'**
  String get settingsHelpSection;

  /// No description provided for @settingsHelpSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Introdução, contato e sobre'**
  String get settingsHelpSubtitle;

  /// No description provided for @helpSeeIntroAction.
  ///
  /// In pt, this message translates to:
  /// **'Ver introdução'**
  String get helpSeeIntroAction;

  /// No description provided for @helpContactAction.
  ///
  /// In pt, this message translates to:
  /// **'Falar com a gente'**
  String get helpContactAction;

  /// No description provided for @helpContactCopied.
  ///
  /// In pt, this message translates to:
  /// **'E-mail copiado'**
  String get helpContactCopied;

  /// No description provided for @settingsAboutSection.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get settingsAboutSection;

  /// No description provided for @aboutDataLocal.
  ///
  /// In pt, this message translates to:
  /// **'Os dados ficam neste aparelho.'**
  String get aboutDataLocal;

  /// No description provided for @introSkipAction.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get introSkipAction;

  /// No description provided for @introNextAction.
  ///
  /// In pt, this message translates to:
  /// **'Próximo'**
  String get introNextAction;

  /// No description provided for @introStartAction.
  ///
  /// In pt, this message translates to:
  /// **'Começar'**
  String get introStartAction;

  /// No description provided for @introProgress.
  ///
  /// In pt, this message translates to:
  /// **'Cartão {current} de {total}'**
  String introProgress(int current, int total);

  /// No description provided for @intro1Title.
  ///
  /// In pt, this message translates to:
  /// **'Seus filhos'**
  String get intro1Title;

  /// No description provided for @intro1Body.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre cada filho e a mesada dele.'**
  String get intro1Body;

  /// No description provided for @intro2Title.
  ///
  /// In pt, this message translates to:
  /// **'As regras'**
  String get intro2Title;

  /// No description provided for @intro2Body.
  ///
  /// In pt, this message translates to:
  /// **'Defina o que ganha e o que desconta.'**
  String get intro2Body;

  /// No description provided for @intro3Title.
  ///
  /// In pt, this message translates to:
  /// **'Lançar'**
  String get intro3Title;

  /// No description provided for @intro3Body.
  ///
  /// In pt, this message translates to:
  /// **'Toque em + ou − e o saldo muda na hora.'**
  String get intro3Body;

  /// No description provided for @intro4Title.
  ///
  /// In pt, this message translates to:
  /// **'Os dois responsáveis'**
  String get intro4Title;

  /// No description provided for @intro4Body.
  ///
  /// In pt, this message translates to:
  /// **'Os dois responsáveis veem os mesmos números em tempo real. Dá para ativar depois, em Ajustes.'**
  String get intro4Body;

  /// No description provided for @sharingPitch.
  ///
  /// In pt, this message translates to:
  /// **'Os dois responsáveis veem os mesmos números, em tempo real, cada um no seu aparelho.'**
  String get sharingPitch;

  /// No description provided for @sharingOtherNeedsApp.
  ///
  /// In pt, this message translates to:
  /// **'O outro responsável instala o Mesada no aparelho dele (com o acesso ao app dele), cria a conta e entra com o código que você enviar.'**
  String get sharingOtherNeedsApp;

  /// No description provided for @sharingLocalOnly.
  ///
  /// In pt, this message translates to:
  /// **'Hoje os dados ficam só neste aparelho.'**
  String get sharingLocalOnly;

  /// No description provided for @settingsFamilySharingSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar com o outro responsável'**
  String get settingsFamilySharingSubtitle;

  /// No description provided for @sharingStart.
  ///
  /// In pt, this message translates to:
  /// **'Entrar para compartilhar'**
  String get sharingStart;

  /// No description provided for @sharingHint.
  ///
  /// In pt, this message translates to:
  /// **'Você entra com uma conta e os dados deste aparelho sobem para a nuvem. Depois é só convidar o outro responsável.'**
  String get sharingHint;

  /// No description provided for @backToLocalAction.
  ///
  /// In pt, this message translates to:
  /// **'Usar só neste aparelho'**
  String get backToLocalAction;

  /// No description provided for @accessTrialBanner.
  ///
  /// In pt, this message translates to:
  /// **'Teste grátis: {days, plural, =1{falta 1 dia} other{faltam {days} dias}}'**
  String accessTrialBanner(int days);

  /// No description provided for @accessReadOnlyBanner.
  ///
  /// In pt, this message translates to:
  /// **'O teste acabou: só leitura.'**
  String get accessReadOnlyBanner;

  /// No description provided for @accessBuyAction.
  ///
  /// In pt, this message translates to:
  /// **'Comprar'**
  String get accessBuyAction;

  /// No description provided for @errorReadOnly.
  ///
  /// In pt, this message translates to:
  /// **'O teste acabou. Compre o app para lançar e editar.'**
  String get errorReadOnly;

  /// No description provided for @purchaseTitle.
  ///
  /// In pt, this message translates to:
  /// **'Comprar o Mesada'**
  String get purchaseTitle;

  /// No description provided for @purchasePitch.
  ///
  /// In pt, this message translates to:
  /// **'Uma compra única libera o app neste aparelho para sempre, sem mensalidade.'**
  String get purchasePitch;

  /// No description provided for @purchaseSharingNote.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar com o outro responsável é uma assinatura à parte, em Ajustes › Família. Quem recebe o convite precisa ter o próprio acesso ao app.'**
  String get purchaseSharingNote;

  /// No description provided for @purchaseBuyAction.
  ///
  /// In pt, this message translates to:
  /// **'Comprar por {price}'**
  String purchaseBuyAction(String price);

  /// No description provided for @purchaseRestoreAction.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar compras'**
  String get purchaseRestoreAction;

  /// No description provided for @purchaseRestoreEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma compra encontrada nesta conta da loja.'**
  String get purchaseRestoreEmpty;

  /// No description provided for @purchaseStoreUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'A loja não respondeu agora. Tente de novo mais tarde.'**
  String get purchaseStoreUnavailable;

  /// No description provided for @purchaseOwned.
  ///
  /// In pt, this message translates to:
  /// **'Você já tem o app. Obrigado!'**
  String get purchaseOwned;

  /// No description provided for @settingsPurchaseTile.
  ///
  /// In pt, this message translates to:
  /// **'Comprar o app'**
  String get settingsPurchaseTile;

  /// No description provided for @settingsPurchaseReadOnly.
  ///
  /// In pt, this message translates to:
  /// **'O teste acabou: só leitura'**
  String get settingsPurchaseReadOnly;

  /// No description provided for @sharingSubscribeHint.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar é uma assinatura por família: quem cria a família assina, e o outro responsável só precisa ter o app.'**
  String get sharingSubscribeHint;

  /// No description provided for @sharingSubscribeAction.
  ///
  /// In pt, this message translates to:
  /// **'Assinar por {price}'**
  String sharingSubscribeAction(String price);
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
