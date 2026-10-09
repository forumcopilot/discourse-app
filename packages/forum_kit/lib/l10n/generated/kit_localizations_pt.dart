// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'kit_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class KitLocalizationsPt extends KitLocalizations {
  KitLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get okButton => 'OK';

  @override
  String get copied => 'Copiado';

  @override
  String get cancel => 'Cancelar';

  @override
  String get tryAgain => 'Tentar Novamente';

  @override
  String get latest => 'Recentes';

  @override
  String get language => 'Idioma';

  @override
  String get all => 'Todos';

  @override
  String get reason => 'Motivo';

  @override
  String get pleaseSpecifyReason => 'Por favor, especifique o motivo';

  @override
  String get selectDate => 'Selecionar data';

  @override
  String get search => 'Buscar';

  @override
  String get messages => 'Mensagens';

  @override
  String get add => 'Adicionar';

  @override
  String get delete => 'Excluir';

  @override
  String get temporary => 'Temporário';

  @override
  String error(String error) {
    return 'Erro: $error';
  }

  @override
  String get none => 'Nenhum';

  @override
  String get italic => 'Itálico';

  @override
  String get link => 'Link';

  @override
  String get image => 'Imagem';

  @override
  String get quote => 'Citação';

  @override
  String get code => 'Código';

  @override
  String participants(int count) {
    return 'Participantes ($count)';
  }

  @override
  String get refresh => 'Atualizar';

  @override
  String get share => 'Compartilhar';

  @override
  String get reply => 'Responder';

  @override
  String get dark => 'Escuro';

  @override
  String get notifications => 'Notificações';

  @override
  String get edit => 'Editar';

  @override
  String get remove => 'Remover';

  @override
  String get message => 'Mensagem';

  @override
  String couldNotOpenLink(String error) {
    return 'Não foi possível abrir o link: $error';
  }

  @override
  String timeGapDaysLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias depois',
      one: '1 dia depois',
    );
    return '$_temp0';
  }

  @override
  String timeGapMonthsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses depois',
      one: '1 mês depois',
    );
    return '$_temp0';
  }

  @override
  String timeGapYearsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anos depois',
      one: '1 ano depois',
    );
    return '$_temp0';
  }

  @override
  String get apply => 'Aplicar';

  @override
  String get bookmarks => 'Favoritos';

  @override
  String get copy => 'Copiar';

  @override
  String get firstPostsOnly => 'Apenas primeiras postagens';

  @override
  String get relevance => 'Relevância';

  @override
  String get reset => 'Redefinir';

  @override
  String get titleOnly => 'Apenas título';

  @override
  String get solved => 'Resolvido';

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
  String get postNeedsApprovalTitle => 'A postagem precisa de aprovação';

  @override
  String get postNeedsApprovalBody =>
      'Nós recebemos sua nova postagem, mas é necessário ter aprovação da moderação antes de ser exibida. Pedimos paciência.';

  @override
  String get tapToOpen => 'Toque para abrir';

  @override
  String get imageNotAvailable => 'Imagem indisponível';

  @override
  String get searchFilters => 'Filtros de pesquisa';

  @override
  String get tags => 'Tags';

  @override
  String topicMapViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'visualizações',
      one: 'visualização',
    );
    return '$_temp0';
  }

  @override
  String topicMapLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'curtidas',
      one: 'curtida',
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
      other: 'usuários',
      one: 'usuário',
    );
    return '$_temp0';
  }

  @override
  String get day => 'Dia';

  @override
  String get month => 'Mês';

  @override
  String get suspendUser => 'Suspender usuário(a)';

  @override
  String get suspendUntil => 'Suspender usuário até';

  @override
  String get suspendForever => 'Suspender para sempre';

  @override
  String get suspendReasonNotListening =>
      'Não dava atenção aos comentários da equipe';

  @override
  String get suspendReasonStaffTime =>
      'Consumia uma quantidade desproporcional de tempo da equipe';

  @override
  String get suspendReasonCombative => 'Muito agressivo(a)';

  @override
  String get suspendReasonWrongPlace => 'No lugar errado';

  @override
  String get suspendReasonNoPurpose =>
      'Nenhum propósito construtivo em suas ações, exceto criar discórdia na comunidade';

  @override
  String get suspendReasonCustom => 'Personalizado…';

  @override
  String get suspendReasonQuestion =>
      'Por que você está suspendendo? Este texto será exibido para o(a) usuário(a) quando tentar entrar. Seja breve.';

  @override
  String get closedLabel => 'Fechado';

  @override
  String get pleaseSelectSuspensionEndDate =>
      'Escolha quando a suspensão termina';

  @override
  String get dismissAllNotifications => 'Descartar tudo';

  @override
  String get searchFilterStatusSection => 'Status';

  @override
  String get searchFilterMyActivitySection => 'Minha atividade';

  @override
  String get searchFilterMatchTypeSection => 'Tipo de correspondência';

  @override
  String get searchTagsFilterHelper =>
      'Separadas por espaço ou vírgula. Todas as etiquetas são obrigatórias.';

  @override
  String get searchSortBy => 'Ordenar por';

  @override
  String get searchStatusOpen => 'Aberto';

  @override
  String get searchStatusArchived => 'Arquivado';

  @override
  String get searchStatusNoReplies => 'Sem respostas';

  @override
  String get searchStatusPublicOnly => 'Somente públicos';

  @override
  String get searchStatusUnsolved => 'Não solucionado';

  @override
  String get searchInBookmarked => 'Marquei como favorito';

  @override
  String get searchInMyMessages => 'Nas minhas mensagens';

  @override
  String get searchInLiked => 'Curti';

  @override
  String get searchInPosted => 'Postei em';

  @override
  String get searchInWatching => 'Estou acompanhando';

  @override
  String get searchInTracking => 'Estou monitorando';

  @override
  String get searchInSeen => 'Li';

  @override
  String get searchInUnseen => 'Não li';

  @override
  String get searchSortLatestPost => 'Última postagem';

  @override
  String get searchSortMostLiked => 'Mais curtido(a)';

  @override
  String get searchSortMostViewed => 'Mais visto(a)';

  @override
  String get searchSortLatestTopic => 'Último tópico';

  @override
  String get searchFieldHint => 'Pesquisar…';

  @override
  String get postLikeAction => 'Curtir a postagem';

  @override
  String get postUnlikeAction => 'Desfazer curtida';
}
