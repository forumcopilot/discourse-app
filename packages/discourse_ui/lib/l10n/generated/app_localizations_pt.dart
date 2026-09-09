// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get loginTitle => 'Entrar';

  @override
  String get usePasskey => 'Use Passkey';

  @override
  String get passkeyContinuePrompt => 'Use your passkey to continue';

  @override
  String get continueButton => 'Continuar';

  @override
  String get errorTitle => 'Erro';

  @override
  String get okButton => 'OK';

  @override
  String get retryButton => 'Tentar novamente';

  @override
  String get copyToClipboard => 'Copiar para área de transferência';

  @override
  String get copied => 'Copiado';

  @override
  String get errorMessageCopiedToClipboard =>
      'Mensagem de erro copiada para área de transferência';

  @override
  String get dismiss => 'Dispensar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get tryAgain => 'Tentar Novamente';

  @override
  String get anErrorOccurred => 'Ocorreu um erro';

  @override
  String get accountPendingApproval =>
      'Sua conta está aguardando aprovação. Você pode navegar pelo fórum, mas não pode postar até que um moderador aprove sua conta.';

  @override
  String get checkEmailToConfirm =>
      'Por favor, verifique seu e-mail para confirmar sua conta. Clique no link de confirmação no e-mail que enviamos.';

  @override
  String get checkNewEmailToConfirm =>
      'Por favor, verifique seu novo endereço de e-mail para confirmar a alteração. Seu e-mail antigo permanecerá ativo até que você confirme o novo.';

  @override
  String get emailAddressInvalid =>
      'Seu endereço de e-mail parece ser inválido ou está rejeitando e-mails. Por favor, atualize seu endereço de e-mail nas configurações da conta.';

  @override
  String get accountDisabled =>
      'Sua conta foi desabilitada. Por favor, entre em contato com um administrador para obter assistência.';

  @override
  String get accountRegistrationRejected =>
      'O registro da sua conta foi rejeitado. Por favor, entre em contato com um administrador para mais informações.';

  @override
  String get welcomeToForumCopilot => 'Bem-vindo ao Forum Copilot!';

  @override
  String get successfullyLoggedOut => 'Você foi desconectado com sucesso';

  @override
  String get accountStatusRequiresAttention =>
      'O status da sua conta requer atenção. Por favor, entre em contato com um administrador se tiver dúvidas.';

  @override
  String get updateEmail => 'Atualizar e-mail';

  @override
  String get resend => 'Reenviar';

  @override
  String get noLatestTopics => 'Sem tópicos recentes';

  @override
  String get noRecentTopicsToDisplay =>
      'Não há tópicos recentes para exibir. Volte mais tarde para novas discussões.';

  @override
  String get signInToViewLatestTopics => 'Faça login para ver tópicos recentes';

  @override
  String get youNeedToBeSignedInToViewLatestTopics =>
      'Você precisa estar conectado para ver tópicos recentes';

  @override
  String get thereAreNoUnreadTopics =>
      'Não há tópicos não lidos. Volte mais tarde para novas discussões.';

  @override
  String get youAreAllCaughtUp => 'Você está em dia!';

  @override
  String get signInToViewUnreadTopics =>
      'Faça login para ver tópicos não lidos';

  @override
  String get youNeedToBeSignedInToViewUnreadTopics =>
      'Você precisa estar conectado para ver seus tópicos não lidos';

  @override
  String get latest => 'Recentes';

  @override
  String get unread => 'Não lidos';

  @override
  String get failedToConnectToSite =>
      'Falha ao conectar ao site. O site pode estar fora do ar ou inacessível.';

  @override
  String get connectionFailed => 'Falha de conexão';

  @override
  String failedToConnectToSiteName(String siteName) {
    return 'Falha ao conectar a $siteName';
  }

  @override
  String get loading => 'Carregando...';

  @override
  String get newConversation => 'Nova conversa';

  @override
  String get language => 'Idioma';

  @override
  String get all => 'Todos';

  @override
  String get topicsOnly => 'Apenas tópicos';

  @override
  String get titlesOnly => 'Apenas títulos';

  @override
  String failedToShareTopic(String error) {
    return 'Falha ao compartilhar tópico: $error';
  }

  @override
  String get pleaseLoginToSubscribe =>
      'Por favor, faça login para null este tópico';

  @override
  String get subscribe => 'Inscrever-se';

  @override
  String get failedToSubscribeToThread => 'Falha ao null tópico';

  @override
  String get youCannotReplyToThisThread =>
      'Você não pode responder a este tópico';

  @override
  String get pleaseWaitForThreadToLoad =>
      'Por favor, aguarde o carregamento do tópico';

  @override
  String get softDelete => 'Exclusão suave';

  @override
  String get postCanBeRestoredLater =>
      'A postagem pode ser restaurada mais tarde';

  @override
  String get hardDelete => 'Exclusão permanente';

  @override
  String get postWillBePermanentlyDeleted =>
      'A postagem será excluída permanentemente';

  @override
  String get reasonForDeletion => 'Motivo da exclusão';

  @override
  String get enterReasonForDeletingPost =>
      'Insira o motivo para excluir esta postagem';

  @override
  String get pleaseEnterReasonForDeletion =>
      'Por favor, digite um motivo para a exclusão';

  @override
  String get reportPost => 'Denunciar postagem';

  @override
  String get pleaseProvideReasonForReporting =>
      'Por favor, forneça um motivo para denunciar esta postagem.';

  @override
  String get reason => 'Motivo';

  @override
  String get enterReasonForReportingPost =>
      'Insira o motivo para denunciar esta postagem';

  @override
  String get pleaseEnterReason => 'Por favor, insira um motivo';

  @override
  String get submitReport => 'Enviar denúncia';

  @override
  String get selectedActions => 'Ações selecionadas:';

  @override
  String get thisActionCannotBeUndone => 'Esta ação não pode ser desfeita.';

  @override
  String get participantsLabel => 'Participantes';

  @override
  String usernameHasBeenInvited(String username) {
    return '$username foi convidado para a conversa';
  }

  @override
  String errorInvitingUser(String error) {
    return 'Erro ao convidar usuário: $error';
  }

  @override
  String get newTopic => 'Novo tópico';

  @override
  String get markRead => 'Marcar como lido';

  @override
  String get spamOrAdvertising => 'Spam ou publicidade';

  @override
  String get otherPleaseSpecify => 'Outro (por favor, especifique)';

  @override
  String get pleaseSpecifyReason => 'Por favor, especifique o motivo';

  @override
  String get banUser => 'Banir usuário';

  @override
  String get unbanUser => 'Desbanir usuário';

  @override
  String pleaseSelectReasonForBanningUser(String username) {
    return 'Por favor, selecione um motivo para banir $username';
  }

  @override
  String get violationOfCommunityGuidelines =>
      'Violação das diretrizes da comunidade';

  @override
  String get harassmentOrAbusiveBehavior => 'Assédio ou comportamento abusivo';

  @override
  String get postingInappropriateContent => 'Publicação de conteúdo inadequado';

  @override
  String get accountCompromiseOrSecurityIssue =>
      'Comprometimento da conta ou problema de segurança';

  @override
  String get enterReasonForBanningUser =>
      'Insira o motivo para banir este usuário';

  @override
  String get banUntil => 'Banir até';

  @override
  String get selectDate => 'Selecionar data';

  @override
  String get moreOptions => 'Mais opções';

  @override
  String get topicClosed => 'Tópico fechado';

  @override
  String get topicOpened => 'Tópico aberto';

  @override
  String get topicStickied => 'Tópico fixado';

  @override
  String get topicUnstickied => 'Tópico desfixado';

  @override
  String cannotEditMessage(String error) {
    return 'Não é possível editar esta mensagem: $error';
  }

  @override
  String get confirmSpamClean => 'Confirmar limpeza de spam';

  @override
  String get handleThreads => 'Gerenciar tópicos';

  @override
  String get deleteMessages => 'Excluir mensagens';

  @override
  String get deleteConversations => 'Excluir conversas';

  @override
  String get noConversations => 'Sem conversas';

  @override
  String get noConversationsMessage =>
      'Você ainda não tem conversas. Inicie uma nova conversa para começar a enviar mensagens.';

  @override
  String get imageSavedToGallery => 'Imagem salva na galeria!';

  @override
  String failedToSaveImage(String error) {
    return 'Falha ao salvar imagem: $error';
  }

  @override
  String get userProfile => 'Perfil do Usuário';

  @override
  String get deletePost => 'Excluir Publicação';

  @override
  String get loginRequired => 'Login Necessário';

  @override
  String get spamCleaner => 'Limpeza de Spam';

  @override
  String get sendMessage => 'Enviar mensagem';

  @override
  String get memberSince => 'Membro Desde';

  @override
  String get lastActivity => 'Última Atividade';

  @override
  String get likesReceived => 'Curtidas Recebidas';

  @override
  String get likesGiven => 'Curtidas Dadas';

  @override
  String get showMore => 'Mostrar mais';

  @override
  String get cleanSpam => 'Limpar spam';

  @override
  String get failedToSaveConversation => 'Falha ao salvar conversa';

  @override
  String get members => 'Membros';

  @override
  String membersCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString Membros';
  }

  @override
  String get noSubject => 'Sem assunto';

  @override
  String get search => 'Buscar';

  @override
  String get logout => 'Sair';

  @override
  String get areYouSureYouWantToLogout => 'Tem certeza de que deseja sair?';

  @override
  String get register => 'Registrar';

  @override
  String get signIn => 'Entrar';

  @override
  String get markForumRead => 'Marcar Fórum como Lido';

  @override
  String get notificationTest => 'Teste de Notificação';

  @override
  String get forum => 'Fórum';

  @override
  String get profile => 'Perfil';

  @override
  String get messages => 'Mensagens';

  @override
  String get add => 'Adicionar';

  @override
  String get retry => 'Tentar Novamente';

  @override
  String get delete => 'Excluir';

  @override
  String get deleteMessage => 'Excluir Mensagem';

  @override
  String get deletingPost => 'Excluindo publicação...';

  @override
  String failedToUnlikePost(String error) {
    return 'Falha ao remover curtida da publicação: $error';
  }

  @override
  String failedToLikePost(String error) {
    return 'Falha ao curtir publicação: $error';
  }

  @override
  String get signInToViewMessages => 'Faça login para ver mensagens';

  @override
  String get youNeedToBeSignedInToViewConversations =>
      'Você precisa estar conectado para ver suas conversas.';

  @override
  String errorLoadingConversations(String error) {
    return 'Erro ao carregar conversas: $error';
  }

  @override
  String failedToLeaveConversation(String error) {
    return 'Falha ao deixar conversa: $error';
  }

  @override
  String errorLoadingMoreConversations(String error) {
    return 'Erro ao carregar mais conversas: $error';
  }

  @override
  String get searchFailed => 'Busca falhou';

  @override
  String get userInformationNotAvailable =>
      'Informações do usuário não disponíveis';

  @override
  String get birthday => 'Aniversário';

  @override
  String get posts => 'Publicações';

  @override
  String get following => 'Seguindo';

  @override
  String get followers => 'Seguidores';

  @override
  String get about => 'Sobre';

  @override
  String get location => 'Localização';

  @override
  String get website => 'Site';

  @override
  String get next => 'Próximo';

  @override
  String get permanent => 'Permanente';

  @override
  String get temporary => 'Temporário';

  @override
  String setBanDurationFor(String username) {
    return 'Definir a duração do banimento para $username';
  }

  @override
  String get pleaseSelectEndDateForTemporaryBan =>
      'Por favor, selecione uma data de término para o banimento temporário';

  @override
  String get back => 'Voltar';

  @override
  String get unban => 'Desbanir';

  @override
  String get confirm => 'Confirmar';

  @override
  String spamClean(String username) {
    return 'Limpar Spam de $username';
  }

  @override
  String get selectActionsToPerform => 'Selecione as ações a realizar:';

  @override
  String get moveOrDeleteThreadsBasedOnAdminSettings =>
      'Mover ou excluir tópicos com base nas configurações do administrador';

  @override
  String get messageUpdatedSuccessfully => 'Mensagem atualizada com sucesso';

  @override
  String error(String error) {
    return 'Erro: $error';
  }

  @override
  String failedToRemoveAttachment(String error) {
    return 'Falha ao remover anexo: $error';
  }

  @override
  String failedToLoadMessage(String error) {
    return 'Falha ao carregar mensagem: $error';
  }

  @override
  String get editMessage => 'Editar Mensagem';

  @override
  String get removeAttachment => 'Remover Anexo';

  @override
  String get areYouSureYouWantToRemoveThisAttachment =>
      'Tem certeza de que deseja remover este anexo?';

  @override
  String get none => 'Nenhum';

  @override
  String get attachFile => 'Anexar Arquivo';

  @override
  String get uploadImage => 'Enviar Imagem';

  @override
  String get formatting => 'Formatação';

  @override
  String get bold => 'Negrito';

  @override
  String get italic => 'Itálico';

  @override
  String get underline => 'Sublinhado';

  @override
  String get strikethrough => 'Tachado';

  @override
  String get link => 'Link';

  @override
  String get image => 'Imagem';

  @override
  String get video => 'Vídeo';

  @override
  String get quote => 'Citação';

  @override
  String get code => 'Código';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get bulletList => 'Lista com Marcadores';

  @override
  String get numberedList => 'Lista Numerada';

  @override
  String get listItem => 'Item da Lista';

  @override
  String participants(int count) {
    return 'Participantes ($count)';
  }

  @override
  String get markAsUnread => 'Marcar como não lido';

  @override
  String get invite => 'Convidar';

  @override
  String get enterKeywordsToSearchTopics =>
      'Digite palavras-chave para buscar tópicos...';

  @override
  String get undelete => 'Restaurar';

  @override
  String get refresh => 'Atualizar';

  @override
  String get share => 'Compartilhar';

  @override
  String get viewOnWeb => 'Ver na Web';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get lock => 'Bloquear';

  @override
  String get stick => 'Fixar';

  @override
  String get unstick => 'Desfixar';

  @override
  String get reply => 'Responder';

  @override
  String get vote => 'Votar';

  @override
  String votesCount(int count) {
    return '$count votos';
  }

  @override
  String get pollClosed => 'Enquete encerrada';

  @override
  String pollEndsOn(String date) {
    return 'Termina em $date';
  }

  @override
  String get voteToSeeResults => 'Vote para ver os resultados';

  @override
  String get viewFullPoll => 'Ver enquete completa';

  @override
  String pollOptionsCount(int count) {
    return '$count opções';
  }

  @override
  String get reactedBy => 'Reagido por';

  @override
  String get enterKeywordsToFindTopicsAndPosts =>
      'Digite palavras-chave para encontrar tópicos e postagens';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Escuro';

  @override
  String version(String version, String buildNumber) {
    return 'versão $version ($buildNumber)';
  }

  @override
  String get unableToLoadProfile => 'Não foi possível carregar o perfil';

  @override
  String get banned => 'BANIDO';

  @override
  String get reportSubmittedSuccessfully => 'Denúncia enviada com sucesso';

  @override
  String get deleteTopic => 'Excluir tópico';

  @override
  String get topicCanBeRestoredLater =>
      'O tópico pode ser restaurado mais tarde';

  @override
  String get topicWillBePermanentlyDeleted =>
      'O tópico será excluído permanentemente';

  @override
  String get enterReasonForDeletingTopic =>
      'Digite o motivo para excluir este tópico';

  @override
  String get pleaseSelectEndDate => 'Por favor, selecione uma data de término';

  @override
  String get userBannedSuccessfully => 'Usuário banido com sucesso';

  @override
  String get failedToBanUser => 'Falha ao banir usuário';

  @override
  String get userUnbannedSuccessfully => 'Usuário desbanido com sucesso';

  @override
  String get failedToUnbanUser => 'Falha ao desbanir usuário';

  @override
  String get spamCleanUser => 'Limpar spam do usuário';

  @override
  String get deletePrivateConversations => 'Excluir conversas privadas';

  @override
  String get banTheUserAccount => 'Banir a conta do usuário';

  @override
  String get handledThreads => 'Tópicos tratados';

  @override
  String get deletedMessages => 'Mensagens excluídas';

  @override
  String get deletedConversations => 'Conversas excluídas';

  @override
  String get bannedUser => 'Usuário banido';

  @override
  String successfullyCleanedSpam(String username, String actions) {
    return 'Spam limpo com sucesso para $username. Ações: $actions';
  }

  @override
  String get home => 'Início';

  @override
  String get notifications => 'Notificações';

  @override
  String get forums => 'Fóruns';

  @override
  String get markAllForumsAsRead => 'Marcar todos os fóruns como lidos?';

  @override
  String get markAllForumsAsReadMessage =>
      'Isso marcará todos os fóruns e tópicos como lidos. Esta ação não pode ser desfeita.';

  @override
  String get markAsRead => 'Marcar como lido';

  @override
  String get content => 'Conteúdo';

  @override
  String get insertImage => 'Inserir imagem';

  @override
  String get howWouldYouLikeToInsertImage =>
      'Como você gostaria de inserir esta imagem?';

  @override
  String get thumbnail => 'Miniatura';

  @override
  String get fullSize => 'Tamanho completo';

  @override
  String get pleaseEnterTitle => 'Por favor, insira um título';

  @override
  String get pleaseEnterContent => 'Por favor, insira algum conteúdo';

  @override
  String get uploading => 'Enviando...';

  @override
  String get uploaded => 'Enviado';

  @override
  String get mentionUser => 'Mencionar usuário';

  @override
  String get submittingReport => 'Enviando relatório...';

  @override
  String get banningUser => 'Banindo usuário...';

  @override
  String get unbanningUser => 'Desbanindo usuário...';

  @override
  String get cleaningSpam => 'Limpando spam...';

  @override
  String get writeYourMessage => 'Escreva sua mensagem...';

  @override
  String get writeYourReply => 'Escreva sua resposta...';

  @override
  String get conversationCreatedSuccessfully => 'Conversa criada com sucesso';

  @override
  String get conversationMarkedAsUnread => 'Conversa marcada como não lida';

  @override
  String get conversationClosed => 'Conversa fechada';

  @override
  String get conversationOpened => 'Conversa aberta';

  @override
  String get pleaseLoginToLikeMessages =>
      'Por favor, faça login para curtir mensagens';

  @override
  String get loadEarlierMessages => 'Carregar mensagens anteriores';

  @override
  String failedToLoadQuote(String error) {
    return 'Falha ao carregar citação: \n$error';
  }

  @override
  String failedToSendReply(String error) {
    return 'Falha ao enviar resposta: $error';
  }

  @override
  String failedToMarkConversationAsUnread(String error) {
    return 'Falha ao marcar conversa como não lida: $error';
  }

  @override
  String failedToCloseConversation(String error) {
    return 'Falha ao fechar conversa: $error';
  }

  @override
  String failedToOpenConversation(String error) {
    return 'Falha ao abrir conversa: $error';
  }

  @override
  String failedToJumpToMessage(String error) {
    return 'Falha ao pular para mensagem: $error';
  }

  @override
  String get goToTop => 'Ir para o topo';

  @override
  String get goToBottom => 'Ir para o fundo';

  @override
  String get pleaseLoginToAccessContent =>
      'Por favor, faça login para acessar este conteúdo e interagir com as postagens.';

  @override
  String get searchUsers => 'Buscar usuários...';

  @override
  String get enterConversationTitle => 'Insira o título da conversa';

  @override
  String enterCode(int count) {
    return 'Insira código de $count dígitos';
  }

  @override
  String get edit => 'Editar';

  @override
  String get report => 'Denunciar';

  @override
  String get remove => 'Remover';

  @override
  String get subject => 'Assunto';

  @override
  String get message => 'Mensagem';

  @override
  String get titleCannotBeEmpty => 'O título não pode estar vazio';

  @override
  String get conversationUpdatedSuccessfully =>
      'Conversa atualizada com sucesso';

  @override
  String get goBack => 'Voltar';

  @override
  String failedToLoadPost(String error) {
    return 'Erro ao carregar publicação: \n$error';
  }

  @override
  String failedToLikeOrUnlikeMessage(String action, String error) {
    return 'Falha ao $action mensagem: $error';
  }

  @override
  String get like => 'curtir';

  @override
  String get unlike => 'descurtir';

  @override
  String downloading(String filename) {
    return 'Baixando $filename...';
  }

  @override
  String openingShareSheet(String filename) {
    return 'Abrindo folha de compartilhamento para $filename';
  }

  @override
  String errorDownloading(String filename, String error) {
    return 'Erro ao baixar $filename: $error';
  }

  @override
  String get failedToNavigateToForum => 'Falha ao navegar para o fórum';

  @override
  String forumNotFoundById(String forumId) {
    return 'Fórum não encontrado: $forumId';
  }

  @override
  String couldNotOpenLink(String error) {
    return 'Não foi possível abrir o link: $error';
  }

  @override
  String get translating => 'Traduzindo...';

  @override
  String get translated => 'Traduzido';

  @override
  String get translatedContent => 'Conteúdo traduzido';

  @override
  String get twoFactorAuthentication => 'Autenticação de dois fatores';

  @override
  String get authenticationCodeLabel => 'Código de autenticação';

  @override
  String get pleaseEnterYourAuthenticationCode =>
      'Digite seu código de autenticação';

  @override
  String codeMustBeDigits(int count) {
    return 'O código deve ter $count dígitos';
  }

  @override
  String get codeMustContainOnlyNumbers =>
      'O código deve conter apenas números';

  @override
  String get verifyButton => 'Verificar';

  @override
  String get attachments => 'Anexos';

  @override
  String get replyOptions => 'Opcoes de resposta';

  @override
  String get replyWithQuote => 'Responder com citacao';

  @override
  String fileSavedToDownloads(String filename) {
    return 'Arquivo salvo em Downloads: $filename';
  }

  @override
  String fileSavedToDocuments(String filename) {
    return 'Arquivo salvo em Documentos: $filename';
  }

  @override
  String topicLastReplyBy(String username, String time) {
    return '$username respondeu $time';
  }

  @override
  String inReplyToUser(String username) {
    return 'em resposta a $username';
  }

  @override
  String inReplyToPost(int number) {
    return 'em resposta à postagem #$number';
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
  String get profileViews => 'Visualizações';

  @override
  String get badges => 'Emblemas';

  @override
  String get chatWithUser => 'Chat';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count respostas',
      one: '1 resposta',
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
    return '$label — em breve';
  }

  @override
  String moreBadges(Object count) {
    return '+$count mais';
  }

  @override
  String get allNotificationsMarkedAsRead =>
      'Todas as notificações marcadas como lidas';

  @override
  String get apply => 'Aplicar';

  @override
  String get bookmarks => 'Favoritos';

  @override
  String reviewableBy(String username) {
    return 'Por $username';
  }

  @override
  String get changeEmail => 'Alterar e-mail';

  @override
  String get changePassword => 'Alterar senha';

  @override
  String get checkingStatus => 'Verificando estado…';

  @override
  String get clearReminder => 'Remover lembrete';

  @override
  String get copy => 'Copiar';

  @override
  String get copyLink => 'Copiar link';

  @override
  String couldNotEnableNotifications(String error) {
    return 'Não foi possível ativar as notificações: $error';
  }

  @override
  String get couldNotFindBookmark => 'Este favorito não foi encontrado';

  @override
  String couldNotOpenEmail(String email) {
    return 'Não foi possível abrir o e-mail: $email';
  }

  @override
  String couldNotStartSignIn(String error) {
    return 'Não foi possível iniciar o login: $error';
  }

  @override
  String get customDateAndTime => 'Data e hora personalizadas';

  @override
  String get deleteAccount => 'Excluir conta';

  @override
  String get deleteMessageQuestion => 'Excluir mensagem?';

  @override
  String get discard => 'Descartar';

  @override
  String get discardDraftQuestion => 'Descartar rascunho?';

  @override
  String get doNotDisturb => 'Não perturbe';

  @override
  String get editHistory => 'Histórico de edições';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get editReminder => 'Editar lembrete';

  @override
  String emailCopiedToClipboard(String email) {
    return 'E-mail copiado para a área de transferência: $email';
  }

  @override
  String get pushEnabledForThisLogin => 'Ativadas para este login';

  @override
  String get failedToLoadMoreTopics =>
      'Não foi possível carregar mais tópicos. Role para tentar novamente.';

  @override
  String get failedToUpdateNotificationLevel =>
      'Não foi possível atualizar o nível de notificação';

  @override
  String get firstPostsOnly => 'Apenas primeiras postagens';

  @override
  String get ignoredUsers => 'Usuários ignorados';

  @override
  String get inTwoHours => 'Em duas horas';

  @override
  String get inviteByEmail => 'Convidar por e-mail';

  @override
  String get inviteLinkCopied => 'Link de convite copiado';

  @override
  String inviteSentTo(String email) {
    return 'Convite enviado para $email';
  }

  @override
  String get leave => 'Sair';

  @override
  String get leaveGroup => 'Sair do grupo';

  @override
  String get leaveGroupQuestion => 'Sair do grupo?';

  @override
  String get linkCopied => 'Link copiado';

  @override
  String get loadMore => 'Carregar mais';

  @override
  String get manageAccountOnWeb => 'Gerenciar conta na web';

  @override
  String get merge => 'Mesclar';

  @override
  String get mergeIntoTopic => 'Mesclar em tópico';

  @override
  String get newInviteLink => 'Novo link de convite';

  @override
  String get nextWeek => 'Próxima semana';

  @override
  String get pushNotAvailableInThisBuild => 'Não disponível nesta versão';

  @override
  String get notNow => 'Agora não';

  @override
  String tagNotificationLevelUpdated(String tag) {
    return 'Nível de notificação de \"$tag\" atualizado';
  }

  @override
  String doNotDisturbOnUntil(String until) {
    return 'Ativado até $until';
  }

  @override
  String get pleaseLogInToBookmark => 'Faça login para adicionar aos favoritos';

  @override
  String get pleaseLogInToFollowUsers => 'Faça login para seguir usuários';

  @override
  String get pleaseLogInToMarkAnswers => 'Faça login para marcar respostas';

  @override
  String get pleaseLogInToReact => 'Faça login para reagir';

  @override
  String get pleaseLogInToVote => 'Faça login para votar';

  @override
  String get pushNotifications => 'Notificações push';

  @override
  String get relevance => 'Relevância';

  @override
  String get reminderTimeMustBeInFuture =>
      'O horário do lembrete deve estar no futuro';

  @override
  String get removeBookmark => 'Remover favorito';

  @override
  String get removeVote => 'Remover voto';

  @override
  String get renameTopic => 'Renomear tópico';

  @override
  String reportedBy(String username) {
    return 'Denunciado por $username';
  }

  @override
  String get requestToJoin => 'Solicitar entrada';

  @override
  String requestToJoinGroup(String group) {
    return 'Solicitar entrada em $group';
  }

  @override
  String get reset => 'Redefinir';

  @override
  String get resizeAndUpload => 'Redimensionar e enviar';

  @override
  String get retryConnection => 'Tentar conectar novamente';

  @override
  String get reviewQueue => 'Fila de revisão';

  @override
  String get revoke => 'Revogar';

  @override
  String get revokeInviteQuestion => 'Revogar convite?';

  @override
  String get save => 'Salvar';

  @override
  String get sendInvite => 'Enviar convite';

  @override
  String get sendRequest => 'Enviar solicitação';

  @override
  String get settings => 'Configurações';

  @override
  String get showVoters => 'Mostrar votantes';

  @override
  String get signOut => 'Sair';

  @override
  String get signOutQuestion => 'Sair?';

  @override
  String get signInCancelledNoPayload =>
      'Login cancelado — nenhuma resposta recebida';

  @override
  String signInFailed(String error) {
    return 'Falha no login: $error';
  }

  @override
  String get startChat => 'Iniciar chat';

  @override
  String stoppedIgnoringUser(String username) {
    return 'Você parou de ignorar @$username';
  }

  @override
  String get submit => 'Enviar';

  @override
  String get discardDraftWarning =>
      'O rascunho salvo será removido permanentemente.';

  @override
  String get deleteChatMessageWarning => 'A mensagem será removida para todos.';

  @override
  String get titleOnly => 'Apenas título';

  @override
  String get tomorrow => 'Amanhã';

  @override
  String get turnOff => 'Desativar';

  @override
  String get turnOnNotifications => 'Ativar notificações';

  @override
  String get whisper => 'Sussurro';

  @override
  String likeAgainInSeconds(Object seconds) {
    return 'Você pode curtir esta postagem novamente em ${seconds}s';
  }

  @override
  String get loginInfo => 'Informações de login';

  @override
  String get loginFailed => 'Falha no login';

  @override
  String get moveToCategory => 'Mover para categoria';

  @override
  String get undeleteTopic => 'Restaurar tópico';

  @override
  String get undeleteTopicConfirmation =>
      'Tem certeza de que deseja restaurar este tópico? Ele voltará a ficar visível para outros usuários.';

  @override
  String get send => 'Enviar';

  @override
  String get changeEmailExplanation =>
      'Enviaremos um link de confirmação para o novo e-mail. A alteração entra em vigor quando você clicar nele.';

  @override
  String get changeEmailSecurityNote =>
      'Por segurança, o Discourse pode exigir confirmação pelo link no e-mail. Verifique a pasta de spam se não o encontrar.';

  @override
  String get newDirectMessage => 'Nova mensagem direta';

  @override
  String get noMessagesYetSayHi => 'Nenhuma mensagem ainda — diga oi.';

  @override
  String get edited => 'editado';

  @override
  String get editProfileManagedOnWebNote =>
      'Nome de exibição, e-mail, senha e outras configurações da conta são gerenciados em Conta → Gerenciar conta na web. Seu avatar pode ser alterado tocando no ícone de câmera na foto.';

  @override
  String get approvedButRelayUnreachable =>
      'Aprovado, mas não foi possível contatar o ForumCopilot para concluir a configuração. Tente novamente mais tarde em Configurações.';

  @override
  String get notificationsAreTurnedOffForThisApp =>
      'As notificações estão desativadas para este app';

  @override
  String forumWillAskToApproveNotifications(Object forumName) {
    return 'Em seguida, $forumName pedirá que você aprove \"Notificações\".';
  }

  @override
  String get approveNotificationsExplanation =>
      'Ao aprovar, podemos verificar suas notificações e enviá-las a este dispositivo. Esta permissão não pode publicar, responder ou ler suas mensagens.';

  @override
  String get forumOwnerPushNote =>
      'Se o responsável por este fórum configurar as notificações para o app, esta etapa não será necessária.';

  @override
  String get pleaseLoginToCreateANewTopic =>
      'Faça login para criar um novo tópico';

  @override
  String get pleaseLoginToSubscribeToForums =>
      'Faça login para se inscrever em fóruns';

  @override
  String leaveGroupWarning(Object group) {
    return 'Você deixará de ser membro de $group. Pode voltar a qualquer momento.';
  }

  @override
  String get groupMembersPrivate => 'A lista de membros deste grupo é privada.';

  @override
  String get unignore => 'Parar de ignorar';

  @override
  String get inviteLinkCreated => 'Link de convite criado';

  @override
  String expiresOn(Object date) {
    return 'Expira em $date';
  }

  @override
  String get protected => 'Protegido';

  @override
  String get solution => 'Solução';

  @override
  String get deleted => 'EXCLUÍDO';

  @override
  String get pleaseLoginToViewUserProfiles =>
      'Faça login para ver perfis de usuário.';

  @override
  String get announcement => 'Anúncio';

  @override
  String get solved => 'Resolvido';

  @override
  String get hot => 'Em alta';

  @override
  String get pinned => 'Fixado';

  @override
  String get subscribedLabel => 'Inscrito';

  @override
  String get locked => 'Bloqueado';

  @override
  String get poll => 'Enquete';

  @override
  String errorLoadingContent(Object error) {
    return 'Erro ao carregar o conteúdo: $error';
  }

  @override
  String get noPermissionToViewSubforum =>
      'Você não tem permissão para ver tópicos neste subfórum.';

  @override
  String get noDiscussionsYet => 'Nenhuma discussão ainda.';

  @override
  String get jumpToPost => 'Ir para a postagem';

  @override
  String get jump => 'Ir';

  @override
  String get endOfTheDiscussion => 'Fim da discussão';

  @override
  String get reviewQueueStaffOnly =>
      'Apenas a equipe e revisores podem ver a fila de revisão.';

  @override
  String get nothingToReview => 'Nada para revisar';

  @override
  String refreshFailed(Object error) {
    return 'Falha ao atualizar: $error';
  }

  @override
  String get topicDeletedBanner =>
      'Este tópico foi excluído e está oculto para outros usuários';

  @override
  String get topicClosedBanner =>
      'Este tópico está fechado e não aceita mais respostas';

  @override
  String get topicPinnedBanner => 'Este tópico está fixado no topo do fórum';

  @override
  String get youAreSubscribedToThisTopic => 'Você está inscrito neste tópico';

  @override
  String get refreshing => 'Atualizando...';

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
      'Esta diferença é grande demais para ser exibida.';

  @override
  String get noContentChangesInThisRevision =>
      'Nenhuma alteração de conteúdo nesta revisão.';

  @override
  String revisionOf(Object currentVersion, Object versionCount) {
    return 'Revisão $currentVersion de $versionCount';
  }

  @override
  String get editConversation => 'Editar conversa';

  @override
  String get closeConversation => 'Fechar conversa';

  @override
  String get openConversation => 'Abrir conversa';

  @override
  String get leaveConversation2 => 'Sair da conversa';

  @override
  String get reportConversation2 => 'Denunciar conversa';

  @override
  String get closeConversation2 => 'Fechar conversa';

  @override
  String get closeConversationConfirmation =>
      'Tem certeza de que deseja fechar esta conversa? Novas respostas não poderão ser publicadas.';

  @override
  String get close => 'Fechar';

  @override
  String get openConversation2 => 'Abrir conversa';

  @override
  String get openConversationConfirmation =>
      'Tem certeza de que deseja abrir esta conversa? Novas respostas poderão ser publicadas.';

  @override
  String get open => 'Abrir';

  @override
  String get leaveConversation3 => 'Sair da conversa';

  @override
  String get leaveConversationConfirmation =>
      'Tem certeza de que deseja sair desta conversa? Ela será ocultada da sua caixa de entrada.';

  @override
  String errorLoadingConversation(Object error) {
    return 'Erro ao carregar a conversa: $error';
  }

  @override
  String get conversationNotFound => 'Conversa não encontrada';

  @override
  String get conversationClosedBanner =>
      'Esta conversa está fechada e não aceita mais respostas';

  @override
  String get noMessagesFound => 'Nenhuma mensagem encontrada';

  @override
  String get endOfConversation => 'Fim da conversa';

  @override
  String get jumpToMessage => 'Ir para a mensagem';

  @override
  String get editConversation2 => 'Editar conversa';

  @override
  String get failedToLoadMessage2 => 'Não foi possível carregar a mensagem';

  @override
  String get cannotEditThisConversation =>
      'Não é possível editar esta conversa';

  @override
  String get options => 'Opções';

  @override
  String get conversationOpen => 'Conversa aberta';

  @override
  String failedToCreateConversation(Object error) {
    return 'Não foi possível criar a conversa: $error';
  }

  @override
  String maximumAttachmentsAllowed(Object count) {
    return 'Máximo de $count anexo(s) permitido(s)';
  }

  @override
  String get noImagesFoundToDisplay => 'Nenhuma imagem encontrada para exibir.';

  @override
  String get pleaseLoginToViewThisAttachment =>
      'Faça login para ver este anexo';

  @override
  String get searchForTopics => 'Pesquisar tópicos';

  @override
  String get noTopicsFound => 'Nenhum tópico encontrado';

  @override
  String get trySearchingWithDifferentKeywords =>
      'Tente pesquisar com outras palavras-chave';

  @override
  String get noPostsFound => 'Nenhuma postagem encontrada';

  @override
  String get perTopicNotificationLevelsNote =>
      'Os níveis de notificação por categoria e por tópico são definidos nessas telas — toque no ícone de sino em qualquer tópico ou categoria.';

  @override
  String get pushNotActiveForThisLogin =>
      'Não ativas para este login — saia e entre novamente para autorizar notificações push';

  @override
  String get pauseNotificationsFor => 'Pausar notificações por…';

  @override
  String get doNotDisturbExplanation =>
      'Pause as notificações por um tempo — o Discourse as retém até o fim do período';

  @override
  String get emailSettingsSubtitle =>
      'Frequência de e-mail, agregação de curtidas, resumo periódico';

  @override
  String get manageAccountSubtitle =>
      'Perfil, e-mail, senha, segurança, configurações avançadas';

  @override
  String get changePasswordSubtitle =>
      'Envia um e-mail de redefinição de senha para o endereço atual';

  @override
  String get ignoredUsersSubtitle =>
      'Veja e gerencie usuários cujas postagens estão ocultas para você';

  @override
  String get deleteAccountExplanation =>
      'A remoção da conta é feita no fórum. Continue para abrir o site e contatar a equipe — fóruns Discourse processam exclusões conforme sua própria política.';

  @override
  String get verificationEmailSent =>
      'E-mail de verificação enviado — clique no link para confirmar o novo endereço.';

  @override
  String get passwordResetExplanation =>
      'Enviaremos um link de redefinição de senha por e-mail. Clique nele para escolher uma nova senha — a alteração é feita no fórum, não neste app.';

  @override
  String get sendResetEmail => 'Enviar e-mail de redefinição';

  @override
  String get deleteAccountDialogBody =>
      'Sua conta é gerenciada pelo fórum. Contate a equipe do fórum diretamente para solicitar a remoção. \"Continuar\" abrirá o fórum no navegador para usar o fluxo de contato / mensagem à equipe do próprio site.';

  @override
  String get initializingForum => 'Inicializando fórum…';

  @override
  String get unableToLoadForums => 'Não foi possível carregar os fóruns';

  @override
  String get noForumsToDisplayExplanation =>
      'Não há fóruns para exibir. Isso pode ser devido a permissões ou à estrutura do fórum.';

  @override
  String get subscribedForums => 'Fóruns inscritos';

  @override
  String get errorLoadingNotifications => 'Erro ao carregar notificações';

  @override
  String get pullDownToRefresh => 'Puxe para baixo para atualizar';

  @override
  String get noNewNotificationsExplanation =>
      'Você não tem novas notificações. Volte mais tarde para ver atualizações dos tópicos que segue.';

  @override
  String noTagsMatch(Object filter) {
    return 'Nenhuma tag corresponde a \"$filter\".';
  }

  @override
  String noTopicsTagged(Object tag) {
    return 'Nenhum tópico com a tag \"$tag\"';
  }

  @override
  String failedToBanUser2(Object error) {
    return 'Não foi possível banir o usuário: $error';
  }

  @override
  String unbanUserConfirmation(Object username) {
    return 'Tem certeza de que deseja remover o banimento de $username?';
  }

  @override
  String failedToUnbanUser2(Object error) {
    return 'Não foi possível remover o banimento: $error';
  }

  @override
  String get deletePostsProfilePostsAndComments =>
      'Excluir postagens, postagens de perfil e comentários';

  @override
  String spamCleanConfirmation(Object username) {
    return 'Tem certeza de que deseja limpar o spam de $username?';
  }

  @override
  String failedToCleanSpam(Object error) {
    return 'Falha ao limpar spam: $error';
  }

  @override
  String get searchUser => 'Pesquisar usuário';

  @override
  String get tapToOpen => 'Toque para abrir';

  @override
  String get imageNotAvailable => 'Imagem indisponível';

  @override
  String get allForumTopicsHaveBeenMarkedAs =>
      'Todos os tópicos do fórum foram marcados como lidos';

  @override
  String postsCount(Object count) {
    return '$count postagens';
  }

  @override
  String get permissionDeniedToSaveImage =>
      'Permissão negada para salvar a imagem';

  @override
  String get postNotFound => 'Postagem não encontrada.';

  @override
  String get failedToUploadFilePleaseTryAgain =>
      'Falha ao enviar o arquivo. Tente novamente.';

  @override
  String failedToUploadFile2(Object errorMessage) {
    return 'Falha ao enviar o arquivo: $errorMessage';
  }

  @override
  String get failedToPickFile => 'Falha ao selecionar o arquivo';

  @override
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return 'Apenas mais $remainingSlots anexo(s) permitido(s). Processando as primeiras $remainingSlots2 imagens.';
  }

  @override
  String get attachmentLimitReachedSkippingRemainingImages =>
      'Limite de anexos atingido. Ignorando as imagens restantes.';

  @override
  String failedToUploadImagePleaseTryAgain(Object fileName) {
    return '$fileName: falha ao enviar a imagem. Tente novamente.';
  }

  @override
  String failedToUploadImage2(Object errorMessage, Object fileName) {
    return '$fileName: falha ao enviar a imagem: $errorMessage';
  }

  @override
  String get failedToPickImage => 'Falha ao selecionar a imagem';

  @override
  String failedToRemoveAttachment2(Object error) {
    return 'Falha ao remover o anexo: $error';
  }

  @override
  String sentFromMobileApp(Object siteName) {
    return 'Enviado do aplicativo móvel $siteName';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      'Aguarde o término do envio dos anexos';

  @override
  String get imageIsTooLargeToUpload => 'A imagem é grande demais para enviar';

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName tem $fileBytes. Este fórum permite até $maxBytes.';
  }

  @override
  String get resizeToFitExplanation =>
      'Ela pode ser reduzida apenas o suficiente para caber, mantendo o formato e o máximo de detalhe que o limite permitir.';

  @override
  String get failedToPostReplyPleaseTryAgain =>
      'Falha ao publicar a resposta. Tente novamente.';

  @override
  String get pleaseWaitForTheThreadToLoad => 'Aguarde o carregamento do tópico';

  @override
  String get failedToUpdatePostPleaseTryAgain =>
      'Falha ao atualizar a postagem. Tente novamente.';

  @override
  String get postDeletedSuccessfully => 'Postagem excluída';

  @override
  String failedToDeletePost(Object error) {
    return 'Falha ao excluir a postagem: $error';
  }

  @override
  String failedToSubmitReport2(Object error) {
    return 'Falha ao enviar a denúncia: $error';
  }

  @override
  String get editHistoryNotAvailable =>
      'O histórico de edições não está disponível para esta postagem';

  @override
  String get noPermissionToUploadAvatar =>
      'Você não tem permissão para enviar avatares';

  @override
  String get avatarUploadedSuccessfully => 'Avatar enviado';

  @override
  String failedToPickImage2(Object error) {
    return 'Falha ao selecionar a imagem: $error';
  }

  @override
  String get react => 'Reagir';

  @override
  String get reactionsAreNotEnabledOnThisForum =>
      'As reações não estão habilitadas neste fórum.';

  @override
  String get noReactionsYet => 'Nenhuma reação ainda';

  @override
  String get searchFilters => 'Filtros de pesquisa';

  @override
  String signOutWarning(Object siteName) {
    return 'Você sairá de $siteName. Pode entrar novamente a qualquer momento.';
  }

  @override
  String get suggestedTopics => 'Tópicos sugeridos';

  @override
  String get newLabel => 'NOVO';

  @override
  String get voteRemoved => 'Voto removido';

  @override
  String get voters => 'Votantes';

  @override
  String get noVotesYet => 'Nenhum voto ainda.';

  @override
  String get trustLevels => 'Níveis de confiança';

  @override
  String get trustLevelsExplanation =>
      'Os membros ganham confiança lendo e participando. Cada nível desbloqueia novas habilidades.';

  @override
  String get activity => 'Atividade';

  @override
  String get dontUpload => 'Não enviar';

  @override
  String get dontAskAgainAlwaysResize =>
      'Não perguntar novamente — sempre redimensionar';

  @override
  String get couldNotLoadCategories =>
      'Não foi possível carregar as categorias.';

  @override
  String get switchForum => 'Trocar de fórum';
}
