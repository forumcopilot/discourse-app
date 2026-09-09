// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

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
  String get newConversation => 'Nueva conversación';

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
  String get pleaseLoginToSubscribe =>
      'Por favor inicia sesión para null este hilo';

  @override
  String get subscribe => 'Suscribirse';

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
  String get spamOrAdvertising => 'Spam o publicidad';

  @override
  String get otherPleaseSpecify => 'Otro (por favor especifica)';

  @override
  String get pleaseSpecifyReason => 'Por favor especifica el motivo';

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
  String get failedToSaveConversation => 'Error al guardar conversación';

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
  String get enterKeywordsToSearchTopics =>
      'Ingresa palabras clave para buscar temas...';

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
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String version(String version, String buildNumber) {
    return 'versión $version ($buildNumber)';
  }

  @override
  String get unableToLoadProfile => 'No se puede cargar el perfil';

  @override
  String get banned => 'BLOQUEADO';

  @override
  String get reportSubmittedSuccessfully => 'Reporte enviado exitosamente';

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
  String get submittingReport => 'Enviando reporte...';

  @override
  String get banningUser => 'Prohibiendo usuario...';

  @override
  String get unbanningUser => 'Desprohibiendo usuario...';

  @override
  String get cleaningSpam => 'Limpiando spam...';

  @override
  String get writeYourMessage => 'Escribe tu mensaje...';

  @override
  String get writeYourReply => 'Escribe tu respuesta...';

  @override
  String get conversationCreatedSuccessfully =>
      'Conversación creada exitosamente';

  @override
  String get conversationMarkedAsUnread => 'Conversación marcada como no leída';

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
  String failedToSendReply(String error) {
    return 'Error al enviar respuesta: $error';
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
  String get pleaseLoginToAccessContent =>
      'Por favor inicia sesión para acceder a este contenido e interactuar con las publicaciones.';

  @override
  String get searchUsers => 'Buscar usuarios...';

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
  String get failedToNavigateToForum => 'Error al navegar al foro';

  @override
  String forumNotFoundById(String forumId) {
    return 'Foro no encontrado: $forumId';
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
  String get loginInfo => 'Información de inicio de sesión';

  @override
  String get loginFailed => 'Error de inicio de sesión';

  @override
  String get moveToCategory => 'Mover a categoría';

  @override
  String get undeleteTopic => 'Restaurar tema';

  @override
  String get undeleteTopicConfirmation =>
      '¿Seguro que quieres restaurar este tema? Volverá a ser visible para otros usuarios.';

  @override
  String get send => 'Enviar';

  @override
  String get changeEmailExplanation =>
      'Enviaremos un enlace de confirmación a tu nuevo correo. El cambio se aplicará cuando hagas clic en él.';

  @override
  String get changeEmailSecurityNote =>
      'Por seguridad, Discourse puede pedirte confirmar mediante el enlace del correo. Revisa la carpeta de spam si no lo ves.';

  @override
  String get newDirectMessage => 'Nuevo mensaje directo';

  @override
  String get noMessagesYetSayHi => 'Aún no hay mensajes: saluda.';

  @override
  String get edited => 'editado';

  @override
  String get editProfileManagedOnWebNote =>
      'El nombre visible, el correo, la contraseña y otros ajustes de la cuenta se gestionan en Cuenta → Administrar cuenta en la web. Puedes cambiar tu avatar tocando el icono de cámara en tu foto.';

  @override
  String get approvedButRelayUnreachable =>
      'Aprobado, pero no pudimos conectar con ForumCopilot para terminar la configuración. Inténtalo más tarde desde Ajustes.';

  @override
  String get notificationsAreTurnedOffForThisApp =>
      'Las notificaciones están desactivadas para esta app';

  @override
  String forumWillAskToApproveNotifications(Object forumName) {
    return 'A continuación, $forumName te pedirá aprobar «Notificaciones».';
  }

  @override
  String get approveNotificationsExplanation =>
      'Al aprobar, podremos consultar tus notificaciones y enviarlas a este dispositivo. Este permiso no puede publicar, responder ni leer tus mensajes.';

  @override
  String get forumOwnerPushNote =>
      'Si el administrador de este foro configura las notificaciones para la app, este paso no será necesario.';

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
  String get protected => 'Protegido';

  @override
  String get solution => 'Solución';

  @override
  String get deleted => 'ELIMINADO';

  @override
  String get pleaseLoginToViewUserProfiles =>
      'Inicia sesión para ver perfiles de usuario.';

  @override
  String get announcement => 'Anuncio';

  @override
  String get solved => 'Resuelto';

  @override
  String get hot => 'Popular';

  @override
  String get pinned => 'Fijado';

  @override
  String get subscribedLabel => 'Suscrito';

  @override
  String get locked => 'Bloqueado';

  @override
  String get poll => 'Encuesta';

  @override
  String errorLoadingContent(Object error) {
    return 'Error al cargar el contenido: $error';
  }

  @override
  String get noPermissionToViewSubforum =>
      'No tienes permiso para ver los temas de este subforo.';

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
  String get topicDeletedBanner =>
      'Este tema está eliminado y oculto para otros usuarios';

  @override
  String get topicClosedBanner =>
      'Este tema está cerrado y ya no acepta respuestas';

  @override
  String get topicPinnedBanner =>
      'Este tema está fijado en la parte superior del foro';

  @override
  String get youAreSubscribedToThisTopic => 'Estás suscrito a este tema';

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
  String get editConversation => 'Editar conversación';

  @override
  String get closeConversation => 'Cerrar conversación';

  @override
  String get openConversation => 'Abrir conversación';

  @override
  String get leaveConversation2 => 'Salir de la conversación';

  @override
  String get reportConversation2 => 'Reportar conversación';

  @override
  String get closeConversation2 => 'Cerrar conversación';

  @override
  String get closeConversationConfirmation =>
      '¿Seguro que quieres cerrar esta conversación? Ya no se podrán publicar respuestas.';

  @override
  String get close => 'Cerrar';

  @override
  String get openConversation2 => 'Abrir conversación';

  @override
  String get openConversationConfirmation =>
      '¿Seguro que quieres abrir esta conversación? Se podrán publicar nuevas respuestas.';

  @override
  String get open => 'Abrir';

  @override
  String get leaveConversation3 => 'Salir de la conversación';

  @override
  String get leaveConversationConfirmation =>
      '¿Seguro que quieres salir de esta conversación? Se ocultará de tu bandeja de entrada.';

  @override
  String errorLoadingConversation(Object error) {
    return 'Error al cargar la conversación: $error';
  }

  @override
  String get conversationNotFound => 'Conversación no encontrada';

  @override
  String get conversationClosedBanner =>
      'Esta conversación está cerrada y ya no acepta respuestas';

  @override
  String get noMessagesFound => 'No se encontraron mensajes';

  @override
  String get endOfConversation => 'Fin de la conversación';

  @override
  String get jumpToMessage => 'Ir al mensaje';

  @override
  String get editConversation2 => 'Editar conversación';

  @override
  String get failedToLoadMessage2 => 'No se pudo cargar el mensaje';

  @override
  String get cannotEditThisConversation =>
      'No se puede editar esta conversación';

  @override
  String get options => 'Opciones';

  @override
  String get conversationOpen => 'Conversación abierta';

  @override
  String failedToCreateConversation(Object error) {
    return 'No se pudo crear la conversación: $error';
  }

  @override
  String maximumAttachmentsAllowed(Object count) {
    return 'Máximo de $count adjunto(s) permitido(s)';
  }

  @override
  String get noImagesFoundToDisplay =>
      'No se encontraron imágenes para mostrar.';

  @override
  String get pleaseLoginToViewThisAttachment =>
      'Inicia sesión para ver este adjunto';

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
  String get emailSettingsSubtitle =>
      'Frecuencia de correo, agrupación de me gusta, resumen periódico';

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
      'La eliminación de tu cuenta se gestiona en el foro. Continúa para abrir el sitio y contactar al equipo: los foros Discourse procesan las eliminaciones según su propia política.';

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
  String get unableToLoadForums => 'No se pudieron cargar los foros';

  @override
  String get noForumsToDisplayExplanation =>
      'No hay foros que mostrar. Puede deberse a permisos o a la estructura del foro.';

  @override
  String get subscribedForums => 'Foros suscritos';

  @override
  String get errorLoadingNotifications => 'Error al cargar las notificaciones';

  @override
  String get pullDownToRefresh => 'Desliza hacia abajo para actualizar';

  @override
  String get noNewNotificationsExplanation =>
      'No tienes notificaciones nuevas. Vuelve más tarde para ver novedades de los temas que sigues.';

  @override
  String noTagsMatch(Object filter) {
    return 'Ninguna etiqueta coincide con «$filter».';
  }

  @override
  String noTopicsTagged(Object tag) {
    return 'No hay temas con la etiqueta «$tag»';
  }

  @override
  String failedToBanUser2(Object error) {
    return 'No se pudo banear al usuario: $error';
  }

  @override
  String unbanUserConfirmation(Object username) {
    return '¿Seguro que quieres desbanear a $username?';
  }

  @override
  String failedToUnbanUser2(Object error) {
    return 'No se pudo desbanear al usuario: $error';
  }

  @override
  String get deletePostsProfilePostsAndComments =>
      'Eliminar publicaciones, publicaciones de perfil y comentarios';

  @override
  String spamCleanConfirmation(Object username) {
    return '¿Seguro que quieres limpiar el spam de $username?';
  }

  @override
  String failedToCleanSpam(Object error) {
    return 'No se pudo limpiar el spam: $error';
  }

  @override
  String get searchUser => 'Buscar usuario';

  @override
  String get tapToOpen => 'Toca para abrir';

  @override
  String get imageNotAvailable => 'Imagen no disponible';

  @override
  String get allForumTopicsHaveBeenMarkedAs =>
      'Todos los temas del foro se marcaron como leídos';

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
  String get failedToPickFile => 'No se pudo seleccionar el archivo';

  @override
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return 'Solo se permiten $remainingSlots adjunto(s) más. Se procesarán las primeras $remainingSlots2 imágenes.';
  }

  @override
  String get attachmentLimitReachedSkippingRemainingImages =>
      'Límite de adjuntos alcanzado. Se omiten las imágenes restantes.';

  @override
  String failedToUploadImagePleaseTryAgain(Object fileName) {
    return '$fileName: no se pudo subir la imagen. Inténtalo de nuevo.';
  }

  @override
  String failedToUploadImage2(Object errorMessage, Object fileName) {
    return '$fileName: no se pudo subir la imagen: $errorMessage';
  }

  @override
  String get failedToPickImage => 'No se pudo seleccionar la imagen';

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
  String get pleaseWaitForTheThreadToLoad => 'Espera a que se cargue el tema';

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
  String failedToSubmitReport2(Object error) {
    return 'No se pudo enviar el reporte: $error';
  }

  @override
  String get editHistoryNotAvailable =>
      'El historial de ediciones no está disponible para esta publicación';

  @override
  String get noPermissionToUploadAvatar =>
      'No tienes permiso para subir avatares';

  @override
  String get avatarUploadedSuccessfully => 'Avatar subido';

  @override
  String failedToPickImage2(Object error) {
    return 'No se pudo seleccionar la imagen: $error';
  }

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
  String signOutWarning(Object siteName) {
    return 'Cerrarás sesión en $siteName. Puedes volver a iniciar sesión cuando quieras.';
  }

  @override
  String get suggestedTopics => 'Temas sugeridos';

  @override
  String get newLabel => 'NUEVO';

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
  String get switchForum => 'Cambiar de foro';

  @override
  String get explore => 'Explorar';

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
}
