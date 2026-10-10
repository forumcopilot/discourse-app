// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get accountSessionChanged =>
      'Tu sesión ha cambiado. Vuelve a abrir esta pantalla para continuar.';

  @override
  String get draftSessionChanged =>
      'Tu sesión ha cambiado. Copia tu texto antes de volver a abrir el editor para trabajar con borradores.';

  @override
  String get discardFailedCloseQuestion =>
      '¿Cerrar de todos modos? Un borrador guardado antes se queda en Borradores.';

  @override
  String get keepEditing => 'Seguir editando';

  @override
  String get closeAnyway => 'Cerrar de todos modos';

  @override
  String get uploadSessionChanged =>
      'Tu sesión cambió durante la subida. Vuelve a abrir esta pantalla antes de intentarlo de nuevo.';

  @override
  String get submissionUnconfirmed =>
      'No pudimos confirmar que se haya enviado. Se ha conservado tu texto. Revisa el foro antes de volver a intentarlo.';

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get usePasskey => 'Use Passkey';

  @override
  String get passkeyContinuePrompt => 'Use your passkey to continue';

  @override
  String get continueButton => 'Continuar';

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
  String get latest => 'Recientes';

  @override
  String get unread => 'Sin leer';

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
  String get newConversation => 'Nuevo mensaje';

  @override
  String get language => 'Idioma';

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
  String get youCannotReplyToThisThread => 'No puedes responder a este tema';

  @override
  String get pleaseWaitForThreadToLoad =>
      'Por favor, espera a que se cargue el tema';

  @override
  String get reason => 'Razón';

  @override
  String get participantsLabel => 'Participantes';

  @override
  String usernameHasBeenInvited(String username) {
    return '$username ha sido invitado al mensaje';
  }

  @override
  String errorInvitingUser(String error) {
    return 'Error al invitar usuario: $error';
  }

  @override
  String get newTopic => 'Nuevo tema';

  @override
  String get pleaseSpecifyReason => 'Por favor especifica el motivo';

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String get moreOptions => 'Más opciones';

  @override
  String get topicClosed => 'Tema cerrado';

  @override
  String get topicOpened => 'Tema abierto';

  @override
  String get noConversations => 'No tienes ningún mensaje';

  @override
  String get noConversationsMessage =>
      'Aún no tienes mensajes. Escribe un mensaje nuevo para empezar.';

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
  String get sendMessage => 'Mensaje';

  @override
  String get likesReceived => 'Me Gusta Recibidos';

  @override
  String get showMore => 'Mostrar más';

  @override
  String get failedToSaveConversation => 'No se pudo guardar el mensaje';

  @override
  String get members => 'Miembros';

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
  String get signIn => 'Iniciar sesión';

  @override
  String get notificationTest => 'Prueba de notificaciones';

  @override
  String get forum => 'Categoría';

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
  String get signInToViewMessages => 'Inicia sesión para ver mensajes';

  @override
  String get youNeedToBeSignedInToViewConversations =>
      'Debes iniciar sesión para ver tus mensajes.';

  @override
  String failedToLeaveConversation(String error) {
    return 'No se pudo abandonar el mensaje: $error';
  }

  @override
  String errorLoadingMoreConversations(String error) {
    return 'Error al cargar más mensajes: $error';
  }

  @override
  String get searchFailed => 'Búsqueda fallida';

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
  String get temporary => 'Temporal';

  @override
  String get back => 'Atrás';

  @override
  String get confirm => 'Confirmar';

  @override
  String error(String error) {
    return 'Error: $error';
  }

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
  String get enterKeywordsToSearchTopics =>
      'Ingresa palabras clave para buscar temas...';

  @override
  String get refresh => 'Actualizar';

  @override
  String get share => 'Compartir';

  @override
  String get viewOnWeb => 'Ver en la Web';

  @override
  String get reply => 'Responder';

  @override
  String get vote => 'Votar';

  @override
  String votesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votos',
      one: '$count voto',
    );
    return '$_temp0';
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
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get appearance => 'Apariencia';

  @override
  String get appearanceSystem => 'Sistema';

  @override
  String version(String version, String buildNumber) {
    return 'versión $version ($buildNumber)';
  }

  @override
  String get unableToLoadProfile => 'No se puede cargar el perfil';

  @override
  String get banned => 'BLOQUEADO';

  @override
  String get deleteTopic => 'Eliminar tema';

  @override
  String get home => 'Inicio';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get notificationsTab => 'Avisos';

  @override
  String get forums => 'Categorías';

  @override
  String get content => 'Contenido';

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
  String get writeYourMessage => 'Escribe tu mensaje...';

  @override
  String get writeYourReply => 'Escribe tu respuesta...';

  @override
  String get conversationMarkedAsUnread => 'Mensaje marcado como no leído';

  @override
  String get conversationClosed => 'Mensaje cerrado';

  @override
  String get conversationOpened => 'Mensaje abierto';

  @override
  String failedToLoadQuote(String error) {
    return 'Error al cargar cita: \n$error';
  }

  @override
  String failedToMarkConversationAsUnread(String error) {
    return 'No se pudo marcar el mensaje como no leído: $error';
  }

  @override
  String failedToCloseConversation(String error) {
    return 'No se pudo cerrar el mensaje: $error';
  }

  @override
  String failedToOpenConversation(String error) {
    return 'No se pudo abrir el mensaje: $error';
  }

  @override
  String get goToTop => 'Ir arriba';

  @override
  String get goToBottom => 'Ir abajo';

  @override
  String get pleaseLoginToAccessContent =>
      'Por favor inicia sesión para acceder a este contenido e interactuar con las publicaciones.';

  @override
  String get searchUsers => 'Buscar usuarios...';

  @override
  String get enterConversationTitle => 'Escribe el título del mensaje';

  @override
  String enterCode(int count) {
    return 'Ingresa código de $count dígitos';
  }

  @override
  String get edit => 'Editar';

  @override
  String get remove => 'Eliminar';

  @override
  String get subject => 'Asunto';

  @override
  String get message => 'Mensaje';

  @override
  String get titleCannotBeEmpty => 'El título no puede estar vacío';

  @override
  String get conversationUpdatedSuccessfully => 'Mensaje actualizado';

  @override
  String get goBack => 'Volver';

  @override
  String get like => 'dar me gusta a';

  @override
  String get download => 'Descargar';

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
  String couldNotOpenLink(String error) {
    return 'No se pudo abrir el enlace: $error';
  }

  @override
  String get translating => 'Traduciendo...';

  @override
  String get translated => 'Traducido';

  @override
  String get translatedContent => 'Contenido traducido';

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
  String get badges => 'Medallas';

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
  String get chat => 'Chat';

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
  String get checkConnectionAndRetry =>
      'Comprueba tu conexión a internet e inténtalo de nuevo.';

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
  String get loginInfo => 'Información de inicio de sesión';

  @override
  String get loginFailed => 'Error de inicio de sesión';

  @override
  String get moveToCategory => 'Mover a categoría';

  @override
  String get undeleteTopic => 'Recuperar tema';

  @override
  String get send => 'Enviar';

  @override
  String get changeEmailExplanation =>
      'Enviaremos un enlace de confirmación a tu nuevo correo. El cambio se aplicará cuando hagas clic en él.';

  @override
  String get changeEmailSecurityNote =>
      'Por seguridad, Discourse puede pedirte confirmar mediante el enlace del correo. Revisa la carpeta de spam si no lo ves.';

  @override
  String get noMessagesYetSayHi => 'Aún no hay mensajes: saluda.';

  @override
  String get edited => 'editado';

  @override
  String get approvedButRelayUnreachable =>
      'Aprobado, pero no pudimos conectar con el servidor de notificaciones para terminar la configuración. Inténtalo más tarde desde Ajustes.';

  @override
  String get notificationsAreTurnedOffForThisApp =>
      'Las notificaciones están desactivadas para esta app';

  @override
  String get pleaseLoginToCreateANewTopic => 'Inicia sesión para crear un tema';

  @override
  String get pleaseLoginToSubscribeToForums =>
      'Inicia sesión para suscribirte a foros';

  @override
  String leaveGroupWarning(Object group) {
    return 'Dejarás de ser miembro de $group. Puedes volver a unirte cuando quieras.';
  }

  @override
  String get groupMembersPrivate =>
      'La lista de miembros de este grupo es privada.';

  @override
  String get unignore => 'Dejar de ignorar';

  @override
  String get inviteLinkCreated => 'Enlace de invitación creado';

  @override
  String expiresOn(Object date) {
    return 'Caduca el $date';
  }

  @override
  String get solution => 'Solución';

  @override
  String get deleted => 'ELIMINADO';

  @override
  String get pleaseLoginToViewUserProfiles =>
      'Inicia sesión para ver perfiles de usuario.';

  @override
  String get solved => 'Resuelto';

  @override
  String get hot => 'Popular';

  @override
  String get pinned => 'Fijado';

  @override
  String get locked => 'Bloqueado';

  @override
  String get poll => 'Encuesta';

  @override
  String get noDiscussionsYet => 'Aún no hay discusiones.';

  @override
  String get jumpToPost => 'Ir a la publicación';

  @override
  String get jump => 'Ir';

  @override
  String get endOfTheDiscussion => 'Fin de la discusión';

  @override
  String get reviewQueueStaffOnly =>
      'Solo el personal y los revisores pueden ver la cola de revisión.';

  @override
  String get nothingToReview => 'Nada que revisar';

  @override
  String refreshFailed(Object error) {
    return 'Error al actualizar: $error';
  }

  @override
  String get refreshing => 'Actualizando...';

  @override
  String get title => 'Título';

  @override
  String editedAt(Object time) {
    return 'Editado $time';
  }

  @override
  String editReason(Object reason) {
    return 'Motivo: $reason';
  }

  @override
  String get thisDiffIsTooLargeToDisplay =>
      'Esta diferencia es demasiado grande para mostrarla.';

  @override
  String get noContentChangesInThisRevision =>
      'No hay cambios de contenido en esta revisión.';

  @override
  String revisionOf(Object currentVersion, Object versionCount) {
    return 'Revisión $currentVersion de $versionCount';
  }

  @override
  String get editConversation => 'Editar título';

  @override
  String get closeConversation => 'Cerrar mensaje';

  @override
  String get openConversation => 'Abrir mensaje';

  @override
  String get leaveConversation2 => 'Abandonar mensaje';

  @override
  String get closeConversation2 => 'Cerrar mensaje';

  @override
  String get closeConversationConfirmation =>
      '¿Cerrar este mensaje? Ya no aceptará respuestas nuevas.';

  @override
  String get close => 'Cerrar';

  @override
  String get openConversation2 => 'Abrir mensaje';

  @override
  String get openConversationConfirmation =>
      '¿Abrir este mensaje? Volverá a aceptar respuestas nuevas.';

  @override
  String get open => 'Abrir';

  @override
  String get leaveConversation3 => 'Abandonar mensaje';

  @override
  String get leaveConversationConfirmation =>
      '¿Seguro que quieres salir de este mensaje? Ya no podrás verlo ni responder.';

  @override
  String get editConversation2 => 'Editar título';

  @override
  String get failedToLoadMessage2 => 'No se pudo cargar el mensaje';

  @override
  String get cannotEditThisConversation => 'No puedes editar este mensaje';

  @override
  String get options => 'Opciones';

  @override
  String get conversationOpen => 'Abierto a respuestas';

  @override
  String get messageTitleHint =>
      'En una frase breve, ¿de qué trata este mensaje?';

  @override
  String get messageOpenForReplies => 'Acepta respuestas nuevas';

  @override
  String get messageClosedForReplies =>
      'Cerrado: no se aceptan respuestas nuevas';

  @override
  String get messageSentWithoutId =>
      'El mensaje se envió, pero el foro no lo devolvió. Revisa tus mensajes.';

  @override
  String get messageCouldNotBeSent => 'No se pudo enviar el mensaje.';

  @override
  String get messageIdMissing => 'No se puede abrir este mensaje: falta su ID.';

  @override
  String get pleaseAddARecipient => 'Añade al menos un destinatario';

  @override
  String get archiveMessage => 'Archivar';

  @override
  String get moveToInbox => 'Mover a la bandeja de entrada';

  @override
  String get messageInbox => 'Bandeja de entrada';

  @override
  String get messageArchive => 'Archivo';

  @override
  String get messageListUnread => 'Sin leer';

  @override
  String get messageListNew => 'Nuevo';

  @override
  String get messageListSent => 'Enviados';

  @override
  String removeFromMessageConfirm(String name) {
    return '¿Seguro que quieres eliminar a $name de este mensaje?';
  }

  @override
  String uploadingFilename(String filename) {
    return 'Subiendo: $filename…';
  }

  @override
  String get messageArchived => 'Mensaje archivado';

  @override
  String get messageMovedToInbox => 'Movido a la bandeja de entrada';

  @override
  String failedToArchiveMessage(Object error) {
    return 'No se pudo archivar el mensaje: $error';
  }

  @override
  String failedToMoveMessageToInbox(Object error) {
    return 'No se pudo mover el mensaje a la bandeja de entrada: $error';
  }

  @override
  String get noArchivedMessages => 'No tienes mensajes archivados';

  @override
  String get noArchivedMessagesHint =>
      'Archiva un mensaje desde su menú ⋮ para guardarlo aquí.';

  @override
  String groupHasBeenInvited(String group) {
    return 'Se ha invitado a $group al mensaje';
  }

  @override
  String participantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participantes',
      one: '1 participante',
    );
    return '$_temp0';
  }

  @override
  String get chatChannels => 'Canales';

  @override
  String get chatDms => 'MDs';

  @override
  String get chatNoChannels => '¡No te has unido a ningún canal todavía!';

  @override
  String get chatNoDms => '¡No te has unido a ningún mensaje directo todavía!';

  @override
  String get chatNoDmsCta => 'Inicia una conversación';

  @override
  String chatPlaceholderChannel(String channel) {
    return 'Chat en $channel';
  }

  @override
  String chatPlaceholderUsers(String names) {
    return 'Chatear con $names';
  }

  @override
  String get chatPlaceholderSelf => 'Anota algo';

  @override
  String get chatPlaceholderArchived =>
      'El canal está archivado, no puedes enviar nuevos mensajes en este momento.';

  @override
  String get chatPlaceholderClosed =>
      'El canal está cerrado, no puedes enviar nuevos mensajes en este momento.';

  @override
  String get chatPlaceholderReadOnly =>
      'El canal es de solo lectura, no puedes enviar nuevos mensajes en este momento.';

  @override
  String get chatPlaceholderSilenced =>
      'No puedes enviar mensajes en este momento.';

  @override
  String get chatDeleteConfirm => '¿Seguro que quieres eliminar este mensaje?';

  @override
  String get chatStartNewDm => 'Crear un nuevo MD';

  @override
  String get chatCreatePersonal => 'Crear un chat personal';

  @override
  String get chatCreateGroup => 'Crear chat de grupo';

  @override
  String get chatCannotCreate =>
      'Lo sentimos, no puedes enviar mensajes directos.';

  @override
  String get chatDisabledUser => 'ha desactivado el chat';

  @override
  String get chatSearchPlaceholder => '@alguien';

  @override
  String get chatAddMorePlaceholder => '...añadir más miembros';

  @override
  String chatUserNotFound(String name) {
    return '@$name no encontrado';
  }

  @override
  String get chatCouldNotStartDm => 'No se pudo iniciar el chat.';

  @override
  String get chatSignInTitle => 'Inicia sesión para usar el chat';

  @override
  String get chatSignInMessage =>
      'Debes iniciar sesión para ver canales de chat y unirte a ellos.';

  @override
  String get chatDirectMessage => 'Mensaje directo';

  @override
  String get chatNotAvailable => 'El chat no está disponible en este foro.';

  @override
  String get chatAttachFile => 'Adjuntar un archivo';

  @override
  String get chatRemoveUpload => 'Eliminar archivo';

  @override
  String get takePhoto => 'Tomar foto';

  @override
  String get postNeedsApprovalTitle => 'La publicación requiere aprobación';

  @override
  String get postNeedsApprovalBody =>
      'Hemos recibido tu nueva publicación, pero debe ser aprobada por un moderador antes de que aparezca. Por favor, ten paciencia.';

  @override
  String maximumAttachmentsAllowed(Object count) {
    return 'Máximo de $count adjunto(s) permitido(s)';
  }

  @override
  String get noImagesFoundToDisplay =>
      'No se encontraron imágenes para mostrar.';

  @override
  String get searchForTopics => 'Buscar temas';

  @override
  String get noTopicsFound => 'No se encontraron temas';

  @override
  String get trySearchingWithDifferentKeywords =>
      'Prueba con otras palabras clave';

  @override
  String get noPostsFound => 'No se encontraron publicaciones';

  @override
  String get perTopicNotificationLevelsNote =>
      'Los niveles de notificación por categoría y por tema se ajustan en esas pantallas: toca el icono de campana en cualquier tema o categoría.';

  @override
  String get pushNotActiveForThisLogin =>
      'No activas para este inicio de sesión: cierra sesión y vuelve a entrar para autorizar las notificaciones push';

  @override
  String get pauseNotificationsFor => 'Pausar notificaciones durante…';

  @override
  String get doNotDisturbExplanation =>
      'Pausa las notificaciones un tiempo: Discourse las retiene hasta que termine el periodo';

  @override
  String get manageAccountSubtitle =>
      'Perfil, correo, contraseña, seguridad, ajustes avanzados';

  @override
  String get changePasswordSubtitle =>
      'Envía un correo de restablecimiento de contraseña a tu dirección actual';

  @override
  String get ignoredUsersSubtitle =>
      'Ver y gestionar usuarios cuyas publicaciones están ocultas para ti';

  @override
  String get deleteAccountExplanation =>
      'Elimina tu cuenta y tus publicaciones, si el foro lo permite. Si no, su equipo puede eliminarla por ti.';

  @override
  String get verificationEmailSent =>
      'Correo de verificación enviado: haz clic en el enlace para confirmar tu nueva dirección.';

  @override
  String get passwordResetExplanation =>
      'Te enviaremos un enlace para restablecer la contraseña. Haz clic para elegir una nueva: el cambio se gestiona en el foro, no en esta app.';

  @override
  String get sendResetEmail => 'Enviar correo de restablecimiento';

  @override
  String get deleteAccountDialogBody =>
      'Tu cuenta la gestiona el foro. Contacta directamente con el equipo del foro para solicitar la eliminación. «Continuar» abrirá el foro en tu navegador para usar su propio flujo de contacto o mensaje al equipo.';

  @override
  String get initializingForum => 'Inicializando foro…';

  @override
  String get errorLoadingNotifications => 'Error al cargar las notificaciones';

  @override
  String get noNewNotificationsExplanation =>
      'En esta pestaña te avisaremos sobre actividad relevante para ti incluyendo respuestas a tus temas y mensajes, @menciones o citas, y respuestas a los temas que estés siguiendo. También te notificaremos por correo electrónico si hace tiempo que no te conectas.';

  @override
  String noTagsMatch(Object filter) {
    return 'Ninguna etiqueta coincide con «$filter».';
  }

  @override
  String noTopicsTagged(Object tag) {
    return 'No hay temas con la etiqueta «$tag»';
  }

  @override
  String get searchUser => 'Buscar usuario';

  @override
  String get tapToOpen => 'Toca para abrir';

  @override
  String get imageNotAvailable => 'Imagen no disponible';

  @override
  String postsCount(Object count) {
    return '$count publicaciones';
  }

  @override
  String get permissionDeniedToSaveImage =>
      'Permiso denegado para guardar la imagen';

  @override
  String get postNotFound => 'Publicación no encontrada.';

  @override
  String get failedToUploadFilePleaseTryAgain =>
      'No se pudo subir el archivo. Inténtalo de nuevo.';

  @override
  String failedToUploadFile2(Object errorMessage) {
    return 'No se pudo subir el archivo: $errorMessage';
  }

  @override
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return 'Solo se permiten $remainingSlots adjunto(s) más. Se procesarán las primeras $remainingSlots2 imágenes.';
  }

  @override
  String failedToRemoveAttachment2(Object error) {
    return 'No se pudo quitar el adjunto: $error';
  }

  @override
  String sentFromMobileApp(Object siteName) {
    return 'Enviado desde la app móvil de $siteName';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      'Espera a que terminen de subirse los adjuntos';

  @override
  String get imageIsTooLargeToUpload =>
      'La imagen es demasiado grande para subirla';

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName pesa $fileBytes. Este foro permite hasta $maxBytes.';
  }

  @override
  String get resizeToFitExplanation =>
      'Puede reducirse justo lo necesario para que quepa, manteniendo el formato y todo el detalle que permita el límite.';

  @override
  String get failedToPostReplyPleaseTryAgain =>
      'No se pudo publicar la respuesta. Inténtalo de nuevo.';

  @override
  String get failedToUpdatePostPleaseTryAgain =>
      'No se pudo actualizar la publicación. Inténtalo de nuevo.';

  @override
  String get postDeletedSuccessfully => 'Publicación eliminada';

  @override
  String failedToDeletePost(Object error) {
    return 'No se pudo eliminar la publicación: $error';
  }

  @override
  String get editHistoryNotAvailable =>
      'El historial de ediciones no está disponible para esta publicación';

  @override
  String get react => 'Reaccionar';

  @override
  String get reactionsAreNotEnabledOnThisForum =>
      'Las reacciones no están habilitadas en este foro.';

  @override
  String get noReactionsYet => 'Aún no hay reacciones';

  @override
  String get searchFilters => 'Filtros de búsqueda';

  @override
  String get suggestedTopics => 'Temas sugeridos';

  @override
  String get suggestedMessages => 'Mensajes sugeridos';

  @override
  String get voteRemoved => 'Voto eliminado';

  @override
  String get voters => 'Votantes';

  @override
  String get noVotesYet => 'Aún no hay votos.';

  @override
  String get trustLevels => 'Niveles de confianza';

  @override
  String get trustLevelsExplanation =>
      'Los miembros ganan confianza leyendo y participando. Cada nivel desbloquea nuevas capacidades.';

  @override
  String get activity => 'Actividad';

  @override
  String get dontUpload => 'No subir';

  @override
  String get dontAskAgainAlwaysResize =>
      'No volver a preguntar: reducir siempre para que quepa';

  @override
  String get couldNotLoadCategories => 'No se pudieron cargar las categorías.';

  @override
  String get tags => 'Etiquetas';

  @override
  String get community => 'Comunidad';

  @override
  String get users => 'Usuarios';

  @override
  String get groups => 'Grupos';

  @override
  String get invites => 'Invitaciones';

  @override
  String get account => 'Cuenta';

  @override
  String get drafts => 'Borradores';

  @override
  String get termsOfService => 'Términos del servicio';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get notSignedIn => 'Sin iniciar sesión';

  @override
  String get deviceWillNotShowAlertsUntilAllowedInSettings =>
      'Tu dispositivo no mostrará avisos hasta que permitas las notificaciones en Ajustes.';

  @override
  String get openSettings => 'Abrir ajustes';

  @override
  String get notificationsThisDeviceSection => 'En este dispositivo';

  @override
  String notificationsThisDeviceCaption(Object forumName) {
    return 'Push de $forumName solo a este dispositivo. Tus otros dispositivos y la web no se ven afectados.';
  }

  @override
  String notificationsAccountSection(Object forumName) {
    return 'Tu cuenta en $forumName';
  }

  @override
  String get notificationsAccountCaption =>
      'Se aplican en todas partes: en la web, por correo y en todos tus dispositivos.';

  @override
  String pushOnThisDeviceSubtitle(Object forumName) {
    return 'Activadas: las nuevas notificaciones de $forumName llegan a este dispositivo.';
  }

  @override
  String pushOffThisDeviceSubtitle(Object forumName) {
    return 'Desactivadas en este dispositivo. Para activarlas, lo apruebas una vez en $forumName.';
  }

  @override
  String get stopPushOnThisDevice => 'Detener push en este dispositivo';

  @override
  String stopPushTitle(Object forumName) {
    return '¿Detener push de $forumName en este dispositivo?';
  }

  @override
  String get stopPushOnlyThisDevice =>
      'Solo se detiene en este dispositivo. Tus otros dispositivos conservan el suyo.';

  @override
  String get stopPushNothingElseChanges =>
      'Tus notificaciones siguen apareciendo en la app y en la web, y los correos del foro no cambian.';

  @override
  String stopPushPermissionDeleted(Object forumName) {
    return 'Se elimina el permiso que diste en $forumName. Para volver a activar push, tendrás que aprobarlo allí de nuevo.';
  }

  @override
  String get stopPushQuietHint =>
      '¿Solo quieres silencio un rato? Desactiva arriba los tipos que no necesites o usa No molestar en tu perfil.';

  @override
  String get stopPush => 'Detener push';

  @override
  String get turnOn => 'Activar';

  @override
  String get couldNotTurnOffNotifications =>
      'No se pudo detener push. Inténtalo de nuevo más tarde.';

  @override
  String actionCodeTopicCreated(String when) {
    return 'Creó este tema $when';
  }

  @override
  String actionCodePublicTopic(String when) {
    return 'Hizo este tema público $when';
  }

  @override
  String actionCodeOpenTopic(String when) {
    return 'Convirtió esto en un tema $when';
  }

  @override
  String actionCodePrivateTopic(String when) {
    return 'Hizo este tema un mensaje personal $when';
  }

  @override
  String actionCodeSplitTopic(String when) {
    return 'Separó este tema $when';
  }

  @override
  String actionCodeInvitedUser(String who, String when) {
    return 'Invitó a $who $when';
  }

  @override
  String actionCodeInvitedGroup(String who, String when) {
    return 'Invitó a $who $when';
  }

  @override
  String actionCodeUserLeft(String who, String when) {
    return '$who se eliminó a sí mismo de este mensaje $when';
  }

  @override
  String actionCodeRemovedUser(String who, String when) {
    return 'Eliminó a $who $when';
  }

  @override
  String actionCodeRemovedGroup(String who, String when) {
    return 'Eliminó a $who $when';
  }

  @override
  String actionCodeAutobumped(String when) {
    return 'Reflotado automáticamente $when';
  }

  @override
  String actionCodeTagsChanged(String when) {
    return 'Etiquetas actualizadas $when';
  }

  @override
  String actionCodeCategoryChanged(String when) {
    return 'Categoría actualizada $when';
  }

  @override
  String get actionCodeForwarded => 'Reenvió el correo electrónico de arriba';

  @override
  String actionCodeAutoclosedEnabled(String when) {
    return 'Cerrado $when';
  }

  @override
  String actionCodeAutoclosedDisabled(String when) {
    return 'Abierto $when';
  }

  @override
  String actionCodeClosedEnabled(String when) {
    return 'Cerrado $when';
  }

  @override
  String actionCodeClosedDisabled(String when) {
    return 'Abierto $when';
  }

  @override
  String actionCodeArchivedEnabled(String when) {
    return 'Archivado $when';
  }

  @override
  String actionCodeArchivedDisabled(String when) {
    return 'Desarchivado $when';
  }

  @override
  String actionCodePinnedEnabled(String when) {
    return 'Anclado $when';
  }

  @override
  String actionCodePinnedDisabled(String when) {
    return 'Desanclado $when';
  }

  @override
  String actionCodePinnedGloballyEnabled(String when) {
    return 'Anclado globalmente $when';
  }

  @override
  String actionCodePinnedGloballyDisabled(String when) {
    return 'Desanclado $when';
  }

  @override
  String actionCodeVisibleEnabled(String when) {
    return 'Listado $when';
  }

  @override
  String actionCodeVisibleDisabled(String when) {
    return 'Quitado de la lista $when';
  }

  @override
  String actionCodeBannerEnabled(String when) {
    return 'Hizo esto un banner $when. Aparecerá en la parte superior de cada página hasta que el usuario lo descarte.';
  }

  @override
  String actionCodeBannerDisabled(String when) {
    return 'Quitó este banner $when. Ya no aparecerá en la parte superior de cada página.';
  }

  @override
  String actionCodeAssigned(String who, String when) {
    return 'Asignó a $who el $when';
  }

  @override
  String actionCodeUnassigned(String who, String when) {
    return 'Anuló la asignación de $who el $when';
  }

  @override
  String actionCodeReassigned(String who, String when) {
    return 'Reasignó a $who $when';
  }

  @override
  String localDateToday(String time) {
    return 'Hoy $time';
  }

  @override
  String localDateTomorrow(String time) {
    return 'Mañana $time';
  }

  @override
  String localDateYesterday(String time) {
    return 'Ayer $time';
  }

  @override
  String get eventExpired => 'Caducado';

  @override
  String get eventEveryDay => 'Cada día';

  @override
  String get eventEveryWeekday => 'Todos los días de la semana';

  @override
  String get eventEveryWeek => 'Todas las semanas en este día de la semana';

  @override
  String get eventEveryTwoWeeks => 'Cada dos semanas en este día de la semana';

  @override
  String get eventEveryFourWeeks =>
      'Cada cuatro semanas en este día de la semana';

  @override
  String get eventEveryMonth => 'Todos los meses en este día de la semana';

  @override
  String get errorNoConnection =>
      'No se pudo conectar con el foro. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get errorTimedOut =>
      'El foro tardó demasiado en responder. Inténtalo de nuevo.';

  @override
  String get errorPaywalled =>
      'Esto es solo para los miembros de pago del foro.';

  @override
  String get errorBlocked =>
      'El cortafuegos del foro bloqueó la aplicación. Inténtalo más tarde o abre el foro en un navegador.';

  @override
  String get errorNotAllowed =>
      'No tienes acceso a esto. Iniciar sesión podría ayudar.';

  @override
  String get errorNotFound => 'Esto no existe o se ha eliminado.';

  @override
  String get errorRateLimited =>
      'Estás haciendo eso con demasiada frecuencia. Espera un momento e inténtalo de nuevo.';

  @override
  String get errorForumDown =>
      'El foro no responde en este momento. Inténtalo más tarde.';

  @override
  String get deleteSpammer => 'Eliminar spammer';

  @override
  String get yesDeleteSpammer => 'Sí, eliminar spammer';

  @override
  String get deleteSpammerConfirm =>
      'Estás a punto de eliminar las publicaciones y temas de este usuario, también eliminarás su cuenta, bloquearás registros desde su dirección IP y añadirás su correo electrónico a una lista de bloqueos permanentes. ¿Seguro que el usuario es de verdad un spammer?';

  @override
  String get userWasDeleted => 'El usuario se eliminó.';

  @override
  String get deleteMyAccount => 'Eliminar mi cuenta';

  @override
  String get deleteAccountConfirm =>
      '¿Quieres eliminar permanentemente tu cuenta? ¡Esta acción no se puede deshacer!';

  @override
  String get deletedYourself => 'Tu cuenta se ha eliminado con éxito.';

  @override
  String get deleteYourselfNotAllowed =>
      'Contacta con un miembro del equipo si deseas que se elimine tu cuenta.';

  @override
  String get createTopic => 'Crear tema';

  @override
  String get discardPostQuestion => '¿Quieres descartar tu publicación?';

  @override
  String get discardChangesQuestion => '¿Quieres descartar tus cambios?';

  @override
  String get discardChanges => 'Descartar cambios';

  @override
  String get saveDraft => 'Guardar borrador';

  @override
  String get notificationSettings => 'Ajustes de notificaciones';

  @override
  String get topicIsNew => 'Tema nuevo';

  @override
  String get noNewTopicsSinceLastVisit =>
      'No hay temas nuevos desde tu última visita.';

  @override
  String get messageIsNew => 'Mensaje nuevo';

  @override
  String topicUnreadReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count respuestas sin leer',
      one: '1 respuesta sin leer',
    );
    return '$_temp0';
  }

  @override
  String filterNewWithCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nuevos ($count)',
      one: 'Nuevo ($count)',
    );
    return '$_temp0';
  }

  @override
  String filterUnreadWithCount(int count) {
    return 'Sin leer ($count)';
  }

  @override
  String categoryNewTopics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuevos',
      one: '$count nuevo',
    );
    return '$_temp0';
  }

  @override
  String categoryUnreadTopics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sin leer',
    );
    return '$_temp0';
  }

  @override
  String get dismissNew => 'Descartar nuevos';

  @override
  String get dismissUnread => 'Descartar sin leer';

  @override
  String get dismissNewTitle => '¿Descartar los temas nuevos?';

  @override
  String get dismissNewMessage => 'Ya no aparecerán como nuevos.';

  @override
  String get dismissUnreadTitle => '¿Descartar todos los temas sin leer?';

  @override
  String get dismissUnreadMessage =>
      'Sus respuestas nuevas se marcarán como leídas.';

  @override
  String get dismissUnreadStopTracking =>
      'Dejar de seguir estos temas para que no aparezcan más en mis mensajes no leídos';

  @override
  String get dismissNewAndUnread => 'Descartar nuevos y sin leer';

  @override
  String dismissNewAndUnreadMessage(String category) {
    return 'Los temas de $category ya no aparecerán como nuevos ni sin leer.';
  }

  @override
  String get dismissedTopics => 'Descartados';

  @override
  String topicMapViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'visitas',
      one: 'visita',
    );
    return '$_temp0';
  }

  @override
  String topicMapLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'me gusta',
    );
    return '$_temp0';
  }

  @override
  String topicMapLinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'enlaces',
      one: 'enlace',
    );
    return '$_temp0';
  }

  @override
  String topicMapUsers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'usuarios',
      one: 'usuario',
    );
    return '$_temp0';
  }

  @override
  String get markAsSolution => 'Marcar como solución';

  @override
  String get unmarkAsSolution => 'Desmarcar como solución';

  @override
  String searchForumName(String forum) {
    return 'Buscar en $forum';
  }

  @override
  String countActiveThisMonth(String formatted) {
    return '$formatted activos este mes';
  }

  @override
  String countMembers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted miembros',
      one: '$formatted miembro',
    );
    return '$_temp0';
  }

  @override
  String countTopics(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted temas',
      one: '$formatted tema',
    );
    return '$_temp0';
  }

  @override
  String categoryNewThisWeek(int count) {
    return '$count nuevos esta semana';
  }

  @override
  String get categoriesView => 'Categorías';

  @override
  String get allCategories => 'Todas las categorías';

  @override
  String get allTags => 'Todas las etiquetas';

  @override
  String get myPosts => 'Mis publicaciones';

  @override
  String get drawerIntroduction =>
      'Las categorías, etiquetas y tu cuenta de este foro están en este menú. Ábrelo cuando quieras con el botón de menú.';

  @override
  String trustLevelN(int level) {
    return 'Nivel de confianza $level';
  }

  @override
  String get filterNew => 'Nuevos';

  @override
  String get filterTop => 'Destacados';

  @override
  String get levelWatching => 'Vigilando';

  @override
  String get levelWatchingFirstPost => 'Vigilar primera publicación';

  @override
  String get levelTracking => 'Siguiendo';

  @override
  String get levelNormal => 'Normal';

  @override
  String get levelMuted => 'Silenciado';

  @override
  String get chooseCategory => 'Elige una categoría';

  @override
  String get signInToPostAndGetNotifications =>
      'Inicia sesión para publicar y recibir notificaciones';

  @override
  String forumBlocksNotificationServer(Object forumName) {
    return '$forumName bloquea nuestro servidor de notificaciones, así que es posible que no lleguen. Puedes desactivarlas en Ajustes.';
  }

  @override
  String get relatedTopics => 'Temas relacionados';

  @override
  String get relatedMessages => 'Mensajes relacionados';

  @override
  String moreInCategory(String category) {
    return 'Más en $category';
  }

  @override
  String get latestTopics => 'Temas recientes';

  @override
  String get pushGroupMessages => 'Mensajes y chat';

  @override
  String get pushGroupMessagesHint =>
      'Mensajes personales, bandejas de grupo y chat';

  @override
  String get pushGroupReplies => 'Respuestas y menciones';

  @override
  String get pushGroupRepliesHint =>
      'Respuestas, menciones, citas y temas que sigues';

  @override
  String get pushGroupReactions => 'Me gusta y reacciones';

  @override
  String get pushGroupReactionsHint =>
      'Me gusta y reacciones a tus publicaciones';

  @override
  String get pushGroupOther => 'Todo lo demás';

  @override
  String get pushGroupOtherHint =>
      'Medallas, recordatorios, respuestas aceptadas y más';

  @override
  String get pushChannelOther => 'Otras notificaciones';

  @override
  String get couldNotChangePushSetting =>
      'No se pudo cambiar este ajuste. Inténtalo más tarde.';

  @override
  String neverMissAReplyOn(Object forumName) {
    return 'No te pierdas ninguna respuesta en $forumName';
  }

  @override
  String get notificationsPitch =>
      'Respuestas, menciones, mensajes y chat en tu pantalla de bloqueo, normalmente en menos de 10 minutos. Puedes elegir cuáles cuando quieras en Ajustes.';

  @override
  String get notificationsStepAllow =>
      'Permitir notificaciones en este teléfono';

  @override
  String get notificationsStepAllowed =>
      'Las notificaciones están permitidas en este teléfono';

  @override
  String notificationsStepApprove(Object forumName) {
    return 'Aprobar en $forumName';
  }

  @override
  String get notificationsReadOnlyNote =>
      'Solo lectura: no puede publicar, responder ni leer tus mensajes';

  @override
  String get notificationPreviewReply =>
      'Jane te respondió: ¡Bienvenido! Nos alegra que nos encontraras.';

  @override
  String get notificationPreviewMessage =>
      'Sam te envió un mensaje: ¿Vienes el viernes?';

  @override
  String get notificationPreviewNow => 'ahora';

  @override
  String get notificationPreviewEarlier => 'hace 5 min';

  @override
  String get activityReplied => 'Respondió';

  @override
  String get activityStartedTopic => 'Inició un tema';

  @override
  String get activityLiked => 'Le gustó';

  @override
  String get activitySolution => 'Solución';

  @override
  String get activityAcceptedBy => 'aceptada por';

  @override
  String get activityAwaitingApproval => 'Pendiente de aprobación';

  @override
  String get activityFilterTopics => 'Temas';

  @override
  String get activityFilterReplies => 'Respuestas';

  @override
  String get activityFilterLikes => 'Me gusta';

  @override
  String get activityFilterPending => 'Pendientes';

  @override
  String get sectionToday => 'Hoy';

  @override
  String get sectionThisWeek => 'Esta semana';

  @override
  String get sectionEarlier => 'Antes';

  @override
  String draftsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count borradores pendientes',
      one: '1 borrador pendiente',
    );
    return '$_temp0';
  }

  @override
  String get resumeDrafts => 'Reanudar';

  @override
  String get myPostsEmpty => 'Aún no hay publicaciones';

  @override
  String get myPostsEmptyHint =>
      'Los temas que inicies y las respuestas que escribas aparecerán aquí.';

  @override
  String get activityEmptyTopics => 'Aún no hay temas';

  @override
  String get activityEmptyReplies => 'Aún no hay respuestas';

  @override
  String get activityEmptyLikes => 'Aún no has dado me gusta';

  @override
  String get activityEmptySolved => 'Aún no hay soluciones';

  @override
  String get viewProfile => 'Ver perfil';

  @override
  String get yourStuff => 'Lo tuyo';

  @override
  String get accountAndPrivacy => 'Cuenta y privacidad';

  @override
  String profileStatPosts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'publicaciones',
      one: 'publicación',
    );
    return '$_temp0';
  }

  @override
  String profileStatLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'me gusta',
    );
    return '$_temp0';
  }

  @override
  String profileStatDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'días',
      one: 'día',
    );
    return '$_temp0';
  }

  @override
  String get profileStatSolved => 'resueltos';

  @override
  String joinForum(String forum) {
    return 'Únete a $forum';
  }

  @override
  String get guestBenefitPost => 'Responde y crea temas';

  @override
  String get guestBenefitNotify => 'Recibe avisos cuando te respondan';

  @override
  String get guestBenefitSave => 'Guarda publicaciones y borradores';

  @override
  String get guestBenefitChat => 'Chatea y envía mensajes';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get aboutThisForum => 'Acerca de este foro';

  @override
  String get drawerMore => 'Más';

  @override
  String get goToYourProfile => 'Ir a tu perfil';

  @override
  String profileJoined(String date) {
    return 'Se unió en $date';
  }

  @override
  String profileSeen(String when) {
    return 'Visto $when';
  }

  @override
  String profileLocalTime(String time) {
    return '$time hora local';
  }

  @override
  String get profileTabSummary => 'Resumen';

  @override
  String get summaryTopReplies => 'Mejores respuestas';

  @override
  String get summaryTopTopics => 'Mejores temas';

  @override
  String get summaryMostLikedBy => 'Más me gusta de';

  @override
  String get summaryMostLiked => 'Más le gustó';

  @override
  String get summaryMostRepliedTo => 'Más respondido a';

  @override
  String get summaryTopLinks => 'Enlaces destacados';

  @override
  String get summaryTopCategories => 'Categorías principales';

  @override
  String get featuredTopic => 'Tema destacado';

  @override
  String get profileDetails => 'Detalles';

  @override
  String get followUser => 'Seguir';

  @override
  String get unfollowUser => 'Dejar de seguir';

  @override
  String get profileSuspended => 'Suspendido';

  @override
  String get searchBookmarks => 'Buscar en tus marcadores';

  @override
  String get bookmarksFilterReminders => 'Recordatorios';

  @override
  String get bookmarkWholeTopic => 'Tema completo';

  @override
  String bookmarkSaved(String when) {
    return 'guardado $when';
  }

  @override
  String bookmarkPostNumber(int number) {
    return 'publicación #$number';
  }

  @override
  String reminderToday(String time) {
    return 'Hoy, $time';
  }

  @override
  String reminderTomorrow(String time) {
    return 'Mañana, $time';
  }

  @override
  String reminderDue(String when) {
    return 'Pendiente · $when';
  }

  @override
  String get addBookmarkLabel => 'Añadir etiqueta';

  @override
  String get editBookmarkLabel => 'Editar etiqueta';

  @override
  String get bookmarkLabelHint => '¿Para qué es?';

  @override
  String get pinBookmark => 'Fijar arriba';

  @override
  String get unpinBookmark => 'Desfijar';

  @override
  String get bookmarkRemoved => 'Marcador eliminado';

  @override
  String get undo => 'Deshacer';

  @override
  String get bookmarksNoMatch => 'Ningún marcador coincide';

  @override
  String get addReminder => 'Añadir recordatorio';

  @override
  String get bookmarksEmpty => 'Aún no hay marcadores';

  @override
  String get bookmarksEmptyHint =>
      'Marca una publicación desde sus acciones y te esperará aquí.';

  @override
  String get draftKindNewTopic => 'Nuevo tema';

  @override
  String draftMessageTo(String names) {
    return 'Mensaje a $names';
  }

  @override
  String get untitledTopic => 'Tema sin título';

  @override
  String get draftDiscarded => 'Borrador descartado';

  @override
  String get draftsEmpty => 'Aún no hay borradores';

  @override
  String get draftsEmptyHint =>
      'Los borradores se guardan mientras escribes. Empieza una respuesta o un tema y te esperará aquí.';

  @override
  String get privacySection => 'Privacidad';

  @override
  String get changeEmailSubtitle =>
      'Te enviaremos un enlace de verificación a la nueva dirección';

  @override
  String get aboutMe => 'Sobre mí';

  @override
  String get aboutMeHelper => 'Se muestra en la parte superior de tu perfil';

  @override
  String get aboutMeMarkdownHint =>
      'Admite Markdown: **negrita**, enlaces, :emoji:';

  @override
  String get addCover => 'Añadir portada';

  @override
  String get changeCover => 'Cambiar portada';

  @override
  String get birthdayHint => 'El foro lo celebra contigo. No se guarda el año.';

  @override
  String get birthdayRemoved => 'Cumpleaños eliminado';

  @override
  String get birthdaySaved => 'Cumpleaños guardado';

  @override
  String get cardBackground => 'Fondo de la tarjeta';

  @override
  String get cardBackgroundExplanation =>
      'Detrás de tu tarjeta de usuario cuando alguien toca tu foto';

  @override
  String get cardBackgroundRemoved => 'Fondo de la tarjeta eliminado';

  @override
  String get cardBackgroundSheetHint =>
      'Se muestra detrás de tu tarjeta de usuario. Las fotos anchas quedan mejor.';

  @override
  String get changeProfilePicture => 'Cambiar foto de perfil';

  @override
  String get changeUsername => 'Cambiar nombre de usuario';

  @override
  String changeUsernameExplanation(String username) {
    return 'Las menciones y citas de @$username en las publicaciones pasarán al nuevo nombre. Los enlaces antiguos a tu perfil dejarán de funcionar.';
  }

  @override
  String get chooseFromLibrary => 'Elegir de la galería';

  @override
  String get coverPhoto => 'Foto de portada';

  @override
  String get coverPhotoSheetHint =>
      'Se muestra en la parte superior de tu perfil, detrás de tu foto. Las fotos anchas quedan mejor, de unos 3 a 1.';

  @override
  String get coverRemoved => 'Portada eliminada';

  @override
  String get day => 'Día';

  @override
  String get month => 'Mes';

  @override
  String get displayName => 'Nombre visible';

  @override
  String displayNameHelper(String username) {
    return 'Se muestra junto a tus publicaciones. Tu nombre de usuario sigue siendo @$username.';
  }

  @override
  String get emailPasswordInAccount => 'Correo, contraseña e inicio de sesión';

  @override
  String get featureATopic => 'Destacar un tema';

  @override
  String get featureATopicHint =>
      'Fija uno de tus temas en la parte superior de tu perfil.';

  @override
  String get featuredTopicChanged => 'Tema destacado cambiado';

  @override
  String get featuredTopicNone =>
      'Ninguno. Fija uno de tus temas en tu perfil.';

  @override
  String get featuredTopicRemoved => 'Tema destacado eliminado';

  @override
  String get featuredTopicRules =>
      'No se pueden destacar mensajes ni temas de categorías privadas.';

  @override
  String get fieldManagedBySignIn =>
      'Este foro lo gestiona con su propio inicio de sesión. Cámbialo allí.';

  @override
  String get flair => 'Distintivo';

  @override
  String flairChangedTo(String group) {
    return 'Distintivo cambiado a $group';
  }

  @override
  String get flairRemoved => 'Distintivo eliminado';

  @override
  String get flairSheetHint =>
      'Un pequeño distintivo sobre tu foto, de un grupo al que perteneces.';

  @override
  String forumPictureN(int number) {
    return 'Imagen del foro $number';
  }

  @override
  String forumQuestionNeedsAnswer(String question) {
    return '$question necesita una respuesta';
  }

  @override
  String get forumQuestionRequired => 'Este foro pide a todos que respondan';

  @override
  String get forumQuestionSetByStaff => 'Lo establece el equipo del foro';

  @override
  String get forumQuestionsIntro =>
      'Preguntas de este foro. * indica obligatorio.';

  @override
  String get forumQuestionsNoneAnswered => 'Aún sin responder';

  @override
  String get fromThisForum => 'De este foro';

  @override
  String get hideMyProfile => 'Ocultar mi perfil público';

  @override
  String get hideMyProfileExplanation =>
      'Los demás solo ven tu nombre, tu foto y tus publicaciones';

  @override
  String get letterAvatar => 'Inicial';

  @override
  String get moreAboutYou => 'Más sobre ti';

  @override
  String namesAndMore(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count más',
      one: '1 más',
    );
    return '$names y $_temp0';
  }

  @override
  String get newUsername => 'Nuevo nombre de usuario';

  @override
  String get noFlair => 'Sin distintivo';

  @override
  String noGravatarFound(String service) {
    return '$service no tiene ninguna imagen para tu correo electrónico';
  }

  @override
  String get noTitle => 'Sin título';

  @override
  String get noTopicsMatch => 'Ninguno de tus temas coincide';

  @override
  String get noTopicsToFeature => 'Aún no has creado ningún tema';

  @override
  String get notSet => 'Sin definir';

  @override
  String get orUse => 'O usa';

  @override
  String get pictureManagedBySignIn =>
      'Este foro define tu foto con su propio inicio de sesión';

  @override
  String get primaryGroup => 'Grupo principal';

  @override
  String primaryGroupChangedTo(String group) {
    return 'Grupo principal cambiado a $group';
  }

  @override
  String get primaryGroupRemoved => 'Grupo principal eliminado';

  @override
  String get primaryGroupSheetHint =>
      'Tu grupo principal, que se muestra en tu tarjeta de usuario.';

  @override
  String get profileLoadFailed => 'No se pudo cargar tu perfil';

  @override
  String get profileNowHidden => 'Tu perfil está oculto';

  @override
  String get profileNowPublic => 'Tu perfil es público';

  @override
  String get profilePicture => 'Foto de perfil';

  @override
  String get profilePictureChanged => 'Foto de perfil cambiada';

  @override
  String get profileSaveFailed => 'No se pudo guardar. Inténtalo de nuevo.';

  @override
  String get profileSectionNameAndAbout => 'Nombre y sobre mí';

  @override
  String get profileSectionNextToName => 'Junto a tu nombre';

  @override
  String get profileSectionOnProfile => 'En tu perfil';

  @override
  String get profileSectionPrivacyAndTime => 'Privacidad y hora';

  @override
  String get removeCardBackground => 'Quitar fondo de la tarjeta';

  @override
  String get removeCover => 'Quitar portada';

  @override
  String get removeFeaturedTopic => 'Quitar tema destacado';

  @override
  String get searchTimezones => 'Buscar zonas horarias';

  @override
  String get searchYourTopics => 'Buscar en tus temas';

  @override
  String get seeProfileAsOthersDo => 'Ver tu perfil como lo ven los demás';

  @override
  String get timezone => 'Zona horaria';

  @override
  String timezoneChangedTo(String zone) {
    return 'Zona horaria cambiada a $zone';
  }

  @override
  String timezoneWithTime(String zone, String time) {
    return '$zone · ahora $time';
  }

  @override
  String timezonesMatchingPhone(String offset) {
    return 'Coincide con el reloj de este teléfono ($offset)';
  }

  @override
  String titleChangedTo(String title) {
    return 'Título cambiado a $title';
  }

  @override
  String get titleFromBadge => 'Medalla';

  @override
  String titleFromBadgeEarned(String date) {
    return 'Medalla · obtenida el $date';
  }

  @override
  String titleFromGroup(String group) {
    return 'Grupo $group';
  }

  @override
  String get titleGrantedByStaff => 'Otorgado por el equipo del foro';

  @override
  String get titleRemoved => 'Título eliminado';

  @override
  String get titleSheetHint =>
      'Se muestra después de tu nombre en tu perfil y tus publicaciones.';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get usernameAvailable => 'Disponible';

  @override
  String usernameChanged(String username) {
    return 'Tu nombre de usuario ahora es @$username';
  }

  @override
  String get usernameLockedExplanation =>
      'Este foro solo permite cambiar el nombre de usuario poco después de registrarse. Un moderador puede cambiarlo por ti.';

  @override
  String get yourPhoto => 'Tu foto';

  @override
  String get chooseEmoji => 'Elegir emoji';

  @override
  String get clearStatus => 'Borrar estado';

  @override
  String get clearText => 'Borrar';

  @override
  String get inOneHour => 'En una hora';

  @override
  String get never => 'Nunca';

  @override
  String get pauseNotifications => 'Pausar notificaciones';

  @override
  String get pauseNotificationsUntilStatusClears =>
      'Hasta que se quite tu estado';

  @override
  String get pickATime => 'Elegir una hora';

  @override
  String get removeStatusAfter => 'Quitar estado';

  @override
  String get searchEmoji => 'Buscar emoji';

  @override
  String get setStatus => 'Establecer estado';

  @override
  String get setAStatus => 'Establecer un estado';

  @override
  String get statusUpdated => 'Estado actualizado';

  @override
  String get whatAreYouDoing => '¿Qué estás haciendo?';

  @override
  String cardPosted(String when) {
    return 'Publicó $when';
  }

  @override
  String get change => 'Cambiar';

  @override
  String get copyProfileLink => 'Copiar enlace al perfil';

  @override
  String get ignore => 'Ignorar';

  @override
  String memberOfGroup(String group) {
    return 'Miembro de $group';
  }

  @override
  String get mute => 'Silenciar';

  @override
  String get unmute => 'Dejar de silenciar';

  @override
  String openProfileOf(String username) {
    return 'Abrir el perfil de @$username';
  }

  @override
  String profileIsPrivate(String username) {
    return '$username mantiene su perfil privado.';
  }

  @override
  String showOnlyTheirPostsHere(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'las $count publicaciones',
      one: 'la publicación',
    );
    return 'Mostrar solo $_temp0 de $name en este tema';
  }

  @override
  String showOnlyYourPostsHere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tus $count publicaciones',
      one: 'tu publicación',
    );
    return 'Mostrar solo $_temp0 en este tema';
  }

  @override
  String userIgnoredFor4Months(String username) {
    return 'Ignorarás a @$username durante 4 meses';
  }

  @override
  String userMuted(String username) {
    return 'Silenciaste a @$username';
  }

  @override
  String userUnmuted(String username) {
    return 'Dejaste de silenciar a @$username';
  }

  @override
  String get youParenthetical => '(tú)';

  @override
  String get topicStatusClosedHelp =>
      'Este tema está cerrado; ya no se aceptan respuestas nuevas';

  @override
  String get topicStatusArchivedHelp =>
      'este tema está archivado; está congelado y no se puede cambiar';

  @override
  String get topicStatusClosedArchivedHelp =>
      'este tema está cerrado y archivado; ya no acepta respuestas nuevas y no se puede cambiar';

  @override
  String get topicStatusPinnedTitle => 'Anclado';

  @override
  String get topicStatusPinnedHelp =>
      'Este tema se ha anclado para ti; se mostrará en la parte superior de su categoría';

  @override
  String get topicStatusPinnedGloballyTitle => 'Anclado globalmente';

  @override
  String get topicStatusPinnedGloballyHelp =>
      'Este tema se ha anclado globalmente, se mostrará en la parte superior de la página de mensajes recientes y de su categoría.';

  @override
  String get topicStatusUnpinnedTitle => 'Desanclado';

  @override
  String get topicStatusUnpinnedHelp =>
      'Este tema se ha desanclado para ti; tu lista de temas se mostrará en orden normal';

  @override
  String get topicStatusUnlistedHelp =>
      'Este tema no está incluido en la lista; no se mostrará en las listas de temas y solo se podrá acceder a él mediante un enlace directo.';

  @override
  String get topicStatusWarningHelp => 'Esta es una advertencia oficial.';

  @override
  String get notificationReasonWatchingTag =>
      'Recibirás notificaciones porque estás vigilando una etiqueta de este tema.';

  @override
  String get notificationReasonWatchingCategory =>
      'Recibirás notificaciones porque estás vigilando esta categoría.';

  @override
  String get notificationReasonWatchingAuto =>
      'Recibirás notificaciones porque has empezado a vigilar este tema automáticamente.';

  @override
  String get notificationReasonWatching =>
      'Recibirás notificaciones porque estás vigilando este tema.';

  @override
  String get notificationReasonWatchingCreated =>
      'Recibirás notificaciones porque creaste este tema.';

  @override
  String get notificationReasonTrackingCategory =>
      'Verás el número de respuestas nuevas porque estás siguiendo esta categoría.';

  @override
  String get notificationReasonTrackingReplied =>
      'Verás el número de respuestas nuevas porque has publicado una respuesta en este tema.';

  @override
  String get notificationReasonTracking =>
      'Verás el número de respuestas nuevas porque estás siguiendo este tema.';

  @override
  String get notificationReasonTrackingRead =>
      'Verás un contador con el número de nuevas respuestas porque has leído este tema.';

  @override
  String get notificationReasonNormal =>
      'Se te notificará si alguien menciona tu @nombre o te responde.';

  @override
  String get notificationReasonMutedCategory =>
      'Estás ignorando todas las notificaciones en esta categoría.';

  @override
  String get notificationReasonMuted =>
      'Estás ignorando todas las notificaciones en este tema.';

  @override
  String get notificationLevelWatching => 'Vigilar';

  @override
  String get notificationLevelWatchingFirstPost =>
      'Vigilar la primera publicación';

  @override
  String get notificationLevelTracking => 'Seguir';

  @override
  String get notificationLevelNormal => 'Normal';

  @override
  String get notificationLevelMuted => 'Silenciado';

  @override
  String get topicWatchingDescription =>
      'Se te notificará de cada publicación nueva en este tema y se mostrará el número de publicaciones nuevas.';

  @override
  String get topicTrackingDescription =>
      'Se mostrará el número de respuestas nuevas en este tema. Se te notificará si alguien menciona tu @nombre o te responde.';

  @override
  String get topicNormalDescription =>
      'Se te notificará si alguien menciona tu @nombre o te responde.';

  @override
  String get topicMutedDescription =>
      'No recibirás ninguna notificación de este tema y no aparecerá en temas recientes.';

  @override
  String get messageWatchingDescription =>
      'Se te notificará de cada publicación nueva en este mensaje y se mostrará el número de publicaciones nuevas.';

  @override
  String get messageTrackingDescription =>
      'Se mostrará el número de respuestas nuevas a este mensaje y se te notificará si alguien menciona tu @nombre o te responde.';

  @override
  String get messageNormalDescription =>
      'Se te notificará si alguien menciona tu @nombre o te responde.';

  @override
  String get messageMutedDescription =>
      'No recibirás ninguna notificación de este mensaje.';

  @override
  String get categoryWatchingDescription =>
      'Vigilarás automáticamente todos los temas en esta categoría. Se te notificará de cada nueva respuesta en cada tema, y verás un contador de nuevas respuestas.';

  @override
  String get categoryWatchingFirstPostDescription =>
      'Se te notificará acerca de los temas nuevos en esta categoría, pero no cuando haya respuestas nuevas a los temas.';

  @override
  String get categoryTrackingDescription =>
      'Seguirás todos los temas en esta categoría. Se te notificará si alguien menciona tu @nombre o te responde, y verás un contador con el número de nuevas respuestas de cada tema.';

  @override
  String get categoryNormalDescription =>
      'Se te notificará si alguien menciona tu @nombre o te responde.';

  @override
  String get categoryMutedDescription =>
      'No recibirás notificaciones sobre novedades de temas en esta categoría, y no aparecerán en la lista de temas recientes.';

  @override
  String get tagWatchingDescription =>
      'Vigilarás automáticamente todos los temas con esta etiqueta. Se te notificarán todos los temas y publicaciones nuevas. Además aparecerá un contador de publicaciones nuevas y sin leer al lado del tema.';

  @override
  String get tagWatchingFirstPostDescription =>
      'Se te notificará acerca de nuevos temas con esta etiqueta, pero no cuando haya respuestas al tema.';

  @override
  String get tagTrackingDescription =>
      'Seguirás automáticamente todos los temas con esta etiqueta. Aparecerá un contador de publicaciones nuevas y sin leer al lado del tema.';

  @override
  String get tagNormalDescription =>
      'Se te notificará si alguien menciona tu @nombre o responde a alguna de tus publicaciones.';

  @override
  String get tagMutedDescription =>
      'No se te notificará sobre temas nuevos con esta etiqueta, ni aparecerán en tu pestaña de no leídos.';

  @override
  String topicTimerAutoOpen(String timeLeft) {
    return 'Este tema se abrirá automáticamente $timeLeft.';
  }

  @override
  String topicTimerAutoClose(String timeLeft) {
    return 'Este tema se cerrará automáticamente $timeLeft.';
  }

  @override
  String topicTimerAutoPublish(String categoryName, String timeLeft) {
    return 'Este tema se publicará en #$categoryName $timeLeft.';
  }

  @override
  String topicTimerAutoCloseAfterLastPost(String duration) {
    return 'Este tema se cerrará $duration después de la última respuesta.';
  }

  @override
  String topicTimerAutoDeleteAfterLastPost(String duration) {
    return 'Este tema será eliminado tras $duration desde la última publicación.';
  }

  @override
  String topicTimerAutoDelete(String timeLeft) {
    return 'Este tema se eliminará automáticamente $timeLeft.';
  }

  @override
  String topicTimerAutoBump(String timeLeft) {
    return 'Este tema se reflotará automáticamente $timeLeft.';
  }

  @override
  String topicTimerAutoDeleteReplies(String duration) {
    return 'Las respuestas a este tema se eliminarán automáticamente después de $duration.';
  }

  @override
  String slowModeNotice(String duration) {
    return 'Por favor, espera $duration entre tus publicaciones en este tema.';
  }

  @override
  String get closeTopic => 'Cerrar tema';

  @override
  String get openTopic => 'Abrir tema';

  @override
  String get pinTopic => 'Anclar tema';

  @override
  String get unpinTopic => 'Desanclar tema';

  @override
  String get archiveTopic => 'Archivar tema';

  @override
  String get unarchiveTopic => 'Desarchivar tema';

  @override
  String get unlistTopic => 'Quitar de la lista';

  @override
  String get listTopic => 'Devolver a la lista';

  @override
  String get permanentlyDelete => 'Eliminar permanentemente';

  @override
  String get permanentlyDeleteTopicConfirmation =>
      'Esta acción no se puede deshacer. El tema se eliminará de forma permanente de la base de datos.';

  @override
  String get deleteTopicConfirmYes => 'Sí, eliminar este tema';

  @override
  String get deleteTopicConfirmNo => 'No, conservar este tema';

  @override
  String get topicPinned => 'Tema anclado';

  @override
  String get topicUnpinned => 'Tema desanclado';

  @override
  String get topicArchived => 'Tema archivado';

  @override
  String get topicUnarchived => 'Tema desarchivado';

  @override
  String get topicUnlisted => 'Tema quitado de la lista';

  @override
  String get topicListed => 'Tema devuelto a la lista';

  @override
  String get topicRecovered => 'Tema recuperado';

  @override
  String topicActionFailed(String error) {
    return 'No se pudo actualizar el tema: $error';
  }

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horas',
      one: '1 hora',
    );
    return '$_temp0';
  }

  @override
  String durationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String timeLeftMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'en $count minutos',
      one: 'en 1 minuto',
    );
    return '$_temp0';
  }

  @override
  String timeLeftHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'en $count horas',
      one: 'en 1 hora',
    );
    return '$_temp0';
  }

  @override
  String timeLeftDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'en $count días',
      one: 'en 1 día',
    );
    return '$_temp0';
  }

  @override
  String get topicStatusDeletedHelp =>
      'Este tema está eliminado y oculto para otros usuarios';

  @override
  String get flagAction => 'Denunciar';

  @override
  String get flagPost => 'Denunciar publicación';

  @override
  String get signUp => 'Registrarse';

  @override
  String get suspendUser => 'Suspender usuario';

  @override
  String get unsuspend => 'Desbloquear';

  @override
  String get suspendUntil => 'Suspender al usuario hasta';

  @override
  String get suspendForever => 'Suspender para siempre';

  @override
  String failedToSuspendUser(String error) {
    return 'Algo salió mal al suspender a este usuario: $error';
  }

  @override
  String failedToUnsuspendUser(String error) {
    return 'Algo salió mal al desbloquear a este usuario: $error';
  }

  @override
  String get suspendReasonNotListening =>
      'No escucha indicaciones del personal';

  @override
  String get suspendReasonStaffTime =>
      'Hace perder el tiempo desproporcionadamente al personal';

  @override
  String get suspendReasonCombative => 'Demasiado combatiente';

  @override
  String get suspendReasonWrongPlace => 'No está en el sitio adecuado';

  @override
  String get suspendReasonNoPurpose =>
      'No hay otro propósito constructivo para sus acciones que crear conflictos dentro de la comunidad';

  @override
  String get suspendReasonCustom => 'Personalizado…';

  @override
  String get suspendReasonQuestion =>
      '¿Por qué se le suspende? Este texto se mostrará al usuario cuando trate de iniciar sesión. Sé conciso.';

  @override
  String get closedLabel => 'Cerrado';

  @override
  String get flaggingPost => 'Denunciando la publicación…';

  @override
  String get pleaseSelectSuspensionEndDate =>
      'Elige cuándo termina la suspensión';

  @override
  String get suspendingUser => 'Suspendiendo al usuario…';

  @override
  String get unsuspendingUser => 'Desbloqueando al usuario…';

  @override
  String get userSuspended => 'Usuario suspendido';

  @override
  String get userUnsuspended => 'Usuario desbloqueado';

  @override
  String unsuspendUserConfirmation(String username) {
    return '¿Desbloquear a $username? Podrá volver a iniciar sesión.';
  }

  @override
  String get noCategoriesToDisplay => 'No hay categorías para mostrar.';

  @override
  String get noPermissionToViewCategory =>
      'No tienes permiso para ver los temas de esta categoría.';

  @override
  String get featureTopicTitle => 'Características de este tema';

  @override
  String get pinTopicMenu => 'Anclar tema...';

  @override
  String pinInCategoryUntil(String category) {
    return 'Hacer que este tema aparezca de primero en la categoría $category hasta';
  }

  @override
  String get pinGloballyUntil =>
      'Hacer que este tema aparezca de primero en todas las listas de temas hasta';

  @override
  String get pinNote =>
      'Los usuarios pueden desanclar el tema de forma individual por sí mismos.';

  @override
  String get pinUntil => 'Anclar hasta';

  @override
  String get pinDateRequired =>
      'Es obligatorio especificar una fecha para anclar este tema.';

  @override
  String get pinTopicGlobally => 'Anclar tema globalmente';

  @override
  String get flagThanks =>
      '¡Gracias por ayudar a mantener una comunidad civilizada!';

  @override
  String get flagReviewProcess =>
      'Los moderadores reciben todas las denuncias y las revisan con la mayor brevedad posible.';

  @override
  String get flagCant =>
      'Lo sentimos, no puedes denunciar esta publicación en este momento.';

  @override
  String get flagSendMessage => 'Mensaje';

  @override
  String get flagMessageForUser => 'Mensaje para el usuario';

  @override
  String get flagMessageForModerators => 'Mensaje para los moderadores';

  @override
  String get flagPlaceholderNotifyUser =>
      'Sé específico, constructivo y siempre amable.';

  @override
  String get flagPlaceholderNotifyModerators =>
      'Haznos saber qué te preocupa específicamente y, siempre que sea posible, incluye enlaces y ejemplos relevantes.';

  @override
  String get flagPlaceholderIllegal =>
      'Indícanos exactamente por qué consideras este contenido ilegal, y proporciona enlaces y ejemplos relevantes cuando sea posible.';

  @override
  String get flagConfirmIllegal =>
      'Lo que he escrito más arriba es preciso y completo.';

  @override
  String flagMessageAtLeast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ingresa al menos $count caracteres',
      one: 'introduce al menos $count caracteres',
    );
    return '$_temp0';
  }

  @override
  String get flagMessageSent => 'Tu mensaje ha sido enviado.';

  @override
  String get mergeTopicError =>
      'Se produjo un error al mover las publicaciones a ese tema.';

  @override
  String get topicTitlePlaceholder =>
      'En una frase breve, ¿de qué trata este tema?';

  @override
  String get topicMoved => 'Tema movido';

  @override
  String get topicMerged => 'Tema fusionado';

  @override
  String get mergeTopicExplanation =>
      'Todas las publicaciones de este tema se moverán al tema que elijas. No se puede deshacer en la aplicación.';

  @override
  String get destinationTopicId => 'ID del tema de destino';

  @override
  String get topicAuthorUnknown => 'Desconocido';

  @override
  String get noHotTopics => 'No hay temas candentes.';

  @override
  String get signInToViewNewTopics => 'Inicia sesión para ver temas nuevos';

  @override
  String get newTopicsSignInMessage =>
      'Los temas nuevos muestran lo que se ha creado desde tu última visita.';

  @override
  String get topPeriodAllTime => 'Siempre';

  @override
  String get topPeriodYear => 'Año';

  @override
  String get topPeriodQuarter => 'Trimestre';

  @override
  String get topPeriodMonth => 'Mes';

  @override
  String get topPeriodWeek => 'Semana';

  @override
  String get topPeriodToday => 'Hoy';

  @override
  String noTopTopicsForPeriod(String period) {
    String _temp0 = intl.Intl.selectLogic(
      period,
      {
        'all': 'No hay temas destacados de todos los tiempos.',
        'yearly': 'No hay temas destacados este año.',
        'quarterly': 'No hay temas destacados este trimestre.',
        'monthly': 'No hay temas destacados este mes.',
        'weekly': 'No hay temas destacados esta semana.',
        'daily': 'No hay temas destacados hoy.',
        'other': 'No hay temas destacados.',
      },
    );
    return '$_temp0';
  }

  @override
  String get connectionTimedOutSiteUnreachable =>
      'Se agotó el tiempo de conexión. El sitio puede estar caído o inaccesible.';

  @override
  String get failedToMarkNotificationsRead =>
      'No se pudieron marcar las notificaciones como leídas';

  @override
  String get forumNameFallback => 'Foro';

  @override
  String get noForumDescription => 'No hay descripción disponible.';

  @override
  String get dismissAllNotifications => 'Descartar todo';

  @override
  String get notificationPostIdMissing =>
      'Falta el ID de la publicación. No se puede ir a la publicación.';

  @override
  String get notificationTopicIdMissingForPost =>
      'Falta el ID del tema. No se puede ir a la publicación.';

  @override
  String get notificationTopicIdMissing =>
      'Falta el ID del tema. No se puede abrir el tema.';

  @override
  String get notificationUsernameMissing =>
      'Falta el nombre de usuario. No se puede abrir el perfil.';

  @override
  String get notificationChannelIdMissing =>
      'Falta el ID del canal. No se puede abrir el chat.';

  @override
  String get notificationGroupNameMissingForInbox =>
      'Falta el nombre del grupo. No se puede abrir la bandeja de entrada.';

  @override
  String get notificationGroupNameMissing =>
      'Falta el nombre del grupo. No se puede abrir el grupo.';

  @override
  String get notificationNoActionUrl =>
      'No hay ninguna URL de acción para este tipo de notificación.';

  @override
  String get notificationBadgeUnavailable =>
      'Los detalles de la medalla no están disponibles.';

  @override
  String get notificationBadgeLoadFailed => 'No se pudo cargar esta medalla.';

  @override
  String get personalMessageTitleFallback => 'Mensaje personal';

  @override
  String get topicTitleFallback => 'Tema';

  @override
  String get signInToViewNotifications =>
      'Inicia sesión para ver las notificaciones';

  @override
  String get youNeedToBeSignedInToViewNotifications =>
      'Debes iniciar sesión para ver tus notificaciones.';

  @override
  String get noUnreadNotifications => 'No hay notificaciones sin leer';

  @override
  String get noNotificationsYet => 'Aún no hay notificaciones';

  @override
  String get newNotificationFallbackBody => 'Nueva notificación';

  @override
  String get unableToOpenNotification => 'No se puede abrir la notificación';

  @override
  String get notificationMissingSiteInfo =>
      'Falta la información del sitio (site_id).';

  @override
  String get notificationInvalidSiteInfo =>
      'Información del sitio no válida (site_id).';

  @override
  String get notificationMissingPostInfo =>
      'Falta la información de la publicación (content_id).';

  @override
  String get notificationMissingMessageInfo =>
      'Falta la información del mensaje (conversation_id).';

  @override
  String get notificationMissingUserInfo =>
      'Falta la información del usuario (sender_id).';

  @override
  String get notificationUnsupportedType =>
      'Tipo de notificación no compatible.';

  @override
  String get notificationForumNotFound =>
      'No se encontró el foro de este sitio.';

  @override
  String get notificationForumOpenFailed => 'No se pudo inicializar el foro.';

  @override
  String get notificationMissingTopicInfo =>
      'Falta la información del tema (topic_id).';

  @override
  String get failedToLoadTags => 'No se pudieron cargar las etiquetas.';

  @override
  String get searchTagsHint => 'Buscar etiquetas…';

  @override
  String get tagsSortedByCountTooltip =>
      'Ordenadas por número de temas: toca para cambiar a A→Z';

  @override
  String get tagsSortedAlphabeticallyTooltip =>
      'Ordenadas alfabéticamente: toca para cambiar a popularidad';

  @override
  String get noTagsYet => 'Aún no hay etiquetas en este foro.';

  @override
  String get tagNotificationLevelTooltip => 'Nivel de notificación';

  @override
  String get tagTopicsLoadFailed => 'No se pudo cargar';

  @override
  String searchFailedWithError(String error) {
    return 'Búsqueda fallida: $error';
  }

  @override
  String get searchFiltersButtonTooltip => 'Filtros';

  @override
  String get searchFilterStatusSection => 'Estado';

  @override
  String get searchFilterMyActivitySection => 'Mi actividad';

  @override
  String get searchFilterMatchTypeSection => 'Tipo de coincidencia';

  @override
  String get searchTagsFilterHelper =>
      'Separadas por espacios o comas. Cada etiqueta es obligatoria.';

  @override
  String get searchSortBy => 'Ordenar por';

  @override
  String get searchStatusOpen => 'Abierto';

  @override
  String get searchStatusArchived => 'Archivado';

  @override
  String get searchStatusNoReplies => 'Sin respuestas';

  @override
  String get searchStatusPublicOnly => 'Solo públicos';

  @override
  String get searchStatusUnsolved => 'Sin solución';

  @override
  String get searchInBookmarked => 'En mis marcadores';

  @override
  String get searchInMyMessages => 'En mis mensajes';

  @override
  String get searchInLiked => 'Me gustaron';

  @override
  String get searchInPosted => 'He publicado en ellos';

  @override
  String get searchInWatching => 'Estoy vigilando';

  @override
  String get searchInTracking => 'Estoy siguiendo';

  @override
  String get searchInSeen => 'He leído';

  @override
  String get searchInUnseen => 'No he leído';

  @override
  String get searchSortLatestPost => 'Publicación más reciente';

  @override
  String get searchSortMostLiked => 'Más me gusta recibidos';

  @override
  String get searchSortMostViewed => 'Más visto';

  @override
  String get searchSortLatestTopic => 'Tema más reciente';

  @override
  String get searchFieldHint => 'Buscar…';

  @override
  String get bookmarksUnavailable => 'Los marcadores no están disponibles';

  @override
  String get failedToLoadBookmarks => 'No se pudieron cargar los marcadores';

  @override
  String get failedToRemoveBookmark => 'No se pudo quitar el marcador';

  @override
  String get failedToUpdateBookmark => 'No se pudo actualizar el marcador';

  @override
  String get bookmarkWithReminder => 'Marcador con recordatorio';

  @override
  String get noReminder => 'Sin recordatorio';

  @override
  String get failedToLoadDrafts => 'No se pudieron cargar los borradores.';

  @override
  String get failedToDiscardDraft => 'No se pudo descartar el borrador';

  @override
  String draftNotDiscardedAway(String error) {
    return 'No se descartó el borrador. Sigue en Borradores. $error';
  }

  @override
  String get messagesLoadFailed => 'No se pudieron cargar los mensajes';

  @override
  String get moreMessagesLoadFailed => 'No se pudieron cargar más mensajes';

  @override
  String get messageUnknownUser => 'Desconocido';

  @override
  String get unknownErrorFallback => 'Error desconocido';

  @override
  String get chatComposerDefaultHint => 'Escribe un mensaje…';

  @override
  String chatChannelNumbered(Object id) {
    return 'canal $id';
  }

  @override
  String get chatSendFailed => 'No se pudo enviar el mensaje.';

  @override
  String get chatEditFailed => 'No se pudo editar el mensaje.';

  @override
  String get chatDeleteFailed => 'No se pudo eliminar el mensaje.';

  @override
  String get chatReactionsUnsupported =>
      'Las reacciones no están disponibles aquí.';

  @override
  String get chatReactionFailed => 'No se pudo actualizar la reacción.';

  @override
  String get attachmentDefaultName => 'Archivo adjunto';

  @override
  String get fileTypeAudio => 'Audio';

  @override
  String get fileTypeText => 'Texto';

  @override
  String get fileTypeArchive => 'Archivo comprimido';

  @override
  String get fileTypeFile => 'Archivo';

  @override
  String downloadFailedHttpStatus(String status) {
    return 'No se pudo descargar el archivo: HTTP $status';
  }

  @override
  String get downloadedFileEmpty => 'El archivo descargado está vacío';

  @override
  String downloadFileFailed(String error) {
    return 'No se pudo descargar el archivo: $error';
  }

  @override
  String attachmentTypeNotAllowed(String extension, String allowed) {
    return 'El tipo de archivo .$extension no está permitido. Tipos permitidos: $allowed';
  }

  @override
  String attachmentFileTooLarge(String size, String max) {
    return 'El tamaño del archivo ($size) supera el máximo de $max';
  }

  @override
  String get attachmentValidationFailed => 'La validación del archivo falló';

  @override
  String get uploadMissingReference =>
      'La subida se completó, pero el servidor no devolvió ninguna referencia al archivo.';

  @override
  String get imageFileNotFound => 'No se encontró el archivo de imagen';

  @override
  String get failedToLoadVideo => 'No se pudo cargar el video';

  @override
  String get userInfoLoadFailed =>
      'No se pudo cargar la información del usuario.';

  @override
  String userInfoLoadFailedWithError(String error) {
    return 'No se pudo cargar la información del usuario: $error';
  }

  @override
  String get profileMenuIgnoreUser => 'Ignorar usuario';

  @override
  String get profileMenuUnignoreUser => 'Dejar de ignorar al usuario';

  @override
  String get ignoreStateUpdateFailed =>
      'No se pudo cambiar el estado de ignorado';

  @override
  String profileNowIgnoringUser(String username) {
    return 'Estás ignorando a @$username. Sus publicaciones se ocultarán.';
  }

  @override
  String get profileIgnoreToggleFailed =>
      'No se pudo cambiar la opción de ignorar.';

  @override
  String get profileStatsLoadFailed =>
      'No se pudieron cargar las estadísticas.';

  @override
  String get profileFollowFailed => 'No se pudo seguir';

  @override
  String get profileUnfollowFailed => 'No se pudo dejar de seguir';

  @override
  String get profileChatOpenFailed =>
      'No se pudo abrir un chat con este usuario.';

  @override
  String summaryLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count me gusta',
      one: '1 me gusta',
    );
    return '$_temp0';
  }

  @override
  String summaryLinkClicks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clics',
      one: '1 clic',
    );
    return '$_temp0';
  }

  @override
  String get directoryPeriodAllTime => 'Siempre';

  @override
  String get directoryPeriodYear => 'Año';

  @override
  String get directoryPeriodQuarter => 'Trimestre';

  @override
  String get directoryPeriodMonth => 'Mes';

  @override
  String get directoryPeriodWeek => 'Semana';

  @override
  String get directoryPeriodToday => 'Hoy';

  @override
  String get directoryOrderReceived => 'Recibidos';

  @override
  String get directoryOrderReplies => 'Respuestas';

  @override
  String get directoryOrderTopics => 'Temas';

  @override
  String get directoryOrderVisits => 'Visitas';

  @override
  String get directoryLoadFailed => 'No se pudo cargar el directorio.';

  @override
  String get directoryNoUsersMatch => 'Ningún usuario coincide con ese nombre.';

  @override
  String get directoryNoUsersForPeriod =>
      'No se encontraron usuarios en este período.';

  @override
  String get userSearchNoResults => 'No se encontraron usuarios';

  @override
  String get userSearchTryDifferentUsername =>
      'Prueba a buscar con otro nombre de usuario';

  @override
  String get userSearchPromptTitle => 'Buscar usuarios';

  @override
  String get userSearchPromptHint =>
      'Introduce un nombre de usuario para encontrar e invitar usuarios';

  @override
  String get ignoredUsersUnignoreFailed => 'No se pudo dejar de ignorar.';

  @override
  String get ignoredUsersEmpty => 'No estás ignorando a nadie.';

  @override
  String get ignoredUsersEmptyHint =>
      'Abre un perfil de usuario y usa «Ignorar usuario» en el menú para ocultar sus publicaciones y notificaciones.';

  @override
  String get badgesLoadFailed => 'No se pudieron cargar las medallas.';

  @override
  String get badgesEmpty => 'No hay medallas en este foro.';

  @override
  String get badgeTierGold => 'Oro';

  @override
  String get badgeTierSilver => 'Plata';

  @override
  String get badgeTierBronze => 'Bronce';

  @override
  String badgeEarnedAgo(String time) {
    return 'Obtenida $time';
  }

  @override
  String badgeEarnedByUsers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Obtenida por $formatted usuarios',
      one: 'Obtenida por $formatted usuario',
    );
    return '$_temp0';
  }

  @override
  String get trustLevelNameNewUser => 'Usuario nuevo';

  @override
  String get trustLevelNameBasic => 'Usuario básico';

  @override
  String get trustLevelNameMember => 'Miembro';

  @override
  String get trustLevelNameRegular => 'Habitual';

  @override
  String get trustLevelNameLeader => 'Líder';

  @override
  String get trustLevelSummary0 =>
      'Recién llegado. Puede leer y publicar, con límites en enlaces, imágenes y mensajes.';

  @override
  String get trustLevelSummary1 =>
      'Desbloquea las funciones básicas de publicación: imágenes y adjuntos, más enlaces y denunciar publicaciones.';

  @override
  String get trustLevelSummary2 =>
      'Puede enviar invitaciones, ignorar usuarios y editar sus propias publicaciones durante más tiempo.';

  @override
  String get trustLevelSummary3 =>
      'Puede cambiar la categoría y el título de los temas, crear etiquetas, y sus denuncias de spam tienen más peso.';

  @override
  String get trustLevelSummary4 =>
      'Otorgado por el equipo. Puede editar cualquier publicación y fijar, cerrar, dividir o combinar temas.';

  @override
  String trustLevelRowTitle(int level, String name) {
    return 'NC$level · $name';
  }

  @override
  String get profileNoUserSpecified => 'No se especificó ningún usuario';

  @override
  String get userTopicsLoadFailed => 'No se pudieron cargar los temas';

  @override
  String get userTopicsEmpty => 'Aún no ha creado temas.';

  @override
  String get userRecentPostsLoadFailed =>
      'No se pudieron cargar las publicaciones recientes';

  @override
  String get activityUnknownTopic => 'Tema desconocido';

  @override
  String groupJoinedSnack(String group) {
    return 'Te uniste a $group';
  }

  @override
  String get groupJoinFailed => 'No se pudo unir al grupo';

  @override
  String groupLeftSnack(String group) {
    return 'Saliste de $group';
  }

  @override
  String get groupLeaveFailed => 'No se pudo salir del grupo';

  @override
  String get groupMembershipRequestHint =>
      '¿Por qué quieres unirte? Los propietarios del grupo verán esto con tu solicitud.';

  @override
  String get groupMembershipReasonRequired =>
      'Se necesita un motivo para solicitar unirse';

  @override
  String get groupMembershipRequestSent =>
      'Solicitud enviada: un propietario del grupo debe aprobarla';

  @override
  String get groupMembershipRequestFailed =>
      'No se pudo enviar la solicitud de membresía';

  @override
  String get groupMemberBadge => 'Miembro';

  @override
  String get groupRequestPending => 'Solicitud pendiente';

  @override
  String get groupJoining => 'Uniéndote…';

  @override
  String get groupJoinButton => 'Unirse al grupo';

  @override
  String get groupsLoadFailed => 'No se pudieron cargar los grupos.';

  @override
  String get groupBuiltIn => 'Grupo integrado';

  @override
  String invitesPendingWithCount(int count) {
    return 'Pendientes ($count)';
  }

  @override
  String invitesExpiredWithCount(int count) {
    return 'Caducado ($count)';
  }

  @override
  String invitesRedeemedWithCount(int count) {
    return 'Canjeados ($count)';
  }

  @override
  String get invitesLoadFailed => 'No se pudieron cargar las invitaciones.';

  @override
  String get inviteLinkCreateFailed =>
      'No se pudo crear el enlace de invitación';

  @override
  String get inviteEmailAddressLabel => 'Correo electrónico';

  @override
  String get inviteEmailInvalid => 'Introduce un correo electrónico válido';

  @override
  String get inviteMessageOptionalLabel => 'Mensaje (opcional)';

  @override
  String get inviteSendFailed => 'No se pudo enviar la invitación';

  @override
  String get revokeInviteLinkWarning =>
      'El enlace de invitación dejará de funcionar.';

  @override
  String revokeInviteEmailWarning(String email) {
    return 'La invitación a $email dejará de funcionar.';
  }

  @override
  String get inviteRevokeFailed => 'No se pudo revocar la invitación';

  @override
  String get inviteNoPermission => 'No tienes permiso para invitar';

  @override
  String get invitesEmptyPending => 'No hay invitaciones pendientes';

  @override
  String get invitesEmptyExpired => 'No hay invitaciones caducadas';

  @override
  String get invitesEmptyRedeemed => 'No hay invitaciones canjeadas';

  @override
  String get invitesEmptyPendingHint =>
      'Crea un enlace de invitación para traer gente al foro.';

  @override
  String get inviteLinkFallbackTitle => 'Enlace de invitación';

  @override
  String inviteRedeemedOn(String date) {
    return 'Aceptada el $date';
  }

  @override
  String inviteRedemptions(int count, int max) {
    return 'Canjeadas $count de $max';
  }

  @override
  String get inviteEmailSent => 'Correo enviado';

  @override
  String get inviteEmailNotSent => 'Correo no enviado';

  @override
  String inviteExpiredOn(String date) {
    return 'Caducó el $date';
  }

  @override
  String get inviteRevokeTooltip => 'Revocar invitación';

  @override
  String get reviewStatusPending => 'Pendiente';

  @override
  String get reviewStatusApproved => 'Aprobado';

  @override
  String get reviewStatusRejected => 'Rechazado';

  @override
  String get reviewStatusAll => 'Todo';

  @override
  String get reviewStatusIgnored => 'Denuncia ignorada';

  @override
  String get reviewStatusDeleted => 'Tema o publicación eliminada';

  @override
  String get reviewQueueUnavailable =>
      'La cola de revisión no está disponible en este foro.';

  @override
  String get reviewQueueLoadFailed => 'No se pudo cargar la cola de revisión';

  @override
  String get reviewableChangedByOther =>
      'Otro moderador cambió este elemento. Actualizando…';

  @override
  String get reviewActionFailed => 'No se pudo realizar la acción';

  @override
  String reviewActionDone(String action) {
    return '$action: hecho';
  }

  @override
  String get reviewRejectReasonHint => '¿Por qué se rechaza?';

  @override
  String get reviewTypeFlaggedPost => 'Publicación denunciada';

  @override
  String get reviewTypeQueuedPost => 'Publicación en cola';

  @override
  String get reviewTypeQueuedTopic => 'Tema en cola';

  @override
  String get reviewTypeUser => 'Usuario';

  @override
  String get reviewTypePost => 'Publicación';

  @override
  String get reviewTypeChatMessage => 'Mensaje de chat denunciado';

  @override
  String get reviewModeratorAccessRequired => 'Se requiere acceso de moderador';

  @override
  String reviewableScore(String score) {
    return 'Puntuación $score';
  }

  @override
  String get postRepliesLoadFailed => 'No se pudieron cargar las respuestas.';

  @override
  String get postMakeWiki => 'Transformar en formato wiki';

  @override
  String get postRemoveWiki => 'Deshacer formato wiki';

  @override
  String get postBookmarkRemoveFailed => 'No se pudo quitar el marcador';

  @override
  String get postBookmarkFailed =>
      'No se pudo guardar la publicación en marcadores';

  @override
  String get postBookmarkReminderUpdateFailed =>
      'No se pudo actualizar el recordatorio';

  @override
  String get postBookmarkReminderSet => 'Recordatorio establecido';

  @override
  String get postBookmarkReminderCleared => 'Recordatorio borrado';

  @override
  String get solutionMarkFailed =>
      'No se pudo marcar la respuesta como solución';

  @override
  String get solutionUnmarkFailed => 'No se pudo desmarcar la solución';

  @override
  String get postUnknownDate => 'Fecha desconocida';

  @override
  String get postBookmarkAction => 'Guardar publicación en marcadores';

  @override
  String get reactionButtonRemoveLike =>
      'Te gusta. Toca para quitar tu me gusta.';

  @override
  String reactionButtonRemove(String reaction) {
    return 'Tu reacción: $reaction. Toca para quitarla.';
  }

  @override
  String reactionButtonLocked(String reaction) {
    return 'Tu reacción: $reaction. Ya no se puede cambiar.';
  }

  @override
  String get reactionHoldHint => 'Mantén pulsado para ver más reacciones';

  @override
  String reactionSummarySemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reacciones. Toca para ver quién reaccionó.',
      one: '1 reacción. Toca para ver quién reaccionó.',
    );
    return '$_temp0';
  }

  @override
  String get reactionLockedMessage =>
      'Ya no puedes cambiar tu reacción a esta publicación.';

  @override
  String get reactionHoldTip =>
      'Consejo: mantén pulsado el corazón para ver más reacciones.';

  @override
  String reactionsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reacciones',
      one: '1 reacción',
    );
    return '$_temp0';
  }

  @override
  String get reactionsAll => 'Todas';

  @override
  String get reactionYou => 'Tú';

  @override
  String get changeYourReaction => 'Cambiar tu reacción';

  @override
  String get reactionTapAgainToRemove =>
      'Toca tu reacción otra vez para quitarla.';

  @override
  String reactionFilterSemantics(String reaction, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$reaction, $count personas',
      one: '$reaction, 1 persona',
    );
    return '$_temp0';
  }

  @override
  String get postLikeAction => 'Me gusta la publicación';

  @override
  String get postUnlikeAction => 'Deshacer me gusta';

  @override
  String get postVoteRemoveFailed =>
      'No se pudo quitar el voto (¿se agotó el tiempo para deshacerlo?)';

  @override
  String get postVoteCastFailed => 'No se pudo votar';

  @override
  String get postUpvote => 'Votar a favor';

  @override
  String get postDownvote => 'Votar en contra';

  @override
  String get pollVoteFailed => 'No se pudo votar. Inténtalo de nuevo.';

  @override
  String get pollRemoveVoteFailed =>
      'No se pudo quitar tu voto. Inténtalo de nuevo.';

  @override
  String get pollVotersLoadFailed => 'No se pudieron cargar los votantes.';

  @override
  String get pollVotersNotVisible =>
      'Los votantes de esta encuesta no son visibles.';

  @override
  String get pollRankedChoiceHint =>
      'Toca las opciones en orden de preferencia. Las opciones sin puesto cuentan como abstención.';

  @override
  String get pollRankAbstain => 'Abstención';

  @override
  String pollRank(int rank) {
    return 'Puesto $rank';
  }

  @override
  String get pollRankedChoiceWinner => 'Ganador';

  @override
  String get pollRankedChoiceTied => 'Empate';

  @override
  String solutionSolvedByInPost(String name, int postNumber) {
    return 'Resuelto por $name en la publicación #$postNumber';
  }

  @override
  String solutionMarkedBy(String name) {
    return 'marcado por $name';
  }

  @override
  String reactAgainInSeconds(int seconds) {
    return 'Puedes volver a reaccionar a esta publicación en ${seconds}s';
  }

  @override
  String get reactionUpdateFailed => 'No se pudo actualizar la reacción.';

  @override
  String get reactionsNotSupported => 'Este foro no admite reacciones.';

  @override
  String get reactionsLoadFailed => 'No se pudieron cargar las reacciones.';

  @override
  String viewProfileOfUser(String username) {
    return 'Ver el perfil de $username';
  }

  @override
  String get failedToSavePost => 'No se pudo guardar la publicación';

  @override
  String failedToSavePostWithError(String error) {
    return 'No se pudo guardar la publicación: $error';
  }

  @override
  String get failedToRemoveAttachmentCheckPermissions =>
      'No se pudo quitar el adjunto. Comprueba tus permisos.';

  @override
  String get editPostTitle => 'Editar publicación';

  @override
  String get editYourPostHint => 'Edita tu publicación...';

  @override
  String get failedToPostReply => 'No se pudo publicar la respuesta';

  @override
  String failedToPostReplyWithError(String error) {
    return 'No se pudo publicar la respuesta: $error';
  }

  @override
  String get failedToCreateTopic => 'No se pudo crear el tema';

  @override
  String get writeYourTopicTitle => 'Escribe el título de tu tema...';

  @override
  String get writeYourTopicContent => 'Escribe el contenido de tu tema...';

  @override
  String get composerTitleHint => 'Escribe tu título...';

  @override
  String get composerContentHint => 'Escribe tu contenido...';

  @override
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit) {
    return '$fileName: demasiado grande ($size) y no se pudo reducir. El límite es $limit.';
  }

  @override
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit) {
    return '$fileName se redujo a $size$dimensions para ajustarse al límite de $limit.';
  }

  @override
  String get composerAttachFileHint => 'Adjuntar un archivo a esta publicación';

  @override
  String get composerUploadImageHint => 'Subir una imagen a esta publicación';

  @override
  String get composerFormattingHint => 'Abrir opciones de formato';

  @override
  String get whisperStaffOnly => 'Susurrar (solo personal)';

  @override
  String get whisperOnStaffOnly => 'Susurro activado (solo personal)';

  @override
  String get tagInputMaxReached => 'Se alcanzó el máximo de etiquetas';

  @override
  String get tagInputAddTag => 'Añadir una etiqueta…';

  @override
  String get tagInputAddAnother => '+ etiqueta';

  @override
  String get editHistoryUnavailable =>
      'El historial de ediciones no está disponible en este foro.';

  @override
  String get editHistoryLoadFailed =>
      'No se pudo cargar el historial de ediciones.';

  @override
  String get previousRevision => 'Edición anterior';

  @override
  String get nextRevision => 'Siguiente edición';

  @override
  String get notificationPrefsLoadFailed =>
      'No se pudieron cargar las preferencias de notificaciones.';

  @override
  String get notificationPrefsSaveFailed =>
      'No se pudo guardar: comprueba tu conexión';

  @override
  String get signInToManageNotificationPrefs =>
      'Inicia sesión para gestionar tus preferencias de notificaciones.';

  @override
  String get emailWhenAwayTitle => 'Correo cuando no estés';

  @override
  String get emailLevelDescription =>
      'Enviadme un correo cuando alguien me cite, responda, mencione mi @nombre de usuario o cuando haya nueva actividad en las categorías, etiquetas o temas que vigile';

  @override
  String get notificationPrefAlways => 'Siempre';

  @override
  String get notificationPrefOnlyWhenAway => 'Solo cuando no esté en la página';

  @override
  String get notificationPrefNever => 'Nunca';

  @override
  String get emailForMessagesTitle => 'Correo por mensajes';

  @override
  String get emailMessagesLevelDescription =>
      'Enviadme un correo cuando me manden un mensaje personal';

  @override
  String get activitySummaryTitle => 'Resumen de actividad';

  @override
  String get activitySummaryDescription =>
      'Cuando no visite el sitio, enviarme un correo electrónico con un resumen de los temas y respuestas populares';

  @override
  String get activitySummaryFrequencyTitle =>
      'Frecuencia del resumen de actividad';

  @override
  String get activitySummaryDaily => 'Diariamente';

  @override
  String get activitySummaryWeekly => 'Semanalmente';

  @override
  String get activitySummaryMonthly => 'Cada mes';

  @override
  String get mailingListModeTitle => 'Modo lista de correo';

  @override
  String get mailingListModeDescription =>
      'Enviarme por correo cada publicación (desactiva el resumen de actividad). No recomendado en foros con mucho tráfico.';

  @override
  String get likeNotificationFrequencyTitle =>
      'Notificar cuando me dan me gusta';

  @override
  String get likeNotificationFirstTimeAndDaily =>
      'Cuando mi publicación reciba el primer me gusta y luego diariamente si recibe más';

  @override
  String get likeNotificationFirstTime =>
      'Cuando mi publicación reciba el primer me gusta';

  @override
  String get whenPostingTitle => 'Al publicar';

  @override
  String get whenPostingDescription => 'Qué pasa con un tema al que respondes';

  @override
  String get whenPostingWatchTopic => 'Ver tema';

  @override
  String get whenPostingTrackTopic => 'Seguir tema';

  @override
  String get whenPostingDoNothing => 'No hacer nada';

  @override
  String get pauseNotificationsUntilTomorrow => 'Hasta mañana';

  @override
  String get couldNotEnableDoNotDisturb => 'No se pudo activar No molestar';

  @override
  String get doNotDisturbNotEnabledSessionChanged =>
      'No molestar no se activó: tu sesión ha cambiado.';

  @override
  String get couldNotTurnOffDoNotDisturb => 'No se pudo desactivar No molestar';

  @override
  String get passwordResetEmailSent =>
      'Correo para restablecer la contraseña enviado.';

  @override
  String get couldNotSendResetEmail =>
      'No se pudo enviar el correo de restablecimiento';

  @override
  String get accountRequestFailed => 'La solicitud falló.';

  @override
  String get forumUrlUnavailable => 'La URL del foro no está disponible.';

  @override
  String get couldNotOpenPreferencesPage =>
      'No se pudo abrir la página de preferencias.';

  @override
  String get couldNotOpenForumUrl => 'No se pudo abrir la URL del foro.';

  @override
  String get couldNotRequestEmailChange =>
      'No se pudo solicitar el cambio de correo';

  @override
  String get newEmailLabel => 'Correo electrónico nuevo';

  @override
  String get enterAnEmailAddress =>
      'Introduce una dirección de correo electrónico';

  @override
  String get emailLooksInvalid => 'Eso no parece un correo electrónico';

  @override
  String get emailNoSpaces => 'Los correos no pueden contener espacios';

  @override
  String get allowNotificationsSheetTitle => 'Permitir notificaciones';

  @override
  String get notificationsGrantNoPayload =>
      'La autorización no devolvió ninguna respuesta.';

  @override
  String get thisForumFallback => 'este foro';

  @override
  String signInToDomain(String domain) {
    return 'Iniciar sesión en $domain';
  }

  @override
  String get loginResultTitle => 'Resultado del inicio de sesión';

  @override
  String get invalidAuthenticationCode => 'Código de autenticación no válido';

  @override
  String get tfaVerificationError =>
      'Se produjo un error durante la verificación. Inténtalo de nuevo.';

  @override
  String get passwordFieldLabel => 'Contraseña';

  @override
  String get somethingWentWrongTryAgain =>
      'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get unexpectedErrorTryAgain =>
      'Se produjo un error inesperado. Inténtalo de nuevo.';

  @override
  String get errorNoInternetConnection =>
      'Sin conexión a internet. Comprueba la configuración de red.';

  @override
  String get errorRequestTimedOut =>
      'La solicitud tardó demasiado. Inténtalo de nuevo.';

  @override
  String get errorServerTryLater =>
      'Se produjo un error del servidor. Inténtalo de nuevo más tarde.';

  @override
  String get errorInvalidCredentials =>
      'Nombre de usuario o contraseña no válidos.';

  @override
  String get errorSessionExpired =>
      'Tu sesión ha caducado. Vuelve a iniciar sesión.';

  @override
  String get errorAccountSuspended =>
      'Tu cuenta ha sido suspendida. Contacta con el equipo del foro.';

  @override
  String get errorForumNotFound => 'Foro no encontrado.';

  @override
  String get errorForumAccessDenied =>
      'No tienes permiso para acceder a este foro.';

  @override
  String get errorForumUnavailable =>
      'El foro no está disponible en este momento. Inténtalo de nuevo más tarde.';

  @override
  String get errorDataNotFound => 'No se encontraron los datos solicitados.';

  @override
  String get errorDataCorrupted =>
      'Los datos parecen estar dañados. Actualiza la página.';

  @override
  String get errorCacheLoadFailed =>
      'No se pudieron cargar los datos en caché. Inténtalo de nuevo.';

  @override
  String errorInvalidField(String field) {
    return 'Valor no válido para $field.';
  }

  @override
  String errorFieldRequired(String field) {
    return '$field es obligatorio.';
  }

  @override
  String errorPermissionDeniedFor(String action) {
    return 'No tienes permiso para: $action.';
  }

  @override
  String errorFeatureNotAvailable(String feature) {
    return '$feature no está disponible en este foro.';
  }

  @override
  String get errorStorageFull =>
      'El almacenamiento está lleno. Libera algo de espacio.';

  @override
  String get errorStorageAccessDenied =>
      'Acceso al almacenamiento denegado. Revisa los permisos de la aplicación.';

  @override
  String get errorNetworkTryAgain =>
      'Se produjo un error de red. Inténtalo de nuevo.';

  @override
  String get errorAuthenticationTryAgain =>
      'Error de autenticación. Inténtalo de nuevo.';

  @override
  String get errorForumTryAgain =>
      'Se produjo un error en el foro. Inténtalo de nuevo.';

  @override
  String get connectionErrorTitle => 'Error de conexión';

  @override
  String get authenticationErrorTitle => 'Error de autenticación';

  @override
  String get forumErrorTitle => 'Error del foro';

  @override
  String get permissionErrorTitle => 'Error de permisos';

  @override
  String errorRemovingFromMessage(String name) {
    return 'No se pudo quitar a $name de este mensaje.';
  }

  @override
  String get chatNewMessage => 'Nuevo mensaje';

  @override
  String get chatStarred => 'Favoritos';

  @override
  String get chatBrowseChannels => 'Examinar canales';

  @override
  String get chatFilterAll => 'Todos';

  @override
  String get chatFilterOpen => 'Abierto';

  @override
  String get chatFilterClosed => 'Cerrado';

  @override
  String get chatFilterArchived => 'Archivado';

  @override
  String get chatBrowseSearch => 'Buscar canal por nombre';

  @override
  String get chatJoin => 'Unirse';

  @override
  String get chatJoined => 'Se unió';

  @override
  String get chatLeave => 'Abandonar';

  @override
  String chatMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '$count miembro',
    );
    return '$_temp0';
  }

  @override
  String get chatYesterday => 'Ayer';

  @override
  String get chatNoChannelsFound => 'No se han encontrado canales';

  @override
  String get chatCloseDm => 'Cerrar este chat personal';

  @override
  String get chatToday => 'Hoy';

  @override
  String get chatLastVisit => 'última visita';

  @override
  String chatNewMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes nuevos',
      one: '$count mensaje nuevo',
    );
    return '$_temp0';
  }

  @override
  String get chatScrollToBottom => 'Desplazar hacia abajo';

  @override
  String get chatInReplyTo => 'En respuesta a';

  @override
  String get chatCopyText => 'Copiar texto';

  @override
  String get chatTextCopied => 'Texto copiado en el portapapeles';

  @override
  String get chatBookmark => 'Marcador';

  @override
  String get chatPinMessage => 'Anclar mensaje';

  @override
  String get chatUnpinMessage => 'Desanclar mensaje';

  @override
  String get chatFlag => 'Denunciar';

  @override
  String get chatReactWithEmoji => 'Reaccionar con emojis';

  @override
  String chatReplyingTo(String username) {
    return 'Respondiendo a $username';
  }

  @override
  String get chatEditingMessage => 'Editando mensaje';

  @override
  String chatTypingOne(String username) {
    return '$username está escribiendo';
  }

  @override
  String chatTypingTwo(String commaSeparatedUsernames, String lastUsername) {
    return '$commaSeparatedUsernames y $lastUsername están escribiendo';
  }

  @override
  String chatTypingMany(String commaSeparatedUsernames, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$commaSeparatedUsernames y $count más están escribiendo',
      one: '$commaSeparatedUsernames y $count más está escribiendo',
    );
    return '$_temp0';
  }

  @override
  String get chatOpenThread => 'Hilo abierto';

  @override
  String get chatMembers => 'Miembros';

  @override
  String get chatAddMember => 'Añadir miembro';

  @override
  String get chatFindMembers => 'Buscar miembros';

  @override
  String get chatRemoveMember => 'Eliminar';

  @override
  String get chatNotifyNever => 'Nunca';

  @override
  String get chatNotifyMention => 'Solo para menciones';

  @override
  String get chatNotifyAlways => 'Para toda actividad';

  @override
  String get chatNotificationLevel => 'Enviar notificaciones push';

  @override
  String get chatMuteChannel => 'Silenciar canal';

  @override
  String get chatStarChannel => 'Añadir canal a favoritos';

  @override
  String get chatLeaveChannel => 'Abandonar canal';

  @override
  String get chatSearchTitle => 'Buscar chat';

  @override
  String get chatSearchNoResults => 'No se ha encontrado ningún resultado';

  @override
  String get chatMyThreads => 'Mis hilos';

  @override
  String chatThreadReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count respuestas',
      one: '$count respuesta',
    );
    return '$_temp0';
  }

  @override
  String get chatNoThreads => 'No participas en ningún hilo de este canal.';

  @override
  String get chatGroupName => 'Nombre del chat de grupo (opcional)';

  @override
  String chatMembersCounter(int count, int max) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count/$max miembros',
      one: '$count/$max miembro',
    );
    return '$_temp0';
  }

  @override
  String get chatTooManyMembers => 'Número máximo de miembros alcanzado';

  @override
  String get chatThread => 'Hilo';

  @override
  String get chatChannelSettings => 'Ajustes del canal';

  @override
  String get chatSearchMessagesHint => 'Buscar en mensajes';

  @override
  String get chatMyThreadsEmpty =>
      'Aún no tienes ningún tema. Los temas en los que participes se mostrarán aquí.';

  @override
  String get chatLeaveGroupInfo =>
      'Al abandonar este chat de grupo, dejarás de tener acceso al mismo y no recibirás notificaciones relacionadas con él. Para volver a unirte, deberás ser invitado de nuevo por un miembro del chat de grupo.';

  @override
  String get chatPlaceholderThread => 'Chatear en el hilo';

  @override
  String get chatLastReply => 'última respuesta';

  @override
  String messageListUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sin leer ($count)',
      one: 'Sin leer ($count)',
    );
    return '$_temp0';
  }

  @override
  String messageListNewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nuevo ($count)',
      one: 'Nuevo ($count)',
    );
    return '$_temp0';
  }

  @override
  String get messagePersonal => 'Personal';

  @override
  String messageListIncoming(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ver $count temas nuevos o actualizados',
      one: 'Ver $count tema nuevo o actualizado',
    );
    return '$_temp0';
  }

  @override
  String get chatPlaceholderGroup => 'Chatear en grupo';

  @override
  String get notificationAccountMismatch =>
      'Esta notificación no se puede abrir con la cuenta actual. Abre Notificaciones para ver las novedades de esta cuenta.';

  @override
  String get mediaPlay => 'Reproducir';

  @override
  String get mediaPause => 'Pausar';

  @override
  String get chatChannelStatusReadOnly => 'Solo lectura';

  @override
  String get chatChannelStatusClosed => 'Cerrado';

  @override
  String get chatChannelStatusArchived => 'Archivado';

  @override
  String get failedToLoadAudio => 'No se pudo cargar el audio';
}
