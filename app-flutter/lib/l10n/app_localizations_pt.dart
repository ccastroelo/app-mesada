// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Mesada';

  @override
  String get navChildren => 'Filhos';

  @override
  String get navRules => 'Regras';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get welcomeTitle =>
      'A mesada dos seus filhos, em dia, com os dois responsáveis.';

  @override
  String get continueWithGoogle => 'Continuar com o Google';

  @override
  String get continueWithEmail => 'Entrar com e-mail';

  @override
  String get signInTitle => 'Entrar';

  @override
  String get signUpTitle => 'Criar conta';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get signInAction => 'Entrar';

  @override
  String get signUpAction => 'Criar conta';

  @override
  String get switchToSignUp => 'Não tem conta? Criar conta';

  @override
  String get switchToSignIn => 'Já tem conta? Entrar';

  @override
  String get forgotPassword => 'Esqueci a senha';

  @override
  String get passwordResetSent =>
      'Enviamos um e-mail para você redefinir a senha.';

  @override
  String get emailInvalid => 'Digite um e-mail válido.';

  @override
  String get passwordTooShort => 'A senha precisa ter pelo menos 6 caracteres.';

  @override
  String get errorInvalidCredentials => 'E-mail ou senha incorretos.';

  @override
  String get errorInvalidEmail => 'Esse e-mail não parece válido.';

  @override
  String get errorEmailInUse => 'Já existe uma conta com esse e-mail.';

  @override
  String get errorWeakPassword =>
      'Escolha uma senha com pelo menos 6 caracteres.';

  @override
  String get errorNoConnection => 'Sem conexão. Tente de novo.';

  @override
  String get errorInvalidInvite => 'Código inválido, expirado ou já usado.';

  @override
  String get errorPermissionDenied => 'Você não tem permissão para isso.';

  @override
  String get errorUnexpected => 'Algo deu errado. Tente de novo.';

  @override
  String get familyChoiceTitle => 'Sua família';

  @override
  String get familyChoiceSubtitle =>
      'Crie uma família nova ou entre na que o outro responsável já criou.';

  @override
  String get createFamilyOption => 'Criar uma família';

  @override
  String get haveCodeOption => 'Tenho um código';

  @override
  String get createFamilyTitle => 'Nova família';

  @override
  String get familyNameLabel => 'Nome da família';

  @override
  String get familyNameHint => 'Família Castro';

  @override
  String get familyNameRequired => 'Digite um nome.';

  @override
  String get createFamilyAction => 'Criar família';

  @override
  String get joinFamilyTitle => 'Entrar com código';

  @override
  String get inviteCodeLabel => 'Código de convite';

  @override
  String get joinFamilyAction => 'Entrar na família';

  @override
  String get tryAgain => 'Tentar de novo';

  @override
  String get signOutAction => 'Sair';

  @override
  String get settingsFamilySection => 'Família';

  @override
  String get settingsInviteTile => 'Convidar outro responsável';

  @override
  String get settingsAccountSection => 'Conta';

  @override
  String get inviteDialogTitle => 'Código de convite';

  @override
  String get inviteDialogBody =>
      'Peça para o outro responsável escolher “Tenho um código” e digitar este código. Vale por 2 dias e só pode ser usado uma vez.';

  @override
  String get inviteCopy => 'Copiar';

  @override
  String get inviteShare => 'Compartilhar';

  @override
  String get inviteCopied => 'Código copiado';

  @override
  String inviteShareText(String code) {
    return 'Entre na nossa família no app Mesada com o código $code.';
  }

  @override
  String get close => 'Fechar';

  @override
  String get cancelAction => 'Cancelar';

  @override
  String get saveAction => 'Salvar';

  @override
  String get editAction => 'Editar';

  @override
  String get deleteAction => 'Excluir';

  @override
  String get reorderAction => 'Reordenar';

  @override
  String get doneAction => 'Concluir';

  @override
  String get rulesRewardsSection => 'Recompensas';

  @override
  String get rulesDiscountsSection => 'Descontos';

  @override
  String get ruleRewardLabel => 'Recompensa';

  @override
  String get ruleDiscountLabel => 'Desconto';

  @override
  String ruleSubtitleReward(String value) {
    return 'Recompensa · $value';
  }

  @override
  String ruleSubtitleDiscount(String value) {
    return 'Desconto · $value';
  }

  @override
  String get newRuleAction => 'Nova regra';

  @override
  String get newRuleTitle => 'Nova regra';

  @override
  String get editRuleTitle => 'Editar regra';

  @override
  String get ruleDescriptionLabel => 'Descrição';

  @override
  String get ruleDescriptionRequired => 'Digite uma descrição.';

  @override
  String get ruleValueLabel => 'Valor';

  @override
  String get rulesEmptyTitle => 'Nenhuma regra ainda';

  @override
  String get rulesEmptyBody => 'Use as sugestões ou crie a sua primeira regra.';

  @override
  String get useSuggestionsAction => 'Usar sugestões';

  @override
  String deleteRuleTitle(String name) {
    return 'Excluir “$name”?';
  }

  @override
  String get deleteRuleBody =>
      'Isso remove os lançamentos dessa regra de todos os filhos.';

  @override
  String get ruleDeleted => 'Regra excluída';
}

/// The translations for Portuguese, as used in Portugal (`pt_PT`).
class AppLocalizationsPtPt extends AppLocalizationsPt {
  AppLocalizationsPtPt() : super('pt_PT');

  @override
  String get appTitle => 'Mesada';

  @override
  String get navChildren => 'Filhos';

  @override
  String get navRules => 'Regras';

  @override
  String get navSettings => 'Definições';

  @override
  String get welcomeTitle =>
      'A mesada dos seus filhos, em dia, com os dois responsáveis.';

  @override
  String get continueWithGoogle => 'Continuar com o Google';

  @override
  String get continueWithEmail => 'Entrar com e-mail';

  @override
  String get signInTitle => 'Entrar';

  @override
  String get signUpTitle => 'Criar conta';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Palavra-passe';

  @override
  String get signInAction => 'Entrar';

  @override
  String get signUpAction => 'Criar conta';

  @override
  String get switchToSignUp => 'Não tem conta? Criar conta';

  @override
  String get switchToSignIn => 'Já tem conta? Entrar';

  @override
  String get forgotPassword => 'Esqueci-me da palavra-passe';

  @override
  String get passwordResetSent =>
      'Enviámos um e-mail para redefinir a palavra-passe.';

  @override
  String get emailInvalid => 'Introduza um e-mail válido.';

  @override
  String get passwordTooShort =>
      'A palavra-passe tem de ter pelo menos 6 caracteres.';

  @override
  String get errorInvalidCredentials => 'E-mail ou palavra-passe incorretos.';

  @override
  String get errorInvalidEmail => 'Esse e-mail não parece válido.';

  @override
  String get errorEmailInUse => 'Já existe uma conta com esse e-mail.';

  @override
  String get errorWeakPassword =>
      'Escolha uma palavra-passe com pelo menos 6 caracteres.';

  @override
  String get errorNoConnection => 'Sem ligação. Tente novamente.';

  @override
  String get errorInvalidInvite => 'Código inválido, expirado ou já utilizado.';

  @override
  String get errorPermissionDenied => 'Não tem permissão para isso.';

  @override
  String get errorUnexpected => 'Algo correu mal. Tente novamente.';

  @override
  String get familyChoiceTitle => 'A sua família';

  @override
  String get familyChoiceSubtitle =>
      'Crie uma família nova ou entre na que o outro responsável já criou.';

  @override
  String get createFamilyOption => 'Criar uma família';

  @override
  String get haveCodeOption => 'Tenho um código';

  @override
  String get createFamilyTitle => 'Nova família';

  @override
  String get familyNameLabel => 'Nome da família';

  @override
  String get familyNameHint => 'Família Castro';

  @override
  String get familyNameRequired => 'Introduza um nome.';

  @override
  String get createFamilyAction => 'Criar família';

  @override
  String get joinFamilyTitle => 'Entrar com código';

  @override
  String get inviteCodeLabel => 'Código de convite';

  @override
  String get joinFamilyAction => 'Entrar na família';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get signOutAction => 'Terminar sessão';

  @override
  String get settingsFamilySection => 'Família';

  @override
  String get settingsInviteTile => 'Convidar outro responsável';

  @override
  String get settingsAccountSection => 'Conta';

  @override
  String get inviteDialogTitle => 'Código de convite';

  @override
  String get inviteDialogBody =>
      'Peça ao outro responsável para escolher “Tenho um código” e introduzir este código. É válido por 2 dias e só pode ser utilizado uma vez.';

  @override
  String get inviteCopy => 'Copiar';

  @override
  String get inviteShare => 'Partilhar';

  @override
  String get inviteCopied => 'Código copiado';

  @override
  String inviteShareText(String code) {
    return 'Entre na nossa família na app Mesada com o código $code.';
  }

  @override
  String get close => 'Fechar';

  @override
  String get cancelAction => 'Cancelar';

  @override
  String get saveAction => 'Guardar';

  @override
  String get editAction => 'Editar';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get reorderAction => 'Reordenar';

  @override
  String get doneAction => 'Concluir';

  @override
  String get rulesRewardsSection => 'Recompensas';

  @override
  String get rulesDiscountsSection => 'Descontos';

  @override
  String get ruleRewardLabel => 'Recompensa';

  @override
  String get ruleDiscountLabel => 'Desconto';

  @override
  String ruleSubtitleReward(String value) {
    return 'Recompensa · $value';
  }

  @override
  String ruleSubtitleDiscount(String value) {
    return 'Desconto · $value';
  }

  @override
  String get newRuleAction => 'Nova regra';

  @override
  String get newRuleTitle => 'Nova regra';

  @override
  String get editRuleTitle => 'Editar regra';

  @override
  String get ruleDescriptionLabel => 'Descrição';

  @override
  String get ruleDescriptionRequired => 'Introduza uma descrição.';

  @override
  String get ruleValueLabel => 'Valor';

  @override
  String get rulesEmptyTitle => 'Ainda não há regras';

  @override
  String get rulesEmptyBody => 'Use as sugestões ou crie a sua primeira regra.';

  @override
  String get useSuggestionsAction => 'Usar sugestões';

  @override
  String deleteRuleTitle(String name) {
    return 'Eliminar “$name”?';
  }

  @override
  String get deleteRuleBody =>
      'Isto remove os lançamentos desta regra de todos os filhos.';

  @override
  String get ruleDeleted => 'Regra eliminada';
}
