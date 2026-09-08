// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Forum App';

  @override
  String get loginTitle => 'Вход';

  @override
  String get usernameLabel => 'Имя пользователя';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get loginButton => 'Войти';

  @override
  String get signInWithPasskey => 'Sign in with Passkey';

  @override
  String get usePasskey => 'Use Passkey';

  @override
  String get passkeyContinuePrompt => 'Use your passkey to continue';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get pleaseEnterUsername => 'Пожалуйста, введите ваше имя пользователя';

  @override
  String get pleaseEnterPassword => 'Пожалуйста, введите ваш пароль';

  @override
  String credentialsSentToDomain(String domain) {
    return 'Ваше имя пользователя и пароль будут отправлены на $domain';
  }

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт? ';

  @override
  String get logIn => 'Войти';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get registrationNotAvailable => 'Регистрация недоступна';

  @override
  String get registrationNotAvailableMessage =>
      'Регистрация в настоящее время недоступна. Форум может быть закрыт или регистрация может быть отключена.';

  @override
  String get webRegistrationRequired => 'Требуется регистрация через веб';

  @override
  String get webRegistrationRequiredMessage =>
      'Этот форум требует регистрации через веб-браузер. Пожалуйста, нажмите кнопку ниже, чтобы открыть страницу регистрации.';

  @override
  String get openRegistrationPage => 'Открыть страницу регистрации';

  @override
  String get loadingAdditionalFields => 'Загрузка дополнительных полей...';

  @override
  String get pleaseSelectDateOfBirth =>
      'Пожалуйста, выберите вашу дату рождения';

  @override
  String get pleaseEnterLocation => 'Пожалуйста, введите ваше местоположение';

  @override
  String get pleaseIndicateEmailPreference =>
      'Пожалуйста, укажите ваши предпочтения по электронной почте';

  @override
  String get pleaseFillAllRequiredFields =>
      'Пожалуйста, заполните все обязательные поля';

  @override
  String get pleaseAcceptTermsOfService =>
      'Пожалуйста, примите Условия использования';

  @override
  String get pleaseAcceptPrivacyPolicy =>
      'Пожалуйста, примите Политику конфиденциальности';

  @override
  String get registrationError => 'Ошибка регистрации';

  @override
  String get registrationFailed =>
      'Регистрация не удалась. Пожалуйста, проверьте вашу информацию.';

  @override
  String get registrationFailedTryAgain =>
      'Регистрация не удалась. Пожалуйста, попробуйте снова.';

  @override
  String get registrationInfo => 'Информация о регистрации';

  @override
  String get openWebsite => 'Открыть веб-сайт';

  @override
  String couldNotOpenForumWebsite(String url) {
    return 'Не удалось открыть веб-сайт форума. Пожалуйста, попробуйте посетить: $url';
  }

  @override
  String get registrationSuccessfulEmailConfirm =>
      'Регистрация успешна! Пожалуйста, проверьте вашу электронную почту, чтобы подтвердить ваш аккаунт перед входом.';

  @override
  String get registrationSuccessfulPendingApproval =>
      'Регистрация успешна! Ваш аккаунт ожидает одобрения. Вы будете уведомлены, когда ваш аккаунт будет одобрен.';

  @override
  String get registrationSuccessfulAutoLogin =>
      'Регистрация успешна! Вы автоматически вошли в систему.';

  @override
  String get welcome => 'Добро пожаловать!';

  @override
  String get registrationSuccessful => 'Регистрация успешна';

  @override
  String get pleaseLoginWithNewAccount =>
      'Пожалуйста, войдите с вашим новым аккаунтом.';

  @override
  String get forgotPasswordTitle => 'Забыли пароль';

  @override
  String get usernameOrEmailLabel => 'Имя пользователя или электронная почта';

  @override
  String get pleaseEnterUsernameOrEmail =>
      'Пожалуйста, введите ваше имя пользователя или электронную почту';

  @override
  String get sendResetLink => 'Отправить ссылку для сброса';

  @override
  String get resetLinkSent => 'Ссылка для сброса отправлена';

  @override
  String get passwordResetInstructionsSent =>
      'Инструкции по сбросу пароля были отправлены на ваш зарегистрированный адрес электронной почты.';

  @override
  String get resetFailed => 'Сброс не удался';

  @override
  String get unableToSendResetLink =>
      'Не удалось отправить ссылку для сброса. Пожалуйста, попробуйте снова.';

  @override
  String get errorSendingResetLink =>
      'Произошла ошибка при отправке ссылки для сброса. Пожалуйста, проверьте ваше соединение и попробуйте снова.';

  @override
  String get errorTitle => 'Ошибка';

  @override
  String get okButton => 'ОК';

  @override
  String get retryButton => 'Повторить';

  @override
  String get copyToClipboard => 'Копировать в буфер обмена';

  @override
  String get copied => 'Скопировано';

  @override
  String get errorMessageCopiedToClipboard =>
      'Сообщение об ошибке скопировано в буфер обмена';

  @override
  String get dismiss => 'Закрыть';

  @override
  String get cancel => 'Отмена';

  @override
  String get tryAgain => 'Попробовать Снова';

  @override
  String get getHelp => 'Получить помощь';

  @override
  String get somethingWentWrong => 'Что-то пошло не так';

  @override
  String get unexpectedErrorOccurred =>
      'Произошла неожиданная ошибка. Пожалуйста, попробуйте снова.';

  @override
  String get noInternetConnection => 'Нет подключения к интернету';

  @override
  String get checkInternetConnection =>
      'Пожалуйста, проверьте ваше подключение к интернету и попробуйте снова.';

  @override
  String get authenticationRequired => 'Требуется аутентификация';

  @override
  String get pleaseLoginToContinue => 'Пожалуйста, войдите, чтобы продолжить.';

  @override
  String get forumError => 'Ошибка форума';

  @override
  String get anErrorOccurred => 'Произошла ошибка';

  @override
  String get accountPendingApproval =>
      'Ваш аккаунт ожидает одобрения. Вы можете просматривать форум, но не можете публиковать сообщения, пока модератор не одобрит ваш аккаунт.';

  @override
  String get checkEmailToConfirm =>
      'Пожалуйста, проверьте вашу электронную почту, чтобы подтвердить ваш аккаунт. Нажмите на ссылку подтверждения в письме, которое мы вам отправили.';

  @override
  String get checkNewEmailToConfirm =>
      'Пожалуйста, проверьте ваш новый адрес электронной почты, чтобы подтвердить изменение. Ваш старый адрес электронной почты останется активным, пока вы не подтвердите новый.';

  @override
  String get emailAddressInvalid =>
      'Ваш адрес электронной почты кажется недействительным или отклоняет письма. Пожалуйста, обновите ваш адрес электронной почты в настройках аккаунта.';

  @override
  String get accountDisabled =>
      'Ваш аккаунт был отключен. Пожалуйста, свяжитесь с администратором для получения помощи.';

  @override
  String get accountRegistrationRejected =>
      'Регистрация вашего аккаунта была отклонена. Пожалуйста, свяжитесь с администратором для получения дополнительной информации.';

  @override
  String get welcomeToForumCopilot => 'Добро пожаловать в Forum Copilot!';

  @override
  String get successfullyLoggedOut => 'Вы успешно вышли из системы';

  @override
  String get accountStatusRequiresAttention =>
      'Статус вашего аккаунта требует внимания. Пожалуйста, свяжитесь с администратором, если у вас есть вопросы.';

  @override
  String get updateEmail => 'Обновить электронную почту';

  @override
  String get resend => 'Отправить снова';

  @override
  String get noLatestTopics => 'Нет последних тем';

  @override
  String get noRecentTopicsToDisplay =>
      'Нет последних тем для отображения. Вернитесь позже для новых обсуждений.';

  @override
  String get signInToViewLatestTopics =>
      'Войдите, чтобы просмотреть последние темы';

  @override
  String get youNeedToBeSignedInToViewLatestTopics =>
      'Вам нужно войти, чтобы просмотреть последние темы';

  @override
  String get noUnreadTopics => 'Нет непрочитанных тем';

  @override
  String get thereAreNoUnreadTopics =>
      'Нет непрочитанных тем. Вернитесь позже для новых обсуждений.';

  @override
  String get youAreAllCaughtUp => 'Вы все просмотрели!';

  @override
  String get signInToViewUnreadTopics =>
      'Войдите, чтобы просмотреть непрочитанные темы';

  @override
  String get youNeedToBeSignedInToViewUnreadTopics =>
      'Вам нужно войти, чтобы просмотреть ваши непрочитанные темы';

  @override
  String get noSubscribedTopics => 'Нет подписанных тем';

  @override
  String get noSubscribedTopicsMessage =>
      'Вы не подписались ни на одну тему. Нажмите кнопку звездочки на теме, чтобы подписаться и получать уведомления о новых обновлениях.';

  @override
  String get signInToViewSubscribedTopics =>
      'Войдите, чтобы просмотреть подписанные темы';

  @override
  String get youNeedToBeSignedInToViewSubscribedTopics =>
      'Вам нужно войти, чтобы просмотреть ваши подписанные темы';

  @override
  String get noParticipatedTopics => 'Нет тем с участием';

  @override
  String get topicsYouParticipatedIn =>
      'Темы, в которых вы участвовали, будут показаны здесь.';

  @override
  String get signInToViewParticipatedTopics =>
      'Войдите, чтобы просмотреть темы с участием';

  @override
  String get youNeedToBeSignedInToViewParticipatedTopics =>
      'Вам нужно войти, чтобы просмотреть темы, в которых вы участвовали';

  @override
  String get latest => 'Последние';

  @override
  String get unread => 'Непрочитанные';

  @override
  String get subscribed => 'Подписанные';

  @override
  String get participated => 'С участием';

  @override
  String get connectionTimedOut =>
      'Время соединения истекло. Сайт может быть недоступен или недостижим.';

  @override
  String get failedToConnectToSite =>
      'Не удалось подключиться к сайту. Сайт может быть недоступен или недостижим.';

  @override
  String get connectionFailed => 'Ошибка подключения';

  @override
  String failedToConnectToSiteName(String siteName) {
    return 'Не удалось подключиться к $siteName';
  }

  @override
  String get loading => 'Загрузка...';

  @override
  String get newConversation => 'Новый разговор';

  @override
  String get newMessage => 'Новое сообщение';

  @override
  String get appSettings => 'Настройки приложения';

  @override
  String get searchSites => 'Поиск сайтов';

  @override
  String get language => 'Язык';

  @override
  String get systemDefault => 'По умолчанию системы';

  @override
  String get followSystemLanguage => 'Следовать языку системы';

  @override
  String get all => 'Все';

  @override
  String get topicsOnly => 'Только темы';

  @override
  String get titlesOnly => 'Только заголовки';

  @override
  String failedToShareTopic(String error) {
    return 'Не удалось поделиться темой: $error';
  }

  @override
  String get pleaseLoginToSubscribe =>
      'Пожалуйста, войдите, чтобы null эту тему';

  @override
  String get subscribe => 'Подписаться';

  @override
  String get unsubscribe => 'Отписаться';

  @override
  String get failedToSubscribeToThread => 'Не удалось null тему';

  @override
  String get youCannotReplyToThisThread => 'Вы не можете ответить на эту тему';

  @override
  String get pleaseWaitForThreadToLoad =>
      'Пожалуйста, подождите, пока тема загрузится';

  @override
  String get softDelete => 'Мягкое удаление';

  @override
  String get postCanBeRestoredLater => 'Сообщение можно восстановить позже';

  @override
  String get hardDelete => 'Жёсткое удаление';

  @override
  String get postWillBePermanentlyDeleted => 'Сообщение будет удалено навсегда';

  @override
  String get reasonForDeletion => 'Причина удаления';

  @override
  String get enterReasonForDeletingPost =>
      'Введите причину удаления этого сообщения';

  @override
  String get pleaseEnterReasonForDeletion =>
      'Пожалуйста, введите причину удаления';

  @override
  String get reportPost => 'Пожаловаться на сообщение';

  @override
  String get pleaseProvideReasonForReporting =>
      'Пожалуйста, укажите причину жалобы на это сообщение.';

  @override
  String get reason => 'Причина';

  @override
  String get enterReasonForReportingPost =>
      'Введите причину жалобы на это сообщение';

  @override
  String get pleaseEnterReason => 'Пожалуйста, введите причину';

  @override
  String get submitReport => 'Отправить жалобу';

  @override
  String get selectedActions => 'Выбранные действия:';

  @override
  String get thisActionCannotBeUndone => 'Это действие нельзя отменить.';

  @override
  String get participantsLabel => 'Участники';

  @override
  String usernameHasBeenInvited(String username) {
    return '$username был приглашен в разговор';
  }

  @override
  String errorInvitingUser(String error) {
    return 'Ошибка приглашения пользователя: $error';
  }

  @override
  String get newTopic => 'Новая тема';

  @override
  String get markRead => 'Отметить как прочитанное';

  @override
  String get reportUser => 'Пожаловаться на пользователя';

  @override
  String get pleaseSelectReasonForReportingUser =>
      'Пожалуйста, выберите причину жалобы на этого пользователя.';

  @override
  String get spamOrAdvertising => 'Спам или реклама';

  @override
  String get harassmentOrBullying => 'Преследование или издевательство';

  @override
  String get inappropriateContent => 'Неуместный контент';

  @override
  String get impersonationOrFakeAccount =>
      'Подделка личности или фальшивый аккаунт';

  @override
  String get otherPleaseSpecify => 'Другое (пожалуйста, укажите)';

  @override
  String get pleaseSpecifyReason => 'Пожалуйста, укажите причину';

  @override
  String get enterReasonForReportingUser =>
      'Введите причину жалобы на этого пользователя';

  @override
  String get pleaseSelectReason => 'Пожалуйста, выберите причину';

  @override
  String get banUser => 'Заблокировать пользователя';

  @override
  String get unbanUser => 'Разблокировать пользователя';

  @override
  String pleaseSelectReasonForBanningUser(String username) {
    return 'Пожалуйста, выберите причину блокировки $username';
  }

  @override
  String get violationOfCommunityGuidelines => 'Нарушение правил сообщества';

  @override
  String get harassmentOrAbusiveBehavior =>
      'Преследование или оскорбительное поведение';

  @override
  String get postingInappropriateContent => 'Публикация неуместного контента';

  @override
  String get accountCompromiseOrSecurityIssue =>
      'Компрометация аккаунта или проблема безопасности';

  @override
  String get enterReasonForBanningUser =>
      'Введите причину блокировки этого пользователя';

  @override
  String get banUntil => 'Заблокировать до';

  @override
  String get selectDate => 'Выбрать дату';

  @override
  String get moreOptions => 'Дополнительные опции';

  @override
  String get leaveConversation => 'Покинуть разговор';

  @override
  String get reportConversation => 'Пожаловаться на разговор';

  @override
  String get topicClosed => 'Тема закрыта';

  @override
  String get topicOpened => 'Тема открыта';

  @override
  String get topicStickied => 'Тема закреплена';

  @override
  String get topicUnstickied => 'Тема откреплена';

  @override
  String cannotEditMessage(String error) {
    return 'Невозможно отредактировать это сообщение: $error';
  }

  @override
  String get confirmSpamClean => 'Подтвердить очистку спама';

  @override
  String get handleThreads => 'Управление темами';

  @override
  String get deleteMessages => 'Удалить сообщения';

  @override
  String get deleteConversations => 'Удалить разговоры';

  @override
  String get myForums => 'Мои Форумы';

  @override
  String get recentlyVisited => 'Недавно Посещенные';

  @override
  String get explore => 'Исследовать';

  @override
  String get forumCopilot => 'Forum Copilot';

  @override
  String get noConversations => 'Нет разговоров';

  @override
  String get noConversationsMessage =>
      'У вас пока нет разговоров. Начните новый разговор, чтобы начать обмен сообщениями.';

  @override
  String get imageSavedToGallery => 'Изображение сохранено в галерею!';

  @override
  String failedToSaveImage(String error) {
    return 'Ошибка при сохранении изображения: $error';
  }

  @override
  String get userProfile => 'Профиль Пользователя';

  @override
  String get deletePost => 'Удалить Сообщение';

  @override
  String get loginRequired => 'Требуется Вход';

  @override
  String get spamCleaner => 'Очистка спама';

  @override
  String get sendMessage => 'Отправить сообщение';

  @override
  String get memberSince => 'Участник С';

  @override
  String get lastActivity => 'Последняя Активность';

  @override
  String get likesReceived => 'Полученные Лайки';

  @override
  String get likesGiven => 'Данные Лайки';

  @override
  String get showMore => 'Показать больше';

  @override
  String get cleanSpam => 'Очистить спам';

  @override
  String get failedToSaveMessage => 'Ошибка при сохранении сообщения';

  @override
  String get failedToSaveConversation => 'Не удалось сохранить разговор';

  @override
  String get failedToSaveSetting => 'Ошибка при сохранении настройки';

  @override
  String get failedToSavePost => 'Ошибка при сохранении сообщения';

  @override
  String errorLoadingSites(String error) {
    return 'Ошибка при загрузке сайтов: $error';
  }

  @override
  String connectingTo(String domainName) {
    return 'Подключение к $domainName...';
  }

  @override
  String get members => 'Участники';

  @override
  String get allMembers => 'Все Участники';

  @override
  String get online => 'Онлайн';

  @override
  String get noMembersFound => 'Участники не найдены';

  @override
  String get searchForMembers => 'Поиск участников';

  @override
  String get enterUsernameToFindMembers =>
      'Введите имя пользователя, чтобы найти участников форума';

  @override
  String get noMembersOnline => 'В настоящее время нет участников в сети';

  @override
  String get enterUsernameToSearch => 'Введите имя пользователя для поиска...';

  @override
  String get lookupMembers => 'Поиск Участников';

  @override
  String get addMembers => 'Добавить Участников';

  @override
  String get membersAddedSuccessfully => 'Участники успешно добавлены';

  @override
  String errorAddingMembers(String error) {
    return 'Ошибка при добавлении участников: $error';
  }

  @override
  String get failedToLoadOnlineUsers =>
      'Ошибка при загрузке пользователей в сети';

  @override
  String get noUsersOnline => 'Нет пользователей в сети';

  @override
  String membersCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString Участников';
  }

  @override
  String get noSubject => 'Без темы';

  @override
  String get search => 'Поиск';

  @override
  String get logout => 'Выйти';

  @override
  String get areYouSureYouWantToLogout => 'Вы уверены, что хотите выйти?';

  @override
  String get register => 'Зарегистрироваться';

  @override
  String get signIn => 'Войти';

  @override
  String get markForumRead => 'Отметить Форум как Прочитанный';

  @override
  String get notificationTest => 'Тест Уведомлений';

  @override
  String get forum => 'Форум';

  @override
  String get profile => 'Профиль';

  @override
  String get messages => 'Сообщения';

  @override
  String get add => 'Добавить';

  @override
  String get retry => 'Повторить';

  @override
  String get delete => 'Удалить';

  @override
  String get deleteMessage => 'Удалить Сообщение';

  @override
  String get areYouSureYouWantToDeleteThisMessage =>
      'Вы уверены, что хотите удалить это сообщение?';

  @override
  String failedToDeleteMessage(String error) {
    return 'Ошибка при удалении сообщения: $error';
  }

  @override
  String get deletingPost => 'Удаление сообщения...';

  @override
  String failedToUnlikePost(String error) {
    return 'Ошибка при снятии лайка с сообщения: $error';
  }

  @override
  String failedToLikePost(String error) {
    return 'Ошибка при лайке сообщения: $error';
  }

  @override
  String failedToThankPost(String error) {
    return 'Ошибка при благодарности сообщению: $error';
  }

  @override
  String get signInToViewMessages => 'Войдите, чтобы просмотреть сообщения';

  @override
  String get youNeedToBeSignedInToViewConversations =>
      'Вам нужно войти, чтобы просмотреть ваши разговоры.';

  @override
  String errorLoadingConversations(String error) {
    return 'Ошибка при загрузке разговоров: $error';
  }

  @override
  String failedToLeaveConversation(String error) {
    return 'Ошибка при выходе из разговора: $error';
  }

  @override
  String errorLoadingMoreConversations(String error) {
    return 'Ошибка при загрузке дополнительных разговоров: $error';
  }

  @override
  String errorLoadingMoreMessages(String error) {
    return 'Ошибка при загрузке дополнительных сообщений: $error';
  }

  @override
  String get inviteMessageOptional =>
      'Пригласительное Сообщение (необязательно)';

  @override
  String get iWouldLikeToAddYouToThisConversation =>
      'Я хотел бы добавить вас в этот разговор.';

  @override
  String get searchFailed => 'Поиск не удался';

  @override
  String get trySearchingWithDifferentUsername =>
      'Попробуйте поискать с другим именем пользователя';

  @override
  String get noSitesFound => 'Сайты не найдены.';

  @override
  String get userInformationNotAvailable =>
      'Информация о пользователе недоступна';

  @override
  String get birthday => 'День рождения';

  @override
  String get posts => 'Сообщения';

  @override
  String get following => 'Подписки';

  @override
  String get followers => 'Подписчики';

  @override
  String get about => 'О себе';

  @override
  String get location => 'Местоположение';

  @override
  String get website => 'Веб-сайт';

  @override
  String get next => 'Далее';

  @override
  String get permanent => 'Постоянный';

  @override
  String get temporary => 'Временный';

  @override
  String setBanDurationFor(String username) {
    return 'Установить длительность бана для $username';
  }

  @override
  String get pleaseSelectEndDateForTemporaryBan =>
      'Пожалуйста, выберите дату окончания временного бана';

  @override
  String get back => 'Назад';

  @override
  String get unban => 'Разблокировать';

  @override
  String get confirm => 'Подтвердить';

  @override
  String spamClean(String username) {
    return 'Очистить Спам $username';
  }

  @override
  String get selectActionsToPerform => 'Выберите действия для выполнения:';

  @override
  String get moveOrDeleteThreadsBasedOnAdminSettings =>
      'Переместить или удалить темы на основе настроек администратора';

  @override
  String get messageUpdatedSuccessfully => 'Сообщение успешно обновлено';

  @override
  String error(String error) {
    return 'Ошибка: $error';
  }

  @override
  String failedToRemoveAttachment(String error) {
    return 'Ошибка при удалении вложения: $error';
  }

  @override
  String failedToLoadMessage(String error) {
    return 'Ошибка при загрузке сообщения: $error';
  }

  @override
  String get editMessage => 'Редактировать Сообщение';

  @override
  String get removeAttachment => 'Удалить Вложение';

  @override
  String get areYouSureYouWantToRemoveThisAttachment =>
      'Вы уверены, что хотите удалить это вложение?';

  @override
  String get none => 'Нет';

  @override
  String get attachFile => 'Прикрепить Файл';

  @override
  String get uploadImage => 'Загрузить Изображение';

  @override
  String get formatting => 'Форматирование';

  @override
  String get bold => 'Жирный';

  @override
  String get italic => 'Курсив';

  @override
  String get underline => 'Подчеркнутый';

  @override
  String get strikethrough => 'Зачеркнутый';

  @override
  String get link => 'Ссылка';

  @override
  String get image => 'Изображение';

  @override
  String get video => 'Видео';

  @override
  String get quote => 'Цитата';

  @override
  String get code => 'Код';

  @override
  String get spoiler => 'Спойлер';

  @override
  String get bulletList => 'Маркированный Список';

  @override
  String get numberedList => 'Нумерованный Список';

  @override
  String get listItem => 'Элемент Списка';

  @override
  String participants(int count) {
    return 'Участники ($count)';
  }

  @override
  String get markAsUnread => 'Отметить как непрочитанное';

  @override
  String get invite => 'Пригласить';

  @override
  String get welcomeBack => 'С возвращением!';

  @override
  String get signInToAccessYourProfile =>
      'Войдите, чтобы получить доступ к своему профилю и управлять аккаунтом';

  @override
  String get enterYourUsername => 'Введите ваше имя пользователя';

  @override
  String get enterYourPassword => 'Введите ваш пароль';

  @override
  String get dontHaveAnAccount => 'Нет аккаунта?';

  @override
  String get enterKeywordsToSearchTopics =>
      'Введите ключевые слова для поиска тем...';

  @override
  String get pleaseFillInAllRequiredFields =>
      'Пожалуйста, заполните все обязательные поля';

  @override
  String get undelete => 'Восстановить';

  @override
  String get refresh => 'Обновить';

  @override
  String get share => 'Поделиться';

  @override
  String get viewOnWeb => 'Открыть в браузере';

  @override
  String get unlock => 'Разблокировать';

  @override
  String get lock => 'Заблокировать';

  @override
  String get stick => 'Закрепить';

  @override
  String get unstick => 'Открепить';

  @override
  String get reply => 'Ответить';

  @override
  String get vote => 'Голосовать';

  @override
  String votesCount(int count) {
    return '$count голосов';
  }

  @override
  String get pollClosed => 'Опрос закрыт';

  @override
  String pollEndsOn(String date) {
    return 'Заканчивается $date';
  }

  @override
  String get voteToSeeResults => 'Проголосуйте, чтобы увидеть результаты';

  @override
  String get viewFullPoll => 'Полный опрос';

  @override
  String pollOptionsCount(int count) {
    return '$count вариантов';
  }

  @override
  String get reactedBy => 'Отреагировали';

  @override
  String get enterKeywordsToFindTopicsAndPosts =>
      'Введите ключевые слова для поиска тем и сообщений';

  @override
  String get enterKeywordsOrDomainToFindForums =>
      'Введите ключевые слова или домен для поиска форумов';

  @override
  String get enterKeywordsOrDomainNamesToFindForums =>
      'Введите ключевые слова или доменные имена для поиска форумов';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get followSystemTheme => 'Следовать теме системы';

  @override
  String get light => 'Светлая';

  @override
  String get dark => 'Тёмная';

  @override
  String version(String version, String buildNumber) {
    return 'версия $version ($buildNumber)';
  }

  @override
  String get forumSettings => 'Настройки форума';

  @override
  String get noSettingsAvailable => 'Настройки недоступны';

  @override
  String get settingsCategoriesWillAppearHere =>
      'Категории настроек появятся здесь, когда будут доступны.';

  @override
  String get unableToLoadProfile => 'Не удалось загрузить профиль';

  @override
  String get banned => 'ЗАБЛОКИРОВАН';

  @override
  String get reportSubmittedSuccessfully => 'Жалоба успешно отправлена';

  @override
  String get failedToSubmitReport => 'Не удалось отправить жалобу';

  @override
  String get searchForForums => 'Поиск форумов';

  @override
  String get searchForums => 'Поиск форумов';

  @override
  String get deleteTopic => 'Удалить тему';

  @override
  String get topicCanBeRestoredLater => 'Тему можно восстановить позже';

  @override
  String get topicWillBePermanentlyDeleted => 'Тема будет удалена навсегда';

  @override
  String get enterReasonForDeletingTopic =>
      'Введите причину удаления этой темы';

  @override
  String get pleaseSelectEndDate => 'Пожалуйста, выберите дату окончания';

  @override
  String get userBannedSuccessfully => 'Пользователь успешно заблокирован';

  @override
  String get failedToBanUser => 'Не удалось заблокировать пользователя';

  @override
  String get userUnbannedSuccessfully => 'Пользователь успешно разблокирован';

  @override
  String get failedToUnbanUser => 'Не удалось разблокировать пользователя';

  @override
  String get spamCleanUser => 'Очистить спам пользователя';

  @override
  String get deletePrivateConversations => 'Удалить приватные разговоры';

  @override
  String get banTheUserAccount => 'Заблокировать учётную запись пользователя';

  @override
  String get handledThreads => 'Обработанные темы';

  @override
  String get deletedMessages => 'Удалённые сообщения';

  @override
  String get deletedConversations => 'Удалённые разговоры';

  @override
  String get bannedUser => 'Заблокированный пользователь';

  @override
  String successfullyCleanedSpam(String username, String actions) {
    return 'Спам успешно очищен для $username. Действия: $actions';
  }

  @override
  String errorLoadingMessage(String error) {
    return 'Ошибка загрузки сообщения: $error';
  }

  @override
  String get messageNotFound => 'Сообщение не найдено';

  @override
  String get home => 'Главная';

  @override
  String get notifications => 'Уведомления';

  @override
  String get forums => 'Форумы';

  @override
  String get markAllForumsAsRead => 'Отметить все форумы как прочитанные?';

  @override
  String get markAllForumsAsReadMessage =>
      'Это отметит все форумы и темы как прочитанные. Это действие нельзя отменить.';

  @override
  String get markAsRead => 'Отметить как прочитанное';

  @override
  String get content => 'Содержание';

  @override
  String get insertImage => 'Вставить изображение';

  @override
  String get howWouldYouLikeToInsertImage =>
      'Как вы хотите вставить это изображение?';

  @override
  String get thumbnail => 'Миниатюра';

  @override
  String get fullSize => 'Полный размер';

  @override
  String get alignLeft => 'Выровнять по левому краю';

  @override
  String get alignCenter => 'Выровнять по центру';

  @override
  String get alignRight => 'Выровнять по правому краю';

  @override
  String get pleaseEnterTitle => 'Пожалуйста, введите заголовок';

  @override
  String get pleaseEnterContent => 'Пожалуйста, введите содержимое';

  @override
  String get uploading => 'Загрузка...';

  @override
  String get uploaded => 'Загружено';

  @override
  String get mentionUser => 'Упомянуть пользователя';

  @override
  String get loggingIn => 'Вход в систему...';

  @override
  String get submittingReport => 'Отправка отчёта...';

  @override
  String get banningUser => 'Блокировка пользователя...';

  @override
  String get unbanningUser => 'Разблокировка пользователя...';

  @override
  String get cleaningSpam => 'Очистка спама...';

  @override
  String get enterSubject => 'Введите тему';

  @override
  String get typeYourMessageHere => 'Введите ваше сообщение здесь';

  @override
  String get writeYourMessage => 'Напишите ваше сообщение...';

  @override
  String get writeYourReply => 'Напишите ваш ответ...';

  @override
  String get messageSentSuccessfully => 'Сообщение успешно отправлено';

  @override
  String get replySentSuccessfully => 'Ответ успешно отправлен';

  @override
  String get conversationCreatedSuccessfully => 'Разговор успешно создан';

  @override
  String get conversationMarkedAsUnread => 'Разговор отмечен как непрочитанный';

  @override
  String get messageMarkedAsUnread => 'Сообщение отмечено как непрочитанное';

  @override
  String get conversationClosed => 'Разговор закрыт';

  @override
  String get conversationOpened => 'Разговор открыт';

  @override
  String get pleaseLoginToLikeMessages =>
      'Пожалуйста, войдите, чтобы лайкать сообщения';

  @override
  String get loadEarlierMessages => 'Загрузить более ранние сообщения';

  @override
  String failedToLoadQuote(String error) {
    return 'Не удалось загрузить цитату: \n$error';
  }

  @override
  String failedToUploadFile(String error) {
    return 'Не удалось загрузить файл: $error';
  }

  @override
  String failedToUploadImage(String error) {
    return 'Не удалось загрузить изображение: $error';
  }

  @override
  String failedToSendMessage(String error) {
    return 'Не удалось отправить сообщение: $error';
  }

  @override
  String failedToSendReply(String error) {
    return 'Не удалось отправить ответ: $error';
  }

  @override
  String failedToMarkAsUnread(String error) {
    return 'Не удалось отметить сообщение как непрочитанное: $error';
  }

  @override
  String failedToMarkConversationAsUnread(String error) {
    return 'Не удалось отметить разговор как непрочитанный: $error';
  }

  @override
  String failedToCloseConversation(String error) {
    return 'Не удалось закрыть разговор: $error';
  }

  @override
  String failedToOpenConversation(String error) {
    return 'Не удалось открыть разговор: $error';
  }

  @override
  String failedToJumpToMessage(String error) {
    return 'Не удалось перейти к сообщению: $error';
  }

  @override
  String get goToTop => 'Перейти вверх';

  @override
  String get goToBottom => 'Перейти вниз';

  @override
  String get replyAll => 'Ответить всем';

  @override
  String get forward => 'Переслать';

  @override
  String get noForumsFound => 'Форумы не найдены.';

  @override
  String get pleaseLoginToAccessContent =>
      'Пожалуйста, войдите, чтобы получить доступ к этому содержимому и взаимодействовать с сообщениями.';

  @override
  String get searchUsers => 'Поиск пользователей...';

  @override
  String get writeYourTitle => 'Напишите ваш заголовок...';

  @override
  String get writeYourContent => 'Напишите ваше содержимое...';

  @override
  String get selectAnOption => 'Выберите опцию';

  @override
  String get enterConversationTitle => 'Введите заголовок разговора';

  @override
  String enterCode(int count) {
    return 'Введите $count-значный код';
  }

  @override
  String get edit => 'Редактировать';

  @override
  String get report => 'Пожаловаться';

  @override
  String get unfollow => 'Отписаться';

  @override
  String get follow => 'Подписаться';

  @override
  String get goToForums => 'Перейти к форумам';

  @override
  String get remove => 'Удалить';

  @override
  String get subject => 'Тема';

  @override
  String get message => 'Сообщение';

  @override
  String get titleCannotBeEmpty => 'Заголовок не может быть пустым';

  @override
  String get conversationUpdatedSuccessfully => 'Разговор успешно обновлён';

  @override
  String get goBack => 'Назад';

  @override
  String get privateMessagesNotAvailable => 'Приватные сообщения недоступны';

  @override
  String failedToLoadPost(String error) {
    return 'Не удалось загрузить сообщение: \n$error';
  }

  @override
  String failedToLikeOrUnlikeMessage(String action, String error) {
    return 'Не удалось $action сообщение: $error';
  }

  @override
  String get like => 'лайкнуть';

  @override
  String get unlike => 'убрать лайк';

  @override
  String get optimizeImage => 'Оптимизировать изображение';

  @override
  String get optimizeAndUpload => 'Оптимизировать и загрузить';

  @override
  String downloading(String filename) {
    return 'Загрузка $filename...';
  }

  @override
  String openingShareSheet(String filename) {
    return 'Открытие листа общего доступа для $filename';
  }

  @override
  String errorDownloading(String filename, String error) {
    return 'Ошибка при загрузке $filename: $error';
  }

  @override
  String get enterANumber => 'Введите число';

  @override
  String get failedToNavigateToForum => 'Не удалось перейти к форуму';

  @override
  String failedToNavigateToForumName(String forumName) {
    return 'Не удалось перейти к $forumName';
  }

  @override
  String forumNotFound(String forumName) {
    return 'Форум не найден: $forumName';
  }

  @override
  String forumNotFoundById(String forumId) {
    return 'Форум не найден: $forumId';
  }

  @override
  String couldNotOpenLink(String error) {
    return 'Не удалось открыть ссылку: $error';
  }

  @override
  String get likePost => 'Нравится';

  @override
  String get unlikePost => 'Больше не нравится';

  @override
  String get thankPost => 'Поблагодарить';

  @override
  String get showLikes => 'Показать лайки';

  @override
  String get showThanks => 'Показать благодарности';

  @override
  String get quotePost => 'Цитировать пост';

  @override
  String get translate => 'Перевести';

  @override
  String get showOriginal => 'Показать оригинал';

  @override
  String get translating => 'Перевод...';

  @override
  String get translated => 'Переведено';

  @override
  String get translatedContent => 'Переведённый контент';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get translateTo => 'Перевести на:';

  @override
  String get deviceLanguage => 'Язык устройства';

  @override
  String get noPostsToTranslate => 'Нет постов для перевода';

  @override
  String get translationFailed => 'Ошибка перевода';

  @override
  String get twoFactorAuthentication => 'Двухфакторная аутентификация';

  @override
  String get authenticationCodeLabel => 'Код аутентификации';

  @override
  String get pleaseEnterYourAuthenticationCode => 'Введите код аутентификации';

  @override
  String codeMustBeDigits(int count) {
    return 'Код должен содержать $count цифр';
  }

  @override
  String get codeMustContainOnlyNumbers => 'Код должен содержать только цифры';

  @override
  String get verifyButton => 'Проверить';

  @override
  String get attachments => 'Вложения';

  @override
  String get replyOptions => 'Параметры ответа';

  @override
  String get replyWithQuote => 'Ответить с цитатой';

  @override
  String fileSavedToDownloads(String filename) {
    return 'Файл сохранен в Загрузки: $filename';
  }

  @override
  String fileSavedToDocuments(String filename) {
    return 'Файл сохранен в Документы: $filename';
  }

  @override
  String topicLastReplyBy(String username, String time) {
    return '$username ответил(а) $time';
  }

  @override
  String inReplyToUser(String username) {
    return 'в ответ $username';
  }

  @override
  String inReplyToPost(int number) {
    return 'в ответ на сообщение #$number';
  }

  @override
  String timeGapDaysLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дней спустя',
      few: '$count дня спустя',
      one: '1 день спустя',
    );
    return '$_temp0';
  }

  @override
  String timeGapMonthsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count месяцев спустя',
      few: '$count месяца спустя',
      one: '1 месяц спустя',
    );
    return '$_temp0';
  }

  @override
  String timeGapYearsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count лет спустя',
      few: '$count года спустя',
      one: '1 год спустя',
    );
    return '$_temp0';
  }

  @override
  String get profileViews => 'Просмотры';

  @override
  String get badges => 'Награды';

  @override
  String get chatWithUser => 'Чат';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ответов',
      few: '$count ответа',
      one: '1 ответ',
    );
    return '$_temp0';
  }

  @override
  String nVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count голосов',
      few: '$count голоса',
      one: '1 голос',
    );
    return '$_temp0';
  }

  @override
  String get lastSeen => 'Был(а)';

  @override
  String get chat => 'Чат';

  @override
  String comingSoon(String label) {
    return '$label — скоро';
  }

  @override
  String moreBadges(Object count) {
    return 'ещё $count';
  }

  @override
  String get allNotificationsMarkedAsRead =>
      'Все уведомления отмечены как прочитанные';

  @override
  String get apply => 'Применить';

  @override
  String get bookmarks => 'Закладки';

  @override
  String reviewableBy(String username) {
    return 'Автор: $username';
  }

  @override
  String get changeEmail => 'Изменить адрес электронной почты';

  @override
  String get changePassword => 'Изменить пароль';

  @override
  String get checkingStatus => 'Проверка состояния…';

  @override
  String get clearReminder => 'Убрать напоминание';

  @override
  String get copy => 'Копировать';

  @override
  String get copyLink => 'Скопировать ссылку';

  @override
  String couldNotEnableNotifications(String error) {
    return 'Не удалось включить уведомления: $error';
  }

  @override
  String get couldNotFindBookmark => 'Закладка не найдена';

  @override
  String couldNotOpenEmail(String email) {
    return 'Не удалось открыть почту: $email';
  }

  @override
  String couldNotStartSignIn(String error) {
    return 'Не удалось начать вход: $error';
  }

  @override
  String get customDateAndTime => 'Своя дата и время';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteMessageQuestion => 'Удалить сообщение?';

  @override
  String get discard => 'Отменить';

  @override
  String get discardDraftQuestion => 'Удалить черновик?';

  @override
  String get doNotDisturb => 'Не беспокоить';

  @override
  String get editHistory => 'История правок';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get editReminder => 'Изменить напоминание';

  @override
  String emailCopiedToClipboard(String email) {
    return 'Адрес скопирован в буфер обмена: $email';
  }

  @override
  String get pushEnabledForThisLogin => 'Включены для этого входа';

  @override
  String get failedToLoadMoreTopics =>
      'Не удалось загрузить темы. Прокрутите, чтобы повторить.';

  @override
  String get failedToUpdateNotificationLevel =>
      'Не удалось изменить уровень уведомлений';

  @override
  String get firstPostsOnly => 'Только первые сообщения';

  @override
  String get ignoredUsers => 'Игнорируемые пользователи';

  @override
  String get inTwoHours => 'Через два часа';

  @override
  String get inviteByEmail => 'Пригласить по почте';

  @override
  String get inviteLinkCopied => 'Ссылка-приглашение скопирована';

  @override
  String inviteSentTo(String email) {
    return 'Приглашение отправлено на $email';
  }

  @override
  String get leave => 'Покинуть';

  @override
  String get leaveGroup => 'Покинуть группу';

  @override
  String get leaveGroupQuestion => 'Покинуть группу?';

  @override
  String get linkCopied => 'Ссылка скопирована';

  @override
  String get loadMore => 'Загрузить ещё';

  @override
  String get manageAccountOnWeb => 'Управление аккаунтом в браузере';

  @override
  String get merge => 'Объединить';

  @override
  String get mergeIntoTopic => 'Объединить с темой';

  @override
  String get newInviteLink => 'Новая ссылка-приглашение';

  @override
  String get nextWeek => 'На следующей неделе';

  @override
  String get pushNotAvailableInThisBuild => 'Недоступно в этой сборке';

  @override
  String get notNow => 'Не сейчас';

  @override
  String tagNotificationLevelUpdated(String tag) {
    return 'Уровень уведомлений для «$tag» обновлён';
  }

  @override
  String doNotDisturbOnUntil(String until) {
    return 'Включено до $until';
  }

  @override
  String get pleaseLogInToBookmark => 'Войдите, чтобы добавить закладку';

  @override
  String get pleaseLogInToFollowUsers =>
      'Войдите, чтобы подписаться на пользователей';

  @override
  String get pleaseLogInToMarkAnswers => 'Войдите, чтобы отмечать ответы';

  @override
  String get pleaseLogInToReact => 'Войдите, чтобы отреагировать';

  @override
  String get pleaseLogInToVote => 'Войдите, чтобы проголосовать';

  @override
  String get pushNotifications => 'Push-уведомления';

  @override
  String get relevance => 'Релевантность';

  @override
  String get reminderTimeMustBeInFuture =>
      'Время напоминания должно быть в будущем';

  @override
  String get removeBookmark => 'Удалить закладку';

  @override
  String get removeVote => 'Отозвать голос';

  @override
  String get renameTopic => 'Переименовать тему';

  @override
  String reportedBy(String username) {
    return 'Пожаловался: $username';
  }

  @override
  String get requestToJoin => 'Запросить вступление';

  @override
  String requestToJoinGroup(String group) {
    return 'Запросить вступление в $group';
  }

  @override
  String get reset => 'Сбросить';

  @override
  String get resizeAndUpload => 'Уменьшить и загрузить';

  @override
  String get retryConnection => 'Повторить подключение';

  @override
  String get reviewQueue => 'Очередь на проверку';

  @override
  String get revoke => 'Отозвать';

  @override
  String get revokeInviteQuestion => 'Отозвать приглашение?';

  @override
  String get save => 'Сохранить';

  @override
  String get sendInvite => 'Отправить приглашение';

  @override
  String get sendRequest => 'Отправить запрос';

  @override
  String get settings => 'Настройки';

  @override
  String get showVoters => 'Показать проголосовавших';

  @override
  String get signOut => 'Выйти';

  @override
  String get signOutQuestion => 'Выйти?';

  @override
  String get signInCancelledNoPayload => 'Вход отменён — ответ не получен';

  @override
  String signInFailed(String error) {
    return 'Ошибка входа: $error';
  }

  @override
  String get startChat => 'Начать чат';

  @override
  String stoppedIgnoringUser(String username) {
    return '@$username больше не игнорируется';
  }

  @override
  String get submit => 'Отправить';

  @override
  String get discardDraftWarning =>
      'Сохранённый черновик будет удалён без возможности восстановления.';

  @override
  String get deleteChatMessageWarning => 'Сообщение будет удалено для всех.';

  @override
  String get titleOnly => 'Только заголовок';

  @override
  String get tomorrow => 'Завтра';

  @override
  String get turnOff => 'Выключить';

  @override
  String get turnOnNotifications => 'Включить уведомления';

  @override
  String get whisper => 'Шёпот';

  @override
  String likeAgainInSeconds(Object seconds) {
    return 'Снова поставить лайк можно через $seconds с';
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
