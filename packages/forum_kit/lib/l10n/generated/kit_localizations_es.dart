// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'kit_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class KitLocalizationsEs extends KitLocalizations {
  KitLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get okButton => 'Aceptar';

  @override
  String get copied => 'Copiado';

  @override
  String get cancel => 'Cancelar';

  @override
  String get tryAgain => 'Intentar de Nuevo';

  @override
  String get latest => 'Recientes';

  @override
  String get language => 'Idioma';

  @override
  String get all => 'Todo';

  @override
  String get reason => 'Razón';

  @override
  String get pleaseSpecifyReason => 'Por favor especifica el motivo';

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String get search => 'Buscar';

  @override
  String get messages => 'Mensajes';

  @override
  String get add => 'Agregar';

  @override
  String get delete => 'Eliminar';

  @override
  String get temporary => 'Temporal';

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String get none => 'Ninguno';

  @override
  String get italic => 'Cursiva';

  @override
  String get link => 'Enlace';

  @override
  String get image => 'Imagen';

  @override
  String get quote => 'Cita';

  @override
  String get code => 'Código';

  @override
  String participants(int count) {
    return 'Participantes ($count)';
  }

  @override
  String get refresh => 'Actualizar';

  @override
  String get share => 'Compartir';

  @override
  String get reply => 'Responder';

  @override
  String get dark => 'Oscuro';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get edit => 'Editar';

  @override
  String get remove => 'Eliminar';

  @override
  String get message => 'Mensaje';

  @override
  String couldNotOpenLink(String error) {
    return 'No se pudo abrir el enlace: $error';
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
  String get apply => 'Aplicar';

  @override
  String get bookmarks => 'Marcadores';

  @override
  String get copy => 'Copiar';

  @override
  String get firstPostsOnly => 'Solo primeras publicaciones';

  @override
  String get relevance => 'Relevancia';

  @override
  String get reset => 'Restablecer';

  @override
  String get titleOnly => 'Solo título';

  @override
  String get solved => 'Resuelto';

  @override
  String get open => 'Abrir';

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
  String get postNeedsApprovalTitle => 'La publicación requiere aprobación';

  @override
  String get postNeedsApprovalBody =>
      'Hemos recibido tu nueva publicación, pero debe ser aprobada por un moderador antes de que aparezca. Por favor, ten paciencia.';

  @override
  String get tapToOpen => 'Toca para abrir';

  @override
  String get imageNotAvailable => 'Imagen no disponible';

  @override
  String get searchFilters => 'Filtros de búsqueda';

  @override
  String get tags => 'Etiquetas';

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
  String get day => 'Día';

  @override
  String get month => 'Mes';

  @override
  String get chooseEmoji => 'Elegir emoji';

  @override
  String get searchEmoji => 'Buscar emoji';

  @override
  String get suspendUser => 'Suspender usuario';

  @override
  String get suspendUntil => 'Suspender al usuario hasta';

  @override
  String get suspendForever => 'Suspender para siempre';

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
  String get pleaseSelectSuspensionEndDate =>
      'Elige cuándo termina la suspensión';

  @override
  String get dismissAllNotifications => 'Descartar todo';

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
  String get postLikeAction => 'Me gusta la publicación';

  @override
  String get postUnlikeAction => 'Deshacer me gusta';
}
