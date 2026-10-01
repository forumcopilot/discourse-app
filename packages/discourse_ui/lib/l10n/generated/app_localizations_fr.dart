// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get loginTitle => 'Connexion';

  @override
  String get usePasskey => 'Use Passkey';

  @override
  String get passkeyContinuePrompt => 'Use your passkey to continue';

  @override
  String get continueButton => 'Continuer';

  @override
  String get errorTitle => 'Erreur';

  @override
  String get okButton => 'OK';

  @override
  String get retryButton => 'Réessayer';

  @override
  String get copyToClipboard => 'Copier dans le presse-papiers';

  @override
  String get copied => 'Copié';

  @override
  String get errorMessageCopiedToClipboard =>
      'Message d\'erreur copié dans le presse-papiers';

  @override
  String get dismiss => 'Ignorer';

  @override
  String get cancel => 'Annuler';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get anErrorOccurred => 'Une erreur s\'est produite';

  @override
  String get accountPendingApproval =>
      'Votre compte est en attente d\'approbation. Vous pouvez parcourir le forum mais ne pouvez pas publier jusqu\'à ce qu\'un modérateur approuve votre compte.';

  @override
  String get checkEmailToConfirm =>
      'Veuillez vérifier votre e-mail pour confirmer votre compte. Cliquez sur le lien de confirmation dans l\'e-mail que nous vous avons envoyé.';

  @override
  String get checkNewEmailToConfirm =>
      'Veuillez vérifier votre nouvelle adresse e-mail pour confirmer le changement. Votre ancien e-mail restera actif jusqu\'à ce que vous confirmiez le nouveau.';

  @override
  String get emailAddressInvalid =>
      'Votre adresse e-mail semble invalide ou rejette les e-mails. Veuillez mettre à jour votre adresse e-mail dans les paramètres du compte.';

  @override
  String get accountDisabled =>
      'Votre compte a été désactivé. Veuillez contacter un administrateur pour obtenir de l\'aide.';

  @override
  String get accountRegistrationRejected =>
      'L\'inscription de votre compte a été rejetée. Veuillez contacter un administrateur pour plus d\'informations.';

  @override
  String get welcomeToForumCopilot => 'Bienvenue sur Forum Copilot !';

  @override
  String get successfullyLoggedOut => 'Vous avez été déconnecté avec succès';

  @override
  String get accountStatusRequiresAttention =>
      'Le statut de votre compte nécessite une attention. Veuillez contacter un administrateur si vous avez des questions.';

  @override
  String get updateEmail => 'Mettre à jour l\'e-mail';

  @override
  String get resend => 'Renvoyer';

  @override
  String get noLatestTopics => 'Aucun sujet récent';

  @override
  String get noRecentTopicsToDisplay =>
      'Il n\'y a pas de sujets récents à afficher. Revenez plus tard pour de nouvelles discussions.';

  @override
  String get signInToViewLatestTopics =>
      'Connectez-vous pour voir les sujets récents';

  @override
  String get youNeedToBeSignedInToViewLatestTopics =>
      'Vous devez être connecté pour voir les sujets récents';

  @override
  String get thereAreNoUnreadTopics =>
      'Il n\'y a pas de sujets non lus. Revenez plus tard pour de nouvelles discussions.';

  @override
  String get youAreAllCaughtUp => 'Vous êtes à jour !';

  @override
  String get signInToViewUnreadTopics =>
      'Connectez-vous pour voir les sujets non lus';

  @override
  String get youNeedToBeSignedInToViewUnreadTopics =>
      'Vous devez être connecté pour voir vos sujets non lus';

  @override
  String get latest => 'Récent';

  @override
  String get unread => 'Non lu';

  @override
  String get failedToConnectToSite =>
      'Échec de la connexion au site. Le site peut être hors ligne ou inaccessible.';

  @override
  String get connectionFailed => 'Échec de la connexion';

  @override
  String failedToConnectToSiteName(String siteName) {
    return 'Échec de la connexion à $siteName';
  }

  @override
  String get loading => 'Chargement...';

  @override
  String get newConversation => 'Nouveau message';

  @override
  String get language => 'Langue';

  @override
  String get all => 'Tout';

  @override
  String get topicsOnly => 'Sujets uniquement';

  @override
  String get titlesOnly => 'Titres uniquement';

  @override
  String failedToShareTopic(String error) {
    return 'Échec du partage du sujet : $error';
  }

  @override
  String get youCannotReplyToThisThread =>
      'Vous ne pouvez pas répondre à ce fil';

  @override
  String get pleaseWaitForThreadToLoad =>
      'Veuillez attendre le chargement du fil';

  @override
  String get reason => 'Raison';

  @override
  String get participantsLabel => 'Participants';

  @override
  String usernameHasBeenInvited(String username) {
    return '$username a été invité au message';
  }

  @override
  String errorInvitingUser(String error) {
    return 'Erreur lors de l\'invitation de l\'utilisateur : $error';
  }

  @override
  String get newTopic => 'Nouveau sujet';

  @override
  String get pleaseSpecifyReason => 'Veuillez préciser la raison';

  @override
  String get selectDate => 'Sélectionner la date';

  @override
  String get moreOptions => 'Plus d\'options';

  @override
  String get topicClosed => 'Sujet fermé';

  @override
  String get topicOpened => 'Sujet ouvert';

  @override
  String get noConversations => 'Vous n\'avez aucun message';

  @override
  String get noConversationsMessage =>
      'Vous n\'avez encore aucun message. Écrivez un nouveau message pour commencer.';

  @override
  String get imageSavedToGallery => 'Image enregistrée dans la galerie !';

  @override
  String failedToSaveImage(String error) {
    return 'Échec de l\'enregistrement de l\'image : $error';
  }

  @override
  String get userProfile => 'Profil Utilisateur';

  @override
  String get deletePost => 'Supprimer le Message';

  @override
  String get loginRequired => 'Connexion Requise';

  @override
  String get sendMessage => 'Message direct';

  @override
  String get likesReceived => 'J\'aime Reçus';

  @override
  String get showMore => 'Afficher plus';

  @override
  String get failedToSaveConversation => 'Impossible d\'enregistrer le message';

  @override
  String get members => 'Membres';

  @override
  String membersCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString Membres';
  }

  @override
  String get noSubject => 'Sans objet';

  @override
  String get search => 'Rechercher';

  @override
  String get logout => 'Déconnexion';

  @override
  String get areYouSureYouWantToLogout =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get signIn => 'Se connecter';

  @override
  String get notificationTest => 'Test de Notification';

  @override
  String get forum => 'Catégorie';

  @override
  String get profile => 'Profil';

  @override
  String get messages => 'Messages';

  @override
  String get add => 'Ajouter';

  @override
  String get retry => 'Réessayer';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteMessage => 'Supprimer le Message';

  @override
  String get deletingPost => 'Suppression du message...';

  @override
  String failedToUnlikePost(String error) {
    return 'Échec du retrait du j\'aime du message : $error';
  }

  @override
  String failedToLikePost(String error) {
    return 'Échec du j\'aime du message : $error';
  }

  @override
  String get signInToViewMessages => 'Connectez-vous pour voir les messages';

  @override
  String get youNeedToBeSignedInToViewConversations =>
      'Vous devez être connecté pour voir vos messages.';

  @override
  String failedToLeaveConversation(String error) {
    return 'Impossible de quitter le message : $error';
  }

  @override
  String errorLoadingMoreConversations(String error) {
    return 'Erreur lors du chargement d\'autres messages : $error';
  }

  @override
  String get searchFailed => 'Recherche échouée';

  @override
  String get userInformationNotAvailable =>
      'Informations utilisateur non disponibles';

  @override
  String get birthday => 'Anniversaire';

  @override
  String get posts => 'Messages';

  @override
  String get following => 'Abonnements';

  @override
  String get followers => 'Abonnés';

  @override
  String get about => 'À propos';

  @override
  String get location => 'Localisation';

  @override
  String get website => 'Site web';

  @override
  String get next => 'Suivant';

  @override
  String get temporary => 'Temporaire';

  @override
  String get back => 'Retour';

  @override
  String get confirm => 'Confirmer';

  @override
  String error(String error) {
    return 'Erreur : $error';
  }

  @override
  String get removeAttachment => 'Supprimer la Pièce Jointe';

  @override
  String get areYouSureYouWantToRemoveThisAttachment =>
      'Êtes-vous sûr de vouloir supprimer cette pièce jointe ?';

  @override
  String get none => 'Aucun';

  @override
  String get attachFile => 'Joindre un Fichier';

  @override
  String get uploadImage => 'Télécharger une Image';

  @override
  String get formatting => 'Formatage';

  @override
  String get bold => 'Gras';

  @override
  String get italic => 'Italique';

  @override
  String get underline => 'Souligné';

  @override
  String get strikethrough => 'Barré';

  @override
  String get link => 'Lien';

  @override
  String get image => 'Image';

  @override
  String get video => 'Vidéo';

  @override
  String get quote => 'Citation';

  @override
  String get code => 'Code';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get bulletList => 'Liste à Puces';

  @override
  String get numberedList => 'Liste Numérotée';

  @override
  String get listItem => 'Élément de Liste';

  @override
  String participants(int count) {
    return 'Participants ($count)';
  }

  @override
  String get markAsUnread => 'Marquer comme non lu';

  @override
  String get invite => 'Inviter';

  @override
  String get enterKeywordsToSearchTopics =>
      'Entrez des mots-clés pour rechercher des sujets...';

  @override
  String get refresh => 'Actualiser';

  @override
  String get share => 'Partager';

  @override
  String get viewOnWeb => 'Voir sur le Web';

  @override
  String get reply => 'Répondre';

  @override
  String get vote => 'Voter';

  @override
  String votesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes',
      one: '$count vote',
    );
    return '$_temp0';
  }

  @override
  String get pollClosed => 'Sondage fermé';

  @override
  String pollEndsOn(String date) {
    return 'Se termine le $date';
  }

  @override
  String get voteToSeeResults => 'Votez pour voir les résultats';

  @override
  String get viewFullPoll => 'Voir le sondage';

  @override
  String pollOptionsCount(int count) {
    return '$count options';
  }

  @override
  String get reactedBy => 'Réagi par';

  @override
  String get enterKeywordsToFindTopicsAndPosts =>
      'Entrez des mots-clés pour trouver des sujets et des messages';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get appearance => 'Apparence';

  @override
  String get appearanceSystem => 'Système';

  @override
  String version(String version, String buildNumber) {
    return 'version $version ($buildNumber)';
  }

  @override
  String get unableToLoadProfile => 'Impossible de charger le profil';

  @override
  String get banned => 'BANNI';

  @override
  String get deleteTopic => 'Supprimer le sujet';

  @override
  String get pleaseSelectEndDate => 'Veuillez sélectionner une date de fin';

  @override
  String get home => 'Accueil';

  @override
  String get notifications => 'Notifications';

  @override
  String get forums => 'Catégories';

  @override
  String get content => 'Contenu';

  @override
  String get pleaseEnterTitle => 'Veuillez entrer un titre';

  @override
  String get pleaseEnterContent => 'Veuillez entrer du contenu';

  @override
  String get uploading => 'Téléchargement...';

  @override
  String get uploaded => 'Téléchargé';

  @override
  String get mentionUser => 'Mentionner un utilisateur';

  @override
  String get writeYourMessage => 'Écrivez votre message...';

  @override
  String get writeYourReply => 'Écrivez votre réponse...';

  @override
  String get conversationMarkedAsUnread => 'Message marqué comme non lu';

  @override
  String get conversationClosed => 'Message fermé';

  @override
  String get conversationOpened => 'Message ouvert';

  @override
  String failedToLoadQuote(String error) {
    return 'Échec du chargement de la citation : \n$error';
  }

  @override
  String failedToMarkConversationAsUnread(String error) {
    return 'Impossible de marquer le message comme non lu : $error';
  }

  @override
  String failedToCloseConversation(String error) {
    return 'Impossible de fermer le message : $error';
  }

  @override
  String failedToOpenConversation(String error) {
    return 'Impossible d\'ouvrir le message : $error';
  }

  @override
  String get goToTop => 'Aller en haut';

  @override
  String get goToBottom => 'Aller en bas';

  @override
  String get pleaseLoginToAccessContent =>
      'Veuillez vous connecter pour accéder à ce contenu et interagir avec les publications.';

  @override
  String get searchUsers => 'Rechercher des utilisateurs...';

  @override
  String get enterConversationTitle => 'Saisissez le titre du message';

  @override
  String enterCode(int count) {
    return 'Entrez le code à $count chiffres';
  }

  @override
  String get edit => 'Modifier';

  @override
  String get remove => 'Supprimer';

  @override
  String get subject => 'Sujet';

  @override
  String get message => 'Message';

  @override
  String get titleCannotBeEmpty => 'Le titre ne peut pas être vide';

  @override
  String get conversationUpdatedSuccessfully => 'Message mis à jour';

  @override
  String get goBack => 'Retour';

  @override
  String get like => 'aimer';

  @override
  String get download => 'Télécharger';

  @override
  String downloading(String filename) {
    return 'Téléchargement de $filename...';
  }

  @override
  String openingShareSheet(String filename) {
    return 'Ouverture de la feuille de partage pour $filename';
  }

  @override
  String errorDownloading(String filename, String error) {
    return 'Erreur lors du téléchargement de $filename : $error';
  }

  @override
  String couldNotOpenLink(String error) {
    return 'Impossible d\'ouvrir le lien : $error';
  }

  @override
  String get translating => 'Traduction en cours...';

  @override
  String get translated => 'Traduit';

  @override
  String get translatedContent => 'Contenu traduit';

  @override
  String get twoFactorAuthentication => 'Authentification à deux facteurs';

  @override
  String get authenticationCodeLabel => 'Code d\'authentification';

  @override
  String get pleaseEnterYourAuthenticationCode =>
      'Veuillez saisir votre code d\'authentification';

  @override
  String codeMustBeDigits(int count) {
    return 'Le code doit contenir $count chiffres';
  }

  @override
  String get codeMustContainOnlyNumbers =>
      'Le code doit contenir uniquement des chiffres';

  @override
  String get verifyButton => 'Vérifier';

  @override
  String get attachments => 'Pièces jointes';

  @override
  String get replyOptions => 'Options de reponse';

  @override
  String get replyWithQuote => 'Repondre avec citation';

  @override
  String fileSavedToDownloads(String filename) {
    return 'Fichier enregistré dans Téléchargements : $filename';
  }

  @override
  String fileSavedToDocuments(String filename) {
    return 'Fichier enregistré dans Documents : $filename';
  }

  @override
  String topicLastReplyBy(String username, String time) {
    return '$username a répondu $time';
  }

  @override
  String inReplyToUser(String username) {
    return 'en réponse à $username';
  }

  @override
  String inReplyToPost(int number) {
    return 'en réponse au message n°$number';
  }

  @override
  String timeGapDaysLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours plus tard',
      one: '1 jour plus tard',
    );
    return '$_temp0';
  }

  @override
  String timeGapMonthsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mois plus tard',
      one: '1 mois plus tard',
    );
    return '$_temp0';
  }

  @override
  String timeGapYearsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ans plus tard',
      one: '1 an plus tard',
    );
    return '$_temp0';
  }

  @override
  String get profileViews => 'Vues';

  @override
  String get badges => 'Badges';

  @override
  String get chatWithUser => 'Discussion';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count réponses',
      one: '1 réponse',
    );
    return '$_temp0';
  }

  @override
  String get chat => 'Discussion';

  @override
  String moreBadges(Object count) {
    return '+$count de plus';
  }

  @override
  String get allNotificationsMarkedAsRead =>
      'Toutes les notifications marquées comme lues';

  @override
  String get apply => 'Appliquer';

  @override
  String get bookmarks => 'Signets';

  @override
  String reviewableBy(String username) {
    return 'Par $username';
  }

  @override
  String get changeEmail => 'Changer l’adresse e-mail';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get checkingStatus => 'Vérification de l’état…';

  @override
  String get clearReminder => 'Supprimer le rappel';

  @override
  String get copy => 'Copier';

  @override
  String get copyLink => 'Copier le lien';

  @override
  String couldNotEnableNotifications(String error) {
    return 'Impossible d’activer les notifications : $error';
  }

  @override
  String get couldNotFindBookmark => 'Signet introuvable';

  @override
  String couldNotOpenEmail(String email) {
    return 'Impossible d’ouvrir l’e-mail : $email';
  }

  @override
  String couldNotStartSignIn(String error) {
    return 'Impossible de démarrer la connexion : $error';
  }

  @override
  String get customDateAndTime => 'Date et heure personnalisées';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteMessageQuestion => 'Supprimer le message ?';

  @override
  String get discard => 'Abandonner';

  @override
  String get doNotDisturb => 'Ne pas déranger';

  @override
  String get editHistory => 'Historique des modifications';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get editReminder => 'Modifier le rappel';

  @override
  String emailCopiedToClipboard(String email) {
    return 'E-mail copié dans le presse-papiers : $email';
  }

  @override
  String get pushEnabledForThisLogin => 'Activées pour cette connexion';

  @override
  String get failedToLoadMoreTopics =>
      'Impossible de charger plus de sujets. Faites défiler pour réessayer.';

  @override
  String get failedToUpdateNotificationLevel =>
      'Impossible de modifier le niveau de notification';

  @override
  String get firstPostsOnly => 'Premiers messages uniquement';

  @override
  String get ignoredUsers => 'Utilisateurs ignorés';

  @override
  String get inTwoHours => 'Dans deux heures';

  @override
  String get inviteByEmail => 'Inviter par e-mail';

  @override
  String get inviteLinkCopied => 'Lien d’invitation copié';

  @override
  String inviteSentTo(String email) {
    return 'Invitation envoyée à $email';
  }

  @override
  String get leave => 'Quitter';

  @override
  String get leaveGroup => 'Quitter le groupe';

  @override
  String get leaveGroupQuestion => 'Quitter le groupe ?';

  @override
  String get linkCopied => 'Lien copié';

  @override
  String get loadMore => 'Charger plus';

  @override
  String get manageAccountOnWeb => 'Gérer le compte sur le web';

  @override
  String get merge => 'Fusionner';

  @override
  String get mergeIntoTopic => 'Fusionner dans un sujet';

  @override
  String get newInviteLink => 'Nouveau lien d’invitation';

  @override
  String get nextWeek => 'La semaine prochaine';

  @override
  String get pushNotAvailableInThisBuild => 'Non disponible dans cette version';

  @override
  String get notNow => 'Pas maintenant';

  @override
  String tagNotificationLevelUpdated(String tag) {
    return 'Niveau de notification de « $tag » mis à jour';
  }

  @override
  String doNotDisturbOnUntil(String until) {
    return 'Activé jusqu’à $until';
  }

  @override
  String get pleaseLogInToBookmark => 'Connectez-vous pour ajouter un signet';

  @override
  String get pleaseLogInToFollowUsers =>
      'Connectez-vous pour suivre des utilisateurs';

  @override
  String get pleaseLogInToMarkAnswers =>
      'Connectez-vous pour marquer les réponses';

  @override
  String get pleaseLogInToReact => 'Connectez-vous pour réagir';

  @override
  String get pleaseLogInToVote => 'Connectez-vous pour voter';

  @override
  String get pushNotifications => 'Notifications push';

  @override
  String get relevance => 'Pertinence';

  @override
  String get reminderTimeMustBeInFuture =>
      'L’heure du rappel doit être dans le futur';

  @override
  String get removeBookmark => 'Supprimer le signet';

  @override
  String get removeVote => 'Retirer le vote';

  @override
  String get renameTopic => 'Renommer le sujet';

  @override
  String reportedBy(String username) {
    return 'Signalé par $username';
  }

  @override
  String get requestToJoin => 'Demander à rejoindre';

  @override
  String requestToJoinGroup(String group) {
    return 'Demander à rejoindre $group';
  }

  @override
  String get reset => 'Réinitialiser';

  @override
  String get resizeAndUpload => 'Redimensionner et envoyer';

  @override
  String get checkConnectionAndRetry =>
      'Vérifiez votre connexion Internet et réessayez.';

  @override
  String get reviewQueue => 'File de modération';

  @override
  String get revoke => 'Révoquer';

  @override
  String get revokeInviteQuestion => 'Révoquer l’invitation ?';

  @override
  String get save => 'Enregistrer';

  @override
  String get sendInvite => 'Envoyer l’invitation';

  @override
  String get sendRequest => 'Envoyer la demande';

  @override
  String get settings => 'Paramètres';

  @override
  String get showVoters => 'Afficher les votants';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get signInCancelledNoPayload =>
      'Connexion annulée — aucune réponse reçue';

  @override
  String signInFailed(String error) {
    return 'Échec de la connexion : $error';
  }

  @override
  String get startChat => 'Démarrer la discussion';

  @override
  String stoppedIgnoringUser(String username) {
    return 'Vous n’ignorez plus @$username';
  }

  @override
  String get titleOnly => 'Titre uniquement';

  @override
  String get tomorrow => 'Demain';

  @override
  String get turnOff => 'Désactiver';

  @override
  String get turnOnNotifications => 'Activer les notifications';

  @override
  String get whisper => 'Chuchotement';

  @override
  String likeAgainInSeconds(Object seconds) {
    return 'Vous pourrez aimer ce message de nouveau dans ${seconds}s';
  }

  @override
  String get loginInfo => 'Informations de connexion';

  @override
  String get loginFailed => 'Échec de la connexion';

  @override
  String get moveToCategory => 'Déplacer vers une catégorie';

  @override
  String get undeleteTopic => 'Annuler la suppression du sujet';

  @override
  String get send => 'Envoyer';

  @override
  String get changeEmailExplanation =>
      'Nous enverrons un lien de confirmation à votre nouvelle adresse. Le changement prend effet lorsque vous cliquez dessus.';

  @override
  String get changeEmailSecurityNote =>
      'Pour plus de sécurité, Discourse peut demander une confirmation via le lien de l’e-mail. Vérifiez vos spams si vous ne le voyez pas.';

  @override
  String get noMessagesYetSayHi => 'Pas encore de messages — dites bonjour.';

  @override
  String get edited => 'modifié';

  @override
  String get approvedButRelayUnreachable =>
      'Approuvé, mais le serveur de notifications est injoignable pour terminer la configuration. Réessayez plus tard depuis les Réglages.';

  @override
  String get notificationsAreTurnedOffForThisApp =>
      'Les notifications sont désactivées pour cette application';

  @override
  String get pleaseLoginToCreateANewTopic =>
      'Connectez-vous pour créer un sujet';

  @override
  String get pleaseLoginToSubscribeToForums =>
      'Connectez-vous pour vous abonner aux forums';

  @override
  String leaveGroupWarning(Object group) {
    return 'Vous ne serez plus membre de $group. Vous pourrez rejoindre le groupe à tout moment.';
  }

  @override
  String get groupMembersPrivate =>
      'La liste des membres de ce groupe est privée.';

  @override
  String get unignore => 'Ne plus ignorer';

  @override
  String get inviteLinkCreated => 'Lien d’invitation créé';

  @override
  String expiresOn(Object date) {
    return 'Expire le $date';
  }

  @override
  String get solution => 'Solution';

  @override
  String get deleted => 'SUPPRIMÉ';

  @override
  String get pleaseLoginToViewUserProfiles =>
      'Connectez-vous pour voir les profils.';

  @override
  String get solved => 'Résolu';

  @override
  String get hot => 'Populaire';

  @override
  String get pinned => 'Épinglé';

  @override
  String get locked => 'Verrouillé';

  @override
  String get poll => 'Sondage';

  @override
  String get noDiscussionsYet => 'Pas encore de discussions.';

  @override
  String get jumpToPost => 'Aller au message';

  @override
  String get jump => 'Aller';

  @override
  String get endOfTheDiscussion => 'Fin de la discussion';

  @override
  String get reviewQueueStaffOnly =>
      'Seuls le personnel et les modérateurs peuvent voir la file de modération.';

  @override
  String get nothingToReview => 'Rien à modérer';

  @override
  String refreshFailed(Object error) {
    return 'Échec de l’actualisation : $error';
  }

  @override
  String get refreshing => 'Actualisation...';

  @override
  String get title => 'Titre';

  @override
  String editedAt(Object time) {
    return 'Modifié $time';
  }

  @override
  String editReason(Object reason) {
    return 'Raison : $reason';
  }

  @override
  String get thisDiffIsTooLargeToDisplay =>
      'Ce diff est trop volumineux pour être affiché.';

  @override
  String get noContentChangesInThisRevision =>
      'Aucune modification de contenu dans cette révision.';

  @override
  String revisionOf(Object currentVersion, Object versionCount) {
    return 'Révision $currentVersion sur $versionCount';
  }

  @override
  String get editConversation => 'Modifier le titre';

  @override
  String get closeConversation => 'Fermer le message';

  @override
  String get openConversation => 'Ouvrir le message';

  @override
  String get leaveConversation2 => 'Quitter le message';

  @override
  String get closeConversation2 => 'Fermer le message';

  @override
  String get closeConversationConfirmation =>
      'Fermer ce message ? Il n\'acceptera plus de nouvelles réponses.';

  @override
  String get close => 'Fermer';

  @override
  String get openConversation2 => 'Ouvrir le message';

  @override
  String get openConversationConfirmation =>
      'Ouvrir ce message ? Il acceptera de nouveau les réponses.';

  @override
  String get open => 'Ouvrir';

  @override
  String get leaveConversation3 => 'Quitter le message';

  @override
  String get leaveConversationConfirmation =>
      'Voulez-vous vraiment vous retirer de ce message ? Vous ne pourrez plus le voir ni y répondre.';

  @override
  String get editConversation2 => 'Modifier le titre';

  @override
  String get failedToLoadMessage2 => 'Impossible de charger le message';

  @override
  String get cannotEditThisConversation =>
      'Vous ne pouvez pas modifier ce message';

  @override
  String get options => 'Options';

  @override
  String get conversationOpen => 'Ouvert aux réponses';

  @override
  String get messageTitleHint =>
      'Pouvez-vous résumer le sujet en une courte phrase ?';

  @override
  String get messageOpenForReplies => 'Accepte de nouvelles réponses';

  @override
  String get messageClosedForReplies => 'Fermé : aucune nouvelle réponse';

  @override
  String get messageSentWithoutId =>
      'Le message a été envoyé, mais le forum ne l\'a pas renvoyé. Consultez vos messages.';

  @override
  String get messageCouldNotBeSent => 'Le message n\'a pas pu être envoyé.';

  @override
  String get messageIdMissing =>
      'Impossible d\'ouvrir ce message : son identifiant est manquant.';

  @override
  String get pleaseAddARecipient => 'Ajoutez au moins un destinataire';

  @override
  String get archiveMessage => 'Archiver';

  @override
  String get moveToInbox => 'Déplacer dans la boîte de réception';

  @override
  String get messageInbox => 'Boîte de réception';

  @override
  String get messageArchive => 'Archivés';

  @override
  String get messageListUnread => 'Non lus';

  @override
  String get messageListNew => 'Nouveau';

  @override
  String get messageListSent => 'Envoyés';

  @override
  String removeFromMessageConfirm(String name) {
    return 'Voulez-vous vraiment supprimer $name de ce message direct ?';
  }

  @override
  String uploadingFilename(String filename) {
    return 'Téléversement : $filename…';
  }

  @override
  String get messageArchived => 'Message archivé';

  @override
  String get messageMovedToInbox => 'Déplacé dans la boîte de réception';

  @override
  String failedToArchiveMessage(Object error) {
    return 'Impossible d\'archiver le message : $error';
  }

  @override
  String failedToMoveMessageToInbox(Object error) {
    return 'Impossible de déplacer le message dans la boîte de réception : $error';
  }

  @override
  String get noArchivedMessages => 'Vous n\'avez aucun message archivé';

  @override
  String get noArchivedMessagesHint =>
      'Archivez un message depuis son menu ⋮ pour le ranger ici.';

  @override
  String groupHasBeenInvited(String group) {
    return '$group a été invité au message';
  }

  @override
  String participantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants',
      one: '1 participant',
    );
    return '$_temp0';
  }

  @override
  String get chatChannels => 'Canaux';

  @override
  String get chatDms => 'DM';

  @override
  String get chatNoChannels => 'Vous n\'avez encore rejoint aucun canal !';

  @override
  String get chatNoDms => 'Vous n\'avez encore rejoint aucun message direct !';

  @override
  String get chatNoDmsCta => 'Commencer une conversation';

  @override
  String chatPlaceholderChannel(String channel) {
    return 'Discuter dans $channel';
  }

  @override
  String chatPlaceholderUsers(String names) {
    return 'Discuter avec $names';
  }

  @override
  String get chatPlaceholderSelf => 'Noter quelque chose';

  @override
  String get chatPlaceholderArchived =>
      'Le canal est archivé, vous ne pouvez pas envoyer de nouveaux messages pour le moment.';

  @override
  String get chatPlaceholderClosed =>
      'Le canal est fermé, vous ne pouvez pas envoyer de nouveaux messages pour le moment.';

  @override
  String get chatPlaceholderReadOnly =>
      'Le canal est en lecture seule, vous ne pouvez pas envoyer de nouveaux messages pour le moment.';

  @override
  String get chatPlaceholderSilenced =>
      'Vous ne pouvez pas envoyer de messages pour le moment.';

  @override
  String get chatDeleteConfirm => 'Voulez-vous vraiment supprimer ce message ?';

  @override
  String get chatStartNewDm => 'Nouveau DM';

  @override
  String get chatCreatePersonal => 'Créer une conversation personnelle';

  @override
  String get chatCreateGroup => 'Créer une discussion de groupe';

  @override
  String get chatCannotCreate =>
      'Nous sommes désolés, vous ne pouvez pas envoyer de messages directs.';

  @override
  String get chatDisabledUser => 'a désactivé la discussion';

  @override
  String get chatSearchPlaceholder => '@personne';

  @override
  String get chatAddMorePlaceholder => '...ajouter d\'autres membres';

  @override
  String chatUserNotFound(String name) {
    return '@$name introuvable';
  }

  @override
  String get chatCouldNotStartDm => 'Impossible de démarrer la discussion.';

  @override
  String get chatSignInTitle => 'Connectez-vous pour utiliser la discussion';

  @override
  String get chatSignInMessage =>
      'Vous devez être connecté pour voir et rejoindre les canaux de discussion.';

  @override
  String get chatDirectMessage => 'Message direct';

  @override
  String get chatNotAvailable =>
      'La discussion n\'est pas disponible sur ce forum.';

  @override
  String get chatAttachFile => 'Joindre un fichier';

  @override
  String get chatRemoveUpload => 'Supprimer le fichier';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get postNeedsApprovalTitle => 'Ce message doit être approuvé';

  @override
  String get postNeedsApprovalBody =>
      'Votre nouveau message a bien été envoyé, mais il doit être accepté par un modérateur avant d\'apparaître publiquement. Merci de votre patience.';

  @override
  String maximumAttachmentsAllowed(Object count) {
    return 'Maximum de $count pièce(s) jointe(s)';
  }

  @override
  String get noImagesFoundToDisplay => 'Aucune image à afficher.';

  @override
  String get searchForTopics => 'Rechercher des sujets';

  @override
  String get noTopicsFound => 'Aucun sujet trouvé';

  @override
  String get trySearchingWithDifferentKeywords => 'Essayez d’autres mots-clés';

  @override
  String get noPostsFound => 'Aucun message trouvé';

  @override
  String get perTopicNotificationLevelsNote =>
      'Les niveaux de notification par catégorie et par sujet se règlent directement depuis ces écrans — touchez l’icône cloche d’un sujet ou d’une catégorie.';

  @override
  String get pushNotActiveForThisLogin =>
      'Inactives pour cette connexion — déconnectez-vous puis reconnectez-vous pour autoriser les notifications push';

  @override
  String get pauseNotificationsFor => 'Suspendre les notifications pendant…';

  @override
  String get doNotDisturbExplanation =>
      'Suspendez les notifications un moment — Discourse les retient jusqu’à la fin de la période';

  @override
  String get manageAccountSubtitle =>
      'Profil, e-mail, mot de passe, sécurité, paramètres avancés';

  @override
  String get changePasswordSubtitle =>
      'Envoie un e-mail de réinitialisation du mot de passe à votre adresse actuelle';

  @override
  String get ignoredUsersSubtitle =>
      'Voir et gérer les utilisateurs dont les messages vous sont masqués';

  @override
  String get deleteAccountExplanation =>
      'Supprimez votre compte et vos publications, si le forum le permet. Sinon, son équipe peut le supprimer pour vous.';

  @override
  String get verificationEmailSent =>
      'E-mail de vérification envoyé — cliquez sur le lien pour confirmer votre nouvelle adresse.';

  @override
  String get passwordResetExplanation =>
      'Nous vous enverrons un lien de réinitialisation. Cliquez dessus pour choisir un nouveau mot de passe — le changement se fait sur le forum, pas dans cette application.';

  @override
  String get sendResetEmail => 'Envoyer l’e-mail de réinitialisation';

  @override
  String get deleteAccountDialogBody =>
      'Votre compte est géré par le forum. Contactez directement l’équipe du forum pour demander la suppression. « Continuer » ouvrira le forum dans votre navigateur pour utiliser son propre contact / message à l’équipe.';

  @override
  String get initializingForum => 'Initialisation du forum…';

  @override
  String get errorLoadingNotifications =>
      'Erreur de chargement des notifications';

  @override
  String get noNewNotificationsExplanation =>
      'Des notifications s\'afficheront ici pour vous informer de l\'activité qui vous concerne directement sur le forum, telle que les réponses qui vous sont adressées, les personnes qui citent vos messages ou qui mentionnent votre pseudo, et les nouveaux messages publiés dans les sujets que vous suivez. Si vous ne vous êtes pas connecté(e) au forum depuis un moment, vous recevrez aussi ces notifications par e-mail.';

  @override
  String noTagsMatch(Object filter) {
    return 'Aucune étiquette ne correspond à « $filter ».';
  }

  @override
  String noTopicsTagged(Object tag) {
    return 'Aucun sujet avec l’étiquette « $tag »';
  }

  @override
  String get searchUser => 'Rechercher un utilisateur';

  @override
  String get tapToOpen => 'Touchez pour ouvrir';

  @override
  String get imageNotAvailable => 'Image indisponible';

  @override
  String postsCount(Object count) {
    return '$count messages';
  }

  @override
  String get permissionDeniedToSaveImage =>
      'Permission refusée pour enregistrer l’image';

  @override
  String get postNotFound => 'Message introuvable.';

  @override
  String get failedToUploadFilePleaseTryAgain =>
      'Échec de l’envoi du fichier. Veuillez réessayer.';

  @override
  String failedToUploadFile2(Object errorMessage) {
    return 'Échec de l’envoi du fichier : $errorMessage';
  }

  @override
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return 'Seulement $remainingSlots pièce(s) jointe(s) supplémentaire(s) autorisée(s). Traitement des $remainingSlots2 première(s) image(s).';
  }

  @override
  String failedToRemoveAttachment2(Object error) {
    return 'Impossible de supprimer la pièce jointe : $error';
  }

  @override
  String sentFromMobileApp(Object siteName) {
    return 'Envoyé depuis l’application mobile $siteName';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      'Veuillez attendre la fin de l’envoi des pièces jointes';

  @override
  String get imageIsTooLargeToUpload =>
      'L’image est trop volumineuse pour être envoyée';

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName fait $fileBytes. Ce forum autorise jusqu’à $maxBytes.';
  }

  @override
  String get resizeToFitExplanation =>
      'Elle peut être réduite juste assez pour tenir, en conservant son format et autant de détails que la limite le permet.';

  @override
  String get failedToPostReplyPleaseTryAgain =>
      'Échec de la publication de la réponse. Veuillez réessayer.';

  @override
  String get failedToUpdatePostPleaseTryAgain =>
      'Échec de la mise à jour du message. Veuillez réessayer.';

  @override
  String get postDeletedSuccessfully => 'Message supprimé';

  @override
  String failedToDeletePost(Object error) {
    return 'Échec de la suppression du message : $error';
  }

  @override
  String get editHistoryNotAvailable =>
      'L’historique des modifications n’est pas disponible pour ce message';

  @override
  String get react => 'Réagir';

  @override
  String get reactionsAreNotEnabledOnThisForum =>
      'Les réactions ne sont pas activées sur ce forum.';

  @override
  String get noReactionsYet => 'Pas encore de réactions';

  @override
  String get searchFilters => 'Filtres de recherche';

  @override
  String get suggestedTopics => 'Sujets suggérés';

  @override
  String get suggestedMessages => 'Messages suggérés';

  @override
  String get voteRemoved => 'Vote retiré';

  @override
  String get voters => 'Votants';

  @override
  String get noVotesYet => 'Pas encore de votes.';

  @override
  String get trustLevels => 'Niveaux de confiance';

  @override
  String get trustLevelsExplanation =>
      'Les membres gagnent en confiance en lisant et en participant. Chaque niveau débloque de nouvelles possibilités.';

  @override
  String get activity => 'Activité';

  @override
  String get dontUpload => 'Ne pas envoyer';

  @override
  String get dontAskAgainAlwaysResize =>
      'Ne plus demander — toujours redimensionner';

  @override
  String get couldNotLoadCategories => 'Impossible de charger les catégories.';

  @override
  String get tags => 'Étiquettes';

  @override
  String get community => 'Communauté';

  @override
  String get users => 'Utilisateurs';

  @override
  String get groups => 'Groupes';

  @override
  String get invites => 'Invitations';

  @override
  String get account => 'Compte';

  @override
  String get drafts => 'Brouillons';

  @override
  String get termsOfService => 'Conditions d’utilisation';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get notSignedIn => 'Non connecté';

  @override
  String get deviceWillNotShowAlertsUntilAllowedInSettings =>
      'Votre appareil n\'affichera aucune alerte tant que vous n\'autorisez pas les notifications dans les Réglages.';

  @override
  String get openSettings => 'Ouvrir les réglages';

  @override
  String get notificationsOnThisDevice => 'Notifications sur cet appareil';

  @override
  String get notificationsGrantOnSubtitle =>
      'Les réponses, mentions et messages de ce forum sont livrés ici.';

  @override
  String get notificationsGrantOffSubtitle =>
      'Approuvez une fois sur le forum pour recevoir ici ses réponses, mentions et messages.';

  @override
  String get turnOn => 'Activer';

  @override
  String get couldNotTurnOffNotifications =>
      'Impossible de désactiver les notifications. Réessayez plus tard.';

  @override
  String actionCodeTopicCreated(String when) {
    return 'A créé ce sujet $when';
  }

  @override
  String actionCodePublicTopic(String when) {
    return 'A rendu ce sujet public ($when)';
  }

  @override
  String actionCodeOpenTopic(String when) {
    return 'A converti ceci en sujet ($when)';
  }

  @override
  String actionCodePrivateTopic(String when) {
    return 'A fait de ce sujet un message direct ($when)';
  }

  @override
  String actionCodeSplitTopic(String when) {
    return 'A scindé ce sujet ($when)';
  }

  @override
  String actionCodeInvitedUser(String who, String when) {
    return 'A invité $who ($when)';
  }

  @override
  String actionCodeInvitedGroup(String who, String when) {
    return 'A invité $who ($when)';
  }

  @override
  String actionCodeUserLeft(String who, String when) {
    return '$who a quitté cette conversation $when';
  }

  @override
  String actionCodeRemovedUser(String who, String when) {
    return 'A retiré $who ($when)';
  }

  @override
  String actionCodeRemovedGroup(String who, String when) {
    return 'A retiré $who ($when)';
  }

  @override
  String actionCodeAutobumped(String when) {
    return 'Remonté automatiquement dans la liste ($when)';
  }

  @override
  String actionCodeTagsChanged(String when) {
    return 'Étiquettes mises à jour $when';
  }

  @override
  String actionCodeCategoryChanged(String when) {
    return 'Catégorie mise à jour $when';
  }

  @override
  String get actionCodeForwarded => 'A transmis l\'e-mail ci-dessus';

  @override
  String actionCodeAutoclosedEnabled(String when) {
    return 'A fermé ce sujet ($when)';
  }

  @override
  String actionCodeAutoclosedDisabled(String when) {
    return 'A ouvert ce sujet ($when)';
  }

  @override
  String actionCodeClosedEnabled(String when) {
    return 'A fermé ce sujet ($when)';
  }

  @override
  String actionCodeClosedDisabled(String when) {
    return 'A ouvert ce sujet ($when)';
  }

  @override
  String actionCodeArchivedEnabled(String when) {
    return 'A archivé ce sujet ($when)';
  }

  @override
  String actionCodeArchivedDisabled(String when) {
    return 'A désarchivé ce sujet ($when)';
  }

  @override
  String actionCodePinnedEnabled(String when) {
    return 'A épinglé ce sujet ($when)';
  }

  @override
  String actionCodePinnedDisabled(String when) {
    return 'A désépinglé ce sujet ($when)';
  }

  @override
  String actionCodePinnedGloballyEnabled(String when) {
    return 'A épinglé ce sujet globalement ($when)';
  }

  @override
  String actionCodePinnedGloballyDisabled(String when) {
    return 'A désépinglé ce sujet ($when)';
  }

  @override
  String actionCodeVisibleEnabled(String when) {
    return 'A rendu ce sujet visible ($when)';
  }

  @override
  String actionCodeVisibleDisabled(String when) {
    return 'A rendu ce sujet invisible ($when)';
  }

  @override
  String actionCodeBannerEnabled(String when) {
    return 'A mis ce sujet à la une ($when). Il sera affiché en haut de chaque page jusqu\'à ce qu\'il soit ignoré par l\'utilisateur.';
  }

  @override
  String actionCodeBannerDisabled(String when) {
    return 'A supprimé ce sujet de la une ($when). Il ne sera plus affiché en haut de chaque page.';
  }

  @override
  String actionCodeAssigned(String who, String when) {
    return 'Attribué à $who le $when';
  }

  @override
  String actionCodeUnassigned(String who, String when) {
    return 'Annulation de l\'attribution à $who le $when';
  }

  @override
  String actionCodeReassigned(String who, String when) {
    return 'Réattribution à $who le $when';
  }

  @override
  String localDateToday(String time) {
    return 'Aujourd\'hui $time';
  }

  @override
  String localDateTomorrow(String time) {
    return 'Demain $time';
  }

  @override
  String localDateYesterday(String time) {
    return 'Hier $time';
  }

  @override
  String get eventExpired => 'Expiré';

  @override
  String get eventEveryDay => 'Tous les jours';

  @override
  String get eventEveryWeekday => 'Chaque jour de la semaine';

  @override
  String get eventEveryWeek => 'Chaque semaine en ce jour de la semaine';

  @override
  String get eventEveryTwoWeeks =>
      'Toutes les deux semaines en ce jour de la semaine';

  @override
  String get eventEveryFourWeeks =>
      'Toutes les quatre semaines en ce jour de la semaine';

  @override
  String get eventEveryMonth => 'Chaque mois en ce jour de la semaine';

  @override
  String get errorNoConnection =>
      'Impossible de joindre le forum. Vérifiez votre connexion et réessayez.';

  @override
  String get errorTimedOut =>
      'Le forum a mis trop de temps à répondre. Veuillez réessayer.';

  @override
  String get errorPaywalled =>
      'Ce contenu est réservé aux membres payants du forum.';

  @override
  String get errorBlocked =>
      'Le pare-feu du forum a bloqué l\'application. Réessayez plus tard ou ouvrez le forum dans un navigateur.';

  @override
  String get errorNotAllowed =>
      'Vous n\'avez pas accès à ce contenu. Se connecter pourrait aider.';

  @override
  String get errorNotFound => 'Ce contenu n\'existe pas ou a été supprimé.';

  @override
  String get errorRateLimited =>
      'Vous faites cela trop souvent. Patientez un instant et réessayez.';

  @override
  String get errorForumDown =>
      'Le forum ne répond pas pour le moment. Veuillez réessayer plus tard.';

  @override
  String get deleteSpammer => 'Supprimer le spammeur';

  @override
  String get yesDeleteSpammer => 'Oui, supprimer le spammeur';

  @override
  String get deleteSpammerConfirm =>
      'Vous êtes sur le point de supprimer les publications et sujets de cet utilisateur, supprimer son compte, bloquer les inscriptions depuis son adresse IP et ajouter son adresse e-mail à une liste de blocage permanent. Êtes-vous sûr(e) que cet utilisateur est un spammeur ?';

  @override
  String get userWasDeleted => 'L\'utilisateur a été supprimé.';

  @override
  String get deleteMyAccount => 'Supprimer mon compte';

  @override
  String get deleteAccountConfirm =>
      'Voulez-vous vraiment supprimer définitivement votre compte ? Cette action est irréversible !';

  @override
  String get deletedYourself => 'Votre compte a été supprimé avec succès.';

  @override
  String get deleteYourselfNotAllowed =>
      'Veuillez contacter un responsable si vous souhaitez supprimer votre compte.';

  @override
  String get createTopic => 'Créer le sujet';

  @override
  String get discardPostQuestion => 'Voulez-vous abandonner votre message ?';

  @override
  String get discardChangesQuestion =>
      'Voulez-vous annuler vos modifications ?';

  @override
  String get discardChanges => 'Annuler les modifications';

  @override
  String get saveDraft => 'Enregistrer le brouillon';

  @override
  String get notificationSettings => 'Paramètres de notification';

  @override
  String get topicIsNew => 'Nouveau sujet';

  @override
  String get noNewTopicsSinceLastVisit =>
      'Aucun nouveau sujet depuis votre dernière visite.';

  @override
  String get messageIsNew => 'Nouveau message';

  @override
  String topicUnreadReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count réponses non lues',
      one: '$count réponse non lue',
    );
    return '$_temp0';
  }

  @override
  String filterNewWithCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nouveaux ($count)',
      one: 'Nouveau ($count)',
    );
    return '$_temp0';
  }

  @override
  String filterUnreadWithCount(int count) {
    return 'Non lus ($count)';
  }

  @override
  String categoryNewTopics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nouveaux',
      one: '$count nouveau',
    );
    return '$_temp0';
  }

  @override
  String categoryUnreadTopics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count non lus',
      one: '$count non lu',
    );
    return '$_temp0';
  }

  @override
  String get dismissNew => 'Ignorer les nouveaux';

  @override
  String get dismissUnread => 'Marquer les non lus comme vus';

  @override
  String get dismissNewTitle => 'Ignorer les nouveaux sujets ?';

  @override
  String get dismissNewMessage => 'Ils n\'apparaîtront plus comme nouveaux.';

  @override
  String get dismissUnreadTitle =>
      'Marquer tous les sujets non lus comme vus ?';

  @override
  String get dismissUnreadMessage =>
      'Leurs nouvelles réponses seront marquées comme lues.';

  @override
  String get dismissUnreadStopTracking =>
      'Arrêter de suivre ces sujets pour qu\'ils ne soient plus jamais marqués comme non lus';

  @override
  String get dismissNewAndUnread => 'Ignorer les nouveaux et les non lus';

  @override
  String dismissNewAndUnreadMessage(String category) {
    return 'Les sujets de $category n\'apparaîtront plus comme nouveaux ou non lus.';
  }

  @override
  String get dismissedTopics => 'Ignorés';

  @override
  String topicMapViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vues',
      one: 'vue',
    );
    return '$_temp0';
  }

  @override
  String topicMapLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'j\'aime',
    );
    return '$_temp0';
  }

  @override
  String topicMapLinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'liens',
      one: 'lien',
    );
    return '$_temp0';
  }

  @override
  String topicMapUsers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'utilisateurs',
      one: 'utilisateur',
    );
    return '$_temp0';
  }

  @override
  String get markAsSolution => 'Marquer comme solution';

  @override
  String get unmarkAsSolution => 'Ne plus marquer comme solution';

  @override
  String searchForumName(String forum) {
    return 'Rechercher dans $forum';
  }

  @override
  String countActiveThisMonth(String formatted) {
    return '$formatted actifs ce mois-ci';
  }

  @override
  String countMembers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted membres',
      one: '$formatted membre',
    );
    return '$_temp0';
  }

  @override
  String countTopics(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted sujets',
      one: '$formatted sujet',
    );
    return '$_temp0';
  }

  @override
  String categoryNewThisWeek(int count) {
    return '$count nouveaux cette semaine';
  }

  @override
  String get categoriesView => 'Catégories';

  @override
  String get allCategories => 'Toutes les catégories';

  @override
  String get allTags => 'Toutes les étiquettes';

  @override
  String get myPosts => 'Mes messages';

  @override
  String get drawerIntroduction =>
      'Les catégories, les étiquettes et votre compte sur ce forum se trouvent dans ce menu. Rouvrez-le à tout moment avec le bouton de menu.';

  @override
  String trustLevelN(int level) {
    return 'Niveau de confiance $level';
  }

  @override
  String get filterNew => 'Nouveaux';

  @override
  String get filterTop => 'Top';

  @override
  String get levelWatching => 'Surveiller';

  @override
  String get levelWatchingFirstPost => 'Surveiller le premier message';

  @override
  String get levelTracking => 'Suivre';

  @override
  String get levelNormal => 'Normal';

  @override
  String get levelMuted => 'Silencieux';

  @override
  String get chooseCategory => 'Choisir une catégorie';

  @override
  String get signInToPostAndGetNotifications =>
      'Connectez-vous pour publier et recevoir des notifications';

  @override
  String forumBlocksNotificationServer(Object forumName) {
    return '$forumName bloque notre serveur de notifications, elles risquent donc de ne pas arriver. Vous pouvez les désactiver dans les Réglages.';
  }

  @override
  String get relatedTopics => 'Sujets connexes';

  @override
  String get relatedMessages => 'Messages connexes';

  @override
  String moreInCategory(String category) {
    return 'Plus dans $category';
  }

  @override
  String get latestTopics => 'Sujets récents';

  @override
  String get pushGroupMessages => 'Messages et chat';

  @override
  String get pushGroupMessagesHint =>
      'Messages personnels, boîtes de groupe et chat';

  @override
  String get pushGroupReplies => 'Réponses et mentions';

  @override
  String get pushGroupRepliesHint =>
      'Réponses, mentions, citations et sujets suivis';

  @override
  String get pushGroupReactions => 'J’aime et réactions';

  @override
  String get pushGroupReactionsHint => 'J’aime et réactions à vos messages';

  @override
  String get pushGroupOther => 'Tout le reste';

  @override
  String get pushGroupOtherHint =>
      'Badges, rappels, réponses acceptées et plus';

  @override
  String get pushChannelOther => 'Autres notifications';

  @override
  String get couldNotChangePushSetting =>
      'Impossible de modifier ce réglage. Réessayez plus tard.';

  @override
  String neverMissAReplyOn(Object forumName) {
    return 'Ne manquez aucune réponse sur $forumName';
  }

  @override
  String get notificationsPitch =>
      'Réponses, mentions, messages et chat sur votre écran verrouillé, en général en moins de 10 minutes. Vous choisissez lesquels à tout moment dans les Réglages.';

  @override
  String get notificationsStepAllow =>
      'Autoriser les notifications sur ce téléphone';

  @override
  String get notificationsStepAllowed =>
      'Les notifications sont autorisées sur ce téléphone';

  @override
  String notificationsStepApprove(Object forumName) {
    return 'Approuver sur $forumName';
  }

  @override
  String get notificationsReadOnlyNote =>
      'Lecture seule : ne peut ni publier, ni répondre, ni lire vos messages';

  @override
  String get notificationPreviewReply =>
      'Jane vous a répondu : Bienvenue ! Ravis que vous nous ayez trouvés.';

  @override
  String get notificationPreviewMessage =>
      'Sam vous a envoyé un message : Tu viens vendredi ?';

  @override
  String get notificationPreviewNow => 'maintenant';

  @override
  String get notificationPreviewEarlier => 'il y a 5 min';

  @override
  String get activityReplied => 'A répondu';

  @override
  String get activityStartedTopic => 'A créé un sujet';

  @override
  String get activityLiked => 'A aimé';

  @override
  String get activitySolution => 'Solution';

  @override
  String get activityAcceptedBy => 'acceptée par';

  @override
  String get activityAwaitingApproval => 'En attente de validation';

  @override
  String get activityFilterTopics => 'Sujets';

  @override
  String get activityFilterReplies => 'Réponses';

  @override
  String get activityFilterLikes => 'J’aime';

  @override
  String get activityFilterPending => 'En attente';

  @override
  String get sectionToday => 'Aujourd’hui';

  @override
  String get sectionThisWeek => 'Cette semaine';

  @override
  String get sectionEarlier => 'Plus tôt';

  @override
  String draftsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count brouillons en attente',
      one: '1 brouillon en attente',
    );
    return '$_temp0';
  }

  @override
  String get resumeDrafts => 'Reprendre';

  @override
  String get myPostsEmpty => 'Aucun message pour l’instant';

  @override
  String get myPostsEmptyHint =>
      'Les sujets que vous créez et les réponses que vous écrivez apparaîtront ici.';

  @override
  String get activityEmptyTopics => 'Aucun sujet pour l’instant';

  @override
  String get activityEmptyReplies => 'Aucune réponse pour l’instant';

  @override
  String get activityEmptyLikes => 'Aucun j’aime donné';

  @override
  String get activityEmptySolved => 'Aucune solution pour l’instant';

  @override
  String get viewProfile => 'Voir le profil';

  @override
  String get yourStuff => 'Vos contenus';

  @override
  String get accountAndPrivacy => 'Compte et confidentialité';

  @override
  String profileStatPosts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'messages',
      one: 'message',
    );
    return '$_temp0';
  }

  @override
  String profileStatLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'j’aime',
    );
    return '$_temp0';
  }

  @override
  String profileStatDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'jours',
      one: 'jour',
    );
    return '$_temp0';
  }

  @override
  String get profileStatSolved => 'résolus';

  @override
  String joinForum(String forum) {
    return 'Rejoindre $forum';
  }

  @override
  String get guestBenefitPost => 'Répondre et créer des sujets';

  @override
  String get guestBenefitNotify => 'Être averti quand on vous répond';

  @override
  String get guestBenefitSave => 'Garder des signets et des brouillons';

  @override
  String get guestBenefitChat => 'Discuter et envoyer des messages';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get aboutThisForum => 'À propos de ce forum';

  @override
  String get drawerMore => 'Plus';

  @override
  String get goToYourProfile => 'Aller à votre profil';

  @override
  String profileJoined(String date) {
    return 'Inscrit en $date';
  }

  @override
  String profileSeen(String when) {
    return 'Vu $when';
  }

  @override
  String profileLocalTime(String time) {
    return '$time heure locale';
  }

  @override
  String get profileTabSummary => 'Résumé';

  @override
  String get summaryTopReplies => 'Meilleures réponses';

  @override
  String get summaryTopTopics => 'Meilleurs sujets';

  @override
  String get summaryMostLikedBy => 'Le plus aimé par';

  @override
  String get summaryMostLiked => 'A le plus aimé';

  @override
  String get summaryMostRepliedTo => 'A le plus répondu à';

  @override
  String get summaryTopLinks => 'Meilleurs liens';

  @override
  String get summaryTopCategories => 'Catégories principales';

  @override
  String get featuredTopic => 'Sujet mis en avant';

  @override
  String get profileDetails => 'Détails';

  @override
  String get followUser => 'Suivre';

  @override
  String get unfollowUser => 'Ne plus suivre';

  @override
  String get profileSuspended => 'Suspendu';

  @override
  String get searchBookmarks => 'Rechercher dans vos signets';

  @override
  String get bookmarksFilterReminders => 'Rappels';

  @override
  String get bookmarkWholeTopic => 'Sujet entier';

  @override
  String bookmarkSaved(String when) {
    return 'enregistré $when';
  }

  @override
  String bookmarkPostNumber(int number) {
    return 'message n° $number';
  }

  @override
  String reminderToday(String time) {
    return 'Aujourd’hui, $time';
  }

  @override
  String reminderTomorrow(String time) {
    return 'Demain, $time';
  }

  @override
  String reminderDue(String when) {
    return 'Échu · $when';
  }

  @override
  String get addBookmarkLabel => 'Ajouter une note';

  @override
  String get editBookmarkLabel => 'Modifier la note';

  @override
  String get bookmarkLabelHint => 'À quoi sert-il ?';

  @override
  String get pinBookmark => 'Épingler en haut';

  @override
  String get unpinBookmark => 'Désépingler';

  @override
  String get bookmarkRemoved => 'Signet supprimé';

  @override
  String get undo => 'Annuler';

  @override
  String get bookmarksNoMatch => 'Aucun signet ne correspond';

  @override
  String get addReminder => 'Ajouter un rappel';

  @override
  String get bookmarksEmpty => 'Aucun signet pour l’instant';

  @override
  String get bookmarksEmptyHint =>
      'Mettez un message en signet depuis ses actions et il vous attendra ici.';

  @override
  String get draftKindNewTopic => 'Nouveau sujet';

  @override
  String draftMessageTo(String names) {
    return 'Message à $names';
  }

  @override
  String get untitledTopic => 'Sujet sans titre';

  @override
  String get draftDiscarded => 'Brouillon supprimé';

  @override
  String get draftsEmpty => 'Aucun brouillon pour l’instant';

  @override
  String get draftsEmptyHint =>
      'Les brouillons s’enregistrent pendant que vous écrivez. Commencez une réponse ou un sujet et il vous attendra ici.';

  @override
  String get privacySection => 'Confidentialité';

  @override
  String get changeEmailSubtitle =>
      'Nous enverrons un lien de vérification à la nouvelle adresse';

  @override
  String get aboutMe => 'À propos de moi';

  @override
  String get aboutMeHelper => 'Affiché en haut de votre profil';

  @override
  String get aboutMeMarkdownHint =>
      'Markdown accepté : **gras**, liens, :emoji:';

  @override
  String get addCover => 'Ajouter une couverture';

  @override
  String get changeCover => 'Changer la couverture';

  @override
  String get birthdayHint =>
      'Le forum le fête avec vous. L’année n’est pas conservée.';

  @override
  String get birthdayRemoved => 'Anniversaire supprimé';

  @override
  String get birthdaySaved => 'Anniversaire enregistré';

  @override
  String get cardBackground => 'Arrière-plan de la carte';

  @override
  String get cardBackgroundExplanation =>
      'Derrière votre carte utilisateur quand on touche votre photo';

  @override
  String get cardBackgroundRemoved => 'Arrière-plan de la carte supprimé';

  @override
  String get cardBackgroundSheetHint =>
      'Affiché derrière votre carte utilisateur. Les photos larges conviennent le mieux.';

  @override
  String get changeProfilePicture => 'Changer la photo de profil';

  @override
  String get changeUsername => 'Changer de nom d’utilisateur';

  @override
  String changeUsernameExplanation(String username) {
    return 'Les mentions et citations de @$username dans les messages passent au nouveau nom. Les anciens liens vers votre profil ne fonctionneront plus.';
  }

  @override
  String get chooseFromLibrary => 'Choisir dans la galerie';

  @override
  String get coverPhoto => 'Photo de couverture';

  @override
  String get coverPhotoSheetHint =>
      'Affichée en haut de votre profil, derrière votre photo. Les photos larges conviennent le mieux, environ 3 pour 1.';

  @override
  String get coverRemoved => 'Couverture supprimée';

  @override
  String get day => 'Jour';

  @override
  String get month => 'Mois';

  @override
  String get displayName => 'Nom affiché';

  @override
  String displayNameHelper(String username) {
    return 'Affiché avec vos messages. Votre nom d’utilisateur reste @$username.';
  }

  @override
  String get emailPasswordInAccount => 'E-mail, mot de passe et connexion';

  @override
  String get featureATopic => 'Mettre un sujet en avant';

  @override
  String get featureATopicHint =>
      'Épinglez l’un de vos sujets en haut de votre profil.';

  @override
  String get featuredTopicChanged => 'Sujet mis en avant modifié';

  @override
  String get featuredTopicNone =>
      'Aucun. Épinglez l’un de vos sujets sur votre profil.';

  @override
  String get featuredTopicRemoved => 'Sujet mis en avant retiré';

  @override
  String get featuredTopicRules =>
      'Les messages et les sujets des catégories privées ne peuvent pas être mis en avant.';

  @override
  String get fieldManagedBySignIn =>
      'Ce forum le gère via sa propre connexion. Modifiez-le là-bas.';

  @override
  String get flair => 'Emblème';

  @override
  String flairChangedTo(String group) {
    return 'Emblème modifié : $group';
  }

  @override
  String get flairRemoved => 'Emblème retiré';

  @override
  String get flairSheetHint =>
      'Un petit emblème sur votre photo, issu d’un groupe dont vous êtes membre.';

  @override
  String forumPictureN(int number) {
    return 'Image du forum $number';
  }

  @override
  String forumQuestionNeedsAnswer(String question) {
    return '$question attend une réponse';
  }

  @override
  String get forumQuestionRequired =>
      'Ce forum demande à tout le monde d’y répondre';

  @override
  String get forumQuestionSetByStaff => 'Défini par l’équipe du forum';

  @override
  String get forumQuestionsIntro =>
      'Questions de ce forum. * signifie obligatoire.';

  @override
  String get forumQuestionsNoneAnswered => 'Pas encore de réponse';

  @override
  String get fromThisForum => 'De ce forum';

  @override
  String get hideMyProfile => 'Masquer mon profil public';

  @override
  String get hideMyProfileExplanation =>
      'Les autres ne voient que votre nom, votre photo et vos messages';

  @override
  String get letterAvatar => 'Initiale';

  @override
  String get moreAboutYou => 'Informations complémentaires';

  @override
  String namesAndMore(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count autres',
      one: '1 autre',
    );
    return '$names et $_temp0';
  }

  @override
  String get newUsername => 'Nouveau nom d’utilisateur';

  @override
  String get noFlair => 'Aucun emblème';

  @override
  String noGravatarFound(String service) {
    return '$service n’a aucune image pour votre adresse e-mail';
  }

  @override
  String get noTitle => 'Aucun titre';

  @override
  String get noTopicsMatch => 'Aucun de vos sujets ne correspond';

  @override
  String get noTopicsToFeature => 'Vous n’avez encore créé aucun sujet';

  @override
  String get notSet => 'Non défini';

  @override
  String get orUse => 'Ou utiliser';

  @override
  String get pictureManagedBySignIn =>
      'Ce forum définit votre photo via sa propre connexion';

  @override
  String get primaryGroup => 'Groupe principal';

  @override
  String primaryGroupChangedTo(String group) {
    return 'Groupe principal modifié : $group';
  }

  @override
  String get primaryGroupRemoved => 'Groupe principal retiré';

  @override
  String get primaryGroupSheetHint =>
      'Votre groupe principal, affiché sur votre carte utilisateur.';

  @override
  String get profileLoadFailed => 'Impossible de charger votre profil';

  @override
  String get profileNowHidden => 'Votre profil est masqué';

  @override
  String get profileNowPublic => 'Votre profil est public';

  @override
  String get profilePicture => 'Photo de profil';

  @override
  String get profilePictureChanged => 'Photo de profil modifiée';

  @override
  String get profileSaveFailed => 'Impossible d’enregistrer. Réessayez.';

  @override
  String get profileSectionNameAndAbout => 'Nom et présentation';

  @override
  String get profileSectionNextToName => 'À côté de votre nom';

  @override
  String get profileSectionOnProfile => 'Sur votre profil';

  @override
  String get profileSectionPrivacyAndTime => 'Confidentialité et heure';

  @override
  String get removeCardBackground => 'Retirer l’arrière-plan de la carte';

  @override
  String get removeCover => 'Retirer la couverture';

  @override
  String get removeFeaturedTopic => 'Retirer le sujet mis en avant';

  @override
  String get searchTimezones => 'Rechercher un fuseau horaire';

  @override
  String get searchYourTopics => 'Rechercher dans vos sujets';

  @override
  String get seeProfileAsOthersDo =>
      'Voir votre profil comme les autres le voient';

  @override
  String get timezone => 'Fuseau horaire';

  @override
  String timezoneChangedTo(String zone) {
    return 'Fuseau horaire modifié : $zone';
  }

  @override
  String timezoneWithTime(String zone, String time) {
    return '$zone · $time actuellement';
  }

  @override
  String timezonesMatchingPhone(String offset) {
    return 'Correspond à l’horloge de ce téléphone ($offset)';
  }

  @override
  String titleChangedTo(String title) {
    return 'Titre modifié : $title';
  }

  @override
  String get titleFromBadge => 'Badge';

  @override
  String titleFromBadgeEarned(String date) {
    return 'Badge · obtenu le $date';
  }

  @override
  String titleFromGroup(String group) {
    return 'Groupe $group';
  }

  @override
  String get titleGrantedByStaff => 'Attribué par l’équipe du forum';

  @override
  String get titleRemoved => 'Titre retiré';

  @override
  String get titleSheetHint =>
      'Affiché après votre nom sur votre profil et vos messages.';

  @override
  String get username => 'Nom d’utilisateur';

  @override
  String get usernameAvailable => 'Disponible';

  @override
  String usernameChanged(String username) {
    return 'Votre nom d’utilisateur est désormais @$username';
  }

  @override
  String get usernameLockedExplanation =>
      'Ce forum ne permet de changer de nom d’utilisateur que peu après l’inscription. Un modérateur peut le changer pour vous.';

  @override
  String get yourPhoto => 'Votre photo';

  @override
  String get chooseEmoji => 'Choisir un emoji';

  @override
  String get clearStatus => 'Effacer le statut';

  @override
  String get clearText => 'Effacer';

  @override
  String get inOneHour => 'Dans une heure';

  @override
  String get never => 'Jamais';

  @override
  String get pauseNotifications => 'Suspendre les notifications';

  @override
  String get pauseNotificationsUntilStatusClears =>
      'Jusqu’à la suppression de votre statut';

  @override
  String get pickATime => 'Choisir une heure';

  @override
  String get removeStatusAfter => 'Supprimer le statut';

  @override
  String get searchEmoji => 'Rechercher un emoji';

  @override
  String get setStatus => 'Définir le statut';

  @override
  String get setAStatus => 'Définir un statut';

  @override
  String get statusUpdated => 'Statut mis à jour';

  @override
  String get whatAreYouDoing => 'Que faites-vous ?';

  @override
  String cardPosted(String when) {
    return 'Dernier message $when';
  }

  @override
  String get change => 'Modifier';

  @override
  String get copyProfileLink => 'Copier le lien du profil';

  @override
  String get ignore => 'Ignorer';

  @override
  String memberOfGroup(String group) {
    return 'Membre de $group';
  }

  @override
  String get mute => 'Mettre en sourdine';

  @override
  String get unmute => 'Retirer la sourdine';

  @override
  String openProfileOf(String username) {
    return 'Ouvrir le profil de @$username';
  }

  @override
  String profileIsPrivate(String username) {
    return '$username garde son profil privé.';
  }

  @override
  String showOnlyTheirPostsHere(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'les $count messages',
      one: 'le message',
    );
    return 'Afficher uniquement $_temp0 de $name dans ce sujet';
  }

  @override
  String showOnlyYourPostsHere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vos $count messages',
      one: 'votre message',
    );
    return 'Afficher uniquement $_temp0 dans ce sujet';
  }

  @override
  String userIgnoredFor4Months(String username) {
    return 'Vous ignorez @$username pendant 4 mois';
  }

  @override
  String userMuted(String username) {
    return '@$username mis en sourdine';
  }

  @override
  String userUnmuted(String username) {
    return '@$username n’est plus en sourdine';
  }

  @override
  String get youParenthetical => '(vous)';

  @override
  String get topicStatusClosedHelp =>
      'Ce sujet est fermé ; il n\'accepte plus de nouvelles réponses';

  @override
  String get topicStatusArchivedHelp =>
      'Ce sujet est archivé ; il est figé et ne peut plus être modifié';

  @override
  String get topicStatusClosedArchivedHelp =>
      'Ce sujet est fermé et archivé ; il n\'accepte plus de nouvelles réponses et ne peut plus être modifié';

  @override
  String get topicStatusPinnedTitle => 'Épinglé';

  @override
  String get topicStatusPinnedHelp =>
      'Ce sujet est épinglé pour vous ; il s\'affichera en haut de sa catégorie';

  @override
  String get topicStatusPinnedGloballyTitle => 'Épinglé globalement';

  @override
  String get topicStatusPinnedGloballyHelp =>
      'Ce sujet est épinglé globalement ; il apparaîtra en premier dans la liste des derniers sujets et dans sa catégorie';

  @override
  String get topicStatusUnpinnedTitle => 'Désépinglé';

  @override
  String get topicStatusUnpinnedHelp =>
      'Ce sujet est désépinglé pour vous ; il sera affiché dans l\'ordre par défaut';

  @override
  String get topicStatusUnlistedHelp =>
      'Ce sujet n\'apparaît plus dans la liste des sujets et sera seulement accessible via un lien direct.';

  @override
  String get topicStatusWarningHelp => 'Ceci est un avertissement officiel.';

  @override
  String get notificationReasonWatchingTag =>
      'Vous recevrez des notifications car vous surveillez une étiquette de ce sujet.';

  @override
  String get notificationReasonWatchingCategory =>
      'Vous recevrez des notifications car vous surveillez cette catégorie.';

  @override
  String get notificationReasonWatchingAuto =>
      'Vous recevrez des notifications car vous avez commencé à surveiller ce sujet automatiquement.';

  @override
  String get notificationReasonWatching =>
      'Vous recevrez des notifications car vous surveillez ce sujet.';

  @override
  String get notificationReasonWatchingCreated =>
      'Vous recevrez des notifications car vous avez créé ce sujet.';

  @override
  String get notificationReasonTrackingCategory =>
      'Vous verrez un compteur de nouvelles réponses car vous suivez cette catégorie.';

  @override
  String get notificationReasonTrackingReplied =>
      'Vous verrez un compteur de nouvelles réponses car vous avez répondu dans ce sujet.';

  @override
  String get notificationReasonTracking =>
      'Vous verrez un compteur de nouvelles réponses car vous suivez ce sujet.';

  @override
  String get notificationReasonTrackingRead =>
      'Vous verrez un nombre de nouvelles réponses car vous avez lu ce sujet.';

  @override
  String get notificationReasonNormal =>
      'Vous recevrez une notification lorsque quelqu\'un vous mentionnera ou vous répondra.';

  @override
  String get notificationReasonMutedCategory =>
      'Vous ignorez toutes les notifications de cette catégorie.';

  @override
  String get notificationReasonMuted =>
      'Vous ignorez toutes les notifications de ce sujet.';

  @override
  String get notificationLevelWatching => 'Surveiller';

  @override
  String get notificationLevelWatchingFirstPost =>
      'Surveiller les nouveaux sujets';

  @override
  String get notificationLevelTracking => 'Suivre';

  @override
  String get notificationLevelNormal => 'Normal';

  @override
  String get notificationLevelMuted => 'En sourdine';

  @override
  String get topicWatchingDescription =>
      'Vous recevrez une notification pour chaque nouvelle réponse dans ce sujet, et le nombre de nouvelles réponses sera affiché.';

  @override
  String get topicTrackingDescription =>
      'Le nombre de nouvelles réponses apparaîtra pour ce sujet. Vous recevrez une notification si quelqu\'un vous mentionne ou vous répond.';

  @override
  String get topicNormalDescription =>
      'Vous recevrez une notification lorsque quelqu\'un vous mentionnera ou vous répondra.';

  @override
  String get topicMutedDescription =>
      'Vous ne recevrez aucune notification concernant ce sujet et il n\'apparaîtra pas sur la page des sujets récents.';

  @override
  String get messageWatchingDescription =>
      'Vous recevrez une notification pour chaque nouvelle réponse dans ce message, et le nombre de nouvelles réponses sera affiché.';

  @override
  String get messageTrackingDescription =>
      'Le nombre de nouvelles réponses apparaîtra pour ce message. Vous recevrez une notification si quelqu\'un vous mentionne ou vous répond.';

  @override
  String get messageNormalDescription =>
      'Vous recevrez une notification lorsque quelqu\'un vous mentionnera ou vous répondra.';

  @override
  String get messageMutedDescription =>
      'Vous ne recevrez aucune notification concernant ce message.';

  @override
  String get categoryWatchingDescription =>
      'Vous surveillerez automatiquement tous les sujets de cette catégorie. Vous recevrez une notification pour tous les nouveaux messages de chaque sujet, et le nombre de nouvelles réponses sera affiché.';

  @override
  String get categoryWatchingFirstPostDescription =>
      'Vous recevrez une notification concernant les nouveaux sujets dans cette catégorie, mais pas pour les réponses aux sujets.';

  @override
  String get categoryTrackingDescription =>
      'Vous suivrez automatiquement tous les sujets dans cette catégorie. Vous recevrez une notification lorsque quelqu\'un vous mentionnera ou vous répondra, et le nombre de nouvelles réponses sera affiché.';

  @override
  String get categoryNormalDescription =>
      'Vous recevrez une notification lorsque quelqu\'un vous mentionnera ou vous répondra.';

  @override
  String get categoryMutedDescription =>
      'Vous ne recevrez aucune notification concernant les nouveaux sujets dans cette catégorie et ces sujets n\'apparaîtront pas sur la page des sujets récents.';

  @override
  String get tagWatchingDescription =>
      'Vous surveillerez automatiquement tous les sujets marqués par cette étiquette. Vous recevrez des notifications pour tous les nouveaux messages et sujets, et les nombres de messages non lus et nouveaux apparaîtront à côté du sujet.';

  @override
  String get tagWatchingFirstPostDescription =>
      'Vous recevrez une notification concernant les nouveaux sujets avec cette étiquette, mais pas pour les réponses aux sujets.';

  @override
  String get tagTrackingDescription =>
      'Vous suivrez automatiquement tous les sujets ayant cette étiquette. Les nombres de messages non lus et nouveaux apparaîtront à côté du sujet.';

  @override
  String get tagNormalDescription =>
      'Vous recevrez une notification lorsque quelqu\'un vous mentionnera ou vous répondra.';

  @override
  String get tagMutedDescription =>
      'Vous ne recevrez aucune notification concernant les nouveaux sujets ayant cette étiquette et ces sujets n\'apparaîtront pas sur votre page des sujets non lus.';

  @override
  String topicTimerAutoOpen(String timeLeft) {
    return 'Ce sujet sera automatiquement ouvert $timeLeft.';
  }

  @override
  String topicTimerAutoClose(String timeLeft) {
    return 'Ce sujet sera automatiquement fermé $timeLeft.';
  }

  @override
  String topicTimerAutoPublish(String categoryName, String timeLeft) {
    return 'Ce sujet sera publié dans #$categoryName $timeLeft.';
  }

  @override
  String topicTimerAutoCloseAfterLastPost(String duration) {
    return 'Ce sujet sera fermé $duration après la dernière réponse.';
  }

  @override
  String topicTimerAutoDeleteAfterLastPost(String duration) {
    return 'Ce sujet sera supprimé $duration après la dernière réponse.';
  }

  @override
  String topicTimerAutoDelete(String timeLeft) {
    return 'Ce sujet sera automatiquement supprimé $timeLeft.';
  }

  @override
  String topicTimerAutoBump(String timeLeft) {
    return 'Ce sujet sera automatiquement remonté $timeLeft.';
  }

  @override
  String topicTimerAutoDeleteReplies(String duration) {
    return 'Les réponses à ce sujet sont automatiquement supprimées après $duration.';
  }

  @override
  String slowModeNotice(String duration) {
    return 'Veuillez attendre $duration entre vos messages dans ce sujet.';
  }

  @override
  String get closeTopic => 'Fermer le sujet';

  @override
  String get openTopic => 'Ouvrir le sujet';

  @override
  String get pinTopic => 'Épingler le sujet';

  @override
  String get unpinTopic => 'Désépingler le sujet';

  @override
  String get archiveTopic => 'Archiver le sujet';

  @override
  String get unarchiveTopic => 'Désarchiver le sujet';

  @override
  String get unlistTopic => 'Rendre le sujet invisible';

  @override
  String get listTopic => 'Lister le sujet';

  @override
  String get permanentlyDelete => 'Supprimer définitivement';

  @override
  String get permanentlyDeleteTopicConfirmation =>
      'Cette action est irréversible. Ce sujet sera définitivement supprimé de la base de données.';

  @override
  String get deleteTopicConfirmYes => 'Oui, supprimer ce sujet';

  @override
  String get deleteTopicConfirmNo => 'Non, conserver ce sujet';

  @override
  String get topicPinned => 'Sujet épinglé';

  @override
  String get topicUnpinned => 'Sujet désépinglé';

  @override
  String get topicArchived => 'Sujet archivé';

  @override
  String get topicUnarchived => 'Sujet désarchivé';

  @override
  String get topicUnlisted => 'Sujet rendu invisible';

  @override
  String get topicListed => 'Sujet listé';

  @override
  String get topicRecovered => 'Suppression du sujet annulée';

  @override
  String topicActionFailed(String error) {
    return 'Impossible de modifier le sujet : $error';
  }

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count heures',
      one: '1 heure',
    );
    return '$_temp0';
  }

  @override
  String durationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String timeLeftMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dans $count minutes',
      one: 'dans 1 minute',
    );
    return '$_temp0';
  }

  @override
  String timeLeftHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dans $count heures',
      one: 'dans 1 heure',
    );
    return '$_temp0';
  }

  @override
  String timeLeftDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dans $count jours',
      one: 'dans 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get topicStatusDeletedHelp =>
      'Ce sujet est supprimé et masqué aux autres utilisateurs';

  @override
  String get flagAction => 'Signaler';

  @override
  String get flagPost => 'Signaler ce message';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get suspendUser => 'Suspendre l\'utilisateur';

  @override
  String get unsuspend => 'Annuler la suspension';

  @override
  String get suspendUntil => 'Suspendre l\'utilisateur jusqu\'à';

  @override
  String get suspendForever => 'Suspendre pour toujours';

  @override
  String failedToSuspendUser(String error) {
    return 'Une erreur s\'est produite lors de la suspension de cet utilisateur: $error';
  }

  @override
  String failedToUnsuspendUser(String error) {
    return 'Une erreur s\'est produite lors de la réactivation de cet utilisateur: $error';
  }

  @override
  String get suspendReasonNotListening =>
      'N\'écoute pas les remarques des responsables';

  @override
  String get suspendReasonStaffTime =>
      'A fait perdre un temps excessif aux responsables';

  @override
  String get suspendReasonCombative => 'Trop belliqueux(se)';

  @override
  String get suspendReasonWrongPlace => 'Au mauvais endroit';

  @override
  String get suspendReasonNoPurpose =>
      'Aucun but constructif à ses actions autre que de créer une dissidence au sein de la communauté';

  @override
  String get suspendReasonCustom => 'Personnalisé…';

  @override
  String get suspendReasonQuestion =>
      'Pourquoi suspendez-vous cet utilisateur ? Ce texte sera affiché à l\'utilisateur quand il essaiera de se connecter. Tâchez d\'être concis(e).';

  @override
  String get closedLabel => 'Fermé';

  @override
  String get flaggingPost => 'Signalement du message…';

  @override
  String setSuspensionFor(String username) {
    return 'Combien de temps $username doit-il être suspendu ?';
  }

  @override
  String get pleaseSelectSuspensionEndDate =>
      'Choisissez la fin de la suspension';

  @override
  String get suspendingUser => 'Suspension de l\'utilisateur…';

  @override
  String get unsuspendingUser => 'Annulation de la suspension…';

  @override
  String get userSuspended => 'Utilisateur suspendu';

  @override
  String get userUnsuspended => 'Suspension annulée';

  @override
  String unsuspendUserConfirmation(String username) {
    return 'Annuler la suspension de $username ? Cette personne pourra de nouveau se connecter.';
  }

  @override
  String get noCategoriesToDisplay => 'Aucune catégorie à afficher.';

  @override
  String get noPermissionToViewCategory =>
      'Vous n\'avez pas la permission de voir les sujets de cette catégorie.';

  @override
  String get featureTopicTitle => 'Mettre ce sujet en évidence';

  @override
  String get pinTopicMenu => 'Épingler le sujet…';

  @override
  String pinInCategoryUntil(String category) {
    return 'Faire apparaître ce sujet en haut de la catégorie $category jusqu\'à';
  }

  @override
  String get pinGloballyUntil =>
      'Faire apparaître ce sujet en haut de toutes les listes de sujets jusqu\'à';

  @override
  String get pinNote =>
      'Chaque utilisateur pourra désépingler le sujet individuellement (pour lui seulement).';

  @override
  String get pinUntil => 'Épingler jusqu\'au';

  @override
  String get pinDateRequired => 'Une date est requise pour épingler ce sujet.';

  @override
  String get pinTopicGlobally => 'Épingler le sujet globalement';

  @override
  String get flagThanks =>
      'Merci d\'avoir fait preuve de civisme dans notre communauté !';

  @override
  String get flagReviewProcess =>
      'Tous les signalements sont reçus par les modérateurs et seront examinés dès que possible.';

  @override
  String get flagCant =>
      'Nous sommes désolés, vous ne pouvez pas signaler ce message pour le moment.';

  @override
  String get flagSendMessage => 'Message';

  @override
  String get flagMessageForUser => 'Message pour l\'utilisateur';

  @override
  String get flagMessageForModerators => 'Message pour les modérateurs';

  @override
  String get flagPlaceholderNotifyUser =>
      'Soyez précis(e), constructif(ve) et faites toujours preuve de respect.';

  @override
  String get flagPlaceholderNotifyModerators =>
      'Dites-nous ce qui vous dérange spécifiquement, et fournissez des exemples et des liens pertinents si possible.';

  @override
  String get flagPlaceholderIllegal =>
      'Dites-nous précisément pourquoi vous pensez que ce contenu est illégal, et fournissez des liens et des exemples pertinents dans la mesure du possible.';

  @override
  String get flagConfirmIllegal =>
      'Ce que j\'ai écrit ci-dessus est exact et complet.';

  @override
  String flagMessageAtLeast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'saisissez au moins $count caractères',
      one: 'saisissez au moins $count caractère',
    );
    return '$_temp0';
  }

  @override
  String get flagMessageSent => 'Votre message a été envoyé.';

  @override
  String get mergeTopicError =>
      'Une erreur s\'est produite lors du déplacement des messages dans ce sujet.';

  @override
  String get topicTitlePlaceholder =>
      'Pouvez-vous résumer le sujet en une courte phrase ?';

  @override
  String get topicMoved => 'Sujet déplacé';

  @override
  String get topicMerged => 'Sujet fusionné';

  @override
  String get mergeTopicExplanation =>
      'Tous les messages de ce sujet seront déplacés dans le sujet choisi. Impossible d\'annuler depuis l\'application.';

  @override
  String get destinationTopicId => 'ID du sujet de destination';

  @override
  String get topicAuthorUnknown => 'Inconnu';

  @override
  String get noHotTopics => 'Il n\'y a aucun sujet populaire.';

  @override
  String get signInToViewNewTopics =>
      'Connectez-vous pour voir les nouveaux sujets';

  @override
  String get newTopicsSignInMessage =>
      'Les nouveaux sujets montrent ce qui a été créé depuis votre dernière visite.';

  @override
  String get topPeriodAllTime => 'Depuis toujours';

  @override
  String get topPeriodYear => 'Année';

  @override
  String get topPeriodQuarter => 'Trimestre';

  @override
  String get topPeriodMonth => 'Mois';

  @override
  String get topPeriodWeek => 'Semaine';

  @override
  String get topPeriodToday => 'Aujourd\'hui';

  @override
  String noTopTopicsForPeriod(String period) {
    String _temp0 = intl.Intl.selectLogic(
      period,
      {
        'all': 'Il n\'y a pas de meilleurs sujets depuis toujours.',
        'yearly': 'Il n\'y a pas de meilleurs sujets cette année.',
        'quarterly': 'Il n\'y a pas de meilleurs sujets ce trimestre.',
        'monthly': 'Il n\'y a pas de meilleurs sujets ce mois-ci.',
        'weekly': 'Il n\'y a pas de meilleurs sujets cette semaine.',
        'daily': 'Il n\'y a pas de meilleurs sujets aujourd\'hui.',
        'other': 'Il n\'y a pas de meilleurs sujets.',
      },
    );
    return '$_temp0';
  }

  @override
  String get connectionTimedOutSiteUnreachable =>
      'Délai de connexion dépassé. Le site peut être hors ligne ou inaccessible.';

  @override
  String get failedToMarkNotificationsRead =>
      'Impossible de marquer les notifications comme lues';

  @override
  String get forumNameFallback => 'Forum';

  @override
  String get noForumDescription => 'Aucune description disponible.';

  @override
  String get dismissAllNotifications => 'Tout vu';

  @override
  String get notificationPostIdMissing =>
      'L\'identifiant du message est manquant. Impossible d\'accéder au message.';

  @override
  String get notificationTopicIdMissingForPost =>
      'L\'identifiant du sujet est manquant. Impossible d\'accéder au message.';

  @override
  String get notificationTopicIdMissing =>
      'L\'identifiant du sujet est manquant. Impossible d\'ouvrir le sujet.';

  @override
  String get notificationUsernameMissing =>
      'Le nom d\'utilisateur est manquant. Impossible d\'ouvrir le profil.';

  @override
  String get notificationChannelIdMissing =>
      'L\'identifiant du canal est manquant. Impossible d\'ouvrir la discussion.';

  @override
  String get notificationGroupNameMissingForInbox =>
      'Le nom du groupe est manquant. Impossible d\'ouvrir la boîte de réception.';

  @override
  String get notificationGroupNameMissing =>
      'Le nom du groupe est manquant. Impossible d\'ouvrir le groupe.';

  @override
  String get notificationNoActionUrl =>
      'Aucune URL d\'action n\'est disponible pour ce type de notification.';

  @override
  String get notificationBadgeUnavailable =>
      'Les détails du badge ne sont pas disponibles.';

  @override
  String get notificationBadgeLoadFailed => 'Impossible de charger ce badge.';

  @override
  String get personalMessageTitleFallback => 'Message direct';

  @override
  String get topicTitleFallback => 'Sujet';

  @override
  String get signInToViewNotifications =>
      'Connectez-vous pour voir les notifications';

  @override
  String get youNeedToBeSignedInToViewNotifications =>
      'Vous devez être connecté pour voir vos notifications.';

  @override
  String get noUnreadNotifications => 'Aucune notification non lue';

  @override
  String get noNotificationsYet => 'Aucune notification pour l\'instant';

  @override
  String get newNotificationFallbackBody => 'Nouvelle notification';

  @override
  String get unableToOpenNotification => 'Impossible d\'ouvrir la notification';

  @override
  String get notificationMissingSiteInfo =>
      'Informations sur le site manquantes (site_id).';

  @override
  String get notificationInvalidSiteInfo =>
      'Informations sur le site non valides (site_id).';

  @override
  String get notificationMissingPostInfo =>
      'Informations sur le message manquantes (content_id).';

  @override
  String get notificationMissingMessageInfo =>
      'Informations sur le message direct manquantes (conversation_id).';

  @override
  String get notificationMissingUserInfo =>
      'Informations sur l\'utilisateur manquantes (sender_id).';

  @override
  String get notificationUnsupportedType =>
      'Type de notification non pris en charge.';

  @override
  String get notificationForumNotFound => 'Forum introuvable pour ce site.';

  @override
  String get notificationForumOpenFailed =>
      'Impossible d\'initialiser le forum.';

  @override
  String get notificationMissingTopicInfo =>
      'Informations sur le sujet manquantes (topic_id).';

  @override
  String get failedToLoadTags => 'Impossible de charger les étiquettes.';

  @override
  String get searchTagsHint => 'Rechercher des étiquettes…';

  @override
  String get tagsSortedByCountTooltip =>
      'Triées par nombre de sujets — touchez pour passer à A→Z';

  @override
  String get tagsSortedAlphabeticallyTooltip =>
      'Triées par ordre alphabétique — touchez pour trier par popularité';

  @override
  String get noTagsYet => 'Aucune étiquette sur ce forum pour l\'instant.';

  @override
  String get tagNotificationLevelTooltip => 'Niveau de notification';

  @override
  String get tagTopicsLoadFailed => 'Échec du chargement';

  @override
  String searchFailedWithError(String error) {
    return 'Recherche échouée : $error';
  }

  @override
  String get searchFiltersButtonTooltip => 'Filtres';

  @override
  String get searchFilterStatusSection => 'Statut';

  @override
  String get searchFilterMyActivitySection => 'Mon activité';

  @override
  String get searchFilterMatchTypeSection => 'Type de correspondance';

  @override
  String get searchTagsFilterHelper =>
      'Séparées par des espaces ou des virgules. Chaque étiquette est requise.';

  @override
  String get searchSortBy => 'Trier par';

  @override
  String get searchStatusOpen => 'Ouvert';

  @override
  String get searchStatusArchived => 'Archivé';

  @override
  String get searchStatusNoReplies => 'Sans réponse';

  @override
  String get searchStatusPublicOnly => 'Publics uniquement';

  @override
  String get searchStatusUnsolved => 'Non résolu';

  @override
  String get searchInBookmarked => 'Dans mes signets';

  @override
  String get searchInMyMessages => 'Dans mes messages directs';

  @override
  String get searchInLiked => 'Que j\'ai aimés';

  @override
  String get searchInPosted => 'Auxquels j\'ai participé';

  @override
  String get searchInWatching => 'Que je surveille';

  @override
  String get searchInTracking => 'Que je suis';

  @override
  String get searchInSeen => 'Que j\'ai lus';

  @override
  String get searchInUnseen => 'Que je n\'ai pas lus';

  @override
  String get searchSortLatestPost => 'Dernier message';

  @override
  String get searchSortMostLiked => 'Plus aimé';

  @override
  String get searchSortMostViewed => 'Plus vu';

  @override
  String get searchSortLatestTopic => 'Dernier sujet';

  @override
  String get searchFieldHint => 'Recherche…';

  @override
  String get bookmarksUnavailable => 'Les signets ne sont pas disponibles';

  @override
  String get failedToLoadBookmarks => 'Impossible de charger les signets';

  @override
  String get failedToRemoveBookmark => 'Impossible de supprimer le signet';

  @override
  String get failedToUpdateBookmark => 'Impossible de mettre à jour le signet';

  @override
  String get bookmarkWithReminder => 'Signet avec rappel';

  @override
  String get noReminder => 'Pas de rappel';

  @override
  String get failedToLoadDrafts => 'Impossible de charger les brouillons.';

  @override
  String get failedToDiscardDraft => 'Impossible de supprimer le brouillon';

  @override
  String get messagesLoadFailed => 'Impossible de charger les messages';

  @override
  String get moreMessagesLoadFailed => 'Impossible de charger plus de messages';

  @override
  String get messageUnknownUser => 'Inconnu';

  @override
  String get unknownErrorFallback => 'Erreur inconnue';

  @override
  String get chatComposerDefaultHint => 'Écrivez un message…';

  @override
  String chatChannelNumbered(Object id) {
    return 'canal $id';
  }

  @override
  String get chatSendFailed => 'Impossible d\'envoyer le message.';

  @override
  String get chatEditFailed => 'Impossible de modifier le message.';

  @override
  String get chatDeleteFailed => 'Impossible de supprimer le message.';

  @override
  String get chatReactionsUnsupported =>
      'Les réactions ne sont pas prises en charge ici.';

  @override
  String get chatReactionFailed => 'Impossible de mettre à jour la réaction.';

  @override
  String get attachmentDefaultName => 'Pièce jointe';

  @override
  String get fileTypeAudio => 'Audio';

  @override
  String get fileTypeText => 'Texte';

  @override
  String get fileTypeArchive => 'Archive';

  @override
  String get fileTypeFile => 'Fichier';

  @override
  String downloadFailedHttpStatus(String status) {
    return 'Échec du téléchargement du fichier : HTTP $status';
  }

  @override
  String get downloadedFileEmpty => 'Le fichier téléchargé est vide';

  @override
  String downloadFileFailed(String error) {
    return 'Échec du téléchargement du fichier : $error';
  }

  @override
  String attachmentTypeNotAllowed(String extension, String allowed) {
    return 'Le type de fichier .$extension n\'est pas autorisé. Types autorisés : $allowed';
  }

  @override
  String attachmentFileTooLarge(String size, String max) {
    return 'La taille du fichier ($size) dépasse le maximum de $max';
  }

  @override
  String get attachmentValidationFailed =>
      'Échec de la vérification du fichier';

  @override
  String get uploadMissingReference =>
      'Le téléversement a réussi, mais le serveur n\'a renvoyé aucune référence pour le fichier.';

  @override
  String get imageFileNotFound => 'Fichier image introuvable';

  @override
  String get failedToLoadVideo => 'Impossible de charger la vidéo';

  @override
  String get userInfoLoadFailed =>
      'Impossible de charger les informations de l’utilisateur.';

  @override
  String userInfoLoadFailedWithError(String error) {
    return 'Impossible de charger les informations de l’utilisateur : $error';
  }

  @override
  String get profileMenuIgnoreUser => 'Ignorer l\'utilisateur';

  @override
  String get profileMenuUnignoreUser => 'Ne plus ignorer l\'utilisateur';

  @override
  String get ignoreStateUpdateFailed =>
      'Impossible de modifier l’état « ignoré »';

  @override
  String profileNowIgnoringUser(String username) {
    return 'Vous ignorez @$username. Ses messages seront masqués.';
  }

  @override
  String get profileIgnoreToggleFailed =>
      'Impossible de modifier l’option Ignorer.';

  @override
  String get profileStatsLoadFailed =>
      'Impossible de charger les statistiques.';

  @override
  String get profileFollowFailed => 'Impossible de suivre';

  @override
  String get profileUnfollowFailed => 'Impossible de ne plus suivre';

  @override
  String get profileChatOpenFailed =>
      'Impossible d’ouvrir une discussion avec cet utilisateur.';

  @override
  String summaryLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count j’aime',
      one: '1 j’aime',
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
  String get directoryPeriodAllTime => 'Depuis toujours';

  @override
  String get directoryPeriodYear => 'Année';

  @override
  String get directoryPeriodQuarter => 'Trimestre';

  @override
  String get directoryPeriodMonth => 'Mois';

  @override
  String get directoryPeriodWeek => 'Semaine';

  @override
  String get directoryPeriodToday => 'Aujourd\'hui';

  @override
  String get directoryOrderReceived => 'Reçus';

  @override
  String get directoryOrderReplies => 'Réponses';

  @override
  String get directoryOrderTopics => 'Sujets';

  @override
  String get directoryOrderVisits => 'Visites';

  @override
  String get directoryLoadFailed => 'Impossible de charger l’annuaire.';

  @override
  String get directoryNoUsersMatch =>
      'Aucun utilisateur ne correspond à ce nom.';

  @override
  String get directoryNoUsersForPeriod =>
      'Aucun utilisateur trouvé pour cette période.';

  @override
  String get userSearchNoResults => 'Aucun utilisateur trouvé';

  @override
  String get userSearchTryDifferentUsername =>
      'Essayez avec un autre nom d’utilisateur';

  @override
  String get userSearchPromptTitle => 'Rechercher des utilisateurs';

  @override
  String get userSearchPromptHint =>
      'Saisissez un nom d’utilisateur pour trouver et inviter des utilisateurs';

  @override
  String get ignoredUsersUnignoreFailed => 'Impossible de ne plus ignorer.';

  @override
  String get ignoredUsersEmpty => 'Vous n’ignorez personne.';

  @override
  String get ignoredUsersEmptyHint =>
      'Ouvrez un profil utilisateur et choisissez « Ignorer l\'utilisateur » dans le menu pour masquer ses messages et ses notifications.';

  @override
  String get badgesLoadFailed => 'Impossible de charger les badges.';

  @override
  String get badgesEmpty => 'Aucun badge sur ce forum.';

  @override
  String get badgeTierGold => 'Or';

  @override
  String get badgeTierSilver => 'Argent';

  @override
  String get badgeTierBronze => 'Bronze';

  @override
  String badgeEarnedAgo(String time) {
    return 'Obtenu $time';
  }

  @override
  String badgeEarnedByUsers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Obtenu par $formatted utilisateurs',
      one: 'Obtenu par $formatted utilisateur',
    );
    return '$_temp0';
  }

  @override
  String get trustLevelNameNewUser => 'Nouvel utilisateur';

  @override
  String get trustLevelNameBasic => 'Utilisateur de base';

  @override
  String get trustLevelNameMember => 'Membre';

  @override
  String get trustLevelNameRegular => 'Habitué';

  @override
  String get trustLevelNameLeader => 'Meneur';

  @override
  String get trustLevelSummary0 =>
      'Vient d’arriver. Peut lire et publier, avec des limites sur les liens, les images et les messages directs.';

  @override
  String get trustLevelSummary1 =>
      'Débloque les fonctions de publication essentielles : images et pièces jointes, plus de liens, signalement des messages.';

  @override
  String get trustLevelSummary2 =>
      'Peut envoyer des invitations, ignorer des utilisateurs et modifier ses propres messages plus longtemps.';

  @override
  String get trustLevelSummary3 =>
      'Peut changer la catégorie et le titre des sujets, créer des étiquettes, et ses signalements de spam ont plus de poids.';

  @override
  String get trustLevelSummary4 =>
      'Attribué par l’équipe. Peut modifier n’importe quel message et épingler, fermer, scinder ou fusionner des sujets.';

  @override
  String trustLevelRowTitle(int level, String name) {
    return 'TL$level · $name';
  }

  @override
  String get profileNoUserSpecified => 'Aucun utilisateur indiqué';

  @override
  String get userTopicsLoadFailed => 'Impossible de charger les sujets';

  @override
  String get userTopicsEmpty => 'Aucun sujet créé pour l’instant.';

  @override
  String get userRecentPostsLoadFailed =>
      'Impossible de charger les messages récents';

  @override
  String get activityUnknownTopic => 'Sujet inconnu';

  @override
  String groupJoinedSnack(String group) {
    return 'Vous avez rejoint $group';
  }

  @override
  String get groupJoinFailed => 'Impossible de rejoindre le groupe';

  @override
  String groupLeftSnack(String group) {
    return 'Vous avez quitté $group';
  }

  @override
  String get groupLeaveFailed => 'Impossible de quitter le groupe';

  @override
  String get groupMembershipRequestHint =>
      'Pourquoi voulez-vous rejoindre ce groupe ? Les propriétaires du groupe le verront avec votre demande.';

  @override
  String get groupMembershipReasonRequired =>
      'Une raison est requise pour demander à rejoindre le groupe';

  @override
  String get groupMembershipRequestSent =>
      'Demande envoyée — un propriétaire du groupe doit l’approuver';

  @override
  String get groupMembershipRequestFailed =>
      'Impossible d’envoyer la demande d’adhésion';

  @override
  String get groupMemberBadge => 'Membre';

  @override
  String get groupRequestPending => 'Demande en attente';

  @override
  String get groupJoining => 'Adhésion…';

  @override
  String get groupJoinButton => 'Rejoindre le groupe';

  @override
  String get groupsLoadFailed => 'Impossible de charger les groupes.';

  @override
  String get groupBuiltIn => 'Groupe intégré';

  @override
  String invitesPendingWithCount(int count) {
    return 'En attente ($count)';
  }

  @override
  String invitesExpiredWithCount(int count) {
    return 'Expirées ($count)';
  }

  @override
  String invitesRedeemedWithCount(int count) {
    return 'Invitations acceptées ($count)';
  }

  @override
  String get invitesLoadFailed => 'Impossible de charger les invitations.';

  @override
  String get inviteLinkCreateFailed =>
      'Impossible de créer le lien d’invitation';

  @override
  String get inviteEmailAddressLabel => 'Adresse e-mail';

  @override
  String get inviteEmailInvalid => 'Saisissez une adresse e-mail valide';

  @override
  String get inviteMessageOptionalLabel => 'Message (facultatif)';

  @override
  String get inviteSendFailed => 'Impossible d’envoyer l’invitation';

  @override
  String get revokeInviteLinkWarning =>
      'Le lien d’invitation ne fonctionnera plus.';

  @override
  String revokeInviteEmailWarning(String email) {
    return 'L’invitation envoyée à $email ne fonctionnera plus.';
  }

  @override
  String get inviteRevokeFailed => 'Impossible de révoquer l’invitation';

  @override
  String get inviteNoPermission => 'Vous n’avez pas l’autorisation d’inviter';

  @override
  String get invitesEmptyPending => 'Aucune invitation en attente';

  @override
  String get invitesEmptyExpired => 'Aucune invitation expirée';

  @override
  String get invitesEmptyRedeemed => 'Aucune invitation acceptée';

  @override
  String get invitesEmptyPendingHint =>
      'Créez un lien d’invitation pour faire venir des personnes sur le forum.';

  @override
  String get inviteLinkFallbackTitle => 'Lien d\'invitation';

  @override
  String inviteRedeemedOn(String date) {
    return 'Acceptée le $date';
  }

  @override
  String inviteRedemptions(int count, int max) {
    return '$count sur $max acceptées';
  }

  @override
  String get inviteEmailSent => 'E-mail envoyé';

  @override
  String get inviteEmailNotSent => 'E-mail non envoyé';

  @override
  String inviteExpiredOn(String date) {
    return 'Expirée le $date';
  }

  @override
  String get inviteRevokeTooltip => 'Révoquer l’invitation';

  @override
  String get reviewStatusPending => 'En attente';

  @override
  String get reviewStatusApproved => 'Acceptés';

  @override
  String get reviewStatusRejected => 'Rejetés';

  @override
  String get reviewStatusAll => 'Tout';

  @override
  String get reviewStatusIgnored => 'Signalement ignoré';

  @override
  String get reviewStatusDeleted => 'Sujet ou message supprimé';

  @override
  String get reviewQueueUnavailable =>
      'La file de modération n’est pas disponible sur ce forum.';

  @override
  String get reviewQueueLoadFailed =>
      'Impossible de charger la file de modération';

  @override
  String get reviewableChangedByOther =>
      'Cet élément a été modifié par un autre modérateur. Actualisation…';

  @override
  String get reviewActionFailed => 'Impossible d’effectuer l’action';

  @override
  String reviewActionDone(String action) {
    return '$action — terminé';
  }

  @override
  String get reviewRejectReasonHint => 'Pourquoi est-ce rejeté ?';

  @override
  String get reviewTypeFlaggedPost => 'Message signalé';

  @override
  String get reviewTypeQueuedPost => 'Message en file d\'attente';

  @override
  String get reviewTypeQueuedTopic => 'Sujet en file d\'attente';

  @override
  String get reviewTypeUser => 'Utilisateur';

  @override
  String get reviewTypePost => 'Message';

  @override
  String get reviewTypeChatMessage => 'Message de discussion marqué';

  @override
  String get reviewModeratorAccessRequired => 'Accès modérateur requis';

  @override
  String reviewableScore(String score) {
    return 'Score $score';
  }

  @override
  String get postRepliesLoadFailed => 'Impossible de charger les réponses.';

  @override
  String get postMakeWiki => 'Basculer en mode wiki';

  @override
  String get postRemoveWiki => 'Retirer le mode wiki';

  @override
  String get postBookmarkRemoveFailed => 'Impossible de supprimer le signet';

  @override
  String get postBookmarkFailed => 'Impossible de mettre un signet au message';

  @override
  String get postBookmarkReminderUpdateFailed =>
      'Impossible de mettre à jour le rappel';

  @override
  String get postBookmarkReminderSet => 'Rappel programmé';

  @override
  String get postBookmarkReminderCleared => 'Rappel effacé';

  @override
  String get solutionMarkFailed =>
      'Impossible de marquer la réponse comme solution';

  @override
  String get solutionUnmarkFailed =>
      'Impossible de retirer la marque de solution';

  @override
  String get postUnknownDate => 'Date inconnue';

  @override
  String get postBookmarkAction => 'Mettre un signet au message';

  @override
  String postReactionsSemanticsReacted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Vous avez réagi. $count réactions. Touchez pour modifier, appuyez longuement pour voir qui a réagi.',
      one:
          'Vous avez réagi. 1 réaction. Touchez pour modifier, appuyez longuement pour voir qui a réagi.',
    );
    return '$_temp0';
  }

  @override
  String postReactionsSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count réactions. Touchez pour réagir, appuyez longuement pour voir qui a réagi.',
      one:
          '1 réaction. Touchez pour réagir, appuyez longuement pour voir qui a réagi.',
    );
    return '$_temp0';
  }

  @override
  String get postLikeAction => 'Aimer le message';

  @override
  String get postUnlikeAction => 'Annuler le « J\'aime »';

  @override
  String get postVoteRemoveFailed =>
      'Impossible de retirer le vote (délai d\'annulation dépassé ?)';

  @override
  String get postVoteCastFailed => 'Impossible de voter';

  @override
  String get postUpvote => 'Voter pour';

  @override
  String get postDownvote => 'Voter contre';

  @override
  String get pollVoteFailed => 'Échec du vote. Veuillez réessayer.';

  @override
  String get pollRemoveVoteFailed =>
      'Impossible de retirer votre vote. Veuillez réessayer.';

  @override
  String get pollVotersLoadFailed => 'Impossible de charger les votants.';

  @override
  String get pollVotersNotVisible =>
      'Les votants de ce sondage ne sont pas visibles.';

  @override
  String solutionSolvedByInPost(String name, int postNumber) {
    return 'Résolu par $name dans le message #$postNumber';
  }

  @override
  String solutionMarkedBy(String name) {
    return 'marqué par $name';
  }

  @override
  String reactAgainInSeconds(int seconds) {
    return 'Vous pourrez réagir à ce message de nouveau dans ${seconds}s';
  }

  @override
  String get reactionUpdateFailed => 'Impossible de mettre à jour la réaction.';

  @override
  String get reactionsNotSupported =>
      'Les réactions ne sont pas prises en charge sur ce forum.';

  @override
  String get reactionsLoadFailed => 'Impossible de charger les réactions.';

  @override
  String viewProfileOfUser(String username) {
    return 'Voir le profil de $username';
  }

  @override
  String get failedToSavePost => 'Impossible d\'enregistrer le message';

  @override
  String failedToSavePostWithError(String error) {
    return 'Impossible d\'enregistrer le message : $error';
  }

  @override
  String get failedToRemoveAttachmentCheckPermissions =>
      'Impossible de supprimer la pièce jointe. Veuillez vérifier vos autorisations.';

  @override
  String get editPostTitle => 'Modifier le message';

  @override
  String get editYourPostHint => 'Modifiez votre message...';

  @override
  String get failedToPostReply => 'Échec de la publication de la réponse';

  @override
  String failedToPostReplyWithError(String error) {
    return 'Échec de la publication de la réponse : $error';
  }

  @override
  String get failedToCreateTopic => 'Impossible de créer le sujet';

  @override
  String get writeYourTopicTitle => 'Écrivez le titre de votre sujet...';

  @override
  String get writeYourTopicContent => 'Écrivez le contenu de votre sujet...';

  @override
  String get composerTitleHint => 'Écrivez votre titre...';

  @override
  String get composerContentHint => 'Écrivez votre contenu...';

  @override
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit) {
    return '$fileName : trop volumineux ($size) et impossible à redimensionner. La limite est de $limit.';
  }

  @override
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit) {
    return '$fileName redimensionné à $size$dimensions pour respecter la limite de $limit.';
  }

  @override
  String get composerAttachFileHint => 'Joindre un fichier à ce message';

  @override
  String get composerUploadImageHint => 'Téléverser une image dans ce message';

  @override
  String get composerFormattingHint => 'Ouvrir les options de mise en forme';

  @override
  String get whisperStaffOnly => 'Murmurer (responsables uniquement)';

  @override
  String get whisperOnStaffOnly => 'Murmure activé (responsables uniquement)';

  @override
  String get tagInputMaxReached => 'Nombre maximal d\'étiquettes atteint';

  @override
  String get tagInputAddTag => 'Ajouter une étiquette…';

  @override
  String get tagInputAddAnother => '+ étiquette';

  @override
  String get editHistoryUnavailable =>
      'L\'historique des modifications n\'est pas disponible sur ce forum.';

  @override
  String get editHistoryLoadFailed =>
      'Impossible de charger l\'historique des modifications.';

  @override
  String get previousRevision => 'Révision précédente';

  @override
  String get nextRevision => 'Révision suivante';

  @override
  String get notificationPrefsLoadFailed =>
      'Impossible de charger les préférences de notification.';

  @override
  String get notificationPrefsSaveFailed =>
      'Impossible d’enregistrer — vérifiez votre connexion';

  @override
  String get signInToManageNotificationPrefs =>
      'Connectez-vous pour gérer vos préférences de notification.';

  @override
  String get notificationSettingsPushSection => 'Push';

  @override
  String get notificationSettingsEmailSection => 'E-mail';

  @override
  String get emailWhenAwayTitle => 'E-mail en cas d’absence';

  @override
  String get emailLevelDescription =>
      'Envoyez-moi un e-mail lorsque je suis cité(e), lorsque je reçois une réponse, lorsque mon @username est mentionné ou lorsqu\'il y a une nouvelle activité dans les catégories, les étiquettes ou les sujets que je regarde';

  @override
  String get notificationPrefAlways => 'Toujours';

  @override
  String get notificationPrefOnlyWhenAway => 'Seulement en cas d\'absence';

  @override
  String get notificationPrefNever => 'Jamais';

  @override
  String get emailForMessagesTitle => 'E-mail pour les messages directs';

  @override
  String get emailMessagesLevelDescription =>
      'Envoyez-moi un e-mail lorsque je reçois un message privé';

  @override
  String get activitySummaryTitle => 'Résumé d\'activité';

  @override
  String get activitySummaryDescription =>
      'Lorsque je ne visite pas le site, m\'envoyer un e-mail avec un résumé des sujets et réponses populaires';

  @override
  String get activitySummaryFrequencyTitle => 'Fréquence du résumé d\'activité';

  @override
  String get activitySummaryDaily => 'Tous les jours';

  @override
  String get activitySummaryWeekly => 'Toutes les semaines';

  @override
  String get activitySummaryMonthly => 'Tous les mois';

  @override
  String get mailingListModeTitle => 'Liste de diffusion';

  @override
  String get mailingListModeDescription =>
      'M’envoyer chaque message par e-mail (désactive le résumé d\'activité). Déconseillé sur les forums très actifs.';

  @override
  String get likeNotificationFrequencyTitle =>
      'Envoyer une notification si un « J\'aime » est attribué';

  @override
  String get likeNotificationFirstTimeAndDaily =>
      'La première fois qu\'un message reçoit un « J\'aime » puis quotidiennement';

  @override
  String get likeNotificationFirstTime =>
      'La première fois qu\'un message reçoit un « J\'aime »';

  @override
  String get whenPostingTitle => 'Lors de la publication';

  @override
  String get whenPostingDescription =>
      'Ce qu’il advient d’un sujet auquel vous répondez';

  @override
  String get whenPostingWatchTopic => 'Surveiller le sujet';

  @override
  String get whenPostingTrackTopic => 'Suivre le sujet';

  @override
  String get whenPostingDoNothing => 'Ne rien faire';

  @override
  String get pauseNotificationsUntilTomorrow => 'Jusqu\'à demain';

  @override
  String get couldNotEnableDoNotDisturb =>
      'Impossible d’activer Ne pas déranger';

  @override
  String get couldNotTurnOffDoNotDisturb =>
      'Impossible de désactiver Ne pas déranger';

  @override
  String get passwordResetEmailSent =>
      'E-mail de réinitialisation du mot de passe envoyé.';

  @override
  String get couldNotSendResetEmail =>
      'Impossible d’envoyer l’e-mail de réinitialisation';

  @override
  String get accountRequestFailed => 'La requête a échoué.';

  @override
  String get forumUrlUnavailable => 'L’URL du forum n’est pas disponible.';

  @override
  String get couldNotOpenPreferencesPage =>
      'Impossible d’ouvrir la page des préférences.';

  @override
  String get couldNotOpenForumUrl => 'Impossible d’ouvrir l’URL du forum.';

  @override
  String get couldNotRequestEmailChange =>
      'Impossible de demander le changement d’adresse e-mail';

  @override
  String get newEmailLabel => 'Nouvelle adresse e-mail';

  @override
  String get enterAnEmailAddress => 'Saisissez une adresse e-mail';

  @override
  String get emailLooksInvalid => 'Cela ne ressemble pas à une adresse e-mail';

  @override
  String get emailNoSpaces => 'Pas d’espaces dans une adresse e-mail';

  @override
  String get allowNotificationsSheetTitle => 'Autoriser les notifications';

  @override
  String get notificationsGrantNoPayload =>
      'L’autorisation n’a renvoyé aucune réponse.';

  @override
  String get thisForumFallback => 'ce forum';

  @override
  String signInToDomain(String domain) {
    return 'Se connecter à $domain';
  }

  @override
  String get loginResultTitle => 'Résultat de la connexion';

  @override
  String get invalidAuthenticationCode => 'Code d\'authentification invalide';

  @override
  String get tfaVerificationError =>
      'Une erreur s’est produite lors de la vérification. Veuillez réessayer.';

  @override
  String get passwordFieldLabel => 'Mot de passe';

  @override
  String get somethingWentWrongTryAgain =>
      'Une erreur s’est produite. Veuillez réessayer.';

  @override
  String get unexpectedErrorTryAgain =>
      'Une erreur inattendue s’est produite. Veuillez réessayer.';

  @override
  String get errorNoInternetConnection =>
      'Pas de connexion Internet. Veuillez vérifier vos paramètres réseau.';

  @override
  String get errorRequestTimedOut => 'La requête a expiré. Veuillez réessayer.';

  @override
  String get errorServerTryLater =>
      'Une erreur serveur s’est produite. Veuillez réessayer plus tard.';

  @override
  String get errorInvalidCredentials =>
      'Nom d’utilisateur ou mot de passe invalide.';

  @override
  String get errorSessionExpired =>
      'Votre session a expiré. Veuillez vous reconnecter.';

  @override
  String get errorAccountSuspended =>
      'Votre compte a été suspendu. Veuillez contacter l’équipe du forum.';

  @override
  String get errorForumNotFound => 'Forum introuvable.';

  @override
  String get errorForumAccessDenied =>
      'Vous n’avez pas l’autorisation d’accéder à ce forum.';

  @override
  String get errorForumUnavailable =>
      'Le forum est actuellement indisponible. Veuillez réessayer plus tard.';

  @override
  String get errorDataNotFound => 'Données demandées introuvables.';

  @override
  String get errorDataCorrupted =>
      'Les données semblent corrompues. Veuillez actualiser la page.';

  @override
  String get errorCacheLoadFailed =>
      'Impossible de charger les données en cache. Veuillez réessayer.';

  @override
  String errorInvalidField(String field) {
    return 'Valeur invalide pour $field.';
  }

  @override
  String errorFieldRequired(String field) {
    return '$field est requis.';
  }

  @override
  String errorPermissionDeniedFor(String action) {
    return 'Vous n’avez pas l’autorisation : $action.';
  }

  @override
  String errorFeatureNotAvailable(String feature) {
    return '$feature n’est pas disponible sur ce forum.';
  }

  @override
  String get errorStorageFull =>
      'Le stockage est plein. Veuillez libérer de l’espace.';

  @override
  String get errorStorageAccessDenied =>
      'Accès au stockage refusé. Veuillez vérifier les autorisations de l’application.';

  @override
  String get errorNetworkTryAgain =>
      'Une erreur réseau s’est produite. Veuillez réessayer.';

  @override
  String get errorAuthenticationTryAgain =>
      'Échec de l’authentification. Veuillez réessayer.';

  @override
  String get errorForumTryAgain =>
      'Une erreur du forum s’est produite. Veuillez réessayer.';

  @override
  String get connectionErrorTitle => 'Erreur de connexion';

  @override
  String get authenticationErrorTitle => 'Erreur d’authentification';

  @override
  String get forumErrorTitle => 'Erreur du forum';

  @override
  String get permissionErrorTitle => 'Erreur d’autorisation';
}
