// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Forum App';

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get usernameLabel => 'Nombre de usuario';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get signInWithPasskey => 'Sign in with Passkey';

  @override
  String get usePasskey => 'Use Passkey';

  @override
  String get passkeyContinuePrompt => 'Use your passkey to continue';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get pleaseEnterUsername => 'Por favor ingresa tu nombre de usuario';

  @override
  String get pleaseEnterPassword => 'Por favor ingresa tu contraseña';

  @override
  String credentialsSentToDomain(String domain) {
    return 'Tu nombre de usuario y contraseña serán enviados a $domain';
  }

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta? ';

  @override
  String get logIn => 'Iniciar sesión';

  @override
  String get continueButton => 'Continuar';

  @override
  String get registrationNotAvailable => 'Registro no disponible';

  @override
  String get registrationNotAvailableMessage =>
      'El registro no está disponible actualmente. El foro puede estar cerrado o el registro puede estar deshabilitado.';

  @override
  String get webRegistrationRequired => 'Registro web requerido';

  @override
  String get webRegistrationRequiredMessage =>
      'Este foro requiere registro a través del navegador web. Por favor haz clic en el botón de abajo para abrir la página de registro.';

  @override
  String get openRegistrationPage => 'Abrir página de registro';

  @override
  String get loadingAdditionalFields => 'Cargando campos adicionales...';

  @override
  String get pleaseSelectDateOfBirth =>
      'Por favor selecciona tu fecha de nacimiento';

  @override
  String get pleaseEnterLocation => 'Por favor ingresa tu ubicación';

  @override
  String get pleaseIndicateEmailPreference =>
      'Por favor indica tu preferencia de correo electrónico';

  @override
  String get pleaseFillAllRequiredFields =>
      'Por favor completa todos los campos requeridos';

  @override
  String get pleaseAcceptTermsOfService =>
      'Por favor acepta los Términos de Servicio';

  @override
  String get pleaseAcceptPrivacyPolicy =>
      'Por favor acepta la Política de Privacidad';

  @override
  String get registrationError => 'Error de registro';

  @override
  String get registrationFailed =>
      'El registro falló. Por favor verifica tu información.';

  @override
  String get registrationFailedTryAgain =>
      'El registro falló. Por favor intenta de nuevo.';

  @override
  String get registrationInfo => 'Información de registro';

  @override
  String get openWebsite => 'Abrir sitio web';

  @override
  String couldNotOpenForumWebsite(String url) {
    return 'No se pudo abrir el sitio web del foro. Por favor intenta visitar: $url';
  }

  @override
  String get registrationSuccessfulEmailConfirm =>
      '¡Registro exitoso! Por favor revisa tu correo electrónico para confirmar tu cuenta antes de iniciar sesión.';

  @override
  String get registrationSuccessfulPendingApproval =>
      '¡Registro exitoso! Tu cuenta está pendiente de aprobación. Serás notificado cuando tu cuenta sea aprobada.';

  @override
  String get registrationSuccessfulAutoLogin =>
      '¡Registro exitoso! Has sido iniciado sesión automáticamente.';

  @override
  String get welcome => '¡Bienvenido!';

  @override
  String get registrationSuccessful => 'Registro exitoso';

  @override
  String get pleaseLoginWithNewAccount =>
      'Por favor inicia sesión con tu nueva cuenta.';

  @override
  String get forgotPasswordTitle => 'Olvidé mi contraseña';

  @override
  String get usernameOrEmailLabel => 'Nombre de usuario o correo electrónico';

  @override
  String get pleaseEnterUsernameOrEmail =>
      'Por favor ingresa tu nombre de usuario o correo electrónico';

  @override
  String get sendResetLink => 'Enviar enlace de restablecimiento';

  @override
  String get resetLinkSent => 'Enlace de restablecimiento enviado';

  @override
  String get passwordResetInstructionsSent =>
      'Las instrucciones para restablecer tu contraseña han sido enviadas a tu dirección de correo electrónico registrada.';

  @override
  String get resetFailed => 'Restablecimiento fallido';

  @override
  String get unableToSendResetLink =>
      'No se pudo enviar el enlace de restablecimiento. Por favor intenta de nuevo.';

  @override
  String get errorSendingResetLink =>
      'Ocurrió un error al enviar el enlace de restablecimiento. Por favor verifica tu conexión e intenta de nuevo.';

  @override
  String get errorTitle => 'Error';

  @override
  String get okButton => 'Aceptar';

  @override
  String get retryButton => 'Reintentar';

  @override
  String get copyToClipboard => 'Copiar al portapapeles';

  @override
  String get copied => 'Copiado';

  @override
  String get errorMessageCopiedToClipboard =>
      'Mensaje de error copiado al portapapeles';

  @override
  String get dismiss => 'Descartar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get tryAgain => 'Intentar de Nuevo';

  @override
  String get getHelp => 'Obtener ayuda';

  @override
  String get somethingWentWrong => 'Algo salió mal';

  @override
  String get unexpectedErrorOccurred =>
      'Ocurrió un error inesperado. Por favor intenta de nuevo.';

  @override
  String get noInternetConnection => 'Sin conexión a Internet';

  @override
  String get checkInternetConnection =>
      'Por favor verifica tu conexión a Internet e intenta de nuevo.';

  @override
  String get authenticationRequired => 'Autenticación requerida';

  @override
  String get pleaseLoginToContinue => 'Por favor inicia sesión para continuar.';

  @override
  String get forumError => 'Error del foro';

  @override
  String get anErrorOccurred => 'Ocurrió un error';

  @override
  String get accountPendingApproval =>
      'Tu cuenta está pendiente de aprobación. Puedes navegar por el foro pero no puedes publicar hasta que un moderador apruebe tu cuenta.';

  @override
  String get checkEmailToConfirm =>
      'Por favor revisa tu correo electrónico para confirmar tu cuenta. Haz clic en el enlace de confirmación en el correo que te enviamos.';

  @override
  String get checkNewEmailToConfirm =>
      'Por favor revisa tu nueva dirección de correo electrónico para confirmar el cambio. Tu correo anterior permanecerá activo hasta que confirmes el nuevo.';

  @override
  String get emailAddressInvalid =>
      'Tu dirección de correo electrónico parece ser inválida o está rebotando correos. Por favor actualiza tu dirección de correo electrónico en la configuración de la cuenta.';

  @override
  String get accountDisabled =>
      'Tu cuenta ha sido deshabilitada. Por favor contacta a un administrador para obtener asistencia.';

  @override
  String get accountRegistrationRejected =>
      'El registro de tu cuenta fue rechazado. Por favor contacta a un administrador para más información.';

  @override
  String get welcomeToForumCopilot => '¡Bienvenido a Forum Copilot!';

  @override
  String get successfullyLoggedOut => 'Has cerrado sesión exitosamente';

  @override
  String get accountStatusRequiresAttention =>
      'El estado de tu cuenta requiere atención. Por favor contacta a un administrador si tienes preguntas.';

  @override
  String get updateEmail => 'Actualizar correo electrónico';

  @override
  String get resend => 'Reenviar';

  @override
  String get noLatestTopics => 'No hay temas recientes';

  @override
  String get noRecentTopicsToDisplay =>
      'No hay temas recientes para mostrar. Vuelve más tarde para nuevas discusiones.';

  @override
  String get signInToViewLatestTopics =>
      'Inicia sesión para ver temas recientes';

  @override
  String get youNeedToBeSignedInToViewLatestTopics =>
      'Necesitas iniciar sesión para ver temas recientes';

  @override
  String get noUnreadTopics => 'No hay temas sin leer';

  @override
  String get thereAreNoUnreadTopics =>
      'No hay temas sin leer. Vuelve más tarde para nuevas discusiones.';

  @override
  String get youAreAllCaughtUp => '¡Estás al día!';

  @override
  String get signInToViewUnreadTopics =>
      'Inicia sesión para ver temas sin leer';

  @override
  String get youNeedToBeSignedInToViewUnreadTopics =>
      'Necesitas iniciar sesión para ver tus temas sin leer';

  @override
  String get noSubscribedTopics => 'No hay temas suscritos';

  @override
  String get noSubscribedTopicsMessage =>
      'No te has suscrito a ningún tema. Toca el botón de estrella en un tema para suscribirte y recibir notificaciones de nuevas actualizaciones.';

  @override
  String get signInToViewSubscribedTopics =>
      'Inicia sesión para ver temas suscritos';

  @override
  String get youNeedToBeSignedInToViewSubscribedTopics =>
      'Necesitas iniciar sesión para ver tus temas suscritos';

  @override
  String get noParticipatedTopics => 'No hay temas participados';

  @override
  String get topicsYouParticipatedIn =>
      'Los temas en los que has participado se mostrarán aquí.';

  @override
  String get signInToViewParticipatedTopics =>
      'Inicia sesión para ver temas participados';

  @override
  String get youNeedToBeSignedInToViewParticipatedTopics =>
      'Necesitas iniciar sesión para ver temas en los que has participado';

  @override
  String get latest => 'Recientes';

  @override
  String get unread => 'Sin leer';

  @override
  String get subscribed => 'Suscritos';

  @override
  String get participated => 'Participados';

  @override
  String get connectionTimedOut =>
      'La conexión expiró. El sitio puede estar caído o inaccesible.';

  @override
  String get failedToConnectToSite =>
      'Error al conectar con el sitio. El sitio puede estar caído o inaccesible.';

  @override
  String get connectionFailed => 'Error de conexión';

  @override
  String failedToConnectToSiteName(String siteName) {
    return 'Error al conectar con $siteName';
  }

  @override
  String get loading => 'Cargando...';

  @override
  String get newConversation => 'Nueva conversación';

  @override
  String get newMessage => 'Nuevo mensaje';

  @override
  String get appSettings => 'Configuración de la aplicación';

  @override
  String get searchSites => 'Buscar sitios';

  @override
  String get language => 'Idioma';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String get followSystemLanguage => 'Seguir el idioma del sistema';

  @override
  String get all => 'Todo';

  @override
  String get topicsOnly => 'Solo temas';

  @override
  String get titlesOnly => 'Solo títulos';

  @override
  String failedToShareTopic(String error) {
    return 'Error al compartir tema: $error';
  }

  @override
  String get pleaseLoginToSubscribe =>
      'Por favor inicia sesión para null este hilo';

  @override
  String get subscribe => 'Suscribirse';

  @override
  String get unsubscribe => 'Cancelar suscripción';

  @override
  String get failedToSubscribeToThread => 'Error al null hilo';

  @override
  String get youCannotReplyToThisThread => 'No puedes responder a este hilo';

  @override
  String get pleaseWaitForThreadToLoad =>
      'Por favor espera a que el hilo se cargue';

  @override
  String get softDelete => 'Eliminación suave';

  @override
  String get postCanBeRestoredLater =>
      'La publicación puede ser restaurada más tarde';

  @override
  String get hardDelete => 'Eliminación permanente';

  @override
  String get postWillBePermanentlyDeleted =>
      'La publicación será eliminada permanentemente';

  @override
  String get reasonForDeletion => 'Razón de eliminación';

  @override
  String get enterReasonForDeletingPost =>
      'Ingresa la razón para eliminar esta publicación';

  @override
  String get pleaseEnterReasonForDeletion =>
      'Por favor ingresa una razón para la eliminación';

  @override
  String get reportPost => 'Reportar publicación';

  @override
  String get pleaseProvideReasonForReporting =>
      'Por favor proporciona una razón para reportar esta publicación.';

  @override
  String get reason => 'Razón';

  @override
  String get enterReasonForReportingPost =>
      'Ingresa la razón para reportar esta publicación';

  @override
  String get pleaseEnterReason => 'Por favor ingresa una razón';

  @override
  String get submitReport => 'Enviar reporte';

  @override
  String get selectedActions => 'Acciones seleccionadas:';

  @override
  String get thisActionCannotBeUndone => 'Esta acción no se puede deshacer.';

  @override
  String get participantsLabel => 'Participantes';

  @override
  String usernameHasBeenInvited(String username) {
    return '$username ha sido invitado a la conversación';
  }

  @override
  String errorInvitingUser(String error) {
    return 'Error al invitar usuario: $error';
  }

  @override
  String get newTopic => 'Nuevo tema';

  @override
  String get markRead => 'Marcar como leído';

  @override
  String get reportUser => 'Reportar usuario';

  @override
  String get pleaseSelectReasonForReportingUser =>
      'Por favor selecciona un motivo para reportar a este usuario.';

  @override
  String get spamOrAdvertising => 'Spam o publicidad';

  @override
  String get harassmentOrBullying => 'Acoso o intimidación';

  @override
  String get inappropriateContent => 'Contenido inapropiado';

  @override
  String get impersonationOrFakeAccount => 'Suplantación o cuenta falsa';

  @override
  String get otherPleaseSpecify => 'Otro (por favor especifica)';

  @override
  String get pleaseSpecifyReason => 'Por favor especifica el motivo';

  @override
  String get enterReasonForReportingUser =>
      'Ingresa el motivo para reportar a este usuario';

  @override
  String get pleaseSelectReason => 'Por favor selecciona un motivo';

  @override
  String get banUser => 'Bloquear usuario';

  @override
  String get unbanUser => 'Desbanear Usuario';

  @override
  String pleaseSelectReasonForBanningUser(String username) {
    return 'Por favor selecciona un motivo para banear a $username';
  }

  @override
  String get violationOfCommunityGuidelines =>
      'Violación de las pautas de la comunidad';

  @override
  String get harassmentOrAbusiveBehavior => 'Acoso o comportamiento abusivo';

  @override
  String get postingInappropriateContent =>
      'Publicación de contenido inapropiado';

  @override
  String get accountCompromiseOrSecurityIssue =>
      'Compromiso de cuenta o problema de seguridad';

  @override
  String get enterReasonForBanningUser =>
      'Ingresa el motivo para banear a este usuario';

  @override
  String get banUntil => 'Banear hasta';

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String get moreOptions => 'Más opciones';

  @override
  String get leaveConversation => 'Dejar conversación';

  @override
  String get reportConversation => 'Reportar conversación';

  @override
  String get topicClosed => 'Tema cerrado';

  @override
  String get topicOpened => 'Tema abierto';

  @override
  String get topicStickied => 'Tema fijado';

  @override
  String get topicUnstickied => 'Tema desfijado';

  @override
  String cannotEditMessage(String error) {
    return 'No se puede editar este mensaje: $error';
  }

  @override
  String get confirmSpamClean => 'Confirmar Limpieza de Spam';

  @override
  String get handleThreads => 'Gestionar Hilos';

  @override
  String get deleteMessages => 'Eliminar Mensajes';

  @override
  String get deleteConversations => 'Eliminar Conversaciones';

  @override
  String get myForums => 'Mis Foros';

  @override
  String get recentlyVisited => 'Visitados Recientemente';

  @override
  String get explore => 'Explorar';

  @override
  String get forumCopilot => 'Forum Copilot';

  @override
  String get noConversations => 'Sin conversaciones';

  @override
  String get noConversationsMessage =>
      'Aún no tienes conversaciones. Inicia una nueva conversación para comenzar a enviar mensajes.';

  @override
  String get imageSavedToGallery => '¡Imagen guardada en la galería!';

  @override
  String failedToSaveImage(String error) {
    return 'Error al guardar imagen: $error';
  }

  @override
  String get userProfile => 'Perfil de Usuario';

  @override
  String get deletePost => 'Eliminar Publicación';

  @override
  String get loginRequired => 'Inicio de Sesión Requerido';

  @override
  String get spamCleaner => 'Limpiador de Spam';

  @override
  String get sendMessage => 'Enviar mensaje';

  @override
  String get memberSince => 'Miembro Desde';

  @override
  String get lastActivity => 'Última Actividad';

  @override
  String get likesReceived => 'Me Gusta Recibidos';

  @override
  String get likesGiven => 'Me Gusta Dados';

  @override
  String get showMore => 'Mostrar más';

  @override
  String get cleanSpam => 'Limpiar spam';

  @override
  String get failedToSaveMessage => 'Error al guardar mensaje';

  @override
  String get failedToSaveConversation => 'Error al guardar conversación';

  @override
  String get failedToSaveSetting => 'Error al guardar configuración';

  @override
  String get failedToSavePost => 'Error al guardar publicación';

  @override
  String errorLoadingSites(String error) {
    return 'Error al cargar sitios: $error';
  }

  @override
  String connectingTo(String domainName) {
    return 'Conectando a $domainName...';
  }

  @override
  String get members => 'Miembros';

  @override
  String get allMembers => 'Todos los Miembros';

  @override
  String get online => 'En Línea';

  @override
  String get noMembersFound => 'No se encontraron miembros';

  @override
  String get searchForMembers => 'Buscar miembros';

  @override
  String get enterUsernameToFindMembers =>
      'Ingresa un nombre de usuario para encontrar miembros del foro';

  @override
  String get noMembersOnline => 'No hay miembros en línea actualmente';

  @override
  String get enterUsernameToSearch =>
      'Ingresa nombre de usuario para buscar...';

  @override
  String get lookupMembers => 'Buscar Miembros';

  @override
  String get addMembers => 'Agregar Miembros';

  @override
  String get membersAddedSuccessfully => 'Miembros agregados exitosamente';

  @override
  String errorAddingMembers(String error) {
    return 'Error al agregar miembros: $error';
  }

  @override
  String get failedToLoadOnlineUsers => 'Error al cargar usuarios en línea';

  @override
  String get noUsersOnline => 'No hay usuarios en línea';

  @override
  String membersCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString Miembros';
  }

  @override
  String get noSubject => 'Sin asunto';

  @override
  String get search => 'Buscar';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get areYouSureYouWantToLogout =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get register => 'Registrarse';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get markForumRead => 'Marcar foro como leído';

  @override
  String get notificationTest => 'Prueba de notificaciones';

  @override
  String get forum => 'Foro';

  @override
  String get profile => 'Perfil';

  @override
  String get messages => 'Mensajes';

  @override
  String get add => 'Agregar';

  @override
  String get retry => 'Reintentar';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteMessage => 'Eliminar Mensaje';

  @override
  String get areYouSureYouWantToDeleteThisMessage =>
      '¿Estás seguro de que quieres eliminar este mensaje?';

  @override
  String failedToDeleteMessage(String error) {
    return 'Error al eliminar mensaje: $error';
  }

  @override
  String get deletingPost => 'Eliminando publicación...';

  @override
  String failedToUnlikePost(String error) {
    return 'Error al quitar me gusta de la publicación: $error';
  }

  @override
  String failedToLikePost(String error) {
    return 'Error al dar me gusta a la publicación: $error';
  }

  @override
  String failedToThankPost(String error) {
    return 'Error al agradecer publicación: $error';
  }

  @override
  String get signInToViewMessages => 'Inicia sesión para ver mensajes';

  @override
  String get youNeedToBeSignedInToViewConversations =>
      'Necesitas iniciar sesión para ver tus conversaciones.';

  @override
  String errorLoadingConversations(String error) {
    return 'Error al cargar conversaciones: $error';
  }

  @override
  String failedToLeaveConversation(String error) {
    return 'Error al dejar conversación: $error';
  }

  @override
  String errorLoadingMoreConversations(String error) {
    return 'Error al cargar más conversaciones: $error';
  }

  @override
  String errorLoadingMoreMessages(String error) {
    return 'Error al cargar más mensajes: $error';
  }

  @override
  String get inviteMessageOptional => 'Mensaje de Invitación (opcional)';

  @override
  String get iWouldLikeToAddYouToThisConversation =>
      'Me gustaría agregarte a esta conversación.';

  @override
  String get searchFailed => 'Búsqueda fallida';

  @override
  String get trySearchingWithDifferentUsername =>
      'Intenta buscar con un nombre de usuario diferente';

  @override
  String get noSitesFound => 'No se encontraron sitios.';

  @override
  String get userInformationNotAvailable =>
      'Información de usuario no disponible';

  @override
  String get birthday => 'Cumpleaños';

  @override
  String get posts => 'Publicaciones';

  @override
  String get following => 'Siguiendo';

  @override
  String get followers => 'Seguidores';

  @override
  String get about => 'Acerca de';

  @override
  String get location => 'Ubicación';

  @override
  String get website => 'Sitio web';

  @override
  String get next => 'Siguiente';

  @override
  String get permanent => 'Permanente';

  @override
  String get temporary => 'Temporal';

  @override
  String setBanDurationFor(String username) {
    return 'Establecer la duración del ban para $username';
  }

  @override
  String get pleaseSelectEndDateForTemporaryBan =>
      'Por favor selecciona una fecha de finalización para el ban temporal';

  @override
  String get back => 'Atrás';

  @override
  String get unban => 'Desbanear';

  @override
  String get confirm => 'Confirmar';

  @override
  String spamClean(String username) {
    return 'Limpiar Spam de $username';
  }

  @override
  String get selectActionsToPerform => 'Selecciona las acciones a realizar:';

  @override
  String get moveOrDeleteThreadsBasedOnAdminSettings =>
      'Mover o eliminar hilos según la configuración del administrador';

  @override
  String get messageUpdatedSuccessfully => 'Mensaje actualizado exitosamente';

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String failedToRemoveAttachment(String error) {
    return 'Error al eliminar adjunto: $error';
  }

  @override
  String failedToLoadMessage(String error) {
    return 'Error al cargar mensaje: $error';
  }

  @override
  String get editMessage => 'Editar Mensaje';

  @override
  String get removeAttachment => 'Eliminar Adjunto';

  @override
  String get areYouSureYouWantToRemoveThisAttachment =>
      '¿Estás seguro de que quieres eliminar este adjunto?';

  @override
  String get none => 'Ninguno';

  @override
  String get attachFile => 'Adjuntar Archivo';

  @override
  String get uploadImage => 'Subir Imagen';

  @override
  String get formatting => 'Formato';

  @override
  String get bold => 'Negrita';

  @override
  String get italic => 'Cursiva';

  @override
  String get underline => 'Subrayado';

  @override
  String get strikethrough => 'Tachado';

  @override
  String get link => 'Enlace';

  @override
  String get image => 'Imagen';

  @override
  String get video => 'Video';

  @override
  String get quote => 'Cita';

  @override
  String get code => 'Código';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get bulletList => 'Lista con Viñetas';

  @override
  String get numberedList => 'Lista Numerada';

  @override
  String get listItem => 'Elemento de Lista';

  @override
  String participants(int count) {
    return 'Participantes ($count)';
  }

  @override
  String get markAsUnread => 'Marcar como no leído';

  @override
  String get invite => 'Invitar';

  @override
  String get welcomeBack => '¡Bienvenido de nuevo!';

  @override
  String get signInToAccessYourProfile =>
      'Inicia sesión para acceder a tu perfil y gestionar tu cuenta';

  @override
  String get enterYourUsername => 'Ingresa tu nombre de usuario';

  @override
  String get enterYourPassword => 'Ingresa tu contraseña';

  @override
  String get dontHaveAnAccount => '¿No tienes una cuenta?';

  @override
  String get enterKeywordsToSearchTopics =>
      'Ingresa palabras clave para buscar temas...';

  @override
  String get pleaseFillInAllRequiredFields =>
      'Por favor completa todos los campos obligatorios';

  @override
  String get undelete => 'Restaurar';

  @override
  String get refresh => 'Actualizar';

  @override
  String get share => 'Compartir';

  @override
  String get viewOnWeb => 'Ver en la Web';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get lock => 'Bloquear';

  @override
  String get stick => 'Fijar';

  @override
  String get unstick => 'Desfijar';

  @override
  String get reply => 'Responder';

  @override
  String get vote => 'Votar';

  @override
  String votesCount(int count) {
    return '$count votos';
  }

  @override
  String get pollClosed => 'Encuesta cerrada';

  @override
  String pollEndsOn(String date) {
    return 'Termina el $date';
  }

  @override
  String get voteToSeeResults => 'Vota para ver resultados';

  @override
  String get viewFullPoll => 'Ver encuesta completa';

  @override
  String pollOptionsCount(int count) {
    return '$count opciones';
  }

  @override
  String get reactedBy => 'Reaccionado por';

  @override
  String get enterKeywordsToFindTopicsAndPosts =>
      'Ingresa palabras clave para encontrar temas y publicaciones';

  @override
  String get enterKeywordsOrDomainToFindForums =>
      'Ingresa palabras clave o dominio para encontrar foros';

  @override
  String get enterKeywordsOrDomainNamesToFindForums =>
      'Ingresa palabras clave o nombres de dominio para encontrar foros';

  @override
  String get appearance => 'Apariencia';

  @override
  String get followSystemTheme => 'Seguir el tema del sistema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String version(String version, String buildNumber) {
    return 'versión $version ($buildNumber)';
  }

  @override
  String get forumSettings => 'Configuración del Foro';

  @override
  String get noSettingsAvailable => 'No hay configuraciones disponibles';

  @override
  String get settingsCategoriesWillAppearHere =>
      'Las categorías de configuración aparecerán aquí cuando estén disponibles.';

  @override
  String get unableToLoadProfile => 'No se puede cargar el perfil';

  @override
  String get banned => 'BLOQUEADO';

  @override
  String get reportSubmittedSuccessfully => 'Reporte enviado exitosamente';

  @override
  String get failedToSubmitReport => 'Error al enviar el reporte';

  @override
  String get searchForForums => 'Buscar foros';

  @override
  String get searchForums => 'Buscar Foros';

  @override
  String get deleteTopic => 'Eliminar tema';

  @override
  String get topicCanBeRestoredLater => 'El tema puede restaurarse más tarde';

  @override
  String get topicWillBePermanentlyDeleted =>
      'El tema será eliminado permanentemente';

  @override
  String get enterReasonForDeletingTopic =>
      'Ingresa la razón para eliminar este tema';

  @override
  String get pleaseSelectEndDate =>
      'Por favor selecciona una fecha de finalización';

  @override
  String get userBannedSuccessfully => 'Usuario bloqueado exitosamente';

  @override
  String get failedToBanUser => 'Error al bloquear usuario';

  @override
  String get userUnbannedSuccessfully => 'Usuario desbloqueado exitosamente';

  @override
  String get failedToUnbanUser => 'Error al desbloquear usuario';

  @override
  String get spamCleanUser => 'Limpiar spam del usuario';

  @override
  String get deletePrivateConversations => 'Eliminar conversaciones privadas';

  @override
  String get banTheUserAccount => 'Bloquear la cuenta del usuario';

  @override
  String get handledThreads => 'Temas manejados';

  @override
  String get deletedMessages => 'Mensajes eliminados';

  @override
  String get deletedConversations => 'Conversaciones eliminadas';

  @override
  String get bannedUser => 'Usuario bloqueado';

  @override
  String successfullyCleanedSpam(String username, String actions) {
    return 'Spam limpiado exitosamente para $username. Acciones: $actions';
  }

  @override
  String errorLoadingMessage(String error) {
    return 'Error al cargar mensaje: $error';
  }

  @override
  String get messageNotFound => 'Mensaje no encontrado';

  @override
  String get home => 'Inicio';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get forums => 'Foros';

  @override
  String get markAllForumsAsRead => '¿Marcar todos los foros como leídos?';

  @override
  String get markAllForumsAsReadMessage =>
      'Esto marcará todos los foros y temas como leídos. Esta acción no se puede deshacer.';

  @override
  String get markAsRead => 'Marcar como leído';

  @override
  String get content => 'Contenido';

  @override
  String get insertImage => 'Insertar imagen';

  @override
  String get howWouldYouLikeToInsertImage =>
      '¿Cómo te gustaría insertar esta imagen?';

  @override
  String get thumbnail => 'Miniatura';

  @override
  String get fullSize => 'Tamaño completo';

  @override
  String get alignLeft => 'Alinear a la izquierda';

  @override
  String get alignCenter => 'Alinear al centro';

  @override
  String get alignRight => 'Alinear a la derecha';

  @override
  String get pleaseEnterTitle => 'Por favor ingresa un título';

  @override
  String get pleaseEnterContent => 'Por favor ingresa algún contenido';

  @override
  String get uploading => 'Subiendo...';

  @override
  String get uploaded => 'Subido';

  @override
  String get mentionUser => 'Mencionar usuario';

  @override
  String get loggingIn => 'Iniciando sesión...';

  @override
  String get submittingReport => 'Enviando reporte...';

  @override
  String get banningUser => 'Prohibiendo usuario...';

  @override
  String get unbanningUser => 'Desprohibiendo usuario...';

  @override
  String get cleaningSpam => 'Limpiando spam...';

  @override
  String get enterSubject => 'Ingresa el asunto';

  @override
  String get typeYourMessageHere => 'Escribe tu mensaje aquí';

  @override
  String get writeYourMessage => 'Escribe tu mensaje...';

  @override
  String get writeYourReply => 'Escribe tu respuesta...';

  @override
  String get messageSentSuccessfully => 'Mensaje enviado exitosamente';

  @override
  String get replySentSuccessfully => 'Respuesta enviada exitosamente';

  @override
  String get conversationCreatedSuccessfully =>
      'Conversación creada exitosamente';

  @override
  String get conversationMarkedAsUnread => 'Conversación marcada como no leída';

  @override
  String get messageMarkedAsUnread => 'Mensaje marcado como no leído';

  @override
  String get conversationClosed => 'Conversación cerrada';

  @override
  String get conversationOpened => 'Conversación abierta';

  @override
  String get pleaseLoginToLikeMessages =>
      'Por favor inicia sesión para dar me gusta a los mensajes';

  @override
  String get loadEarlierMessages => 'Cargar mensajes anteriores';

  @override
  String failedToLoadQuote(String error) {
    return 'Error al cargar cita: \n$error';
  }

  @override
  String failedToUploadFile(String error) {
    return 'Error al subir archivo: $error';
  }

  @override
  String failedToUploadImage(String error) {
    return 'Error al subir imagen: $error';
  }

  @override
  String failedToSendMessage(String error) {
    return 'Error al enviar mensaje: $error';
  }

  @override
  String failedToSendReply(String error) {
    return 'Error al enviar respuesta: $error';
  }

  @override
  String failedToMarkAsUnread(String error) {
    return 'Error al marcar mensaje como no leído: $error';
  }

  @override
  String failedToMarkConversationAsUnread(String error) {
    return 'Error al marcar conversación como no leída: $error';
  }

  @override
  String failedToCloseConversation(String error) {
    return 'Error al cerrar conversación: $error';
  }

  @override
  String failedToOpenConversation(String error) {
    return 'Error al abrir conversación: $error';
  }

  @override
  String failedToJumpToMessage(String error) {
    return 'Error al saltar al mensaje: $error';
  }

  @override
  String get goToTop => 'Ir arriba';

  @override
  String get goToBottom => 'Ir abajo';

  @override
  String get replyAll => 'Responder a todos';

  @override
  String get forward => 'Reenviar';

  @override
  String get noForumsFound => 'No se encontraron foros.';

  @override
  String get pleaseLoginToAccessContent =>
      'Por favor inicia sesión para acceder a este contenido e interactuar con las publicaciones.';

  @override
  String get searchUsers => 'Buscar usuarios...';

  @override
  String get writeYourTitle => 'Escribe tu título...';

  @override
  String get writeYourContent => 'Escribe tu contenido...';

  @override
  String get selectAnOption => 'Selecciona una opción';

  @override
  String get enterConversationTitle => 'Ingresa el título de la conversación';

  @override
  String enterCode(int count) {
    return 'Ingresa código de $count dígitos';
  }

  @override
  String get edit => 'Editar';

  @override
  String get report => 'Reportar';

  @override
  String get unfollow => 'Dejar de seguir';

  @override
  String get follow => 'Seguir';

  @override
  String get goToForums => 'Ir a Foros';

  @override
  String get remove => 'Eliminar';

  @override
  String get subject => 'Asunto';

  @override
  String get message => 'Mensaje';

  @override
  String get titleCannotBeEmpty => 'El título no puede estar vacío';

  @override
  String get conversationUpdatedSuccessfully =>
      'Conversación actualizada exitosamente';

  @override
  String get goBack => 'Volver';

  @override
  String get privateMessagesNotAvailable =>
      'Los mensajes privados no están disponibles';

  @override
  String failedToLoadPost(String error) {
    return 'Error al cargar publicación: \n$error';
  }

  @override
  String failedToLikeOrUnlikeMessage(String action, String error) {
    return 'Error al $action mensaje: $error';
  }

  @override
  String get like => 'dar me gusta a';

  @override
  String get unlike => 'quitar me gusta a';

  @override
  String get optimizeImage => 'Optimizar imagen';

  @override
  String get optimizeAndUpload => 'Optimizar y subir';

  @override
  String downloading(String filename) {
    return 'Descargando $filename...';
  }

  @override
  String openingShareSheet(String filename) {
    return 'Abriendo hoja de compartir para $filename';
  }

  @override
  String errorDownloading(String filename, String error) {
    return 'Error al descargar $filename: $error';
  }

  @override
  String get enterANumber => 'Ingresa un número';

  @override
  String get failedToNavigateToForum => 'Error al navegar al foro';

  @override
  String failedToNavigateToForumName(String forumName) {
    return 'Error al navegar a $forumName';
  }

  @override
  String forumNotFound(String forumName) {
    return 'Foro no encontrado: $forumName';
  }

  @override
  String forumNotFoundById(String forumId) {
    return 'Foro no encontrado: $forumId';
  }

  @override
  String couldNotOpenLink(String error) {
    return 'No se pudo abrir el enlace: $error';
  }

  @override
  String get likePost => 'Me gusta';

  @override
  String get unlikePost => 'Ya no me gusta';

  @override
  String get thankPost => 'Agradecer publicación';

  @override
  String get showLikes => 'Mostrar me gusta';

  @override
  String get showThanks => 'Mostrar agradecimientos';

  @override
  String get quotePost => 'Citar publicación';

  @override
  String get translate => 'Traducir';

  @override
  String get showOriginal => 'Mostrar original';

  @override
  String get translating => 'Traduciendo...';

  @override
  String get translated => 'Traducido';

  @override
  String get translatedContent => 'Contenido traducido';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get translateTo => 'Traducir a:';

  @override
  String get deviceLanguage => 'Idioma del dispositivo';

  @override
  String get noPostsToTranslate => 'No hay publicaciones para traducir';

  @override
  String get translationFailed => 'Error en la traducción';

  @override
  String get twoFactorAuthentication => 'Autenticación en dos factores';

  @override
  String get authenticationCodeLabel => 'Código de autenticación';

  @override
  String get pleaseEnterYourAuthenticationCode =>
      'Introduce tu código de autenticación';

  @override
  String codeMustBeDigits(int count) {
    return 'El código debe tener $count dígitos';
  }

  @override
  String get codeMustContainOnlyNumbers =>
      'El código solo debe contener números';

  @override
  String get verifyButton => 'Verificar';

  @override
  String get attachments => 'Archivos adjuntos';

  @override
  String get replyOptions => 'Opciones de respuesta';

  @override
  String get replyWithQuote => 'Responder con cita';

  @override
  String fileSavedToDownloads(String filename) {
    return 'Archivo guardado en Descargas: $filename';
  }

  @override
  String fileSavedToDocuments(String filename) {
    return 'Archivo guardado en Documentos: $filename';
  }

  @override
  String topicLastReplyBy(String username, String time) {
    return '$username respondió $time';
  }

  @override
  String inReplyToUser(String username) {
    return 'en respuesta a $username';
  }

  @override
  String inReplyToPost(int number) {
    return 'en respuesta a la publicación #$number';
  }

  @override
  String timeGapDaysLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días después',
      one: '1 día después',
    );
    return '$_temp0';
  }

  @override
  String timeGapMonthsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses después',
      one: '1 mes después',
    );
    return '$_temp0';
  }

  @override
  String timeGapYearsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count años después',
      one: '1 año después',
    );
    return '$_temp0';
  }

  @override
  String get profileViews => 'Visitas';

  @override
  String get badges => 'Insignias';

  @override
  String get chatWithUser => 'Chat';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count respuestas',
      one: '1 respuesta',
    );
    return '$_temp0';
  }

  @override
  String nVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votos',
      one: '1 voto',
    );
    return '$_temp0';
  }

  @override
  String get lastSeen => 'Visto';

  @override
  String get chat => 'Chat';

  @override
  String comingSoon(String label) {
    return '$label — próximamente';
  }

  @override
  String moreBadges(Object count) {
    return '+$count más';
  }

  @override
  String get allNotificationsMarkedAsRead =>
      'Todas las notificaciones marcadas como leídas';

  @override
  String get apply => 'Aplicar';

  @override
  String get bookmarks => 'Marcadores';

  @override
  String reviewableBy(String username) {
    return 'Por $username';
  }

  @override
  String get changeEmail => 'Cambiar correo electrónico';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get checkingStatus => 'Comprobando estado…';

  @override
  String get clearReminder => 'Quitar recordatorio';

  @override
  String get copy => 'Copiar';

  @override
  String get copyLink => 'Copiar enlace';

  @override
  String couldNotEnableNotifications(String error) {
    return 'No se pudieron activar las notificaciones: $error';
  }

  @override
  String get couldNotFindBookmark => 'No se encontró este marcador';

  @override
  String couldNotOpenEmail(String email) {
    return 'No se pudo abrir el correo: $email';
  }

  @override
  String couldNotStartSignIn(String error) {
    return 'No se pudo iniciar sesión: $error';
  }

  @override
  String get customDateAndTime => 'Fecha y hora personalizadas';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteMessageQuestion => '¿Eliminar mensaje?';

  @override
  String get discard => 'Descartar';

  @override
  String get discardDraftQuestion => '¿Descartar borrador?';

  @override
  String get doNotDisturb => 'No molestar';

  @override
  String get editHistory => 'Historial de ediciones';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get editReminder => 'Editar recordatorio';

  @override
  String emailCopiedToClipboard(String email) {
    return 'Correo copiado al portapapeles: $email';
  }

  @override
  String get pushEnabledForThisLogin => 'Activadas para este inicio de sesión';

  @override
  String get failedToLoadMoreTopics =>
      'No se pudieron cargar más temas. Desplázate para reintentar.';

  @override
  String get failedToUpdateNotificationLevel =>
      'No se pudo actualizar el nivel de notificación';

  @override
  String get firstPostsOnly => 'Solo primeras publicaciones';

  @override
  String get ignoredUsers => 'Usuarios ignorados';

  @override
  String get inTwoHours => 'En dos horas';

  @override
  String get inviteByEmail => 'Invitar por correo';

  @override
  String get inviteLinkCopied => 'Enlace de invitación copiado';

  @override
  String inviteSentTo(String email) {
    return 'Invitación enviada a $email';
  }

  @override
  String get leave => 'Salir';

  @override
  String get leaveGroup => 'Salir del grupo';

  @override
  String get leaveGroupQuestion => '¿Salir del grupo?';

  @override
  String get linkCopied => 'Enlace copiado';

  @override
  String get loadMore => 'Cargar más';

  @override
  String get manageAccountOnWeb => 'Administrar cuenta en la web';

  @override
  String get merge => 'Fusionar';

  @override
  String get mergeIntoTopic => 'Fusionar en tema';

  @override
  String get newInviteLink => 'Nuevo enlace de invitación';

  @override
  String get nextWeek => 'La próxima semana';

  @override
  String get pushNotAvailableInThisBuild => 'No disponible en esta versión';

  @override
  String get notNow => 'Ahora no';

  @override
  String tagNotificationLevelUpdated(String tag) {
    return 'Nivel de notificación de «$tag» actualizado';
  }

  @override
  String doNotDisturbOnUntil(String until) {
    return 'Activado hasta $until';
  }

  @override
  String get pleaseLogInToBookmark => 'Inicia sesión para guardar marcadores';

  @override
  String get pleaseLogInToFollowUsers => 'Inicia sesión para seguir usuarios';

  @override
  String get pleaseLogInToMarkAnswers => 'Inicia sesión para marcar respuestas';

  @override
  String get pleaseLogInToReact => 'Inicia sesión para reaccionar';

  @override
  String get pleaseLogInToVote => 'Inicia sesión para votar';

  @override
  String get pushNotifications => 'Notificaciones push';

  @override
  String get relevance => 'Relevancia';

  @override
  String get reminderTimeMustBeInFuture =>
      'La hora del recordatorio debe ser futura';

  @override
  String get removeBookmark => 'Quitar marcador';

  @override
  String get removeVote => 'Quitar voto';

  @override
  String get renameTopic => 'Renombrar tema';

  @override
  String reportedBy(String username) {
    return 'Reportado por $username';
  }

  @override
  String get requestToJoin => 'Solicitar unirse';

  @override
  String requestToJoinGroup(String group) {
    return 'Solicitar unirse a $group';
  }

  @override
  String get reset => 'Restablecer';

  @override
  String get resizeAndUpload => 'Reducir y subir';

  @override
  String get retryConnection => 'Reintentar conexión';

  @override
  String get reviewQueue => 'Cola de revisión';

  @override
  String get revoke => 'Revocar';

  @override
  String get revokeInviteQuestion => '¿Revocar invitación?';

  @override
  String get save => 'Guardar';

  @override
  String get sendInvite => 'Enviar invitación';

  @override
  String get sendRequest => 'Enviar solicitud';

  @override
  String get settings => 'Ajustes';

  @override
  String get showVoters => 'Mostrar votantes';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get signOutQuestion => '¿Cerrar sesión?';

  @override
  String get signInCancelledNoPayload =>
      'Inicio de sesión cancelado: no se recibió respuesta';

  @override
  String signInFailed(String error) {
    return 'Error al iniciar sesión: $error';
  }

  @override
  String get startChat => 'Iniciar chat';

  @override
  String stoppedIgnoringUser(String username) {
    return 'Dejaste de ignorar a @$username';
  }

  @override
  String get submit => 'Enviar';

  @override
  String get discardDraftWarning =>
      'El borrador guardado se eliminará de forma permanente.';

  @override
  String get deleteChatMessageWarning => 'El mensaje se eliminará para todos.';

  @override
  String get titleOnly => 'Solo título';

  @override
  String get tomorrow => 'Mañana';

  @override
  String get turnOff => 'Desactivar';

  @override
  String get turnOnNotifications => 'Activar notificaciones';

  @override
  String get whisper => 'Susurro';

  @override
  String likeAgainInSeconds(Object seconds) {
    return 'Puedes volver a dar me gusta en ${seconds}s';
  }

  @override
  String get loginInfo => 'Login Info';

  @override
  String get loginFailed => 'Login Failed';

  @override
  String get additionalInformation => 'Additional Information';

  @override
  String dateOfBirth(Object marker) {
    return 'Date of Birth$marker';
  }

  @override
  String minimumAgeYears(Object minimumAge) {
    return 'Minimum age: $minimumAge years';
  }

  @override
  String locationLabel(Object marker) {
    return 'Location$marker';
  }

  @override
  String get receiveSiteMailings => 'Receive site mailings';

  @override
  String get moveToCategory => 'Move to category';

  @override
  String get undeleteTopic => 'Undelete Topic';

  @override
  String get undeleteTopicConfirmation =>
      'Are you sure you want to undelete this topic? It will be visible to other users again.';

  @override
  String get send => 'Send';

  @override
  String get changeEmailExplanation =>
      'We’ll send a confirmation link to your new email. The change takes effect when you click it.';

  @override
  String get changeEmailSecurityNote =>
      'For added security, Discourse may require you to confirm via the link in the email. Check your spam folder if you don’t see it.';

  @override
  String get newDirectMessage => 'New direct message';

  @override
  String get noMessagesYetSayHi => 'No messages yet — say hi.';

  @override
  String get edited => 'edited';

  @override
  String get imageExceedsUploadLimits =>
      'This image exceeds the upload limits and needs to be optimized:';

  @override
  String get optimizationsToBeApplied => 'Optimizations to be applied:';

  @override
  String reductionPercent(Object percent) {
    return 'Reduction: $percent%';
  }

  @override
  String get editProfileManagedOnWebNote =>
      'Display name, email, password, and other account settings are managed under Account → Manage account on web. Your avatar can be changed by tapping the camera badge on your photo.';

  @override
  String get approvedButRelayUnreachable =>
      'Approved, but we could not reach ForumCopilot to finish setting up. Try again later from Settings.';

  @override
  String get notificationsAreTurnedOffForThisApp =>
      'Notifications are turned off for this app';

  @override
  String forumWillAskToApproveNotifications(Object forumName) {
    return 'Next, $forumName will ask you to approve “Notifications”.';
  }

  @override
  String get approveNotificationsExplanation =>
      'Approving lets us check your notifications for you and send them to this device. This permission cannot post, reply, or read your messages.';

  @override
  String get forumOwnerPushNote =>
      'If this forum’s owner sets up notifications for the app, this step won’t be needed.';

  @override
  String get pleaseLoginToCreateANewTopic =>
      'Please login to create a new topic';

  @override
  String get pleaseLoginToSubscribeToForums =>
      'Please login to subscribe to forums';

  @override
  String leaveGroupWarning(Object group) {
    return 'You will no longer be a member of $group. You can rejoin at any time.';
  }

  @override
  String get groupMembersPrivate => 'The member list of this group is private.';

  @override
  String get unignore => 'Unignore';

  @override
  String get inviteLinkCreated => 'Invite link created';

  @override
  String expiresOn(Object date) {
    return 'Expires $date';
  }

  @override
  String get protected => 'Protected';

  @override
  String get solution => 'Solution';

  @override
  String get deleted => 'DELETED';

  @override
  String get pleaseLoginToViewUserProfiles =>
      'Please login to view user profiles.';

  @override
  String get announcement => 'Announcement';

  @override
  String get solved => 'Solved';

  @override
  String get hot => 'Hot';

  @override
  String get pinned => 'Pinned';

  @override
  String get subscribedLabel => 'Subscribed';

  @override
  String get locked => 'Locked';

  @override
  String get poll => 'Poll';

  @override
  String errorLoadingContent(Object error) {
    return 'Error loading content: $error';
  }

  @override
  String get noPermissionToViewSubforum =>
      'You do not have permission to view topics in this subforum.';

  @override
  String get noDiscussionsYet => 'No discussions yet.';

  @override
  String get jumpToPost => 'Jump to Post';

  @override
  String get jump => 'Jump';

  @override
  String get endOfTheDiscussion => 'End of the discussion';

  @override
  String get reviewQueueStaffOnly =>
      'Only staff and reviewers can see the review queue.';

  @override
  String get nothingToReview => 'Nothing to review';

  @override
  String refreshFailed(Object error) {
    return 'Refresh failed: $error';
  }

  @override
  String get topicDeletedBanner =>
      'This topic is deleted and hidden from other users';

  @override
  String get topicClosedBanner =>
      'This topic is closed and no longer accepting replies';

  @override
  String get topicPinnedBanner =>
      'This topic is pinned to the top of the forum';

  @override
  String get youAreSubscribedToThisTopic => 'You are subscribed to this topic';

  @override
  String get refreshing => 'Refreshing...';

  @override
  String get title => 'Title';

  @override
  String editedAt(Object time) {
    return 'Edited $time';
  }

  @override
  String editReason(Object reason) {
    return 'Reason: $reason';
  }

  @override
  String get thisDiffIsTooLargeToDisplay =>
      'This diff is too large to display.';

  @override
  String get noContentChangesInThisRevision =>
      'No content changes in this revision.';

  @override
  String revisionOf(Object currentVersion, Object versionCount) {
    return 'Revision $currentVersion of $versionCount';
  }

  @override
  String get editConversation => 'Edit conversation';

  @override
  String get closeConversation => 'Close conversation';

  @override
  String get openConversation => 'Open conversation';

  @override
  String get leaveConversation2 => 'Leave conversation';

  @override
  String get reportConversation2 => 'Report conversation';

  @override
  String get closeConversation2 => 'Close Conversation';

  @override
  String get closeConversationConfirmation =>
      'Are you sure you want to close this conversation? This will prevent new replies from being posted.';

  @override
  String get close => 'Close';

  @override
  String get openConversation2 => 'Open Conversation';

  @override
  String get openConversationConfirmation =>
      'Are you sure you want to open this conversation? This will allow new replies to be posted.';

  @override
  String get open => 'Open';

  @override
  String get leaveConversation3 => 'Leave Conversation';

  @override
  String get leaveConversationConfirmation =>
      'Are you sure you want to leave this conversation? This will hide it from your inbox.';

  @override
  String errorLoadingConversation(Object error) {
    return 'Error loading conversation: $error';
  }

  @override
  String get conversationNotFound => 'Conversation not found';

  @override
  String get conversationClosedBanner =>
      'This conversation is closed and no longer accepting replies';

  @override
  String get noMessagesFound => 'No messages found';

  @override
  String get endOfConversation => 'End of conversation';

  @override
  String get jumpToMessage => 'Jump to Message';

  @override
  String get editConversation2 => 'Edit Conversation';

  @override
  String get failedToLoadMessage2 => 'Failed to load message';

  @override
  String get cannotEditThisConversation => 'Cannot edit this conversation';

  @override
  String get options => 'Options';

  @override
  String get conversationOpen => 'Conversation Open';

  @override
  String failedToCreateConversation(Object error) {
    return 'Failed to create conversation: $error';
  }

  @override
  String maximumAttachmentsAllowed(Object count) {
    return 'Maximum of $count attachment(s) allowed';
  }

  @override
  String get noImagesFoundToDisplay => 'No images found to display.';

  @override
  String get pleaseLoginToViewThisAttachment =>
      'Please login to view this attachment';

  @override
  String get searchForTopics => 'Search for topics';

  @override
  String get noTopicsFound => 'No topics found';

  @override
  String get trySearchingWithDifferentKeywords =>
      'Try searching with different keywords';

  @override
  String get noPostsFound => 'No posts found';

  @override
  String get perTopicNotificationLevelsNote =>
      'Per-category and per-topic notification levels are set from those screens directly — tap the bell icon on any topic or category to override.';

  @override
  String get pushNotActiveForThisLogin =>
      'Not active for this login — log out and log back in to authorize push notifications';

  @override
  String get pauseNotificationsFor => 'Pause notifications for…';

  @override
  String get doNotDisturbExplanation =>
      'Pause notifications for a while — Discourse holds them until the window ends';

  @override
  String get emailSettingsSubtitle =>
      'Email frequency, like aggregation, digest schedule';

  @override
  String get manageAccountSubtitle =>
      'Profile, email, password, security, advanced settings';

  @override
  String get changePasswordSubtitle =>
      'Trigger a password-reset email to your current address';

  @override
  String get ignoredUsersSubtitle =>
      'See and manage users whose posts are hidden from you';

  @override
  String get deleteAccountExplanation =>
      'Removing your account is handled on the forum. Continue to open the site and contact the staff team — Discourse forums process deletions per their own policy.';

  @override
  String get verificationEmailSent =>
      'Verification email sent — click the link to confirm your new address.';

  @override
  String get passwordResetExplanation =>
      'We’ll email you a password-reset link. Click it to choose a new password — the change is handled on the forum, not in this app.';

  @override
  String get sendResetEmail => 'Send reset email';

  @override
  String get deleteAccountDialogBody =>
      'Your account is managed by the forum. Please contact the forum staff directly to request account removal. Continue will open the forum in your browser so you can use the site’s own contact / staff message flow.';

  @override
  String get initializingForum => 'Initializing forum…';

  @override
  String get unableToLoadForums => 'Unable to Load Forums';

  @override
  String get noForumsToDisplayExplanation =>
      'There are no forums to display. This might be due to permissions or the forum structure.';

  @override
  String get subscribedForums => 'Subscribed Forums';

  @override
  String get errorLoadingNotifications => 'Error loading notifications';

  @override
  String get pullDownToRefresh => 'Pull down to refresh';

  @override
  String get noNewNotificationsExplanation =>
      'You have no new notifications. Check back later for updates on topics you\'re following.';

  @override
  String noTagsMatch(Object filter) {
    return 'No tags match \"$filter\".';
  }

  @override
  String noTopicsTagged(Object tag) {
    return 'No topics tagged \"$tag\"';
  }

  @override
  String failedToBanUser2(Object error) {
    return 'Failed to ban user: $error';
  }

  @override
  String unbanUserConfirmation(Object username) {
    return 'Are you sure you want to unban $username?';
  }

  @override
  String failedToUnbanUser2(Object error) {
    return 'Failed to unban user: $error';
  }

  @override
  String get deletePostsProfilePostsAndComments =>
      'Delete posts, profile posts, and comments';

  @override
  String spamCleanConfirmation(Object username) {
    return 'Are you sure you want to spam clean $username?';
  }

  @override
  String failedToCleanSpam(Object error) {
    return 'Failed to clean spam: $error';
  }

  @override
  String get searchUser => 'Search User';

  @override
  String get tapToOpen => 'Tap to open';

  @override
  String get imageNotAvailable => 'Image not available';

  @override
  String get allForumTopicsHaveBeenMarkedAs =>
      'All forum topics have been marked as read';

  @override
  String postsCount(Object count) {
    return '$count Posts';
  }

  @override
  String get protectedForum => 'Protected Forum';

  @override
  String isPasswordProtected(Object forumName) {
    return '$forumName is password protected.';
  }

  @override
  String get enter => 'Enter';

  @override
  String get permissionDeniedToSaveImage => 'Permission denied to save image';

  @override
  String get postNotFound => 'Post not found.';

  @override
  String get failedToUploadFilePleaseTryAgain =>
      'Failed to upload file. Please try again.';

  @override
  String failedToUploadFile2(Object errorMessage) {
    return 'Failed to upload file: $errorMessage';
  }

  @override
  String get failedToPickFile => 'Failed to pick file';

  @override
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return 'Only $remainingSlots more attachment(s) allowed. Processing first $remainingSlots2 image(s).';
  }

  @override
  String get attachmentLimitReachedSkippingRemainingImages =>
      'Attachment limit reached. Skipping remaining images.';

  @override
  String failedToUploadImagePleaseTryAgain(Object fileName) {
    return '$fileName: Failed to upload image. Please try again.';
  }

  @override
  String failedToUploadImage2(Object errorMessage, Object fileName) {
    return '$fileName: Failed to upload image: $errorMessage';
  }

  @override
  String get failedToPickImage => 'Failed to pick image';

  @override
  String failedToRemoveAttachment2(Object error) {
    return 'Failed to remove attachment: $error';
  }

  @override
  String sentFromMobileApp(Object siteName) {
    return 'Sent from $siteName mobile app';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      'Please wait for attachments to finish uploading';

  @override
  String get imageIsTooLargeToUpload => 'Image is too large to upload';

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName is $fileBytes. This forum allows up to $maxBytes.';
  }

  @override
  String get resizeToFitExplanation =>
      'It can be scaled down just enough to fit, keeping its format and as much detail as the limit allows.';

  @override
  String get failedToPostReplyPleaseTryAgain =>
      'Failed to post reply. Please try again.';

  @override
  String get pleaseWaitForTheThreadToLoad =>
      'Please wait for the thread to load';

  @override
  String get failedToUpdatePostPleaseTryAgain =>
      'Failed to update post. Please try again.';

  @override
  String get postDeletedSuccessfully => 'Post deleted successfully';

  @override
  String failedToDeletePost(Object error) {
    return 'Failed to delete post: $error';
  }

  @override
  String failedToSubmitReport2(Object error) {
    return 'Failed to submit report: $error';
  }

  @override
  String get editHistoryNotAvailable =>
      'Edit history is not available for this post';

  @override
  String get noPermissionToUploadAvatar =>
      'You do not have permission to upload avatars';

  @override
  String get avatarUploadedSuccessfully => 'Avatar uploaded successfully';

  @override
  String failedToPickImage2(Object error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get react => 'React';

  @override
  String get reactionsAreNotEnabledOnThisForum =>
      'Reactions are not enabled on this forum.';

  @override
  String get noReactionsYet => 'No reactions yet';

  @override
  String get searchFilters => 'Search filters';

  @override
  String signOutWarning(Object siteName) {
    return 'You will be signed out of $siteName. You can sign back in any time.';
  }

  @override
  String get suggestedTopics => 'Suggested Topics';

  @override
  String get newLabel => 'NEW';

  @override
  String get voteRemoved => 'Vote removed';

  @override
  String get voters => 'Voters';

  @override
  String get noVotesYet => 'No votes yet.';

  @override
  String get trustLevels => 'Trust levels';

  @override
  String get trustLevelsExplanation =>
      'Members earn trust by reading and participating. Each level unlocks new abilities.';

  @override
  String get activity => 'Activity';
}
