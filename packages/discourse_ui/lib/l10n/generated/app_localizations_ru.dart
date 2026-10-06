// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get accountSessionChanged =>
      'Сеанс входа изменился. Откройте этот экран заново, чтобы продолжить.';

  @override
  String get draftSessionChanged =>
      'Сеанс входа изменился. Скопируйте текст, прежде чем снова открыть редактор для работы с черновиками.';

  @override
  String get discardFailedCloseQuestion =>
      'Всё равно закрыть? Сохранённый ранее черновик останется в разделе «Черновики».';

  @override
  String get keepEditing => 'Продолжить';

  @override
  String get closeAnyway => 'Всё равно закрыть';

  @override
  String get uploadSessionChanged =>
      'Во время загрузки изменился сеанс входа. Откройте этот экран заново, прежде чем повторить попытку.';

  @override
  String get submissionUnconfirmed =>
      'Не удалось подтвердить отправку. Ваш текст сохранён. Проверьте форум, прежде чем повторять попытку.';

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
  String get newConversation => 'Новое сообщение';

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
  String get youCannotReplyToThisThread => 'Вы не можете ответить на эту тему';

  @override
  String get pleaseWaitForThreadToLoad =>
      'Пожалуйста, подождите, пока тема загрузится';

  @override
  String get reason => 'Причина';

  @override
  String get participantsLabel => 'Участники';

  @override
  String usernameHasBeenInvited(String username) {
    return '$username приглашён(а) в сообщение';
  }

  @override
  String errorInvitingUser(String error) {
    return 'Ошибка приглашения пользователя: $error';
  }

  @override
  String get newTopic => 'Новая тема';

  @override
  String get pleaseSpecifyReason => 'Пожалуйста, укажите причину';

  @override
  String get selectDate => 'Выбрать дату';

  @override
  String get moreOptions => 'Дополнительные опции';

  @override
  String get topicClosed => 'Тема закрыта';

  @override
  String get topicOpened => 'Тема открыта';

  @override
  String get noConversations => 'У вас нет сообщений';

  @override
  String get noConversationsMessage =>
      'У вас пока нет сообщений. Напишите новое сообщение, чтобы начать.';

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
  String get sendMessage => 'Сообщение';

  @override
  String get likesReceived => 'Полученные Лайки';

  @override
  String get showMore => 'Показать больше';

  @override
  String get failedToSaveConversation => 'Не удалось сохранить сообщение';

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
  String get signIn => 'Войти';

  @override
  String get notificationTest => 'Тест Уведомлений';

  @override
  String get forum => 'Категория';

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
      'Войдите, чтобы увидеть свои сообщения.';

  @override
  String failedToLeaveConversation(String error) {
    return 'Не удалось покинуть сообщение: $error';
  }

  @override
  String errorLoadingMoreConversations(String error) {
    return 'Ошибка загрузки других сообщений: $error';
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
  String get temporary => 'Временный';

  @override
  String get back => 'Назад';

  @override
  String get confirm => 'Подтвердить';

  @override
  String error(String error) {
    return 'Ошибка: $error';
  }

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
  String get refresh => 'Обновить';

  @override
  String get share => 'Поделиться';

  @override
  String get viewOnWeb => 'Открыть в браузере';

  @override
  String get reply => 'Ответить';

  @override
  String get vote => 'Голосовать';

  @override
  String votesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count голоса',
      many: '$count голосов',
      few: '$count голоса',
      one: '$count голос',
    );
    return '$_temp0';
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
  String get appearance => 'Оформление';

  @override
  String get appearanceSystem => 'Как в системе';

  @override
  String version(String version, String buildNumber) {
    return 'версия $version ($buildNumber)';
  }

  @override
  String get unableToLoadProfile => 'Не удалось загрузить профиль';

  @override
  String get banned => 'ЗАБЛОКИРОВАН';

  @override
  String get deleteTopic => 'Удалить тему';

  @override
  String get home => 'Главная';

  @override
  String get notifications => 'Уведомления';

  @override
  String get notificationsTab => 'Оповещения';

  @override
  String get forums => 'Категории';

  @override
  String get content => 'Содержание';

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
  String get writeYourMessage => 'Напишите ваше сообщение...';

  @override
  String get writeYourReply => 'Напишите ваш ответ...';

  @override
  String get conversationMarkedAsUnread =>
      'Сообщение отмечено как непрочитанное';

  @override
  String get conversationClosed => 'Сообщение закрыто';

  @override
  String get conversationOpened => 'Сообщение открыто';

  @override
  String failedToLoadQuote(String error) {
    return 'Не удалось загрузить цитату: \n$error';
  }

  @override
  String failedToMarkConversationAsUnread(String error) {
    return 'Не удалось отметить сообщение как непрочитанное: $error';
  }

  @override
  String failedToCloseConversation(String error) {
    return 'Не удалось закрыть сообщение: $error';
  }

  @override
  String failedToOpenConversation(String error) {
    return 'Не удалось открыть сообщение: $error';
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
  String get enterConversationTitle => 'Введите заголовок сообщения';

  @override
  String enterCode(int count) {
    return 'Введите $count-значный код';
  }

  @override
  String get edit => 'Редактировать';

  @override
  String get remove => 'Удалить';

  @override
  String get subject => 'Тема';

  @override
  String get message => 'Сообщение';

  @override
  String get titleCannotBeEmpty => 'Заголовок не может быть пустым';

  @override
  String get conversationUpdatedSuccessfully => 'Сообщение обновлено';

  @override
  String get goBack => 'Назад';

  @override
  String get like => 'лайкнуть';

  @override
  String get download => 'Скачать';

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
  String get chat => 'Чат';

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
  String get checkConnectionAndRetry =>
      'Проверьте подключение к интернету и повторите попытку.';

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
  String get undeleteTopic => 'Отменить удаление темы';

  @override
  String get send => 'Отправить';

  @override
  String get changeEmailExplanation =>
      'Мы отправим ссылку для подтверждения на новый адрес. Изменение вступит в силу после перехода по ней.';

  @override
  String get changeEmailSecurityNote =>
      'Для безопасности Discourse может запросить подтверждение по ссылке из письма. Проверьте папку «Спам», если письма нет.';

  @override
  String get noMessagesYetSayHi => 'Сообщений пока нет — поздоровайтесь.';

  @override
  String get edited => 'изменено';

  @override
  String get approvedButRelayUnreachable =>
      'Одобрено, но не удалось связаться с сервером уведомлений, чтобы завершить настройку. Повторите попытку позже в настройках.';

  @override
  String get notificationsAreTurnedOffForThisApp =>
      'Уведомления для этого приложения отключены';

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
  String get solution => 'Решение';

  @override
  String get deleted => 'УДАЛЕНО';

  @override
  String get pleaseLoginToViewUserProfiles =>
      'Войдите, чтобы просматривать профили.';

  @override
  String get solved => 'Решено';

  @override
  String get hot => 'Популярное';

  @override
  String get pinned => 'Закреплено';

  @override
  String get locked => 'Закрыто';

  @override
  String get poll => 'Опрос';

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
  String get editConversation => 'Изменить заголовок';

  @override
  String get closeConversation => 'Закрыть сообщение';

  @override
  String get openConversation => 'Открыть сообщение';

  @override
  String get leaveConversation2 => 'Покинуть сообщение';

  @override
  String get closeConversation2 => 'Закрыть сообщение';

  @override
  String get closeConversationConfirmation =>
      'Закрыть это сообщение? В нём больше нельзя будет отвечать.';

  @override
  String get close => 'Закрыть';

  @override
  String get openConversation2 => 'Открыть сообщение';

  @override
  String get openConversationConfirmation =>
      'Открыть это сообщение? В нём снова можно будет отвечать.';

  @override
  String get open => 'Открыть';

  @override
  String get leaveConversation3 => 'Покинуть сообщение';

  @override
  String get leaveConversationConfirmation =>
      'Вы уверены, что хотите выйти из этого сообщения? Вы больше не сможете видеть его или отвечать в нём.';

  @override
  String get editConversation2 => 'Изменить заголовок';

  @override
  String get failedToLoadMessage2 => 'Не удалось загрузить сообщение';

  @override
  String get cannotEditThisConversation =>
      'Вы не можете изменить это сообщение';

  @override
  String get options => 'Параметры';

  @override
  String get conversationOpen => 'Открыто для ответов';

  @override
  String get messageTitleHint => 'Название: суть коротким предложением';

  @override
  String get messageOpenForReplies => 'Можно отвечать';

  @override
  String get messageClosedForReplies => 'Закрыто: отвечать нельзя';

  @override
  String get messageSentWithoutId =>
      'Сообщение отправлено, но форум его не вернул. Проверьте свои сообщения.';

  @override
  String get messageCouldNotBeSent => 'Не удалось отправить сообщение.';

  @override
  String get messageIdMissing =>
      'Не удаётся открыть сообщение: отсутствует его ID.';

  @override
  String get pleaseAddARecipient => 'Добавьте хотя бы одного получателя';

  @override
  String get archiveMessage => 'Архивировать';

  @override
  String get moveToInbox => 'Переместить во входящие';

  @override
  String get messageInbox => 'Входящие';

  @override
  String get messageArchive => 'Архив';

  @override
  String get messageListUnread => 'Непрочитанные';

  @override
  String get messageListNew => 'Новые';

  @override
  String get messageListSent => 'Отправленные';

  @override
  String removeFromMessageConfirm(String name) {
    return 'Действительно удалить $name из этого сообщения?';
  }

  @override
  String uploadingFilename(String filename) {
    return 'Загрузка: $filename…';
  }

  @override
  String get messageArchived => 'Сообщение перемещено в архив';

  @override
  String get messageMovedToInbox => 'Перемещено во входящие';

  @override
  String failedToArchiveMessage(Object error) {
    return 'Не удалось переместить сообщение в архив: $error';
  }

  @override
  String failedToMoveMessageToInbox(Object error) {
    return 'Не удалось переместить сообщение во входящие: $error';
  }

  @override
  String get noArchivedMessages => 'У вас нет сообщений в архиве';

  @override
  String get noArchivedMessagesHint =>
      'Переместите сообщение в архив через меню ⋮, и оно появится здесь.';

  @override
  String groupHasBeenInvited(String group) {
    return 'Группа $group приглашена в сообщение';
  }

  @override
  String participantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участника',
      many: '$count участников',
      few: '$count участника',
      one: '$count участник',
    );
    return '$_temp0';
  }

  @override
  String get chatChannels => 'Каналы';

  @override
  String get chatDms => 'Прямые сообщения';

  @override
  String get chatNoChannels => 'Вы еще не присоединились ни к одному каналу!';

  @override
  String get chatNoDms => 'Вы еще не начали общение через прямые сообщения!';

  @override
  String get chatNoDmsCta => 'Начать разговор';

  @override
  String chatPlaceholderChannel(String channel) {
    return 'Чат в канале «$channel»';
  }

  @override
  String chatPlaceholderUsers(String names) {
    return 'Чат с $names';
  }

  @override
  String get chatPlaceholderSelf => 'Напишите что-нибудь';

  @override
  String get chatPlaceholderArchived =>
      'Канал архивирован, вы не можете отправлять новые сообщения.';

  @override
  String get chatPlaceholderClosed =>
      'Канал закрыт, вы не можете отправлять новые сообщения.';

  @override
  String get chatPlaceholderReadOnly =>
      'Канал в режиме «только для чтения», вы не можете отправлять новые сообщения.';

  @override
  String get chatPlaceholderSilenced =>
      'В настоящее время вы не можете отправлять сообщения.';

  @override
  String get chatDeleteConfirm =>
      'Вы уверены, что хотите удалить это сообщение?';

  @override
  String get chatStartNewDm => 'Начать новый DM';

  @override
  String get chatCreatePersonal => 'Создать личный чат';

  @override
  String get chatCreateGroup => 'Создать групповой чат';

  @override
  String get chatCannotCreate => 'Вы не можете отправлять прямые сообщения.';

  @override
  String get chatDisabledUser => 'отключил(а) чат';

  @override
  String get chatSearchPlaceholder => '@пользователь';

  @override
  String get chatAddMorePlaceholder => '... добавить еще участников';

  @override
  String chatUserNotFound(String name) {
    return '@$name не найден(а)';
  }

  @override
  String get chatCouldNotStartDm => 'Не удалось начать чат.';

  @override
  String get chatSignInTitle => 'Войдите, чтобы пользоваться чатом';

  @override
  String get chatSignInMessage =>
      'Войдите, чтобы видеть каналы чата и присоединяться к ним.';

  @override
  String get chatDirectMessage => 'Прямое сообщение';

  @override
  String get chatNotAvailable => 'Чат недоступен на этом форуме.';

  @override
  String get chatAttachFile => 'Прикрепить файл';

  @override
  String get chatRemoveUpload => 'Удалить файл';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get postNeedsApprovalTitle => 'Сообщение требует одобрения';

  @override
  String get postNeedsApprovalBody =>
      'Сообщение получено, но оно требует проверки и утверждения модератором перед публикацией. Будьте терпеливы.';

  @override
  String maximumAttachmentsAllowed(Object count) {
    return 'Не более $count вложений';
  }

  @override
  String get noImagesFoundToDisplay => 'Нет изображений для показа.';

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
      'Удалите свой аккаунт и сообщения, если форум это разрешает. Иначе его может удалить команда форума.';

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
  String get errorLoadingNotifications => 'Ошибка загрузки уведомлений';

  @override
  String get noNewNotificationsExplanation =>
      'На этой панели будут отображаться уведомления об активности на форуме, имеющей прямое отношение к вам, включая ответы на ваши темы и публикации, @упоминание и цитирование вас, ответы на темы, которые вы отслеживаете. Уведомления также будут отправлены на вашу электронную почту, если вы отсутствовали на форуме в течение некоторого времени.';

  @override
  String noTagsMatch(Object filter) {
    return 'Нет тегов, соответствующих «$filter».';
  }

  @override
  String noTopicsTagged(Object tag) {
    return 'Нет тем с тегом «$tag»';
  }

  @override
  String get searchUser => 'Поиск пользователя';

  @override
  String get tapToOpen => 'Нажмите, чтобы открыть';

  @override
  String get imageNotAvailable => 'Изображение недоступно';

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
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return 'Можно добавить ещё $remainingSlots вложений. Будут обработаны первые $remainingSlots2 изображений.';
  }

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
  String get failedToUpdatePostPleaseTryAgain =>
      'Не удалось обновить сообщение. Попробуйте ещё раз.';

  @override
  String get postDeletedSuccessfully => 'Сообщение удалено';

  @override
  String failedToDeletePost(Object error) {
    return 'Не удалось удалить сообщение: $error';
  }

  @override
  String get editHistoryNotAvailable =>
      'История правок недоступна для этого сообщения';

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
  String get suggestedTopics => 'Похожие темы';

  @override
  String get suggestedMessages => 'Похожие сообщения';

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
  String get notSignedIn => 'Вы не вошли';

  @override
  String get deviceWillNotShowAlertsUntilAllowedInSettings =>
      'Устройство не будет показывать уведомления, пока вы не разрешите их в настройках.';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get notificationsThisDeviceSection => 'На этом устройстве';

  @override
  String notificationsThisDeviceCaption(Object forumName) {
    return 'Push от $forumName только на это устройство. Другие ваши устройства и веб-версия не затрагиваются.';
  }

  @override
  String notificationsAccountSection(Object forumName) {
    return 'Ваш аккаунт на $forumName';
  }

  @override
  String get notificationsAccountCaption =>
      'Действуют везде: в веб-версии, в письмах и на всех ваших устройствах.';

  @override
  String pushOnThisDeviceSubtitle(Object forumName) {
    return 'Включено: новые уведомления $forumName приходят на это устройство.';
  }

  @override
  String pushOffThisDeviceSubtitle(Object forumName) {
    return 'На этом устройстве выключено. Чтобы включить, подтвердите один раз на $forumName.';
  }

  @override
  String get stopPushOnThisDevice => 'Отключить push на этом устройстве';

  @override
  String stopPushTitle(Object forumName) {
    return 'Отключить push от $forumName на этом устройстве?';
  }

  @override
  String get stopPushOnlyThisDevice =>
      'Отключится только это устройство. Другие ваши устройства продолжат получать push.';

  @override
  String get stopPushNothingElseChanges =>
      'Уведомления по-прежнему видны в приложении и в веб-версии, а письма форума не меняются.';

  @override
  String stopPushPermissionDeleted(Object forumName) {
    return 'Разрешение, выданное на $forumName, будет удалено. Чтобы снова включить push, его нужно будет подтвердить там ещё раз.';
  }

  @override
  String get stopPushQuietHint =>
      'Нужна тишина ненадолго? Отключите выше ненужные типы или включите «Не беспокоить» в профиле.';

  @override
  String get stopPush => 'Отключить push';

  @override
  String get turnOn => 'Включить';

  @override
  String get couldNotTurnOffNotifications =>
      'Не удалось отключить push. Повторите попытку позже.';

  @override
  String actionCodeTopicCreated(String when) {
    return 'Эта тема создана $when';
  }

  @override
  String actionCodePublicTopic(String when) {
    return 'Сделал(а) тему публичной $when';
  }

  @override
  String actionCodeOpenTopic(String when) {
    return 'Преобразовал(а) это в тему $when';
  }

  @override
  String actionCodePrivateTopic(String when) {
    return 'Сделал(а) тему личным сообщением $when';
  }

  @override
  String actionCodeSplitTopic(String when) {
    return 'Разделил(а) эту тему $when';
  }

  @override
  String actionCodeInvitedUser(String who, String when) {
    return 'Пригласил(а) $who $when';
  }

  @override
  String actionCodeInvitedGroup(String who, String when) {
    return 'Пригласил(а) $who $when';
  }

  @override
  String actionCodeUserLeft(String who, String when) {
    return '$who удалил(а) себя из этого сообщения $when';
  }

  @override
  String actionCodeRemovedUser(String who, String when) {
    return 'Удалил(а) $who $when';
  }

  @override
  String actionCodeRemovedGroup(String who, String when) {
    return 'Удалил(а) $who $when';
  }

  @override
  String actionCodeAutobumped(String when) {
    return 'Автоматически поднято $when';
  }

  @override
  String actionCodeTagsChanged(String when) {
    return 'Теги обновлены $when';
  }

  @override
  String actionCodeCategoryChanged(String when) {
    return 'Категория обновлена $when';
  }

  @override
  String get actionCodeForwarded => 'Переадресовал(а) вышеуказанное письмо';

  @override
  String actionCodeAutoclosedEnabled(String when) {
    return 'Закрыл(а) тему $when';
  }

  @override
  String actionCodeAutoclosedDisabled(String when) {
    return 'Открыл(а) тему $when';
  }

  @override
  String actionCodeClosedEnabled(String when) {
    return 'Закрыл(а) тему $when';
  }

  @override
  String actionCodeClosedDisabled(String when) {
    return 'Открыл(а) тему $when';
  }

  @override
  String actionCodeArchivedEnabled(String when) {
    return 'Архивировал(а) тему $when';
  }

  @override
  String actionCodeArchivedDisabled(String when) {
    return 'Разархивировал(а) тему $when';
  }

  @override
  String actionCodePinnedEnabled(String when) {
    return 'Закрепил(а) тему $when';
  }

  @override
  String actionCodePinnedDisabled(String when) {
    return 'Открепил(а) тему глобально $when';
  }

  @override
  String actionCodePinnedGloballyEnabled(String when) {
    return 'Закрепил(а) тему глобально $when';
  }

  @override
  String actionCodePinnedGloballyDisabled(String when) {
    return 'Открепил(а) тему глобально $when';
  }

  @override
  String actionCodeVisibleEnabled(String when) {
    return 'Включил(а) отображение темы $when';
  }

  @override
  String actionCodeVisibleDisabled(String when) {
    return 'Выключил(а) отображение темы $when';
  }

  @override
  String actionCodeBannerEnabled(String when) {
    return 'Создал(а) баннер $when, который будет отображаться сверху на всех страницах, пока пользователь не скроет его.';
  }

  @override
  String actionCodeBannerDisabled(String when) {
    return 'Удалил(а) баннер $when. Он не будет отображаться вверху каждой страницы.';
  }

  @override
  String actionCodeAssigned(String who, String when) {
    return 'Назначил(а) ответственным $who $when';
  }

  @override
  String actionCodeUnassigned(String who, String when) {
    return 'Снял(а) ответственного $who $when';
  }

  @override
  String actionCodeReassigned(String who, String when) {
    return 'Переназначено: $who $when';
  }

  @override
  String localDateToday(String time) {
    return 'Сегодня $time';
  }

  @override
  String localDateTomorrow(String time) {
    return 'Завтра $time';
  }

  @override
  String localDateYesterday(String time) {
    return 'Вчера $time';
  }

  @override
  String get eventExpired => 'Истекший срок';

  @override
  String get eventEveryDay => 'Каждый день';

  @override
  String get eventEveryWeekday => 'Каждый будний день';

  @override
  String get eventEveryWeek => 'Каждую неделю в этот будний день';

  @override
  String get eventEveryTwoWeeks => 'Каждые две недели в этот будний день';

  @override
  String get eventEveryFourWeeks => 'Каждые четыре недели в этот будний день';

  @override
  String get eventEveryMonth => 'Каждый месяц в этот будний день';

  @override
  String get errorNoConnection =>
      'Не удалось подключиться к форуму. Проверьте соединение и повторите попытку.';

  @override
  String get errorTimedOut =>
      'Форум слишком долго не отвечает. Повторите попытку.';

  @override
  String get errorPaywalled => 'Это доступно только платным участникам форума.';

  @override
  String get errorBlocked =>
      'Брандмауэр форума заблокировал приложение. Повторите попытку позже или откройте форум в браузере.';

  @override
  String get errorNotAllowed =>
      'У вас нет доступа к этому. Возможно, поможет вход в аккаунт.';

  @override
  String get errorNotFound => 'Этого не существует, или это было удалено.';

  @override
  String get errorRateLimited =>
      'Вы делаете это слишком часто. Подождите немного и повторите попытку.';

  @override
  String get errorForumDown =>
      'Форум сейчас не отвечает. Повторите попытку позже.';

  @override
  String get deleteSpammer => 'Удалить спамера';

  @override
  String get yesDeleteSpammer => 'Да, удалить спамера';

  @override
  String get deleteSpammerConfirm =>
      'Вы собираетесь удалить сообщения и темы этого пользователя, а также удалить его аккаунт, добавить его IP-адрес и его почтовый адрес в черный список. Вы действительно уверены, что этот пользователь — спамер?';

  @override
  String get userWasDeleted => 'Пользователь удалён.';

  @override
  String get deleteMyAccount => 'Удалить мой аккаунт';

  @override
  String get deleteAccountConfirm =>
      'Действительно удалить аккаунт? Отменить удаление будет невозможно!';

  @override
  String get deletedYourself => 'Ваш аккаунт удален.';

  @override
  String get deleteYourselfNotAllowed =>
      'Чтобы удалить аккаунт, свяжитесь с администрацией сайта.';

  @override
  String get createTopic => 'Создать тему';

  @override
  String get discardPostQuestion => 'Отказаться от сообщения?';

  @override
  String get discardChangesQuestion => 'Отменить изменения?';

  @override
  String get discardChanges => 'Отменить изменения';

  @override
  String get saveDraft => 'Сохранить черновик';

  @override
  String get notificationSettings => 'Настройки уведомлений';

  @override
  String get topicIsNew => 'Новая тема';

  @override
  String get noNewTopicsSinceLastVisit =>
      'С вашего последнего визита новых тем нет.';

  @override
  String get messageIsNew => 'Новое сообщение';

  @override
  String topicUnreadReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count непрочитанных ответа',
      many: '$count непрочитанных ответов',
      few: '$count непрочитанных ответа',
      one: '$count непрочитанный ответ',
    );
    return '$_temp0';
  }

  @override
  String filterNewWithCount(int count) {
    return 'Новые ($count)';
  }

  @override
  String filterUnreadWithCount(int count) {
    return 'Непрочитанные ($count)';
  }

  @override
  String categoryNewTopics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count новые',
      many: '$count новых',
      few: '$count новые',
      one: '$count новая',
    );
    return '$_temp0';
  }

  @override
  String categoryUnreadTopics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count непрочитанные',
      many: '$count непрочитанных',
      few: '$count непрочитанные',
      one: '$count непрочитанная',
    );
    return '$_temp0';
  }

  @override
  String get dismissNew => 'Отклонить новые';

  @override
  String get dismissUnread => 'Отложить непрочитанные';

  @override
  String get dismissNewTitle => 'Отклонить новые темы?';

  @override
  String get dismissNewMessage => 'Они больше не будут отмечены как новые.';

  @override
  String get dismissUnreadTitle => 'Отложить все непрочитанные?';

  @override
  String get dismissUnreadMessage =>
      'Их новые ответы будут отмечены как прочитанные.';

  @override
  String get dismissUnreadStopTracking =>
      'Перестать следить за этими темами, чтобы они никогда больше не высвечивались как непрочитанные';

  @override
  String get dismissNewAndUnread => 'Отложить новые и непрочитанные';

  @override
  String dismissNewAndUnreadMessage(String category) {
    return 'Темы в $category больше не будут отмечены как новые или непрочитанные.';
  }

  @override
  String get dismissedTopics => 'Отложено';

  @override
  String topicMapViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'просмотра',
      many: 'просмотров',
      few: 'просмотра',
      one: 'просмотр',
    );
    return '$_temp0';
  }

  @override
  String topicMapLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'лайка',
      many: 'лайков',
      few: 'лайка',
      one: 'лайк',
    );
    return '$_temp0';
  }

  @override
  String topicMapLinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ссылки',
      many: 'ссылок',
      few: 'ссылки',
      one: 'ссылка',
    );
    return '$_temp0';
  }

  @override
  String topicMapUsers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'пользователя',
      many: 'пользователей',
      few: 'пользователя',
      one: 'пользователь',
    );
    return '$_temp0';
  }

  @override
  String get markAsSolution => 'Отметить как решение';

  @override
  String get unmarkAsSolution => 'Снять отметку решения';

  @override
  String searchForumName(String forum) {
    return 'Поиск: $forum';
  }

  @override
  String countActiveThisMonth(String formatted) {
    return '$formatted активны в этом месяце';
  }

  @override
  String countMembers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted участника',
      many: '$formatted участников',
      few: '$formatted участника',
      one: '$formatted участник',
    );
    return '$_temp0';
  }

  @override
  String countTopics(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted темы',
      many: '$formatted тем',
      few: '$formatted темы',
      one: '$formatted тема',
    );
    return '$_temp0';
  }

  @override
  String categoryNewThisWeek(int count) {
    return '$count новых за неделю';
  }

  @override
  String get categoriesView => 'Категории';

  @override
  String get allCategories => 'Все категории';

  @override
  String get allTags => 'Все теги';

  @override
  String get myPosts => 'Мои сообщения';

  @override
  String get drawerIntroduction =>
      'Категории, теги и ваш аккаунт на этом форуме — в этом меню. Открыть его снова можно в любой момент кнопкой меню.';

  @override
  String trustLevelN(int level) {
    return 'Уровень доверия $level';
  }

  @override
  String get filterNew => 'Новые';

  @override
  String get filterTop => 'Обсуждаемые';

  @override
  String get levelWatching => 'Наблюдение';

  @override
  String get levelWatchingFirstPost => 'Наблюдение за первым сообщением';

  @override
  String get levelTracking => 'Отслеживание';

  @override
  String get levelNormal => 'Обычный';

  @override
  String get levelMuted => 'Без уведомлений';

  @override
  String get chooseCategory => 'Выберите категорию';

  @override
  String get signInToPostAndGetNotifications =>
      'Войдите, чтобы писать и получать уведомления';

  @override
  String forumBlocksNotificationServer(Object forumName) {
    return '$forumName блокирует наш сервер уведомлений, поэтому они могут не приходить. Их можно отключить в настройках.';
  }

  @override
  String get relatedTopics => 'Связанные темы';

  @override
  String get relatedMessages => 'Связанные сообщения';

  @override
  String moreInCategory(String category) {
    return 'Ещё в разделе «$category»';
  }

  @override
  String get latestTopics => 'Последние темы';

  @override
  String get pushGroupMessages => 'Сообщения и чат';

  @override
  String get pushGroupMessagesHint =>
      'Личные сообщения, групповые входящие и чат';

  @override
  String get pushGroupReplies => 'Ответы и упоминания';

  @override
  String get pushGroupRepliesHint =>
      'Ответы, упоминания, цитаты и отслеживаемые темы';

  @override
  String get pushGroupReactions => 'Лайки и реакции';

  @override
  String get pushGroupReactionsHint => 'Лайки и реакции на ваши сообщения';

  @override
  String get pushGroupOther => 'Всё остальное';

  @override
  String get pushGroupOtherHint =>
      'Значки, напоминания, принятые ответы и прочее';

  @override
  String get pushChannelOther => 'Другие уведомления';

  @override
  String get couldNotChangePushSetting =>
      'Не удалось изменить эту настройку. Повторите попытку позже.';

  @override
  String neverMissAReplyOn(Object forumName) {
    return 'Не пропускайте ответы на $forumName';
  }

  @override
  String get notificationsPitch =>
      'Ответы, упоминания, сообщения и чат на экране блокировки, обычно в течение 10 минут. Что получать, можно выбрать в любой момент в настройках.';

  @override
  String get notificationsStepAllow => 'Разрешить уведомления на этом телефоне';

  @override
  String get notificationsStepAllowed =>
      'Уведомления на этом телефоне разрешены';

  @override
  String notificationsStepApprove(Object forumName) {
    return 'Одобрить на $forumName';
  }

  @override
  String get notificationsReadOnlyNote =>
      'Только чтение: не может публиковать, отвечать или читать ваши сообщения';

  @override
  String get notificationPreviewReply =>
      'Jane ответила вам: Добро пожаловать! Рады, что вы нас нашли.';

  @override
  String get notificationPreviewMessage =>
      'Sam отправил вам сообщение: Придёшь в пятницу?';

  @override
  String get notificationPreviewNow => 'сейчас';

  @override
  String get notificationPreviewEarlier => '5 мин назад';

  @override
  String get activityReplied => 'Ответ';

  @override
  String get activityStartedTopic => 'Создана тема';

  @override
  String get activityLiked => 'Понравилось';

  @override
  String get activitySolution => 'Решение';

  @override
  String get activityAcceptedBy => 'принял(а)';

  @override
  String get activityAwaitingApproval => 'Ожидает одобрения';

  @override
  String get activityFilterTopics => 'Темы';

  @override
  String get activityFilterReplies => 'Ответы';

  @override
  String get activityFilterLikes => 'Лайки';

  @override
  String get activityFilterPending => 'На проверке';

  @override
  String get sectionToday => 'Сегодня';

  @override
  String get sectionThisWeek => 'На этой неделе';

  @override
  String get sectionEarlier => 'Ранее';

  @override
  String draftsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count черновика ждут',
      many: '$count черновиков ждут',
      few: '$count черновика ждут',
      one: '$count черновик ждёт',
    );
    return '$_temp0';
  }

  @override
  String get resumeDrafts => 'Продолжить';

  @override
  String get myPostsEmpty => 'Пока нет сообщений';

  @override
  String get myPostsEmptyHint =>
      'Здесь появятся созданные вами темы и написанные ответы.';

  @override
  String get activityEmptyTopics => 'Пока нет тем';

  @override
  String get activityEmptyReplies => 'Пока нет ответов';

  @override
  String get activityEmptyLikes => 'Вы ещё не ставили лайки';

  @override
  String get activityEmptySolved => 'Пока нет решений';

  @override
  String get viewProfile => 'Открыть профиль';

  @override
  String get yourStuff => 'Ваше';

  @override
  String get accountAndPrivacy => 'Аккаунт и приватность';

  @override
  String profileStatPosts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'сообщения',
      many: 'сообщений',
      few: 'сообщения',
      one: 'сообщение',
    );
    return '$_temp0';
  }

  @override
  String profileStatLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'лайка',
      many: 'лайков',
      few: 'лайка',
      one: 'лайк',
    );
    return '$_temp0';
  }

  @override
  String profileStatDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'дня',
      many: 'дней',
      few: 'дня',
      one: 'день',
    );
    return '$_temp0';
  }

  @override
  String get profileStatSolved => 'решено';

  @override
  String joinForum(String forum) {
    return 'Присоединиться к $forum';
  }

  @override
  String get guestBenefitPost => 'Отвечать и создавать темы';

  @override
  String get guestBenefitNotify => 'Получать уведомления об ответах';

  @override
  String get guestBenefitSave => 'Сохранять закладки и черновики';

  @override
  String get guestBenefitChat => 'Чат и личные сообщения';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get aboutThisForum => 'Об этом форуме';

  @override
  String get drawerMore => 'Ещё';

  @override
  String get goToYourProfile => 'Перейти в профиль';

  @override
  String profileJoined(String date) {
    return 'С нами с $date';
  }

  @override
  String profileSeen(String when) {
    return 'Был(а) $when';
  }

  @override
  String profileLocalTime(String time) {
    return '$time по местному времени';
  }

  @override
  String get profileTabSummary => 'Сводка';

  @override
  String get summaryTopReplies => 'Лучшие ответы';

  @override
  String get summaryTopTopics => 'Лучшие темы';

  @override
  String get summaryMostLikedBy => 'Больше всего лайков от';

  @override
  String get summaryMostLiked => 'Больше всего лайкает';

  @override
  String get summaryMostRepliedTo => 'Чаще всего отвечает';

  @override
  String get summaryTopLinks => 'Популярные ссылки';

  @override
  String get summaryTopCategories => 'Основные разделы';

  @override
  String get featuredTopic => 'Избранная тема';

  @override
  String get profileDetails => 'Подробности';

  @override
  String get followUser => 'Подписаться';

  @override
  String get unfollowUser => 'Отписаться';

  @override
  String get profileSuspended => 'Заблокирован(а)';

  @override
  String get searchBookmarks => 'Поиск по закладкам';

  @override
  String get bookmarksFilterReminders => 'Напоминания';

  @override
  String get bookmarkWholeTopic => 'Вся тема';

  @override
  String bookmarkSaved(String when) {
    return 'сохранено $when';
  }

  @override
  String bookmarkPostNumber(int number) {
    return 'сообщение №$number';
  }

  @override
  String reminderToday(String time) {
    return 'Сегодня, $time';
  }

  @override
  String reminderTomorrow(String time) {
    return 'Завтра, $time';
  }

  @override
  String reminderDue(String when) {
    return 'Срок · $when';
  }

  @override
  String get addBookmarkLabel => 'Добавить метку';

  @override
  String get editBookmarkLabel => 'Изменить метку';

  @override
  String get bookmarkLabelHint => 'Для чего это?';

  @override
  String get pinBookmark => 'Закрепить сверху';

  @override
  String get unpinBookmark => 'Открепить';

  @override
  String get bookmarkRemoved => 'Закладка удалена';

  @override
  String get undo => 'Отменить';

  @override
  String get bookmarksNoMatch => 'Нет подходящих закладок';

  @override
  String get addReminder => 'Добавить напоминание';

  @override
  String get bookmarksEmpty => 'Пока нет закладок';

  @override
  String get bookmarksEmptyHint =>
      'Добавьте сообщение в закладки через его действия, и оно будет ждать здесь.';

  @override
  String get draftKindNewTopic => 'Новая тема';

  @override
  String draftMessageTo(String names) {
    return 'Сообщение для $names';
  }

  @override
  String get untitledTopic => 'Тема без названия';

  @override
  String get draftDiscarded => 'Черновик удалён';

  @override
  String get draftsEmpty => 'Пока нет черновиков';

  @override
  String get draftsEmptyHint =>
      'Черновики сохраняются, пока вы пишете. Начните ответ или тему, и он будет ждать здесь.';

  @override
  String get privacySection => 'Приватность';

  @override
  String get changeEmailSubtitle =>
      'Мы отправим ссылку для подтверждения на новый адрес';

  @override
  String get aboutMe => 'О себе';

  @override
  String get aboutMeHelper => 'Показывается в верхней части профиля';

  @override
  String get aboutMeMarkdownHint =>
      'Поддерживается Markdown: **жирный**, ссылки, :emoji:';

  @override
  String get addCover => 'Добавить обложку';

  @override
  String get changeCover => 'Сменить обложку';

  @override
  String get birthdayHint => 'Форум поздравит вас. Год не сохраняется.';

  @override
  String get birthdayRemoved => 'День рождения удалён';

  @override
  String get birthdaySaved => 'День рождения сохранён';

  @override
  String get cardBackground => 'Фон карточки';

  @override
  String get cardBackgroundExplanation =>
      'За вашей карточкой пользователя, когда кто-то нажимает на ваше фото';

  @override
  String get cardBackgroundRemoved => 'Фон карточки удалён';

  @override
  String get cardBackgroundSheetHint =>
      'Показывается за вашей карточкой пользователя. Лучше всего подходят широкие фото.';

  @override
  String get changeProfilePicture => 'Сменить фото профиля';

  @override
  String get changeUsername => 'Сменить имя пользователя';

  @override
  String changeUsernameExplanation(String username) {
    return 'Упоминания и цитаты @$username в сообщениях перейдут на новое имя. Старые ссылки на ваш профиль перестанут работать.';
  }

  @override
  String get chooseFromLibrary => 'Выбрать из галереи';

  @override
  String get coverPhoto => 'Обложка';

  @override
  String get coverPhotoSheetHint =>
      'Показывается в верхней части профиля, за вашим фото. Лучше всего подходят широкие фото, примерно 3 к 1.';

  @override
  String get coverRemoved => 'Обложка удалена';

  @override
  String get day => 'День';

  @override
  String get month => 'Месяц';

  @override
  String get displayName => 'Отображаемое имя';

  @override
  String displayNameHelper(String username) {
    return 'Показывается рядом с вашими сообщениями. Имя пользователя остаётся @$username.';
  }

  @override
  String get emailPasswordInAccount => 'Почта, пароль и вход';

  @override
  String get featureATopic => 'Выбрать избранную тему';

  @override
  String get featureATopicHint => 'Закрепите одну из своих тем вверху профиля.';

  @override
  String get featuredTopicChanged => 'Избранная тема изменена';

  @override
  String get featuredTopicNone => 'Нет. Закрепите одну из своих тем в профиле.';

  @override
  String get featuredTopicRemoved => 'Избранная тема убрана';

  @override
  String get featuredTopicRules =>
      'Сообщения и темы из закрытых категорий нельзя сделать избранными.';

  @override
  String get fieldManagedBySignIn =>
      'Этим управляет собственная система входа форума. Измените это там.';

  @override
  String get flair => 'Значок группы';

  @override
  String flairChangedTo(String group) {
    return 'Значок группы изменён: $group';
  }

  @override
  String get flairRemoved => 'Значок группы убран';

  @override
  String get flairSheetHint =>
      'Небольшой значок на вашем фото от группы, в которой вы состоите.';

  @override
  String forumPictureN(int number) {
    return 'Изображение форума $number';
  }

  @override
  String forumQuestionNeedsAnswer(String question) {
    return 'Нужен ответ: $question';
  }

  @override
  String get forumQuestionRequired =>
      'Форум просит всех ответить на этот вопрос';

  @override
  String get forumQuestionSetByStaff => 'Задаётся командой форума';

  @override
  String get forumQuestionsIntro =>
      'Вопросы этого форума. * — обязательный ответ.';

  @override
  String get forumQuestionsNoneAnswered => 'Пока нет ответов';

  @override
  String get fromThisForum => 'С этого форума';

  @override
  String get hideMyProfile => 'Скрыть мой публичный профиль';

  @override
  String get hideMyProfileExplanation =>
      'Другие увидят только ваше имя, фото и сообщения';

  @override
  String get letterAvatar => 'Буква';

  @override
  String get moreAboutYou => 'Подробнее о вас';

  @override
  String namesAndMore(String names, int count) {
    return '$names и ещё $count';
  }

  @override
  String get newUsername => 'Новое имя пользователя';

  @override
  String get noFlair => 'Без значка';

  @override
  String noGravatarFound(String service) {
    return 'В $service нет изображения для вашего адреса почты';
  }

  @override
  String get noTitle => 'Без титула';

  @override
  String get noTopicsMatch => 'Ни одна из ваших тем не подходит';

  @override
  String get noTopicsToFeature => 'Вы ещё не создали ни одной темы';

  @override
  String get notSet => 'Не задано';

  @override
  String get orUse => 'Или используйте';

  @override
  String get pictureManagedBySignIn =>
      'Фото задаёт собственная система входа форума';

  @override
  String get primaryGroup => 'Основная группа';

  @override
  String primaryGroupChangedTo(String group) {
    return 'Основная группа изменена: $group';
  }

  @override
  String get primaryGroupRemoved => 'Основная группа убрана';

  @override
  String get primaryGroupSheetHint =>
      'Ваша главная группа, показывается в карточке пользователя.';

  @override
  String get profileLoadFailed => 'Не удалось загрузить профиль';

  @override
  String get profileNowHidden => 'Ваш профиль скрыт';

  @override
  String get profileNowPublic => 'Ваш профиль открыт';

  @override
  String get profilePicture => 'Фото профиля';

  @override
  String get profilePictureChanged => 'Фото профиля изменено';

  @override
  String get profileSaveFailed => 'Не удалось сохранить. Попробуйте ещё раз.';

  @override
  String get profileSectionNameAndAbout => 'Имя и о себе';

  @override
  String get profileSectionNextToName => 'Рядом с именем';

  @override
  String get profileSectionOnProfile => 'В профиле';

  @override
  String get profileSectionPrivacyAndTime => 'Приватность и время';

  @override
  String get removeCardBackground => 'Убрать фон карточки';

  @override
  String get removeCover => 'Убрать обложку';

  @override
  String get removeFeaturedTopic => 'Убрать избранную тему';

  @override
  String get searchTimezones => 'Поиск часовых поясов';

  @override
  String get searchYourTopics => 'Поиск по вашим темам';

  @override
  String get seeProfileAsOthersDo => 'Посмотреть профиль глазами других';

  @override
  String get timezone => 'Часовой пояс';

  @override
  String timezoneChangedTo(String zone) {
    return 'Часовой пояс изменён: $zone';
  }

  @override
  String timezoneWithTime(String zone, String time) {
    return '$zone · сейчас $time';
  }

  @override
  String timezonesMatchingPhone(String offset) {
    return 'Совпадает с часами этого телефона ($offset)';
  }

  @override
  String titleChangedTo(String title) {
    return 'Титул изменён: $title';
  }

  @override
  String get titleFromBadge => 'Награда';

  @override
  String titleFromBadgeEarned(String date) {
    return 'Награда · получена $date';
  }

  @override
  String titleFromGroup(String group) {
    return 'Группа $group';
  }

  @override
  String get titleGrantedByStaff => 'Присвоен командой форума';

  @override
  String get titleRemoved => 'Титул убран';

  @override
  String get titleSheetHint =>
      'Показывается после вашего имени в профиле и сообщениях.';

  @override
  String get username => 'Имя пользователя';

  @override
  String get usernameAvailable => 'Свободно';

  @override
  String usernameChanged(String username) {
    return 'Теперь ваше имя пользователя — @$username';
  }

  @override
  String get usernameLockedExplanation =>
      'На этом форуме сменить имя пользователя можно только вскоре после регистрации. Модератор может сменить его за вас.';

  @override
  String get yourPhoto => 'Ваше фото';

  @override
  String get chooseEmoji => 'Выбрать эмодзи';

  @override
  String get clearStatus => 'Очистить статус';

  @override
  String get clearText => 'Очистить';

  @override
  String get inOneHour => 'Через час';

  @override
  String get never => 'Никогда';

  @override
  String get pauseNotifications => 'Приостановить уведомления';

  @override
  String get pauseNotificationsUntilStatusClears =>
      'Пока статус не будет убран';

  @override
  String get pickATime => 'Выбрать время';

  @override
  String get removeStatusAfter => 'Убрать статус';

  @override
  String get searchEmoji => 'Поиск эмодзи';

  @override
  String get setStatus => 'Установить статус';

  @override
  String get setAStatus => 'Установить статус';

  @override
  String get statusUpdated => 'Статус обновлён';

  @override
  String get whatAreYouDoing => 'Чем вы заняты?';

  @override
  String cardPosted(String when) {
    return 'Последнее сообщение $when';
  }

  @override
  String get change => 'Изменить';

  @override
  String get copyProfileLink => 'Скопировать ссылку на профиль';

  @override
  String get ignore => 'Игнорировать';

  @override
  String memberOfGroup(String group) {
    return 'Участник группы $group';
  }

  @override
  String get mute => 'Отключить уведомления';

  @override
  String get unmute => 'Включить уведомления';

  @override
  String openProfileOf(String username) {
    return 'Открыть профиль @$username';
  }

  @override
  String profileIsPrivate(String username) {
    return '$username скрывает свой профиль.';
  }

  @override
  String showOnlyTheirPostsHere(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сообщения',
      many: '$count сообщений',
      few: '$count сообщения',
      one: '$count сообщение',
    );
    return 'Показать в этой теме только $_temp0 от $name';
  }

  @override
  String showOnlyYourPostsHere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ваших сообщения',
      many: '$count ваших сообщений',
      few: '$count ваших сообщения',
      one: '$count ваше сообщение',
    );
    return 'Показать в этой теме только $_temp0';
  }

  @override
  String userIgnoredFor4Months(String username) {
    return '@$username будет игнорироваться 4 месяца';
  }

  @override
  String userMuted(String username) {
    return 'Уведомления от @$username отключены';
  }

  @override
  String userUnmuted(String username) {
    return 'Уведомления от @$username включены';
  }

  @override
  String get youParenthetical => '(вы)';

  @override
  String get topicStatusClosedHelp =>
      'Тема закрыта; в ней больше нельзя отвечать';

  @override
  String get topicStatusArchivedHelp =>
      'Тема заархивирована и не может быть изменена';

  @override
  String get topicStatusClosedArchivedHelp =>
      'Тема закрыта и заархивирована; в ней больше нельзя отвечать она больше не может быть изменена';

  @override
  String get topicStatusPinnedTitle => 'Закреплена';

  @override
  String get topicStatusPinnedHelp =>
      'Эта тема для вас закреплена; она будет показана в верхней части свой категории';

  @override
  String get topicStatusPinnedGloballyTitle => 'Закреплена глобально';

  @override
  String get topicStatusPinnedGloballyHelp =>
      'Эта тема закреплена глобально; она будет отображаться вверху как на главной странице, так и в своём разделе';

  @override
  String get topicStatusUnpinnedTitle => 'Откреплена';

  @override
  String get topicStatusUnpinnedHelp =>
      'Эта тема для вас откреплена; она будет отображаться в обычном порядке';

  @override
  String get topicStatusUnlistedHelp =>
      'Тема скрыта — она не будет отображаться в списках тем. Доступ к ней возможен только по прямой ссылке.';

  @override
  String get topicStatusWarningHelp => 'Официальное предупреждение.';

  @override
  String get notificationReasonWatchingTag =>
      'Вы будете получать уведомления, поскольку наблюдаете за тегом этой темы.';

  @override
  String get notificationReasonWatchingCategory =>
      'Вы будете получать уведомления, поскольку наблюдаете за этой категорией.';

  @override
  String get notificationReasonWatchingAuto =>
      'Вы будете получать уведомления, поскольку наблюдение за темой началось автоматически.';

  @override
  String get notificationReasonWatching =>
      'Вы будете получать уведомления, поскольку наблюдаете за этой темой.';

  @override
  String get notificationReasonWatchingCreated =>
      'Вы будете получать уведомления, поскольку создали эту тему.';

  @override
  String get notificationReasonTrackingCategory =>
      'Вы увидите количество новых ответов, поскольку следите за этой категорией.';

  @override
  String get notificationReasonTrackingReplied =>
      'Вы увидите количество новых ответов, поскольку вы размещали ответ в этой теме.';

  @override
  String get notificationReasonTracking =>
      'Вы увидите количество новых ответов, поскольку следите за этой темой.';

  @override
  String get notificationReasonTrackingRead =>
      'Вы увидите количество новых ответов, потому что прочитали эту тему.';

  @override
  String get notificationReasonNormal =>
      'Вам придёт уведомление, если кто-нибудь упомянет ваше @имя или ответит вам.';

  @override
  String get notificationReasonMutedCategory =>
      'Не получать уведомлений из этой категории.';

  @override
  String get notificationReasonMuted => 'Не получать уведомлений по этой теме.';

  @override
  String get notificationLevelWatching => 'Наблюдать';

  @override
  String get notificationLevelWatchingFirstPost =>
      'Наблюдать за первым сообщением';

  @override
  String get notificationLevelTracking => 'Следить';

  @override
  String get notificationLevelNormal => 'Уведомлять';

  @override
  String get notificationLevelMuted => 'Без уведомлений';

  @override
  String get topicWatchingDescription =>
      'Уведомлять по каждому новому ответу в этой теме и показывать количество новых непрочитанных ответов.';

  @override
  String get topicTrackingDescription =>
      'Рядом с этой темой появится количество непрочитанных ответов. Вам придёт уведомление, если кто-нибудь упомянет ваше @имя или ответит вам.';

  @override
  String get topicNormalDescription =>
      'Вам придёт уведомление, если кто-нибудь упомянет ваше @имя или ответит вам.';

  @override
  String get topicMutedDescription =>
      'Не уведомлять об изменениях в этой теме и не отображать её в разделе «Последние».';

  @override
  String get messageWatchingDescription =>
      'Уведомлять по каждому ответу на это сообщение и показывать количество новых непрочитанных ответов.';

  @override
  String get messageTrackingDescription =>
      'Рядом с этим сообщением появится количество непрочитанных ответов. Вам придёт уведомление, если кто-нибудь упомянет ваше @имя или ответит вам.';

  @override
  String get messageNormalDescription =>
      'Вам придёт уведомление, если кто-нибудь упомянет ваше @имя или ответит вам.';

  @override
  String get messageMutedDescription =>
      'Никогда не получать уведомлений по этой теме.';

  @override
  String get categoryWatchingDescription =>
      'Наблюдать за всеми темами этой категории. Уведомлять о каждом новом сообщении в любой из тем и показывать количество новых ответов.';

  @override
  String get categoryWatchingFirstPostDescription =>
      'Вы будете получать уведомления о новых темах в этой категории, но не о новых ответах в них.';

  @override
  String get categoryTrackingDescription =>
      'Вы будете автоматически отслеживать все темы в этой категории. Вы будете уведомлены, если кто-то упомянет ваше @имя или ответит вам. Также вам будет показано общее количество новых ответов.';

  @override
  String get categoryNormalDescription =>
      'Вам придёт уведомление, если кто-нибудь упомянет ваше @имя или ответит вам.';

  @override
  String get categoryMutedDescription =>
      'Не уведомлять о новых темах в этой категории и не отображать их в разделе «Последние».';

  @override
  String get tagWatchingDescription =>
      'Автоматически наблюдать за всеми темами с этим тегом. Уведомлять обо всех новых темах и сообщениях, а также показывать количество непрочитанных и новых сообщений рядом с названиями тем.';

  @override
  String get tagWatchingFirstPostDescription =>
      'Вы будете получать уведомления о новых темах, помеченных этим тегом, но не на ответы на них.';

  @override
  String get tagTrackingDescription =>
      'Вы будете автоматически отслеживать все темы с этим тегом. Рядом с темой появится количество непрочитанных и новых сообщений.';

  @override
  String get tagNormalDescription =>
      'Вам придет уведомление, если кто-нибудь упомянет ваше @имя или ответит на ваше сообщение.';

  @override
  String get tagMutedDescription =>
      'Вы не будете получать уведомления о новых темах с этим тегом, и они не будут отображаться на вкладке «Непрочитанные».';

  @override
  String topicTimerAutoOpen(String timeLeft) {
    return 'Тема автоматически откроется $timeLeft.';
  }

  @override
  String topicTimerAutoClose(String timeLeft) {
    return 'Тема автоматически закроется $timeLeft.';
  }

  @override
  String topicTimerAutoPublish(String categoryName, String timeLeft) {
    return 'Тема будет опубликована в категории #$categoryName $timeLeft.';
  }

  @override
  String topicTimerAutoCloseAfterLastPost(String duration) {
    return 'Тема будет закрыта через $duration после последнего ответа.';
  }

  @override
  String topicTimerAutoDeleteAfterLastPost(String duration) {
    return 'Эта тема будет удалена через $duration после последнего ответа.';
  }

  @override
  String topicTimerAutoDelete(String timeLeft) {
    return 'Тема будет автоматически удалена $timeLeft.';
  }

  @override
  String topicTimerAutoBump(String timeLeft) {
    return 'Тема будет автоматически поднята $timeLeft.';
  }

  @override
  String topicTimerAutoDeleteReplies(String duration) {
    return 'Ответы в этой теме автоматически удаляются через $duration.';
  }

  @override
  String slowModeNotice(String duration) {
    return 'Пожалуйста, подождите $duration между вашими сообщениями в этой теме.';
  }

  @override
  String get closeTopic => 'Закрыть тему';

  @override
  String get openTopic => 'Открыть тему';

  @override
  String get pinTopic => 'Закрепить тему';

  @override
  String get unpinTopic => 'Открепить тему';

  @override
  String get archiveTopic => 'Архивировать тему';

  @override
  String get unarchiveTopic => 'Разархивировать тему';

  @override
  String get unlistTopic => 'Скрыть тему';

  @override
  String get listTopic => 'Показать тему';

  @override
  String get permanentlyDelete => 'Удалить навсегда';

  @override
  String get permanentlyDeleteTopicConfirmation =>
      'Это действие нельзя отменить. Тема будет удалена навсегда и стёрта из базы данных.';

  @override
  String get deleteTopicConfirmYes => 'Да, удалить эту тему';

  @override
  String get deleteTopicConfirmNo => 'Нет, оставить эту тему';

  @override
  String get topicPinned => 'Тема закреплена';

  @override
  String get topicUnpinned => 'Тема откреплена';

  @override
  String get topicArchived => 'Тема архивирована';

  @override
  String get topicUnarchived => 'Тема разархивирована';

  @override
  String get topicUnlisted => 'Тема скрыта';

  @override
  String get topicListed => 'Тема показана';

  @override
  String get topicRecovered => 'Удаление темы отменено';

  @override
  String topicActionFailed(String error) {
    return 'Не удалось изменить тему: $error';
  }

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count минуты',
      many: '$count минут',
      few: '$count минуты',
      one: '$count минуту',
    );
    return '$_temp0';
  }

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count часа',
      many: '$count часов',
      few: '$count часа',
      one: '$count час',
    );
    return '$_temp0';
  }

  @override
  String durationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0';
  }

  @override
  String timeLeftMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'через $count минуты',
      many: 'через $count минут',
      few: 'через $count минуты',
      one: 'через $count минуту',
    );
    return '$_temp0';
  }

  @override
  String timeLeftHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'через $count часа',
      many: 'через $count часов',
      few: 'через $count часа',
      one: 'через $count час',
    );
    return '$_temp0';
  }

  @override
  String timeLeftDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'через $count дня',
      many: 'через $count дней',
      few: 'через $count дня',
      one: 'через $count день',
    );
    return '$_temp0';
  }

  @override
  String get topicStatusDeletedHelp =>
      'Тема удалена и скрыта от других пользователей';

  @override
  String get flagAction => 'Пометить';

  @override
  String get flagPost => 'Пожаловаться на сообщение';

  @override
  String get signUp => 'Регистрация';

  @override
  String get suspendUser => 'Блокировка пользователя';

  @override
  String get unsuspend => 'Разблокировать';

  @override
  String get suspendUntil => 'Блокировка пользователя до';

  @override
  String get suspendForever => 'Бессрочная блокировка';

  @override
  String failedToSuspendUser(String error) {
    return 'Ошибка блокировки пользователя: $error';
  }

  @override
  String failedToUnsuspendUser(String error) {
    return 'Ошибка разблокировки пользователя: $error';
  }

  @override
  String get suspendReasonNotListening =>
      'Не прислушался к рекомендациям персонала';

  @override
  String get suspendReasonStaffTime =>
      'Потрачено слишком много времени персонала';

  @override
  String get suspendReasonCombative => 'Агрессивное поведение';

  @override
  String get suspendReasonWrongPlace => 'Обсуждение не в том месте';

  @override
  String get suspendReasonNoPurpose =>
      'У действий пользователя нет никакой конструктивной цели, кроме внесения раскола в сообщество';

  @override
  String get suspendReasonCustom => 'Другое…';

  @override
  String get suspendReasonQuestion =>
      'Укажите причину блокировки. Этот текст будет показан пользователю, когда он попытается войти в систему. Введите краткое описание.';

  @override
  String get closedLabel => 'Закрыта';

  @override
  String get flaggingPost => 'Отправка жалобы…';

  @override
  String get pleaseSelectSuspensionEndDate =>
      'Выберите, когда закончится блокировка';

  @override
  String get suspendingUser => 'Блокировка пользователя…';

  @override
  String get unsuspendingUser => 'Разблокировка пользователя…';

  @override
  String get userSuspended => 'Пользователь заблокирован';

  @override
  String get userUnsuspended => 'Пользователь разблокирован';

  @override
  String unsuspendUserConfirmation(String username) {
    return 'Разблокировать $username? Пользователь снова сможет входить.';
  }

  @override
  String get noCategoriesToDisplay => 'Нет категорий для показа.';

  @override
  String get noPermissionToViewCategory =>
      'У вас нет прав на просмотр тем в этой категории.';

  @override
  String get featureTopicTitle => 'Закрепить эту тему';

  @override
  String get pinTopicMenu => 'Закрепить тему…';

  @override
  String pinInCategoryUntil(String category) {
    return 'Закрепить эту тему в верхней части категории $category до';
  }

  @override
  String get pinGloballyUntil => 'Закрепить эту тему над всеми спискам тем до';

  @override
  String get pinNote =>
      'Пользователи могут открепить тему, каждый сам для себя.';

  @override
  String get pinUntil => 'Закрепить до';

  @override
  String get pinDateRequired => 'Чтобы закрепить эту тему, требуется дата.';

  @override
  String get pinTopicGlobally => 'Закрепить тему глобально';

  @override
  String get flagThanks =>
      'Благодарим за поддержание порядка в нашем сообществе!';

  @override
  String get flagReviewProcess =>
      'Все жалобы передаются модераторам и будут рассмотрены в ближайшее время.';

  @override
  String get flagCant =>
      'Вы не можете сейчас отправить жалобу на это сообщение.';

  @override
  String get flagSendMessage => 'Сообщение';

  @override
  String get flagMessageForUser => 'Сообщение для пользователя';

  @override
  String get flagMessageForModerators => 'Сообщение для модераторов';

  @override
  String get flagPlaceholderNotifyUser =>
      'Будьте точны, конструктивны и доброжелательны.';

  @override
  String get flagPlaceholderNotifyModerators =>
      'Поясните суть проблемы: на что нам следует обратить внимание. Предоставьте соответствующие ссылки и примеры, если это возможно.';

  @override
  String get flagPlaceholderIllegal =>
      'Поясните суть проблемы: почему вы считаете этот контент незаконным. Предоставьте соответствующие ссылки и примеры, если это возможно.';

  @override
  String get flagConfirmIllegal => 'Приведенная мною информация точна и полна.';

  @override
  String flagMessageAtLeast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'введите не менее $count символа',
      many: 'введите не менее $count символов',
      few: 'введите не менее $count символов',
      one: 'введите не менее $count символа',
    );
    return '$_temp0';
  }

  @override
  String get flagMessageSent => 'Ваше сообщение отправлено.';

  @override
  String get mergeTopicError =>
      'При перемещении сообщений в эту тему произошла ошибка.';

  @override
  String get topicTitlePlaceholder =>
      'Название: суть темы коротким предложением';

  @override
  String get topicMoved => 'Тема перемещена';

  @override
  String get topicMerged => 'Тема объединена';

  @override
  String get mergeTopicExplanation =>
      'Все сообщения этой темы будут перенесены в выбранную тему. В приложении это нельзя отменить.';

  @override
  String get destinationTopicId => 'ID темы назначения';

  @override
  String get topicAuthorUnknown => 'Неизвестно';

  @override
  String get noHotTopics => 'Нет горячих тем.';

  @override
  String get signInToViewNewTopics => 'Войдите, чтобы просмотреть новые темы';

  @override
  String get newTopicsSignInMessage =>
      'В новых темах показано то, что было создано с вашего последнего визита.';

  @override
  String get topPeriodAllTime => 'За всё время';

  @override
  String get topPeriodYear => 'За год';

  @override
  String get topPeriodQuarter => 'За квартал';

  @override
  String get topPeriodMonth => 'За месяц';

  @override
  String get topPeriodWeek => 'За неделю';

  @override
  String get topPeriodToday => 'Сегодня';

  @override
  String noTopTopicsForPeriod(String period) {
    String _temp0 = intl.Intl.selectLogic(
      period,
      {
        'all': 'Нет обсуждаемых тем за всё время.',
        'yearly': 'Нет обсуждаемых тем за год.',
        'quarterly': 'Нет обсуждаемых тем за квартал.',
        'monthly': 'Нет обсуждаемых тем за месяц.',
        'weekly': 'Нет обсуждаемых тем за неделю.',
        'daily': 'Сегодня нет обсуждаемых тем.',
        'other': 'Нет обсуждаемых тем.',
      },
    );
    return '$_temp0';
  }

  @override
  String get connectionTimedOutSiteUnreachable =>
      'Время ожидания подключения истекло. Сайт может быть недоступен.';

  @override
  String get failedToMarkNotificationsRead =>
      'Не удалось отметить уведомления как прочитанные';

  @override
  String get forumNameFallback => 'Форум';

  @override
  String get noForumDescription => 'Описание отсутствует.';

  @override
  String get dismissAllNotifications => 'Отклонить всё';

  @override
  String get notificationPostIdMissing =>
      'Отсутствует ID сообщения. Невозможно перейти к сообщению.';

  @override
  String get notificationTopicIdMissingForPost =>
      'Отсутствует ID темы. Невозможно перейти к сообщению.';

  @override
  String get notificationTopicIdMissing =>
      'Отсутствует ID темы. Невозможно открыть тему.';

  @override
  String get notificationUsernameMissing =>
      'Отсутствует имя пользователя. Невозможно открыть профиль.';

  @override
  String get notificationChannelIdMissing =>
      'Отсутствует ID канала. Невозможно открыть чат.';

  @override
  String get notificationGroupNameMissingForInbox =>
      'Отсутствует название группы. Невозможно открыть входящие.';

  @override
  String get notificationGroupNameMissing =>
      'Отсутствует название группы. Невозможно открыть группу.';

  @override
  String get notificationNoActionUrl =>
      'Для этого типа уведомлений нет URL действия.';

  @override
  String get notificationBadgeUnavailable => 'Сведения о награде недоступны.';

  @override
  String get notificationBadgeLoadFailed => 'Не удалось загрузить эту награду.';

  @override
  String get personalMessageTitleFallback => 'Личное сообщение';

  @override
  String get topicTitleFallback => 'Тема';

  @override
  String get signInToViewNotifications =>
      'Войдите, чтобы просмотреть уведомления';

  @override
  String get youNeedToBeSignedInToViewNotifications =>
      'Войдите, чтобы увидеть свои уведомления.';

  @override
  String get noUnreadNotifications => 'Нет непрочитанных уведомлений';

  @override
  String get noNotificationsYet => 'Пока нет уведомлений';

  @override
  String get newNotificationFallbackBody => 'Новое уведомление';

  @override
  String get unableToOpenNotification => 'Не удалось открыть уведомление';

  @override
  String get notificationMissingSiteInfo =>
      'Отсутствуют сведения о сайте (site_id).';

  @override
  String get notificationInvalidSiteInfo =>
      'Неверные сведения о сайте (site_id).';

  @override
  String get notificationMissingPostInfo =>
      'Отсутствуют сведения о сообщении (content_id).';

  @override
  String get notificationMissingMessageInfo =>
      'Отсутствуют сведения о личном сообщении (conversation_id).';

  @override
  String get notificationMissingUserInfo =>
      'Отсутствуют сведения о пользователе (sender_id).';

  @override
  String get notificationUnsupportedType => 'Неподдерживаемый тип уведомления.';

  @override
  String get notificationForumNotFound => 'Форум для этого сайта не найден.';

  @override
  String get notificationForumOpenFailed =>
      'Не удалось инициализировать форум.';

  @override
  String get notificationMissingTopicInfo =>
      'Отсутствуют сведения о теме (topic_id).';

  @override
  String get failedToLoadTags => 'Не удалось загрузить теги.';

  @override
  String get searchTagsHint => 'Поиск тегов…';

  @override
  String get tagsSortedByCountTooltip =>
      'По числу тем — нажмите, чтобы сортировать по алфавиту';

  @override
  String get tagsSortedAlphabeticallyTooltip =>
      'По алфавиту — нажмите, чтобы сортировать по популярности';

  @override
  String get noTagsYet => 'На этом форуме пока нет тегов.';

  @override
  String get tagNotificationLevelTooltip => 'Уровень уведомлений';

  @override
  String get tagTopicsLoadFailed => 'Не удалось загрузить';

  @override
  String searchFailedWithError(String error) {
    return 'Поиск не удался: $error';
  }

  @override
  String get searchFiltersButtonTooltip => 'Фильтры';

  @override
  String get searchFilterStatusSection => 'Статус';

  @override
  String get searchFilterMyActivitySection => 'Моя активность';

  @override
  String get searchFilterMatchTypeSection => 'Тип совпадения';

  @override
  String get searchTagsFilterHelper =>
      'Через пробел или запятую. Нужны все указанные теги.';

  @override
  String get searchSortBy => 'Сортировка';

  @override
  String get searchStatusOpen => 'Открыта';

  @override
  String get searchStatusArchived => 'В архиве';

  @override
  String get searchStatusNoReplies => 'Без ответов';

  @override
  String get searchStatusPublicOnly => 'Только публичные';

  @override
  String get searchStatusUnsolved => 'Не решено';

  @override
  String get searchInBookmarked => 'В моих закладках';

  @override
  String get searchInMyMessages => 'В моих сообщениях';

  @override
  String get searchInLiked => 'Понравившиеся';

  @override
  String get searchInPosted => 'В которых я отвечал(а)';

  @override
  String get searchInWatching => 'За которыми я наблюдаю';

  @override
  String get searchInTracking => 'За которыми я слежу';

  @override
  String get searchInSeen => 'Прочитанные';

  @override
  String get searchInUnseen => 'Непрочитанные';

  @override
  String get searchSortLatestPost => 'По недавним сообщениям';

  @override
  String get searchSortMostLiked => 'По количеству лайков';

  @override
  String get searchSortMostViewed => 'По количеству просмотров';

  @override
  String get searchSortLatestTopic => 'По недавним темам';

  @override
  String get searchFieldHint => 'Поиск…';

  @override
  String get bookmarksUnavailable => 'Закладки недоступны';

  @override
  String get failedToLoadBookmarks => 'Не удалось загрузить закладки';

  @override
  String get failedToRemoveBookmark => 'Не удалось удалить закладку';

  @override
  String get failedToUpdateBookmark => 'Не удалось обновить закладку';

  @override
  String get bookmarkWithReminder => 'Закладка с напоминанием';

  @override
  String get noReminder => 'Без напоминания';

  @override
  String get failedToLoadDrafts => 'Не удалось загрузить черновики.';

  @override
  String get failedToDiscardDraft => 'Не удалось удалить черновик';

  @override
  String draftNotDiscardedAway(String error) {
    return 'Черновик не удалён и остаётся в разделе «Черновики». $error';
  }

  @override
  String get messagesLoadFailed => 'Не удалось загрузить сообщения';

  @override
  String get moreMessagesLoadFailed => 'Не удалось загрузить больше сообщений';

  @override
  String get messageUnknownUser => 'Неизвестно';

  @override
  String get unknownErrorFallback => 'Неизвестная ошибка';

  @override
  String get chatComposerDefaultHint => 'Введите сообщение…';

  @override
  String chatChannelNumbered(Object id) {
    return 'канал $id';
  }

  @override
  String get chatSendFailed => 'Не удалось отправить сообщение.';

  @override
  String get chatEditFailed => 'Не удалось изменить сообщение.';

  @override
  String get chatDeleteFailed => 'Не удалось удалить сообщение.';

  @override
  String get chatReactionsUnsupported => 'Реакции здесь не поддерживаются.';

  @override
  String get chatReactionFailed => 'Не удалось обновить реакцию.';

  @override
  String get attachmentDefaultName => 'Вложение';

  @override
  String get fileTypeAudio => 'Аудио';

  @override
  String get fileTypeText => 'Текст';

  @override
  String get fileTypeArchive => 'Архив';

  @override
  String get fileTypeFile => 'Файл';

  @override
  String downloadFailedHttpStatus(String status) {
    return 'Не удалось скачать файл: HTTP $status';
  }

  @override
  String get downloadedFileEmpty => 'Скачанный файл пуст';

  @override
  String downloadFileFailed(String error) {
    return 'Не удалось скачать файл: $error';
  }

  @override
  String attachmentTypeNotAllowed(String extension, String allowed) {
    return 'Тип файла .$extension не разрешён. Разрешённые типы: $allowed';
  }

  @override
  String attachmentFileTooLarge(String size, String max) {
    return 'Размер файла ($size) превышает максимум $max';
  }

  @override
  String get attachmentValidationFailed => 'Файл не прошёл проверку';

  @override
  String get uploadMissingReference =>
      'Файл загружен, но сервер не вернул ссылку на него.';

  @override
  String get imageFileNotFound => 'Файл изображения не найден';

  @override
  String get failedToLoadVideo => 'Не удалось загрузить видео';

  @override
  String get userInfoLoadFailed =>
      'Не удалось загрузить информацию о пользователе.';

  @override
  String userInfoLoadFailedWithError(String error) {
    return 'Не удалось загрузить информацию о пользователе: $error';
  }

  @override
  String get profileMenuIgnoreUser => 'Игнорировать пользователя';

  @override
  String get profileMenuUnignoreUser => 'Не игнорировать пользователя';

  @override
  String get ignoreStateUpdateFailed =>
      'Не удалось изменить статус игнорирования';

  @override
  String profileNowIgnoringUser(String username) {
    return 'Вы игнорируете @$username. Сообщения этого пользователя будут скрыты.';
  }

  @override
  String get profileIgnoreToggleFailed =>
      'Не удалось переключить игнорирование.';

  @override
  String get profileStatsLoadFailed => 'Не удалось загрузить статистику.';

  @override
  String get profileFollowFailed => 'Не удалось подписаться';

  @override
  String get profileUnfollowFailed => 'Не удалось отписаться';

  @override
  String get profileChatOpenFailed =>
      'Не удалось открыть чат с этим пользователем.';

  @override
  String summaryLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count лайка',
      many: '$count лайков',
      few: '$count лайка',
      one: '$count лайк',
    );
    return '$_temp0';
  }

  @override
  String summaryLinkClicks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count клика',
      many: '$count кликов',
      few: '$count клика',
      one: '$count клик',
    );
    return '$_temp0';
  }

  @override
  String get directoryPeriodAllTime => 'За всё время';

  @override
  String get directoryPeriodYear => 'За год';

  @override
  String get directoryPeriodQuarter => 'За квартал';

  @override
  String get directoryPeriodMonth => 'За месяц';

  @override
  String get directoryPeriodWeek => 'За неделю';

  @override
  String get directoryPeriodToday => 'Сегодня';

  @override
  String get directoryOrderReceived => 'Получено';

  @override
  String get directoryOrderReplies => 'Ответов';

  @override
  String get directoryOrderTopics => 'Тем';

  @override
  String get directoryOrderVisits => 'Посещений';

  @override
  String get directoryLoadFailed =>
      'Не удалось загрузить список пользователей.';

  @override
  String get directoryNoUsersMatch => 'Нет пользователей с таким именем.';

  @override
  String get directoryNoUsersForPeriod =>
      'За этот период пользователи не найдены.';

  @override
  String get userSearchNoResults => 'Пользователи не найдены';

  @override
  String get userSearchTryDifferentUsername =>
      'Попробуйте поискать по другому имени пользователя';

  @override
  String get userSearchPromptTitle => 'Поиск пользователей';

  @override
  String get userSearchPromptHint =>
      'Введите имя пользователя, чтобы найти и пригласить пользователей';

  @override
  String get ignoredUsersUnignoreFailed => 'Не удалось отменить игнорирование.';

  @override
  String get ignoredUsersEmpty => 'Вы никого не игнорируете.';

  @override
  String get ignoredUsersEmptyHint =>
      'Откройте профиль пользователя и выберите в меню «Игнорировать пользователя», чтобы скрыть его сообщения и уведомления.';

  @override
  String get badgesLoadFailed => 'Не удалось загрузить награды.';

  @override
  String get badgesEmpty => 'На этом форуме нет наград.';

  @override
  String get badgeTierGold => 'Золото';

  @override
  String get badgeTierSilver => 'Серебро';

  @override
  String get badgeTierBronze => 'Бронза';

  @override
  String badgeEarnedAgo(String time) {
    return 'Получено $time';
  }

  @override
  String badgeEarnedByUsers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Получено $formatted пользователями',
      many: 'Получено $formatted пользователями',
      few: 'Получено $formatted пользователями',
      one: 'Получено $formatted пользователем',
    );
    return '$_temp0';
  }

  @override
  String get trustLevelNameNewUser => 'Новичок';

  @override
  String get trustLevelNameBasic => 'Обычный пользователь';

  @override
  String get trustLevelNameMember => 'Участник';

  @override
  String get trustLevelNameRegular => 'Активный(-ая)';

  @override
  String get trustLevelNameLeader => 'Лидер';

  @override
  String get trustLevelSummary0 =>
      'Только что зарегистрировался. Может читать и писать, но с ограничениями на ссылки, изображения и сообщения.';

  @override
  String get trustLevelSummary1 =>
      'Открывает основные возможности: изображения и вложения, больше ссылок, жалобы на сообщения.';

  @override
  String get trustLevelSummary2 =>
      'Может отправлять приглашения, игнорировать пользователей и дольше редактировать свои сообщения.';

  @override
  String get trustLevelSummary3 =>
      'Может менять категорию и название тем, создавать теги, а его жалобы на спам весят больше.';

  @override
  String get trustLevelSummary4 =>
      'Присваивается персоналом. Может редактировать любые сообщения, закреплять, закрывать, разделять и объединять темы.';

  @override
  String trustLevelRowTitle(int level, String name) {
    return 'TL$level · $name';
  }

  @override
  String get profileNoUserSpecified => 'Пользователь не указан';

  @override
  String get userTopicsLoadFailed => 'Не удалось загрузить темы';

  @override
  String get userTopicsEmpty => 'Ещё не создано ни одной темы.';

  @override
  String get userRecentPostsLoadFailed =>
      'Не удалось загрузить последние сообщения';

  @override
  String get activityUnknownTopic => 'Неизвестная тема';

  @override
  String groupJoinedSnack(String group) {
    return 'Вы вступили в $group';
  }

  @override
  String get groupJoinFailed => 'Не удалось вступить в группу';

  @override
  String groupLeftSnack(String group) {
    return 'Вы покинули $group';
  }

  @override
  String get groupLeaveFailed => 'Не удалось покинуть группу';

  @override
  String get groupMembershipRequestHint =>
      'Почему вы хотите вступить? Владельцы группы увидят это вместе с запросом.';

  @override
  String get groupMembershipReasonRequired =>
      'Для запроса на вступление нужно указать причину';

  @override
  String get groupMembershipRequestSent =>
      'Запрос отправлен — его должен одобрить владелец группы';

  @override
  String get groupMembershipRequestFailed =>
      'Не удалось отправить запрос на вступление';

  @override
  String get groupMemberBadge => 'Участник';

  @override
  String get groupRequestPending => 'Запрос на рассмотрении';

  @override
  String get groupJoining => 'Вступление…';

  @override
  String get groupJoinButton => 'Вступить в группу';

  @override
  String get groupsLoadFailed => 'Не удалось загрузить группы.';

  @override
  String get groupBuiltIn => 'Встроенная группа';

  @override
  String invitesPendingWithCount(int count) {
    return 'В ожидании ($count)';
  }

  @override
  String invitesExpiredWithCount(int count) {
    return 'Истекший срок ($count)';
  }

  @override
  String invitesRedeemedWithCount(int count) {
    return 'Принятые ($count)';
  }

  @override
  String get invitesLoadFailed => 'Не удалось загрузить приглашения.';

  @override
  String get inviteLinkCreateFailed => 'Не удалось создать ссылку-приглашение';

  @override
  String get inviteEmailAddressLabel => 'Адрес электронной почты';

  @override
  String get inviteEmailInvalid =>
      'Введите действительный адрес электронной почты';

  @override
  String get inviteMessageOptionalLabel => 'Сообщение (необязательно)';

  @override
  String get inviteSendFailed => 'Не удалось отправить приглашение';

  @override
  String get revokeInviteLinkWarning =>
      'Ссылка-приглашение перестанет работать.';

  @override
  String revokeInviteEmailWarning(String email) {
    return 'Приглашение для $email перестанет работать.';
  }

  @override
  String get inviteRevokeFailed => 'Не удалось отозвать приглашение';

  @override
  String get inviteNoPermission => 'У вас нет разрешения приглашать';

  @override
  String get invitesEmptyPending => 'Нет ожидающих приглашений';

  @override
  String get invitesEmptyExpired => 'Нет приглашений с истекшим сроком';

  @override
  String get invitesEmptyRedeemed => 'Нет принятых приглашений';

  @override
  String get invitesEmptyPendingHint =>
      'Создайте ссылку-приглашение, чтобы позвать людей на форум.';

  @override
  String get inviteLinkFallbackTitle => 'Ссылка-приглашение';

  @override
  String inviteRedeemedOn(String date) {
    return 'Принято $date';
  }

  @override
  String inviteRedemptions(int count, int max) {
    return 'Принято $count из $max';
  }

  @override
  String get inviteEmailSent => 'Письмо отправлено';

  @override
  String get inviteEmailNotSent => 'Письмо не отправлено';

  @override
  String inviteExpiredOn(String date) {
    return 'Истекло $date';
  }

  @override
  String get inviteRevokeTooltip => 'Отозвать приглашение';

  @override
  String get reviewStatusPending => 'В ожидании';

  @override
  String get reviewStatusApproved => 'Одобренные';

  @override
  String get reviewStatusRejected => 'Отклонённые';

  @override
  String get reviewStatusAll => 'Все';

  @override
  String get reviewStatusIgnored => 'Жалоба проигнорирована';

  @override
  String get reviewStatusDeleted => 'Тема или сообщение удалены';

  @override
  String get reviewQueueUnavailable =>
      'Очередь на проверку недоступна на этом форуме.';

  @override
  String get reviewQueueLoadFailed =>
      'Не удалось загрузить очередь на проверку';

  @override
  String get reviewableChangedByOther =>
      'Этот элемент изменил другой модератор. Обновление…';

  @override
  String get reviewActionFailed => 'Не удалось выполнить действие';

  @override
  String reviewActionDone(String action) {
    return '$action — готово';
  }

  @override
  String get reviewRejectReasonHint => 'Почему это отклоняется?';

  @override
  String get reviewTypeFlaggedPost => 'На это сообщение поступила жалоба';

  @override
  String get reviewTypeQueuedPost => 'Сообщение в очереди на проверку';

  @override
  String get reviewTypeQueuedTopic => 'Тема в очереди на проверку';

  @override
  String get reviewTypeUser => 'Пользователь';

  @override
  String get reviewTypePost => 'Сообщение';

  @override
  String get reviewTypeChatMessage => 'На сообщение пожаловались';

  @override
  String get reviewModeratorAccessRequired => 'Требуются права модератора';

  @override
  String reviewableScore(String score) {
    return 'Оценка $score';
  }

  @override
  String get postRepliesLoadFailed => 'Не удалось загрузить ответы.';

  @override
  String get postMakeWiki => 'Сделать вики-сообщением';

  @override
  String get postRemoveWiki => 'Отменить вики-сообщение';

  @override
  String get postBookmarkRemoveFailed => 'Не удалось удалить закладку';

  @override
  String get postBookmarkFailed => 'Не удалось добавить сообщение в закладки';

  @override
  String get postBookmarkReminderUpdateFailed =>
      'Не удалось обновить напоминание';

  @override
  String get postBookmarkReminderSet => 'Напоминание установлено';

  @override
  String get postBookmarkReminderCleared => 'Напоминание удалено';

  @override
  String get solutionMarkFailed => 'Не удалось отметить ответ как решение';

  @override
  String get solutionUnmarkFailed => 'Не удалось снять отметку решения';

  @override
  String get postUnknownDate => 'Дата неизвестна';

  @override
  String get postBookmarkAction => 'Добавить сообщение в закладки';

  @override
  String get reactionButtonRemoveLike =>
      'Вам понравилось. Нажмите, чтобы убрать лайк.';

  @override
  String reactionButtonRemove(String reaction) {
    return 'Ваша реакция: $reaction. Нажмите, чтобы убрать её.';
  }

  @override
  String reactionButtonLocked(String reaction) {
    return 'Ваша реакция: $reaction. Изменить её уже нельзя.';
  }

  @override
  String get reactionHoldHint => 'Удерживайте для других реакций';

  @override
  String reactionSummarySemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count реакции. Нажмите, чтобы увидеть, кто отреагировал.',
      many: '$count реакций. Нажмите, чтобы увидеть, кто отреагировал.',
      few: '$count реакции. Нажмите, чтобы увидеть, кто отреагировал.',
      one: '$count реакция. Нажмите, чтобы увидеть, кто отреагировал.',
    );
    return '$_temp0';
  }

  @override
  String get reactionLockedMessage =>
      'Вы больше не можете изменить свою реакцию на это сообщение.';

  @override
  String get reactionHoldTip =>
      'Совет: удерживайте сердечко, чтобы выбрать другую реакцию.';

  @override
  String reactionsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count реакции',
      many: '$count реакций',
      few: '$count реакции',
      one: '$count реакция',
    );
    return '$_temp0';
  }

  @override
  String get reactionsAll => 'Все';

  @override
  String get reactionYou => 'Вы';

  @override
  String get changeYourReaction => 'Изменить реакцию';

  @override
  String get reactionTapAgainToRemove =>
      'Нажмите на свою реакцию ещё раз, чтобы убрать её.';

  @override
  String reactionFilterSemantics(String reaction, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$reaction, $count человека',
      many: '$reaction, $count человек',
      few: '$reaction, $count человека',
      one: '$reaction, $count человек',
    );
    return '$_temp0';
  }

  @override
  String get postLikeAction => 'Поставить лайк сообщению';

  @override
  String get postUnlikeAction => 'Убрать лайк';

  @override
  String get postVoteRemoveFailed =>
      'Не удалось отозвать голос (время на отмену истекло?)';

  @override
  String get postVoteCastFailed => 'Не удалось проголосовать';

  @override
  String get postUpvote => 'Голосовать за';

  @override
  String get postDownvote => 'Голосовать против';

  @override
  String get pollVoteFailed => 'Не удалось проголосовать. Попробуйте ещё раз.';

  @override
  String get pollRemoveVoteFailed =>
      'Не удалось отозвать ваш голос. Попробуйте ещё раз.';

  @override
  String get pollVotersLoadFailed => 'Не удалось загрузить проголосовавших.';

  @override
  String get pollVotersNotVisible => 'Проголосовавшие в этом опросе скрыты.';

  @override
  String solutionSolvedByInPost(String name, int postNumber) {
    return 'Решено пользователем $name в сообщении #$postNumber';
  }

  @override
  String solutionMarkedBy(String name) {
    return 'отметил(а) $name';
  }

  @override
  String reactAgainInSeconds(int seconds) {
    return 'Снова отреагировать на это сообщение можно через $seconds с';
  }

  @override
  String get reactionUpdateFailed => 'Не удалось обновить реакцию.';

  @override
  String get reactionsNotSupported =>
      'На этом форуме реакции не поддерживаются.';

  @override
  String get reactionsLoadFailed => 'Не удалось загрузить реакции.';

  @override
  String viewProfileOfUser(String username) {
    return 'Открыть профиль $username';
  }

  @override
  String get failedToSavePost => 'Не удалось сохранить сообщение';

  @override
  String failedToSavePostWithError(String error) {
    return 'Не удалось сохранить сообщение: $error';
  }

  @override
  String get failedToRemoveAttachmentCheckPermissions =>
      'Не удалось удалить вложение. Проверьте свои права доступа.';

  @override
  String get editPostTitle => 'Редактировать сообщение';

  @override
  String get editYourPostHint => 'Отредактируйте сообщение...';

  @override
  String get failedToPostReply => 'Не удалось отправить ответ';

  @override
  String failedToPostReplyWithError(String error) {
    return 'Не удалось отправить ответ: $error';
  }

  @override
  String get failedToCreateTopic => 'Не удалось создать тему';

  @override
  String get writeYourTopicTitle => 'Напишите заголовок темы...';

  @override
  String get writeYourTopicContent => 'Напишите текст темы...';

  @override
  String get composerTitleHint => 'Напишите заголовок...';

  @override
  String get composerContentHint => 'Напишите текст...';

  @override
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit) {
    return '$fileName: слишком большой файл ($size), уменьшить не удалось. Ограничение — $limit.';
  }

  @override
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit) {
    return '$fileName уменьшен до $size$dimensions, чтобы уложиться в ограничение $limit.';
  }

  @override
  String get composerAttachFileHint => 'Прикрепить файл к сообщению';

  @override
  String get composerUploadImageHint => 'Загрузить изображение в сообщение';

  @override
  String get composerFormattingHint => 'Открыть параметры форматирования';

  @override
  String get whisperStaffOnly => 'Скрытое сообщение (только для персонала)';

  @override
  String get whisperOnStaffOnly =>
      'Скрытое сообщение включено (только для персонала)';

  @override
  String get tagInputMaxReached => 'Достигнуто максимальное число тегов';

  @override
  String get tagInputAddTag => 'Добавить тег…';

  @override
  String get tagInputAddAnother => '+ тег';

  @override
  String get editHistoryUnavailable =>
      'История правок на этом форуме недоступна.';

  @override
  String get editHistoryLoadFailed => 'Не удалось загрузить историю правок.';

  @override
  String get previousRevision => 'Предыдущая версия';

  @override
  String get nextRevision => 'Следующая версия';

  @override
  String get notificationPrefsLoadFailed =>
      'Не удалось загрузить настройки уведомлений.';

  @override
  String get notificationPrefsSaveFailed =>
      'Не удалось сохранить — проверьте подключение';

  @override
  String get signInToManageNotificationPrefs =>
      'Войдите, чтобы управлять настройками уведомлений.';

  @override
  String get emailWhenAwayTitle => 'Письма, когда вас нет';

  @override
  String get emailLevelDescription =>
      'Отправлять мне письмо, когда меня цитируют или отвечают на мое сообщение, когда упоминается мое @имя_пользователя, или когда есть новая активность в наблюдаемых категориях, темах или тегах';

  @override
  String get notificationPrefAlways => 'Всегда';

  @override
  String get notificationPrefOnlyWhenAway => 'Если вы офлайн';

  @override
  String get notificationPrefNever => 'Никогда';

  @override
  String get emailForMessagesTitle => 'Письма о сообщениях';

  @override
  String get emailMessagesLevelDescription =>
      'Отправлять мне письмо, когда я получаю личное сообщение';

  @override
  String get activitySummaryTitle => 'Сводка активности';

  @override
  String get activitySummaryDescription =>
      'В случае моего отсутствия на форуме присылать мне сводку популярных тем и ответов';

  @override
  String get activitySummaryFrequencyTitle => 'Частота сводки активности';

  @override
  String get activitySummaryDaily => 'Ежедневно';

  @override
  String get activitySummaryWeekly => 'Еженедельно';

  @override
  String get activitySummaryMonthly => 'Каждый месяц';

  @override
  String get mailingListModeTitle => 'Режим почтовой рассылки';

  @override
  String get mailingListModeDescription =>
      'Присылать каждое сообщение по почте (отключает сводку активности). Не рекомендуется на активных форумах.';

  @override
  String get likeNotificationFrequencyTitle => 'Уведомлять при получении лайка';

  @override
  String get likeNotificationFirstTimeAndDaily =>
      'При первом лайке в сообщении, и далее не чаще раза в день';

  @override
  String get likeNotificationFirstTime => 'Только при первом лайке';

  @override
  String get whenPostingTitle => 'При публикации';

  @override
  String get whenPostingDescription =>
      'Что происходит с темой, в которой вы отвечаете';

  @override
  String get whenPostingWatchTopic => 'Наблюдать за темой';

  @override
  String get whenPostingTrackTopic => 'Отслеживать тему';

  @override
  String get whenPostingDoNothing => 'Ничего не делать';

  @override
  String get pauseNotificationsUntilTomorrow => 'До завтра';

  @override
  String get couldNotEnableDoNotDisturb =>
      'Не удалось включить режим «Не беспокоить»';

  @override
  String get doNotDisturbNotEnabledSessionChanged =>
      'Режим «Не беспокоить» не включён: сеанс входа изменился.';

  @override
  String get couldNotTurnOffDoNotDisturb =>
      'Не удалось отключить режим «Не беспокоить»';

  @override
  String get passwordResetEmailSent => 'Письмо для сброса пароля отправлено.';

  @override
  String get couldNotSendResetEmail => 'Не удалось отправить письмо для сброса';

  @override
  String get accountRequestFailed => 'Запрос не выполнен.';

  @override
  String get forumUrlUnavailable => 'Адрес форума недоступен.';

  @override
  String get couldNotOpenPreferencesPage =>
      'Не удалось открыть страницу настроек.';

  @override
  String get couldNotOpenForumUrl => 'Не удалось открыть адрес форума.';

  @override
  String get couldNotRequestEmailChange =>
      'Не удалось запросить смену адреса эл. почты';

  @override
  String get newEmailLabel => 'Новый адрес эл. почты';

  @override
  String get enterAnEmailAddress => 'Введите адрес электронной почты';

  @override
  String get emailLooksInvalid => 'Это не похоже на адрес электронной почты';

  @override
  String get emailNoSpaces => 'В адресе эл. почты не может быть пробелов';

  @override
  String get allowNotificationsSheetTitle => 'Разрешить уведомления';

  @override
  String get notificationsGrantNoPayload => 'Разрешение не вернуло ответа.';

  @override
  String get thisForumFallback => 'этот форум';

  @override
  String signInToDomain(String domain) {
    return 'Вход на $domain';
  }

  @override
  String get loginResultTitle => 'Результат входа';

  @override
  String get invalidAuthenticationCode => 'Неверный код аутентификации';

  @override
  String get tfaVerificationError =>
      'Во время проверки произошла ошибка. Повторите попытку.';

  @override
  String get passwordFieldLabel => 'Пароль';

  @override
  String get somethingWentWrongTryAgain =>
      'Что-то пошло не так. Повторите попытку.';

  @override
  String get unexpectedErrorTryAgain =>
      'Произошла непредвиденная ошибка. Повторите попытку.';

  @override
  String get errorNoInternetConnection =>
      'Нет подключения к интернету. Проверьте настройки сети.';

  @override
  String get errorRequestTimedOut =>
      'Время ожидания запроса истекло. Повторите попытку.';

  @override
  String get errorServerTryLater =>
      'Произошла ошибка сервера. Повторите попытку позже.';

  @override
  String get errorInvalidCredentials => 'Неверное имя пользователя или пароль.';

  @override
  String get errorSessionExpired =>
      'Срок действия сеанса истёк. Войдите снова.';

  @override
  String get errorAccountSuspended =>
      'Ваш аккаунт заблокирован. Обратитесь к персоналу форума.';

  @override
  String get errorForumNotFound => 'Форум не найден.';

  @override
  String get errorForumAccessDenied => 'У вас нет доступа к этому форуму.';

  @override
  String get errorForumUnavailable =>
      'Форум сейчас недоступен. Повторите попытку позже.';

  @override
  String get errorDataNotFound => 'Запрошенные данные не найдены.';

  @override
  String get errorDataCorrupted =>
      'Похоже, данные повреждены. Обновите страницу.';

  @override
  String get errorCacheLoadFailed =>
      'Не удалось загрузить кэшированные данные. Повторите попытку.';

  @override
  String errorInvalidField(String field) {
    return 'Недопустимое значение: $field.';
  }

  @override
  String errorFieldRequired(String field) {
    return 'Поле «$field» обязательно.';
  }

  @override
  String errorPermissionDeniedFor(String action) {
    return 'У вас нет прав на это действие: $action.';
  }

  @override
  String errorFeatureNotAvailable(String feature) {
    return 'Функция «$feature» недоступна на этом форуме.';
  }

  @override
  String get errorStorageFull => 'Хранилище заполнено. Освободите место.';

  @override
  String get errorStorageAccessDenied =>
      'Нет доступа к хранилищу. Проверьте разрешения приложения.';

  @override
  String get errorNetworkTryAgain =>
      'Произошла сетевая ошибка. Повторите попытку.';

  @override
  String get errorAuthenticationTryAgain =>
      'Ошибка аутентификации. Повторите попытку.';

  @override
  String get errorForumTryAgain =>
      'Произошла ошибка форума. Повторите попытку.';

  @override
  String get connectionErrorTitle => 'Ошибка подключения';

  @override
  String get authenticationErrorTitle => 'Ошибка аутентификации';

  @override
  String get forumErrorTitle => 'Ошибка форума';

  @override
  String get permissionErrorTitle => 'Ошибка доступа';

  @override
  String errorRemovingFromMessage(String name) {
    return 'Не удалось удалить $name из этого сообщения.';
  }

  @override
  String get chatNewMessage => 'Новое сообщение';

  @override
  String get chatStarred => 'Отмечено звездочкой';

  @override
  String get chatBrowseChannels => 'Просмотр каналов';

  @override
  String get chatBrowseAllChannels => 'Просмотреть все каналы';

  @override
  String get chatFilterAll => 'Все';

  @override
  String get chatFilterOpen => 'Открытые';

  @override
  String get chatFilterClosed => 'Закрытые';

  @override
  String get chatFilterArchived => 'Архивные';

  @override
  String get chatBrowseSearch => 'Поиск канала по названию';

  @override
  String get chatJoin => 'Подписаться';

  @override
  String get chatJoined => 'Подписан';

  @override
  String get chatLeave => 'Отписаться';

  @override
  String chatMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участников',
      many: '$count участников',
      few: '$count участника',
      one: '$count участник',
    );
    return '$_temp0';
  }

  @override
  String get chatYesterday => 'Вчера';

  @override
  String get chatNoChannelsFound => 'Каналы не обнаружены';

  @override
  String get chatCloseDm => 'Закрыть личный чат';

  @override
  String get chatToday => 'Сегодня';

  @override
  String get chatLastVisit => 'последнее посещение';

  @override
  String chatNewMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count нового сообщения',
      many: '$count новых сообщений',
      few: '$count новых сообщения',
      one: '$count новое сообщение',
    );
    return '$_temp0';
  }

  @override
  String get chatScrollToBottom => 'Прокрутка вниз';

  @override
  String get chatInReplyTo => 'В ответ на';

  @override
  String get chatCopyText => 'Копировать текст';

  @override
  String get chatTextCopied => 'Текст скопирован в буфер обмена';

  @override
  String get chatBookmark => 'Закладка';

  @override
  String get chatPinMessage => 'Закрепить сообщение';

  @override
  String get chatUnpinMessage => 'Открепить сообщение';

  @override
  String get chatFlag => 'Пожаловаться';

  @override
  String get chatReactWithEmoji => 'Реакция с помощью эмодзи';

  @override
  String chatReplyingTo(String username) {
    return 'Ответ $username';
  }

  @override
  String get chatEditingMessage => 'Редактирование сообщения';

  @override
  String chatTypingOne(String username) {
    return '$username печатает';
  }

  @override
  String chatTypingTwo(String commaSeparatedUsernames, String lastUsername) {
    return '$commaSeparatedUsernames и $lastUsername печатают';
  }

  @override
  String chatTypingMany(String commaSeparatedUsernames, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Отвечают $commaSeparatedUsernames и ещё $count пользователей',
      many: 'Отвечают $commaSeparatedUsernames и ещё $count пользователей',
      few: 'Отвечают $commaSeparatedUsernames и ещё $count пользователя',
      one: 'Отвечают $commaSeparatedUsernames и ещё $count пользователь',
    );
    return '$_temp0';
  }

  @override
  String get chatOpenThread => 'Открыть цепочку';

  @override
  String get chatMembers => 'Участники';

  @override
  String get chatAddMember => 'Добавить участника';

  @override
  String get chatFindMembers => 'Найти участников';

  @override
  String get chatRemoveMember => 'Удалить';

  @override
  String get chatNotifyNever => 'Никогда';

  @override
  String get chatNotifyMention => 'Только для упоминаний';

  @override
  String get chatNotifyAlways => 'Для всех действий';

  @override
  String get chatNotificationLevel => 'Отправлять push-уведомления';

  @override
  String get chatMuteChannel => 'Отключить канал';

  @override
  String get chatStarChannel => 'Помеченные каналы';

  @override
  String get chatLeaveChannel => 'Покинуть канал';

  @override
  String get chatSearchTitle => 'Поиск чата';

  @override
  String get chatSearchNoResults => 'Ничего не найдено';

  @override
  String get chatMyThreads => 'Мои цепочки сообщений';

  @override
  String chatThreadReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ответа',
      many: '$count ответов',
      few: '$count ответа',
      one: '$count ответ',
    );
    return '$_temp0';
  }

  @override
  String get chatNoThreads =>
      'Вы не участвуете ни в одной цепочке сообщений на этом канале.';

  @override
  String get chatGroupName => 'Название группового чата (необязательно)';

  @override
  String chatMembersCounter(int count, int max) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Участников: $count/$max',
      many: 'Участников: $count/$max',
      few: 'Участников: $count/$max',
      one: 'Участников: $count/$max',
    );
    return '$_temp0';
  }

  @override
  String get chatTooManyMembers =>
      'Достигнуто максимальное количество участников';

  @override
  String get chatThread => 'Цепочка';

  @override
  String get chatChannelSettings => 'Настройки канала';

  @override
  String get chatSearchMessagesHint => 'Искать в сообщениях';

  @override
  String get chatMyThreadsEmpty =>
      'У вас пока нет цепочек сообщений. Здесь появятся цепочки сообщений, в которых вы участвуете.';

  @override
  String get chatLeaveGroupInfo =>
      'Покинув этот групповой чат, вы потеряете к нему доступ и не будете получать связанные с ним уведомления. Чтобы снова присоединиться, вам потребуется повторное приглашение от участника группового чата.';

  @override
  String get chatPlaceholderThread => 'Чат в цепочке сообщений';

  @override
  String get chatLastReply => 'последний ответ';

  @override
  String messageListUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Непрочитанные ($count)',
      many: 'Непрочитанные ($count)',
      few: 'Непрочитанные ($count)',
      one: 'Непрочитанные ($count)',
    );
    return '$_temp0';
  }

  @override
  String messageListNewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Новые ($count)',
      many: 'Новые ($count)',
      few: 'Новые ($count)',
      one: 'Новые ($count)',
    );
    return '$_temp0';
  }

  @override
  String get messagePersonal => 'Личные';

  @override
  String messageListIncoming(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Есть $count новой или обновлённой темы',
      many: 'Есть $count новых или обновлённых тем',
      few: 'Есть $count новых или обновлённых темы',
      one: 'Есть $count новая или обновлённая тема',
    );
    return '$_temp0';
  }

  @override
  String get chatPlaceholderGroup => 'Чат в группе';

  @override
  String get notificationAccountMismatch =>
      'Это уведомление нельзя открыть в текущем аккаунте. Откройте уведомления, чтобы увидеть обновления для этого аккаунта.';

  @override
  String get chatJoinedChannels => 'Ваши каналы';

  @override
  String get chatAvailableChannels => 'Доступные каналы';

  @override
  String get chatAvailableChannelsDescription =>
      'Каналы, которые можно просматривать или к которым можно присоединиться.';

  @override
  String get chatAllChannelsJoined =>
      'Вы присоединились ко всем доступным каналам.';

  @override
  String get chatViewChannel => 'Просмотреть';

  @override
  String get mediaPlay => 'Воспроизвести';

  @override
  String get mediaPause => 'Пауза';
}
