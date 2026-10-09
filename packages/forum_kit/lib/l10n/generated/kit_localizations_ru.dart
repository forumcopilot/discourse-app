// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'kit_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class KitLocalizationsRu extends KitLocalizations {
  KitLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get okButton => 'ОК';

  @override
  String get copied => 'Скопировано';

  @override
  String get cancel => 'Отмена';

  @override
  String get tryAgain => 'Попробовать Снова';

  @override
  String get latest => 'Последние';

  @override
  String get language => 'Язык';

  @override
  String get all => 'Все';

  @override
  String get reason => 'Причина';

  @override
  String get pleaseSpecifyReason => 'Пожалуйста, укажите причину';

  @override
  String get selectDate => 'Выбрать дату';

  @override
  String get search => 'Поиск';

  @override
  String get messages => 'Сообщения';

  @override
  String get add => 'Добавить';

  @override
  String get delete => 'Удалить';

  @override
  String get temporary => 'Временный';

  @override
  String error(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get none => 'Нет';

  @override
  String get italic => 'Курсив';

  @override
  String get link => 'Ссылка';

  @override
  String get image => 'Изображение';

  @override
  String get quote => 'Цитата';

  @override
  String get code => 'Код';

  @override
  String participants(int count) {
    return 'Участники ($count)';
  }

  @override
  String get refresh => 'Обновить';

  @override
  String get share => 'Поделиться';

  @override
  String get reply => 'Ответить';

  @override
  String get dark => 'Тёмная';

  @override
  String get notifications => 'Уведомления';

  @override
  String get edit => 'Редактировать';

  @override
  String get remove => 'Удалить';

  @override
  String get message => 'Сообщение';

  @override
  String couldNotOpenLink(String error) {
    return 'Не удалось открыть ссылку: $error';
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
  String get apply => 'Применить';

  @override
  String get bookmarks => 'Закладки';

  @override
  String get copy => 'Копировать';

  @override
  String get firstPostsOnly => 'Только первые сообщения';

  @override
  String get relevance => 'Релевантность';

  @override
  String get reset => 'Сбросить';

  @override
  String get titleOnly => 'Только заголовок';

  @override
  String get solved => 'Решено';

  @override
  String get open => 'Открыть';

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
  String get postNeedsApprovalTitle => 'Сообщение требует одобрения';

  @override
  String get postNeedsApprovalBody =>
      'Сообщение получено, но оно требует проверки и утверждения модератором перед публикацией. Будьте терпеливы.';

  @override
  String get tapToOpen => 'Нажмите, чтобы открыть';

  @override
  String get imageNotAvailable => 'Изображение недоступно';

  @override
  String get searchFilters => 'Фильтры поиска';

  @override
  String get tags => 'Теги';

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
  String get day => 'День';

  @override
  String get month => 'Месяц';

  @override
  String get suspendUser => 'Блокировка пользователя';

  @override
  String get suspendUntil => 'Блокировка пользователя до';

  @override
  String get suspendForever => 'Бессрочная блокировка';

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
  String get pleaseSelectSuspensionEndDate =>
      'Выберите, когда закончится блокировка';

  @override
  String get dismissAllNotifications => 'Отклонить всё';

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
  String get postLikeAction => 'Поставить лайк сообщению';

  @override
  String get postUnlikeAction => 'Убрать лайк';
}
