// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'kit_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class KitLocalizationsNl extends KitLocalizations {
  KitLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get discardFailedCloseQuestion =>
      'Toch sluiten? Een eerder opgeslagen concept blijft bij Concepten.';

  @override
  String get keepEditing => 'Verder bewerken';

  @override
  String get closeAnyway => 'Toch sluiten';

  @override
  String get okButton => 'OK';

  @override
  String get copied => 'Gekopieerd';

  @override
  String get cancel => 'Annuleren';

  @override
  String get tryAgain => 'Opnieuw proberen';

  @override
  String get latest => 'Nieuwste';

  @override
  String get language => 'Taal';

  @override
  String get all => 'Alles';

  @override
  String get reason => 'Reden';

  @override
  String get pleaseSpecifyReason => 'Geef de reden op';

  @override
  String get selectDate => 'Selecteer datum';

  @override
  String get search => 'Zoeken';

  @override
  String get messages => 'Berichten';

  @override
  String get add => 'Toevoegen';

  @override
  String get delete => 'Verwijderen';

  @override
  String get temporary => 'Tijdelijk';

  @override
  String error(String error) {
    return 'Fout: $error';
  }

  @override
  String get none => 'Geen';

  @override
  String get italic => 'Cursief';

  @override
  String get link => 'Link';

  @override
  String get image => 'Afbeelding';

  @override
  String get quote => 'Citaat';

  @override
  String get code => 'Code';

  @override
  String participants(int count) {
    return 'Deelnemers ($count)';
  }

  @override
  String get refresh => 'Vernieuwen';

  @override
  String get share => 'Delen';

  @override
  String get reply => 'Beantwoorden';

  @override
  String get dark => 'Donker';

  @override
  String get notifications => 'Meldingen';

  @override
  String get edit => 'Bewerken';

  @override
  String get remove => 'Verwijderen';

  @override
  String get message => 'Bericht';

  @override
  String couldNotOpenLink(String error) {
    return 'Kon link niet openen: $error';
  }

  @override
  String timeGapDaysLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dagen later',
      one: '1 dag later',
    );
    return '$_temp0';
  }

  @override
  String timeGapMonthsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count maanden later',
      one: '1 maand later',
    );
    return '$_temp0';
  }

  @override
  String timeGapYearsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jaar later',
      one: '1 jaar later',
    );
    return '$_temp0';
  }

  @override
  String get apply => 'Toepassen';

  @override
  String get bookmarks => 'Bladwijzers';

  @override
  String get copy => 'Kopiëren';

  @override
  String get discard => 'Verwerpen';

  @override
  String get firstPostsOnly => 'Alleen eerste berichten';

  @override
  String get relevance => 'Relevantie';

  @override
  String get reset => 'Herstellen';

  @override
  String get titleOnly => 'Alleen titel';

  @override
  String get solved => 'Opgelost';

  @override
  String get open => 'Openen';

  @override
  String participantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count deelnemers',
      one: '1 deelnemer',
    );
    return '$_temp0';
  }

  @override
  String get postNeedsApprovalTitle => 'Bericht vereist goedkeuring';

  @override
  String get postNeedsApprovalBody =>
      'We hebben je nieuwe bericht ontvangen, maar dit moet eerst door een moderator worden goedgekeurd voordat het zichtbaar wordt. Heb geduld.';

  @override
  String get tapToOpen => 'Tik om te openen';

  @override
  String get imageNotAvailable => 'Afbeelding niet beschikbaar';

  @override
  String get searchFilters => 'Zoekfilters';

  @override
  String get tags => 'Tags';

  @override
  String get discardPostQuestion => 'Wil je je bericht weggooien?';

  @override
  String get discardChangesQuestion => 'Wil je je wijzigingen negeren?';

  @override
  String get discardChanges => 'Wijzigingen negeren';

  @override
  String get saveDraft => 'Concept opslaan';

  @override
  String topicMapViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'weergaven',
      one: 'weergave',
    );
    return '$_temp0';
  }

  @override
  String topicMapLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'likes',
      one: 'like',
    );
    return '$_temp0';
  }

  @override
  String topicMapLinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'links',
      one: 'link',
    );
    return '$_temp0';
  }

  @override
  String topicMapUsers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'gebruikers',
      one: 'gebruiker',
    );
    return '$_temp0';
  }

  @override
  String get day => 'Dag';

  @override
  String get month => 'Maand';

  @override
  String get chooseEmoji => 'Emoji kiezen';

  @override
  String get searchEmoji => 'Emoji zoeken';

  @override
  String get suspendUser => 'Gebruiker schorsen';

  @override
  String get suspendUntil => 'Gebruiker schorsen tot';

  @override
  String get suspendForever => 'Voor altijd schorsen';

  @override
  String get suspendReasonNotListening =>
      'Wilde niet naar feedback van medewerkers luisteren';

  @override
  String get suspendReasonStaffTime =>
      'Heeft onevenredig veel tijd van medewerkers verbruikt';

  @override
  String get suspendReasonCombative => 'Te strijdlustig';

  @override
  String get suspendReasonWrongPlace => 'Op de verkeerde plek';

  @override
  String get suspendReasonNoPurpose =>
      'Geen constructief doel voor hun acties, anders dan het creëren van onenigheid binnen de community';

  @override
  String get suspendReasonCustom => 'Aangepast…';

  @override
  String get suspendReasonQuestion =>
      'Waarom schors je? Deze tekst wordt aan de gebruiker weergegeven wanneer deze zich probeert aan te melden. Houd het kort.';

  @override
  String get closedLabel => 'Gesloten';

  @override
  String get pleaseSelectSuspensionEndDate =>
      'Kies wanneer de schorsing eindigt';

  @override
  String get dismissAllNotifications => 'Alles negeren';

  @override
  String get searchFilterStatusSection => 'Status';

  @override
  String get searchFilterMyActivitySection => 'Mijn activiteit';

  @override
  String get searchFilterMatchTypeSection => 'Soort overeenkomst';

  @override
  String get searchTagsFilterHelper =>
      'Gescheiden door spaties of komma\'s. Elke tag is vereist.';

  @override
  String get searchSortBy => 'Sorteren op';

  @override
  String get searchStatusOpen => 'Open';

  @override
  String get searchStatusArchived => 'Gearchiveerd';

  @override
  String get searchStatusNoReplies => 'Zonder antwoorden';

  @override
  String get searchStatusPublicOnly => 'Alleen openbaar';

  @override
  String get searchStatusUnsolved => 'Onopgelost';

  @override
  String get searchInBookmarked => 'Met bladwijzer';

  @override
  String get searchInMyMessages => 'In mijn berichten';

  @override
  String get searchInLiked => 'Door mij geliket';

  @override
  String get searchInPosted => 'Waarin ik iets heb geplaatst';

  @override
  String get searchInWatching => 'Die ik observeer';

  @override
  String get searchInTracking => 'Die ik volg';

  @override
  String get searchInSeen => 'Die ik heb gelezen';

  @override
  String get searchInUnseen => 'Die ik niet heb gelezen';

  @override
  String get searchSortLatestPost => 'Nieuwste bericht';

  @override
  String get searchSortMostLiked => 'Meest geliket';

  @override
  String get searchSortMostViewed => 'Meest bekeken';

  @override
  String get searchSortLatestTopic => 'Nieuwste topic';

  @override
  String get searchFieldHint => 'Zoeken…';

  @override
  String get postLikeAction => 'Bericht liken';

  @override
  String get postUnlikeAction => 'Like ongedaan maken';

  @override
  String get somethingWentWrongTryAgain =>
      'Er ging iets mis. Probeer het opnieuw.';
}
