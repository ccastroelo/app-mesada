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
  String get familyDefaultName => 'Minha família';

  @override
  String get settingsFamilyLocalOnly => 'Só neste aparelho';

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

  @override
  String get childrenEmptyTitle => 'Adicione o primeiro filho para começar';

  @override
  String get addChildAction => 'Adicionar filho';

  @override
  String get newChildTitle => 'Novo filho';

  @override
  String get editChildTitle => 'Editar filho';

  @override
  String get childNameLabel => 'Nome';

  @override
  String get childNameRequired => 'Digite o nome.';

  @override
  String get childEmailLabel => 'E-mail (opcional)';

  @override
  String get childEmailInvalid => 'Digite um e-mail válido ou deixe em branco.';

  @override
  String get childAllowanceLabel => 'Mesada';

  @override
  String get childPhotoAction => 'Escolher foto';

  @override
  String get childPhotoRemove => 'Remover foto';

  @override
  String childAllowanceSubtitle(String value) {
    return 'Mesada $value';
  }

  @override
  String get balanceLabel => 'Saldo';

  @override
  String balanceSemantics(String value) {
    return 'Saldo $value';
  }

  @override
  String deleteChildTitle(String name) {
    return 'Excluir $name?';
  }

  @override
  String get deleteChildBody => 'Isso remove também todos os lançamentos dele.';

  @override
  String get childDeleted => 'Filho excluído';

  @override
  String get childLedgerZeroMenu => 'Zerar lançamentos';

  @override
  String get childLedgerZeroAllMenu => 'Zerar lançamentos de todos';

  @override
  String get childRulesMenu => 'Regras deste filho';

  @override
  String get childRulesSubtitle =>
      'Desativar guarda a quantidade, fora do saldo.';

  @override
  String zeroChildTitle(String name) {
    return 'Zerar lançamentos de $name?';
  }

  @override
  String get zeroAllTitle => 'Zerar lançamentos de todos os filhos?';

  @override
  String get zeroBody => 'As quantidades voltam a zero. A mesada não muda.';

  @override
  String get zeroAction => 'Zerar';

  @override
  String get entriesZeroed => 'Lançamentos zerados';

  @override
  String get undoAction => 'Desfazer';

  @override
  String increaseSemantics(String description, int quantity) {
    return 'Aumentar $description, quantidade $quantity';
  }

  @override
  String decreaseSemantics(String description, int quantity) {
    return 'Diminuir $description, quantidade $quantity';
  }

  @override
  String get childLedgerEmptyTitle => 'Nenhuma regra para lançar';

  @override
  String get childLedgerEmptyBody =>
      'Crie regras na aba Regras para começar a lançar.';

  @override
  String childLedgerAllOffTitle(String name) {
    return 'Todas as regras estão desativadas para $name';
  }

  @override
  String get sendReportAction => 'Enviar relatório';

  @override
  String reportTitle(String name) {
    return 'Mesada de $name';
  }

  @override
  String reportGeneratedAt(String date) {
    return 'Gerado em $date';
  }

  @override
  String get reportRuleColumn => 'Regra';

  @override
  String get reportValueColumn => 'Valor';

  @override
  String get reportQuantityColumn => 'Qtd';

  @override
  String get reportTotalColumn => 'Total';

  @override
  String get reportEmpty => 'Nenhum lançamento até agora.';

  @override
  String reportSummary(String name, String allowance, String balance) {
    return '$name — mesada $allowance, saldo $balance.';
  }

  @override
  String get settingsSecuritySection => 'Segurança';

  @override
  String get securityExplanation =>
      'O PIN fica só neste aparelho e é pedido quando o app passa 30 segundos fechado.';

  @override
  String get pinSectionTitle => 'PIN';

  @override
  String get pinStatusOn => 'PIN ativado';

  @override
  String get pinStatusOff => 'PIN desativado';

  @override
  String get pinEnableAction => 'Ativar PIN';

  @override
  String get pinChangeAction => 'Alterar PIN';

  @override
  String get pinDisableAction => 'Desativar PIN';

  @override
  String get pinEnterCurrent => 'Digite o PIN atual';

  @override
  String get pinEnterNew => 'Escolha um PIN de 4 dígitos';

  @override
  String get pinConfirmNew => 'Digite o PIN de novo';

  @override
  String get pinMismatch => 'Os PINs não coincidem. Tente de novo.';

  @override
  String get pinWrong => 'PIN incorreto';

  @override
  String get pinLockMessage => 'Digite seu PIN';

  @override
  String pinWaitMessage(String time) {
    return 'Tente de novo em $time';
  }

  @override
  String get pinEraseAction => 'Apagar';

  @override
  String pinDotsSemantics(int typed, int total) {
    return '$typed de $total dígitos';
  }

  @override
  String get biometricsTitle => 'Desbloquear com biometria';

  @override
  String get biometricsSubtitle =>
      'Face ID ou digital, conforme o aparelho. O PIN continua valendo como reserva.';

  @override
  String get biometricsUseAction => 'Usar biometria';

  @override
  String get biometricsReason => 'Desbloqueie o Mesada';

  @override
  String get biometricsUnavailable =>
      'Não deu para ligar a biometria neste aparelho.';

  @override
  String get settingsHelpSection => 'Ajuda';

  @override
  String get settingsHelpSubtitle => 'Introdução, contato e sobre';

  @override
  String get helpSeeIntroAction => 'Ver introdução';

  @override
  String get helpContactAction => 'Falar com a gente';

  @override
  String get helpContactCopied => 'E-mail copiado';

  @override
  String get settingsAboutSection => 'Sobre';

  @override
  String get aboutDataLocal => 'Os dados ficam neste aparelho.';

  @override
  String get introSkipAction => 'Pular';

  @override
  String get introNextAction => 'Próximo';

  @override
  String get introStartAction => 'Começar';

  @override
  String introProgress(int current, int total) {
    return 'Cartão $current de $total';
  }

  @override
  String get intro1Title => 'Seus filhos';

  @override
  String get intro1Body => 'Cadastre cada filho e a mesada dele.';

  @override
  String get intro2Title => 'As regras';

  @override
  String get intro2Body => 'Defina o que ganha e o que desconta.';

  @override
  String get intro3Title => 'Lançar';

  @override
  String get intro3Body => 'Toque em + ou − e o saldo muda na hora.';

  @override
  String get intro4Title => 'Os dois responsáveis';

  @override
  String get intro4Body =>
      'Com a assinatura Família, os dois veem os mesmos números em tempo real. Dá para decidir depois.';

  @override
  String get planPitch =>
      'Os dois responsáveis veem os mesmos números, em tempo real, cada um no seu aparelho.';

  @override
  String get planLocalOnly => 'Hoje os dados ficam só neste aparelho.';

  @override
  String get planOneTime => 'Pagamento único, sem mensalidade.';

  @override
  String planBuyAction(String price) {
    return 'Liberar por $price';
  }

  @override
  String get planRestoreAction => 'Restaurar compras';

  @override
  String get planRestoreEmpty =>
      'Nenhuma compra encontrada nesta conta da loja.';

  @override
  String get planStoreUnavailable =>
      'A loja não respondeu agora. Tente de novo mais tarde.';

  @override
  String get planActiveTitle => 'Família liberada';

  @override
  String planActiveSince(String date) {
    return 'Pagamento único, desde $date';
  }

  @override
  String get settingsFamilyPlanSubtitle =>
      'Compartilhar com o outro responsável';

  @override
  String get planStartSharing => 'Entrar para compartilhar';

  @override
  String get planSharingHint =>
      'Você entra com uma conta e os dados deste aparelho sobem para a nuvem. Depois é só convidar o outro responsável.';

  @override
  String get backToLocalAction => 'Usar só neste aparelho';
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
  String get familyDefaultName => 'A minha família';

  @override
  String get settingsFamilyLocalOnly => 'Só neste aparelho';

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

  @override
  String get childrenEmptyTitle => 'Adicione o primeiro filho para começar';

  @override
  String get addChildAction => 'Adicionar filho';

  @override
  String get newChildTitle => 'Novo filho';

  @override
  String get editChildTitle => 'Editar filho';

  @override
  String get childNameLabel => 'Nome';

  @override
  String get childNameRequired => 'Introduza o nome.';

  @override
  String get childEmailLabel => 'E-mail (opcional)';

  @override
  String get childEmailInvalid =>
      'Introduza um e-mail válido ou deixe em branco.';

  @override
  String get childAllowanceLabel => 'Mesada';

  @override
  String get childPhotoAction => 'Escolher fotografia';

  @override
  String get childPhotoRemove => 'Remover fotografia';

  @override
  String childAllowanceSubtitle(String value) {
    return 'Mesada $value';
  }

  @override
  String get balanceLabel => 'Saldo';

  @override
  String balanceSemantics(String value) {
    return 'Saldo $value';
  }

  @override
  String deleteChildTitle(String name) {
    return 'Eliminar $name?';
  }

  @override
  String get deleteChildBody => 'Isto remove também todos os lançamentos dele.';

  @override
  String get childDeleted => 'Filho eliminado';

  @override
  String get childLedgerZeroMenu => 'Zerar lançamentos';

  @override
  String get childLedgerZeroAllMenu => 'Zerar lançamentos de todos';

  @override
  String get childRulesMenu => 'Regras deste filho';

  @override
  String get childRulesSubtitle =>
      'Desativar guarda a quantidade, fora do saldo.';

  @override
  String zeroChildTitle(String name) {
    return 'Zerar lançamentos de $name?';
  }

  @override
  String get zeroAllTitle => 'Zerar lançamentos de todos os filhos?';

  @override
  String get zeroBody => 'As quantidades voltam a zero. A mesada não muda.';

  @override
  String get zeroAction => 'Zerar';

  @override
  String get entriesZeroed => 'Lançamentos zerados';

  @override
  String get undoAction => 'Desfazer';

  @override
  String increaseSemantics(String description, int quantity) {
    return 'Aumentar $description, quantidade $quantity';
  }

  @override
  String decreaseSemantics(String description, int quantity) {
    return 'Diminuir $description, quantidade $quantity';
  }

  @override
  String get childLedgerEmptyTitle => 'Nenhuma regra para lançar';

  @override
  String get childLedgerEmptyBody =>
      'Crie regras no separador Regras para começar a lançar.';

  @override
  String childLedgerAllOffTitle(String name) {
    return 'Todas as regras estão desativadas para $name';
  }

  @override
  String get sendReportAction => 'Enviar relatório';

  @override
  String reportTitle(String name) {
    return 'Mesada de $name';
  }

  @override
  String reportGeneratedAt(String date) {
    return 'Gerado em $date';
  }

  @override
  String get reportRuleColumn => 'Regra';

  @override
  String get reportValueColumn => 'Valor';

  @override
  String get reportQuantityColumn => 'Qtd';

  @override
  String get reportTotalColumn => 'Total';

  @override
  String get reportEmpty => 'Nenhum lançamento até agora.';

  @override
  String reportSummary(String name, String allowance, String balance) {
    return '$name — mesada $allowance, saldo $balance.';
  }

  @override
  String get settingsSecuritySection => 'Segurança';

  @override
  String get securityExplanation =>
      'O PIN fica só neste aparelho e é pedido quando a aplicação passa 30 segundos fechada.';

  @override
  String get pinSectionTitle => 'PIN';

  @override
  String get pinStatusOn => 'PIN ativado';

  @override
  String get pinStatusOff => 'PIN desativado';

  @override
  String get pinEnableAction => 'Ativar PIN';

  @override
  String get pinChangeAction => 'Alterar PIN';

  @override
  String get pinDisableAction => 'Desativar PIN';

  @override
  String get pinEnterCurrent => 'Introduza o PIN atual';

  @override
  String get pinEnterNew => 'Escolha um PIN de 4 dígitos';

  @override
  String get pinConfirmNew => 'Introduza o PIN outra vez';

  @override
  String get pinMismatch => 'Os PIN não coincidem. Tente outra vez.';

  @override
  String get pinWrong => 'PIN incorreto';

  @override
  String get pinLockMessage => 'Introduza o seu PIN';

  @override
  String pinWaitMessage(String time) {
    return 'Tente outra vez em $time';
  }

  @override
  String get pinEraseAction => 'Apagar';

  @override
  String pinDotsSemantics(int typed, int total) {
    return '$typed de $total dígitos';
  }

  @override
  String get biometricsTitle => 'Desbloquear com biometria';

  @override
  String get biometricsSubtitle =>
      'Face ID ou digital, conforme o aparelho. O PIN continua valendo como reserva.';

  @override
  String get biometricsUseAction => 'Usar biometria';

  @override
  String get biometricsReason => 'Desbloqueie o Mesada';

  @override
  String get biometricsUnavailable =>
      'Não deu para ligar a biometria neste aparelho.';

  @override
  String get settingsHelpSection => 'Ajuda';

  @override
  String get settingsHelpSubtitle => 'Introdução, contacto e sobre';

  @override
  String get helpSeeIntroAction => 'Ver introdução';

  @override
  String get helpContactAction => 'Falar connosco';

  @override
  String get helpContactCopied => 'E-mail copiado';

  @override
  String get settingsAboutSection => 'Sobre';

  @override
  String get aboutDataLocal => 'Os dados ficam neste aparelho.';

  @override
  String get introSkipAction => 'Saltar';

  @override
  String get introNextAction => 'Seguinte';

  @override
  String get introStartAction => 'Começar';

  @override
  String introProgress(int current, int total) {
    return 'Cartão $current de $total';
  }

  @override
  String get intro1Title => 'Os seus filhos';

  @override
  String get intro1Body => 'Registe cada filho e a mesada dele.';

  @override
  String get intro2Title => 'As regras';

  @override
  String get intro2Body => 'Defina o que ganha e o que desconta.';

  @override
  String get intro3Title => 'Lançar';

  @override
  String get intro3Body => 'Toque em + ou − e o saldo muda na hora.';

  @override
  String get intro4Title => 'Os dois responsáveis';

  @override
  String get intro4Body =>
      'Com a subscrição Família, os dois veem os mesmos números em tempo real. Pode decidir mais tarde.';

  @override
  String get planPitch =>
      'Os dois responsáveis veem os mesmos números, em tempo real, cada um no seu aparelho.';

  @override
  String get planLocalOnly => 'Hoje os dados ficam só neste aparelho.';

  @override
  String get planOneTime => 'Pagamento único, sem mensalidade.';

  @override
  String planBuyAction(String price) {
    return 'Desbloquear por $price';
  }

  @override
  String get planRestoreAction => 'Restaurar compras';

  @override
  String get planRestoreEmpty =>
      'Nenhuma compra encontrada nesta conta da loja.';

  @override
  String get planStoreUnavailable =>
      'A loja não respondeu agora. Tente outra vez mais tarde.';

  @override
  String get planActiveTitle => 'Família desbloqueada';

  @override
  String planActiveSince(String date) {
    return 'Pagamento único, desde $date';
  }

  @override
  String get settingsFamilyPlanSubtitle => 'Partilhar com o outro responsável';

  @override
  String get planStartSharing => 'Entrar para partilhar';

  @override
  String get planSharingHint =>
      'Entra com uma conta e os dados deste aparelho sobem para a nuvem. Depois basta convidar o outro responsável.';

  @override
  String get backToLocalAction => 'Usar só neste aparelho';
}
