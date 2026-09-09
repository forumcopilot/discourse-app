// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get loginTitle => 'Вход';

  @override
  String get usePasskey => 'Use Passkey';

  @override
  String get passkeyContinuePrompt => 'Use your passkey to continue';

  @override
  String get continueButton => 'Продолжить';

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
  String get latest => 'Последние';

  @override
  String get unread => 'Непрочитанные';

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
  String get language => 'Язык';

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
  String get spamOrAdvertising => 'Спам или реклама';

  @override
  String get otherPleaseSpecify => 'Другое (пожалуйста, укажите)';

  @override
  String get pleaseSpecifyReason => 'Пожалуйста, укажите причину';

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
  String get failedToSaveConversation => 'Не удалось сохранить разговор';

  @override
  String get members => 'Участники';

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
  String get searchFailed => 'Поиск не удался';

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
  String get enterKeywordsToSearchTopics =>
      'Введите ключевые слова для поиска тем...';

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
  String get light => 'Светлая';

  @override
  String get dark => 'Тёмная';

  @override
  String version(String version, String buildNumber) {
    return 'версия $version ($buildNumber)';
  }

  @override
  String get unableToLoadProfile => 'Не удалось загрузить профиль';

  @override
  String get banned => 'ЗАБЛОКИРОВАН';

  @override
  String get reportSubmittedSuccessfully => 'Жалоба успешно отправлена';

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
  String get submittingReport => 'Отправка отчёта...';

  @override
  String get banningUser => 'Блокировка пользователя...';

  @override
  String get unbanningUser => 'Разблокировка пользователя...';

  @override
  String get cleaningSpam => 'Очистка спама...';

  @override
  String get writeYourMessage => 'Напишите ваше сообщение...';

  @override
  String get writeYourReply => 'Напишите ваш ответ...';

  @override
  String get conversationCreatedSuccessfully => 'Разговор успешно создан';

  @override
  String get conversationMarkedAsUnread => 'Разговор отмечен как непрочитанный';

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
  String failedToSendReply(String error) {
    return 'Не удалось отправить ответ: $error';
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
  String get pleaseLoginToAccessContent =>
      'Пожалуйста, войдите, чтобы получить доступ к этому содержимому и взаимодействовать с сообщениями.';

  @override
  String get searchUsers => 'Поиск пользователей...';

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
  String get failedToNavigateToForum => 'Не удалось перейти к форуму';

  @override
  String forumNotFoundById(String forumId) {
    return 'Форум не найден: $forumId';
  }

  @override
  String couldNotOpenLink(String error) {
    return 'Не удалось открыть ссылку: $error';
  }

  @override
  String get translating => 'Перевод...';

  @override
  String get translated => 'Переведено';

  @override
  String get translatedContent => 'Переведённый контент';

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
  String get loginInfo => 'Информация о входе';

  @override
  String get loginFailed => 'Ошибка входа';

  @override
  String get moveToCategory => 'Переместить в категорию';

  @override
  String get undeleteTopic => 'Восстановить тему';

  @override
  String get undeleteTopicConfirmation =>
      'Восстановить эту тему? Она снова станет видна другим пользователям.';

  @override
  String get send => 'Отправить';

  @override
  String get changeEmailExplanation =>
      'Мы отправим ссылку для подтверждения на новый адрес. Изменение вступит в силу после перехода по ней.';

  @override
  String get changeEmailSecurityNote =>
      'Для безопасности Discourse может запросить подтверждение по ссылке из письма. Проверьте папку «Спам», если письма нет.';

  @override
  String get newDirectMessage => 'Новое личное сообщение';

  @override
  String get noMessagesYetSayHi => 'Сообщений пока нет — поздоровайтесь.';

  @override
  String get edited => 'изменено';

  @override
  String get editProfileManagedOnWebNote =>
      'Отображаемое имя, почта, пароль и другие настройки аккаунта меняются в разделе Аккаунт → Управление аккаунтом в браузере. Аватар можно сменить, нажав на значок камеры на фото.';

  @override
  String get approvedButRelayUnreachable =>
      'Одобрено, но не удалось связаться с ForumCopilot для завершения настройки. Повторите позже в настройках.';

  @override
  String get notificationsAreTurnedOffForThisApp =>
      'Уведомления для этого приложения отключены';

  @override
  String forumWillAskToApproveNotifications(Object forumName) {
    return 'Далее $forumName попросит разрешить «Уведомления».';
  }

  @override
  String get approveNotificationsExplanation =>
      'Разрешение позволяет нам проверять ваши уведомления и отправлять их на это устройство. Оно не даёт права писать, отвечать или читать ваши сообщения.';

  @override
  String get forumOwnerPushNote =>
      'Если владелец форума настроит уведомления для приложения, этот шаг не понадобится.';

  @override
  String get pleaseLoginToCreateANewTopic => 'Войдите, чтобы создать тему';

  @override
  String get pleaseLoginToSubscribeToForums =>
      'Войдите, чтобы подписаться на форумы';

  @override
  String leaveGroupWarning(Object group) {
    return 'Вы перестанете быть участником $group. Вернуться можно в любой момент.';
  }

  @override
  String get groupMembersPrivate => 'Список участников этой группы скрыт.';

  @override
  String get unignore => 'Не игнорировать';

  @override
  String get inviteLinkCreated => 'Ссылка-приглашение создана';

  @override
  String expiresOn(Object date) {
    return 'Истекает $date';
  }

  @override
  String get protected => 'Защищено';

  @override
  String get solution => 'Решение';

  @override
  String get deleted => 'УДАЛЕНО';

  @override
  String get pleaseLoginToViewUserProfiles =>
      'Войдите, чтобы просматривать профили.';

  @override
  String get announcement => 'Объявление';

  @override
  String get solved => 'Решено';

  @override
  String get hot => 'Популярное';

  @override
  String get pinned => 'Закреплено';

  @override
  String get subscribedLabel => 'Подписка';

  @override
  String get locked => 'Закрыто';

  @override
  String get poll => 'Опрос';

  @override
  String errorLoadingContent(Object error) {
    return 'Ошибка загрузки содержимого: $error';
  }

  @override
  String get noPermissionToViewSubforum =>
      'У вас нет прав на просмотр тем в этом подфоруме.';

  @override
  String get noDiscussionsYet => 'Обсуждений пока нет.';

  @override
  String get jumpToPost => 'Перейти к сообщению';

  @override
  String get jump => 'Перейти';

  @override
  String get endOfTheDiscussion => 'Конец обсуждения';

  @override
  String get reviewQueueStaffOnly =>
      'Очередь на проверку видна только персоналу и проверяющим.';

  @override
  String get nothingToReview => 'Нечего проверять';

  @override
  String refreshFailed(Object error) {
    return 'Не удалось обновить: $error';
  }

  @override
  String get topicDeletedBanner =>
      'Тема удалена и скрыта от других пользователей';

  @override
  String get topicClosedBanner => 'Тема закрыта и больше не принимает ответы';

  @override
  String get topicPinnedBanner => 'Тема закреплена вверху форума';

  @override
  String get youAreSubscribedToThisTopic => 'Вы подписаны на эту тему';

  @override
  String get refreshing => 'Обновление...';

  @override
  String get title => 'Заголовок';

  @override
  String editedAt(Object time) {
    return 'Изменено $time';
  }

  @override
  String editReason(Object reason) {
    return 'Причина: $reason';
  }

  @override
  String get thisDiffIsTooLargeToDisplay =>
      'Слишком большое изменение для отображения.';

  @override
  String get noContentChangesInThisRevision =>
      'В этой версии нет изменений содержимого.';

  @override
  String revisionOf(Object currentVersion, Object versionCount) {
    return 'Версия $currentVersion из $versionCount';
  }

  @override
  String get editConversation => 'Изменить беседу';

  @override
  String get closeConversation => 'Закрыть беседу';

  @override
  String get openConversation => 'Открыть беседу';

  @override
  String get leaveConversation2 => 'Покинуть беседу';

  @override
  String get reportConversation2 => 'Пожаловаться на беседу';

  @override
  String get closeConversation2 => 'Закрыть беседу';

  @override
  String get closeConversationConfirmation =>
      'Закрыть эту беседу? Новые ответы будут невозможны.';

  @override
  String get close => 'Закрыть';

  @override
  String get openConversation2 => 'Открыть беседу';

  @override
  String get openConversationConfirmation =>
      'Открыть эту беседу? Снова можно будет отвечать.';

  @override
  String get open => 'Открыть';

  @override
  String get leaveConversation3 => 'Покинуть беседу';

  @override
  String get leaveConversationConfirmation =>
      'Покинуть эту беседу? Она будет скрыта из входящих.';

  @override
  String errorLoadingConversation(Object error) {
    return 'Ошибка загрузки беседы: $error';
  }

  @override
  String get conversationNotFound => 'Беседа не найдена';

  @override
  String get conversationClosedBanner =>
      'Беседа закрыта и больше не принимает ответы';

  @override
  String get noMessagesFound => 'Сообщения не найдены';

  @override
  String get endOfConversation => 'Конец беседы';

  @override
  String get jumpToMessage => 'Перейти к сообщению';

  @override
  String get editConversation2 => 'Изменить беседу';

  @override
  String get failedToLoadMessage2 => 'Не удалось загрузить сообщение';

  @override
  String get cannotEditThisConversation => 'Эту беседу нельзя изменить';

  @override
  String get options => 'Параметры';

  @override
  String get conversationOpen => 'Беседа открыта';

  @override
  String failedToCreateConversation(Object error) {
    return 'Не удалось создать беседу: $error';
  }

  @override
  String maximumAttachmentsAllowed(Object count) {
    return 'Не более $count вложений';
  }

  @override
  String get noImagesFoundToDisplay => 'Нет изображений для показа.';

  @override
  String get pleaseLoginToViewThisAttachment =>
      'Войдите, чтобы открыть вложение';

  @override
  String get searchForTopics => 'Поиск тем';

  @override
  String get noTopicsFound => 'Темы не найдены';

  @override
  String get trySearchingWithDifferentKeywords =>
      'Попробуйте другие ключевые слова';

  @override
  String get noPostsFound => 'Сообщения не найдены';

  @override
  String get perTopicNotificationLevelsNote =>
      'Уровни уведомлений для категорий и тем задаются на их экранах — нажмите значок колокольчика у темы или категории.';

  @override
  String get pushNotActiveForThisLogin =>
      'Не включены для этого входа — выйдите и войдите снова, чтобы разрешить push-уведомления';

  @override
  String get pauseNotificationsFor => 'Приостановить уведомления на…';

  @override
  String get doNotDisturbExplanation =>
      'Приостановить уведомления на время — Discourse задержит их до конца периода';

  @override
  String get emailSettingsSubtitle =>
      'Частота писем, объединение лайков, расписание дайджеста';

  @override
  String get manageAccountSubtitle =>
      'Профиль, почта, пароль, безопасность, расширенные настройки';

  @override
  String get changePasswordSubtitle =>
      'Отправить письмо для сброса пароля на текущий адрес';

  @override
  String get ignoredUsersSubtitle =>
      'Просмотр и управление пользователями, чьи сообщения скрыты от вас';

  @override
  String get deleteAccountExplanation =>
      'Удаление аккаунта выполняется на форуме. Нажмите «Продолжить», чтобы открыть сайт и связаться с персоналом — форумы Discourse обрабатывают удаления по своим правилам.';

  @override
  String get verificationEmailSent =>
      'Письмо для подтверждения отправлено — перейдите по ссылке, чтобы подтвердить новый адрес.';

  @override
  String get passwordResetExplanation =>
      'Мы отправим ссылку для сброса пароля. Перейдите по ней, чтобы задать новый пароль — изменение выполняется на форуме, а не в приложении.';

  @override
  String get sendResetEmail => 'Отправить письмо для сброса';

  @override
  String get deleteAccountDialogBody =>
      'Ваш аккаунт управляется форумом. Для удаления обратитесь напрямую к персоналу форума. «Продолжить» откроет форум в браузере, где можно воспользоваться его формой связи или сообщением персоналу.';

  @override
  String get initializingForum => 'Инициализация форума…';

  @override
  String get unableToLoadForums => 'Не удалось загрузить форумы';

  @override
  String get noForumsToDisplayExplanation =>
      'Нет форумов для отображения. Возможно, дело в правах доступа или структуре форума.';

  @override
  String get subscribedForums => 'Подписки на форумы';

  @override
  String get errorLoadingNotifications => 'Ошибка загрузки уведомлений';

  @override
  String get pullDownToRefresh => 'Потяните вниз, чтобы обновить';

  @override
  String get noNewNotificationsExplanation =>
      'Новых уведомлений нет. Загляните позже, чтобы увидеть обновления в темах, на которые вы подписаны.';

  @override
  String noTagsMatch(Object filter) {
    return 'Нет тегов, соответствующих «$filter».';
  }

  @override
  String noTopicsTagged(Object tag) {
    return 'Нет тем с тегом «$tag»';
  }

  @override
  String failedToBanUser2(Object error) {
    return 'Не удалось заблокировать пользователя: $error';
  }

  @override
  String unbanUserConfirmation(Object username) {
    return 'Разблокировать $username?';
  }

  @override
  String failedToUnbanUser2(Object error) {
    return 'Не удалось разблокировать пользователя: $error';
  }

  @override
  String get deletePostsProfilePostsAndComments =>
      'Удалить сообщения, записи профиля и комментарии';

  @override
  String spamCleanConfirmation(Object username) {
    return 'Очистить спам пользователя $username?';
  }

  @override
  String failedToCleanSpam(Object error) {
    return 'Не удалось очистить спам: $error';
  }

  @override
  String get searchUser => 'Поиск пользователя';

  @override
  String get tapToOpen => 'Нажмите, чтобы открыть';

  @override
  String get imageNotAvailable => 'Изображение недоступно';

  @override
  String get allForumTopicsHaveBeenMarkedAs =>
      'Все темы форума отмечены как прочитанные';

  @override
  String postsCount(Object count) {
    return 'Сообщений: $count';
  }

  @override
  String get permissionDeniedToSaveImage =>
      'Нет разрешения на сохранение изображения';

  @override
  String get postNotFound => 'Сообщение не найдено.';

  @override
  String get failedToUploadFilePleaseTryAgain =>
      'Не удалось загрузить файл. Попробуйте ещё раз.';

  @override
  String failedToUploadFile2(Object errorMessage) {
    return 'Не удалось загрузить файл: $errorMessage';
  }

  @override
  String get failedToPickFile => 'Не удалось выбрать файл';

  @override
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return 'Можно добавить ещё $remainingSlots вложений. Будут обработаны первые $remainingSlots2 изображений.';
  }

  @override
  String get attachmentLimitReachedSkippingRemainingImages =>
      'Достигнут лимит вложений. Остальные изображения пропущены.';

  @override
  String failedToUploadImagePleaseTryAgain(Object fileName) {
    return '$fileName: не удалось загрузить изображение. Попробуйте ещё раз.';
  }

  @override
  String failedToUploadImage2(Object errorMessage, Object fileName) {
    return '$fileName: не удалось загрузить изображение: $errorMessage';
  }

  @override
  String get failedToPickImage => 'Не удалось выбрать изображение';

  @override
  String failedToRemoveAttachment2(Object error) {
    return 'Не удалось удалить вложение: $error';
  }

  @override
  String sentFromMobileApp(Object siteName) {
    return 'Отправлено из мобильного приложения $siteName';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      'Дождитесь окончания загрузки вложений';

  @override
  String get imageIsTooLargeToUpload =>
      'Изображение слишком велико для загрузки';

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return 'Размер $fileName: $fileBytes. Форум допускает до $maxBytes.';
  }

  @override
  String get resizeToFitExplanation =>
      'Его можно уменьшить ровно настолько, чтобы уложиться в лимит, сохранив формат и максимум деталей.';

  @override
  String get failedToPostReplyPleaseTryAgain =>
      'Не удалось отправить ответ. Попробуйте ещё раз.';

  @override
  String get pleaseWaitForTheThreadToLoad => 'Дождитесь загрузки темы';

  @override
  String get failedToUpdatePostPleaseTryAgain =>
      'Не удалось обновить сообщение. Попробуйте ещё раз.';

  @override
  String get postDeletedSuccessfully => 'Сообщение удалено';

  @override
  String failedToDeletePost(Object error) {
    return 'Не удалось удалить сообщение: $error';
  }

  @override
  String failedToSubmitReport2(Object error) {
    return 'Не удалось отправить жалобу: $error';
  }

  @override
  String get editHistoryNotAvailable =>
      'История правок недоступна для этого сообщения';

  @override
  String get noPermissionToUploadAvatar => 'У вас нет прав на загрузку аватара';

  @override
  String get avatarUploadedSuccessfully => 'Аватар загружен';

  @override
  String failedToPickImage2(Object error) {
    return 'Не удалось выбрать изображение: $error';
  }

  @override
  String get react => 'Отреагировать';

  @override
  String get reactionsAreNotEnabledOnThisForum =>
      'Реакции на этом форуме отключены.';

  @override
  String get noReactionsYet => 'Реакций пока нет';

  @override
  String get searchFilters => 'Фильтры поиска';

  @override
  String signOutWarning(Object siteName) {
    return 'Вы выйдете из $siteName. Войти снова можно в любой момент.';
  }

  @override
  String get suggestedTopics => 'Похожие темы';

  @override
  String get newLabel => 'НОВОЕ';

  @override
  String get voteRemoved => 'Голос отозван';

  @override
  String get voters => 'Проголосовавшие';

  @override
  String get noVotesYet => 'Голосов пока нет.';

  @override
  String get trustLevels => 'Уровни доверия';

  @override
  String get trustLevelsExplanation =>
      'Участники зарабатывают доверие, читая и участвуя. Каждый уровень открывает новые возможности.';

  @override
  String get activity => 'Активность';

  @override
  String get dontUpload => 'Не загружать';

  @override
  String get dontAskAgainAlwaysResize =>
      'Больше не спрашивать — всегда уменьшать';

  @override
  String get couldNotLoadCategories => 'Не удалось загрузить категории.';

  @override
  String get switchForum => 'Сменить форум';

  @override
  String get explore => 'Обзор';

  @override
  String get tags => 'Теги';

  @override
  String get community => 'Сообщество';

  @override
  String get users => 'Пользователи';

  @override
  String get groups => 'Группы';

  @override
  String get invites => 'Приглашения';

  @override
  String get account => 'Аккаунт';

  @override
  String get drafts => 'Черновики';

  @override
  String get termsOfService => 'Условия использования';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String signedInAs(String username) {
    return 'Вы вошли как $username';
  }

  @override
  String get notSignedIn => 'Вы не вошли';
}
