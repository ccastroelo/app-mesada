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
  String get familyDefaultName => 'Mi familia';

  @override
  String get settingsFamilyLocalOnly => 'Solo en este dispositivo';

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

  @override
  String get childLedgerZeroMenu => 'Poner a cero';

  @override
  String get childLedgerZeroAllMenu => 'Poner a cero todos';

  @override
  String get childRulesMenu => 'Reglas de este hijo';

  @override
  String get childRulesSubtitle =>
      'Desactivar una regla guarda su cantidad, fuera del saldo.';

  @override
  String zeroChildTitle(String name) {
    return '¿Poner a cero los registros de $name?';
  }

  @override
  String get zeroAllTitle => '¿Poner a cero los registros de todos los hijos?';

  @override
  String get zeroBody => 'Las cantidades vuelven a cero. La mesada no cambia.';

  @override
  String get zeroAction => 'Poner a cero';

  @override
  String get entriesZeroed => 'Registros puestos a cero';

  @override
  String get undoAction => 'Deshacer';

  @override
  String increaseSemantics(String description, int quantity) {
    return 'Aumentar $description, cantidad $quantity';
  }

  @override
  String decreaseSemantics(String description, int quantity) {
    return 'Disminuir $description, cantidad $quantity';
  }

  @override
  String get childLedgerEmptyTitle => 'Todavía no hay reglas';

  @override
  String get childLedgerEmptyBody =>
      'Crea reglas en la pestaña Reglas para empezar a registrar.';

  @override
  String childLedgerAllOffTitle(String name) {
    return 'Todas las reglas están desactivadas para $name';
  }

  @override
  String get sendReportAction => 'Enviar informe';

  @override
  String reportTitle(String name) {
    return 'Mesada de $name';
  }

  @override
  String reportGeneratedAt(String date) {
    return 'Generado el $date';
  }

  @override
  String get reportRuleColumn => 'Regla';

  @override
  String get reportValueColumn => 'Valor';

  @override
  String get reportQuantityColumn => 'Cant.';

  @override
  String get reportTotalColumn => 'Total';

  @override
  String get reportEmpty => 'Todavía no hay registros.';

  @override
  String reportSummary(String name, String allowance, String balance) {
    return '$name — mesada $allowance, saldo $balance.';
  }

  @override
  String get settingsSecuritySection => 'Seguridad';

  @override
  String get securityExplanation =>
      'El PIN se queda solo en este dispositivo y se pide cuando la app pasa 30 segundos cerrada.';

  @override
  String get pinSectionTitle => 'PIN';

  @override
  String get pinStatusOn => 'PIN activado';

  @override
  String get pinStatusOff => 'PIN desactivado';

  @override
  String get pinEnableAction => 'Activar el PIN';

  @override
  String get pinChangeAction => 'Cambiar el PIN';

  @override
  String get pinDisableAction => 'Desactivar el PIN';

  @override
  String get pinEnterCurrent => 'Escribe el PIN actual';

  @override
  String get pinEnterNew => 'Elige un PIN de 4 dígitos';

  @override
  String get pinConfirmNew => 'Escribe el PIN otra vez';

  @override
  String get pinMismatch => 'Los PIN no coinciden. Inténtalo otra vez.';

  @override
  String get pinWrong => 'PIN incorrecto';

  @override
  String get pinLockMessage => 'Escribe tu PIN';

  @override
  String pinWaitMessage(String time) {
    return 'Inténtalo otra vez en $time';
  }

  @override
  String get pinEraseAction => 'Borrar';

  @override
  String pinDotsSemantics(int typed, int total) {
    return '$typed de $total dígitos';
  }

  @override
  String get biometricsTitle => 'Desbloquear con biometría';

  @override
  String get biometricsSubtitle =>
      'Face ID o huella, según el dispositivo. El PIN sigue valiendo como respaldo.';

  @override
  String get biometricsUseAction => 'Usar biometría';

  @override
  String get biometricsReason => 'Desbloquea Mesada';

  @override
  String get biometricsUnavailable =>
      'No se pudo activar la biometría en este dispositivo.';

  @override
  String get settingsHelpSection => 'Ayuda';

  @override
  String get settingsHelpSubtitle => 'Introducción, contacto y acerca de';

  @override
  String get helpSeeIntroAction => 'Ver la introducción';

  @override
  String get helpContactAction => 'Habla con nosotros';

  @override
  String get helpContactCopied => 'Correo copiado';

  @override
  String get settingsAboutSection => 'Acerca de';

  @override
  String get aboutDataLocal => 'Los datos se quedan en este dispositivo.';

  @override
  String get introSkipAction => 'Saltar';

  @override
  String get introNextAction => 'Siguiente';

  @override
  String get introStartAction => 'Empezar';

  @override
  String introProgress(int current, int total) {
    return 'Tarjeta $current de $total';
  }

  @override
  String get intro1Title => 'Tus hijos';

  @override
  String get intro1Body => 'Registra cada hijo y su mesada.';

  @override
  String get intro2Title => 'Las reglas';

  @override
  String get intro2Body => 'Define qué gana y qué descuenta.';

  @override
  String get intro3Title => 'Registrar';

  @override
  String get intro3Body => 'Toca + o − y el saldo cambia al instante.';

  @override
  String get intro4Title => 'Los dos responsables';

  @override
  String get intro4Body =>
      'Los dos responsables ven los mismos números en tiempo real. Puedes activarlo más tarde, en Ajustes.';

  @override
  String get sharingPitch =>
      'Los dos responsables ven los mismos números, en tiempo real, cada uno en su dispositivo.';

  @override
  String get sharingOtherNeedsApp =>
      'El otro responsable instala Mesada en su dispositivo (con su propio acceso a la app), crea la cuenta y entra con el código que le envíes.';

  @override
  String get sharingLocalOnly =>
      'Por ahora los datos se quedan solo en este dispositivo.';

  @override
  String get settingsFamilySharingSubtitle =>
      'Compartir con el otro responsable';

  @override
  String get sharingStart => 'Entrar para compartir';

  @override
  String get sharingHint =>
      'Entras con una cuenta y los datos de este dispositivo suben a la nube. Después invitas al otro responsable.';

  @override
  String get backToLocalAction => 'Usar solo este dispositivo';
}
