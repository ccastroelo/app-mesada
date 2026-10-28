// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Mesada';

  @override
  String get navChildren => 'Hijos';

  @override
  String get navRules => 'Reglas';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get welcomeTitle =>
      'La paga de tus hijos, al día, con los dos responsables.';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get continueWithEmail => 'Entrar con correo';

  @override
  String get signInTitle => 'Entrar';

  @override
  String get signUpTitle => 'Crear cuenta';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get signInAction => 'Entrar';

  @override
  String get signUpAction => 'Crear cuenta';

  @override
  String get switchToSignUp => '¿No tienes cuenta? Crear cuenta';

  @override
  String get switchToSignIn => '¿Ya tienes cuenta? Entrar';

  @override
  String get forgotPassword => 'Olvidé la contraseña';

  @override
  String get passwordResetSent =>
      'Te enviamos un correo para restablecer la contraseña.';

  @override
  String get emailInvalid => 'Escribe un correo válido.';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 6 caracteres.';

  @override
  String get errorInvalidCredentials => 'Correo o contraseña incorrectos.';

  @override
  String get errorInvalidEmail => 'Ese correo no parece válido.';

  @override
  String get errorEmailInUse => 'Ya existe una cuenta con ese correo.';

  @override
  String get errorWeakPassword =>
      'Elige una contraseña de al menos 6 caracteres.';

  @override
  String get errorNoConnection => 'Sin conexión. Inténtalo de nuevo.';

  @override
  String get errorInvalidInvite =>
      'El código no es válido, caducó o ya se usó.';

  @override
  String get errorPermissionDenied => 'No tienes permiso para eso.';

  @override
  String get errorUnexpected => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get familyChoiceTitle => 'Tu familia';

  @override
  String get familyChoiceSubtitle =>
      'Crea una familia nueva o entra en la que ya creó el otro responsable.';

  @override
  String get createFamilyOption => 'Crear una familia';

  @override
  String get haveCodeOption => 'Tengo un código';

  @override
  String get createFamilyTitle => 'Nueva familia';

  @override
  String get familyNameLabel => 'Nombre de la familia';

  @override
  String get familyNameHint => 'Familia Castro';

  @override
  String get familyNameRequired => 'Escribe un nombre.';

  @override
  String get createFamilyAction => 'Crear familia';

  @override
  String get joinFamilyTitle => 'Entrar con código';

  @override
  String get inviteCodeLabel => 'Código de invitación';

  @override
  String get joinFamilyAction => 'Entrar en la familia';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get signOutAction => 'Salir';

  @override
  String get settingsFamilySection => 'Familia';

  @override
  String get settingsInviteTile => 'Invitar al otro responsable';

  @override
  String get settingsAccountSection => 'Cuenta';

  @override
  String get inviteDialogTitle => 'Código de invitación';

  @override
  String get inviteDialogBody =>
      'Pide al otro responsable que elija “Tengo un código” y escriba este código. Vale 2 días y solo se puede usar una vez.';

  @override
  String get inviteCopy => 'Copiar';

  @override
  String get inviteShare => 'Compartir';

  @override
  String get inviteCopied => 'Código copiado';

  @override
  String inviteShareText(String code) {
    return 'Entra en nuestra familia en la app Mesada con el código $code.';
  }

  @override
  String get close => 'Cerrar';

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
  String get doneAction => 'Listo';

  @override
  String get rulesRewardsSection => 'Recompensas';

  @override
  String get rulesDiscountsSection => 'Descuentos';

  @override
  String get ruleRewardLabel => 'Recompensa';

  @override
  String get ruleDiscountLabel => 'Descuento';

  @override
  String ruleSubtitleReward(String value) {
    return 'Recompensa · $value';
  }

  @override
  String ruleSubtitleDiscount(String value) {
    return 'Descuento · $value';
  }

  @override
  String get newRuleAction => 'Nueva regla';

  @override
  String get newRuleTitle => 'Nueva regla';

  @override
  String get editRuleTitle => 'Editar regla';

  @override
  String get ruleDescriptionLabel => 'Descripción';

  @override
  String get ruleDescriptionRequired => 'Escribe una descripción.';

  @override
  String get ruleValueLabel => 'Valor';

  @override
  String get rulesEmptyTitle => 'Aún no hay reglas';

  @override
  String get rulesEmptyBody => 'Usa las sugerencias o crea tu primera regla.';

  @override
  String get useSuggestionsAction => 'Usar sugerencias';

  @override
  String deleteRuleTitle(String name) {
    return '¿Eliminar “$name”?';
  }

  @override
  String get deleteRuleBody =>
      'Esto elimina los registros de esta regla de todos los hijos.';

  @override
  String get ruleDeleted => 'Regla eliminada';

  @override
  String get childrenEmptyTitle => 'Añade a tu primer hijo para empezar';

  @override
  String get addChildAction => 'Añadir hijo';

  @override
  String get newChildTitle => 'Nuevo hijo';

  @override
  String get editChildTitle => 'Editar hijo';

  @override
  String get childNameLabel => 'Nombre';

  @override
  String get childNameRequired => 'Escribe el nombre.';

  @override
  String get childEmailLabel => 'Correo (opcional)';

  @override
  String get childEmailInvalid =>
      'Escribe un correo válido o déjalo en blanco.';

  @override
  String get childAllowanceLabel => 'Paga';

  @override
  String get childPhotoAction => 'Elegir foto';

  @override
  String get childPhotoRemove => 'Quitar foto';

  @override
  String childAllowanceSubtitle(String value) {
    return 'Paga $value';
  }

  @override
  String get balanceLabel => 'Saldo';

  @override
  String balanceSemantics(String value) {
    return 'Saldo $value';
  }

  @override
  String deleteChildTitle(String name) {
    return '¿Eliminar a $name?';
  }

  @override
  String get deleteChildBody => 'Esto también elimina todos sus registros.';

  @override
  String get childDeleted => 'Hijo eliminado';
}
