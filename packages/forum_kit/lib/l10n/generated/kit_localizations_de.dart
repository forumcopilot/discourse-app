// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'kit_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class KitLocalizationsDe extends KitLocalizations {
  KitLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get okButton => 'OK';

  @override
  String get copied => 'Kopiert';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get tryAgain => 'Erneut Versuchen';

  @override
  String get latest => 'Neueste';

  @override
  String get language => 'Sprache';

  @override
  String get all => 'Alle';

  @override
  String get reason => 'Grund';

  @override
  String get pleaseSpecifyReason => 'Bitte geben Sie den Grund an';

  @override
  String get selectDate => 'Datum auswählen';

  @override
  String get search => 'Suchen';

  @override
  String get messages => 'Nachrichten';

  @override
  String get add => 'Hinzufügen';

  @override
  String get delete => 'Löschen';

  @override
  String get temporary => 'Temporär';

  @override
  String error(String error) {
    return 'Fehler: $error';
  }

  @override
  String get none => 'Keine';

  @override
  String get italic => 'Kursiv';

  @override
  String get link => 'Link';

  @override
  String get image => 'Bild';

  @override
  String get quote => 'Zitat';

  @override
  String get code => 'Code';

  @override
  String participants(int count) {
    return 'Teilnehmer ($count)';
  }

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get share => 'Teilen';

  @override
  String get reply => 'Antworten';

  @override
  String get dark => 'Dunkel';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get remove => 'Entfernen';

  @override
  String get message => 'Nachricht';

  @override
  String couldNotOpenLink(String error) {
    return 'Link konnte nicht geöffnet werden: $error';
  }

  @override
  String timeGapDaysLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage später',
      one: '1 Tag später',
    );
    return '$_temp0';
  }

  @override
  String timeGapMonthsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Monate später',
      one: '1 Monat später',
    );
    return '$_temp0';
  }

  @override
  String timeGapYearsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Jahre später',
      one: '1 Jahr später',
    );
    return '$_temp0';
  }

  @override
  String get apply => 'Anwenden';

  @override
  String get bookmarks => 'Lesezeichen';

  @override
  String get copy => 'Kopieren';

  @override
  String get firstPostsOnly => 'Nur erste Beiträge';

  @override
  String get relevance => 'Relevanz';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get titleOnly => 'Nur Titel';

  @override
  String get solved => 'Gelöst';

  @override
  String get open => 'Öffnen';

  @override
  String participantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Teilnehmer',
      one: '1 Teilnehmer',
    );
    return '$_temp0';
  }

  @override
  String get postNeedsApprovalTitle => 'Beitrag muss genehmigt werden';

  @override
  String get postNeedsApprovalBody =>
      'Wir haben deinen neuen Beitrag erhalten. Dieser muss jedoch von einem Moderator genehmigt werden, bevor er angezeigt wird. Bitte habe etwas Geduld.';

  @override
  String get tapToOpen => 'Zum Öffnen tippen';

  @override
  String get imageNotAvailable => 'Bild nicht verfügbar';

  @override
  String get searchFilters => 'Suchfilter';

  @override
  String get tags => 'Schlagwörter';

  @override
  String topicMapViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aufrufe',
      one: 'Aufruf',
    );
    return '$_temp0';
  }

  @override
  String topicMapLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Likes',
      one: 'Like',
    );
    return '$_temp0';
  }

  @override
  String topicMapLinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Links',
      one: 'Link',
    );
    return '$_temp0';
  }

  @override
  String topicMapUsers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Benutzer',
    );
    return '$_temp0';
  }

  @override
  String get day => 'Tag';

  @override
  String get month => 'Monat';

  @override
  String get chooseEmoji => 'Emoji auswählen';

  @override
  String get searchEmoji => 'Emoji suchen';

  @override
  String get suspendUser => 'Benutzer sperren';

  @override
  String get suspendUntil => 'Benutzer sperren bis';

  @override
  String get suspendForever => 'Für immer sperren';

  @override
  String get suspendReasonNotListening => 'Hat nicht auf Team-Feedback gehört';

  @override
  String get suspendReasonStaffTime =>
      'Hat überproportional viel Zeit des Teams verbraucht';

  @override
  String get suspendReasonCombative => 'Zu streitlustig';

  @override
  String get suspendReasonWrongPlace => 'An der falschen Stelle';

  @override
  String get suspendReasonNoPurpose =>
      'Kein konstruktiver Zweck der Handlungen, außer Dissens innerhalb der Gemeinschaft zu erzeugen';

  @override
  String get suspendReasonCustom => 'Benutzerdefiniert …';

  @override
  String get suspendReasonQuestion =>
      'Was ist der Grund für die Sperre? Dieser Text wird dem Benutzer angezeigt, wenn er versucht, sich anzumelden. Fasse dich kurz.';

  @override
  String get closedLabel => 'Geschlossen';

  @override
  String get pleaseSelectSuspensionEndDate => 'Wähle, wann die Sperre endet';

  @override
  String get dismissAllNotifications => 'Alles gelesen';

  @override
  String get searchFilterStatusSection => 'Status';

  @override
  String get searchFilterMyActivitySection => 'Meine Aktivität';

  @override
  String get searchFilterMatchTypeSection => 'Art der Übereinstimmung';

  @override
  String get searchTagsFilterHelper =>
      'Durch Leerzeichen oder Kommas getrennt. Jedes Schlagwort ist erforderlich.';

  @override
  String get searchSortBy => 'Sortieren nach';

  @override
  String get searchStatusOpen => 'Offen';

  @override
  String get searchStatusArchived => 'Archiviert';

  @override
  String get searchStatusNoReplies => 'Ohne Antworten';

  @override
  String get searchStatusPublicOnly => 'Nur öffentliche';

  @override
  String get searchStatusUnsolved => 'Ungelöst';

  @override
  String get searchInBookmarked => 'Mit Lesezeichen';

  @override
  String get searchInMyMessages => 'In meinen Nachrichten';

  @override
  String get searchInLiked => 'Gefällt mir';

  @override
  String get searchInPosted => 'Mit meinen Beiträgen';

  @override
  String get searchInWatching => 'Beobachte ich';

  @override
  String get searchInTracking => 'Verfolge ich';

  @override
  String get searchInSeen => 'Gelesen';

  @override
  String get searchInUnseen => 'Ungelesen';

  @override
  String get searchSortLatestPost => 'Neuester Beitrag';

  @override
  String get searchSortMostLiked => 'Anzahl der „Gefällt mir“';

  @override
  String get searchSortMostViewed => 'Anzahl der Aufrufe';

  @override
  String get searchSortLatestTopic => 'Neuestes Thema';

  @override
  String get searchFieldHint => 'Suchen …';

  @override
  String get postLikeAction => 'Beitrag mit „Gefällt mir“ markieren';

  @override
  String get postUnlikeAction => '„Gefällt mir“ entfernen';
}
