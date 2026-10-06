// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get accountSessionChanged =>
      'Sua sessão mudou. Reabra esta tela para continuar.';

  @override
  String get draftSessionChanged =>
      'Sua sessão mudou. Copie seu texto antes de reabrir o editor para trabalhar com rascunhos.';

  @override
  String get discardFailedCloseQuestion =>
      'Fechar mesmo assim? Um rascunho salvo antes continua em Rascunhos.';

  @override
  String get keepEditing => 'Continuar editando';

  @override
  String get closeAnyway => 'Fechar mesmo assim';

  @override
  String get uploadSessionChanged =>
      'Sua sessão mudou durante o envio. Reabra esta tela antes de tentar novamente.';

  @override
  String get submissionUnconfirmed =>
      'Não foi possível confirmar o envio. Seu texto foi mantido. Verifique o fórum antes de tentar novamente.';

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
  String get newConversation => 'Nova mensagem';

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
  String get youCannotReplyToThisThread =>
      'Você não pode responder a este tópico';

  @override
  String get pleaseWaitForThreadToLoad =>
      'Por favor, aguarde o carregamento do tópico';

  @override
  String get reason => 'Motivo';

  @override
  String get participantsLabel => 'Participantes';

  @override
  String usernameHasBeenInvited(String username) {
    return '$username foi convidado para a mensagem';
  }

  @override
  String errorInvitingUser(String error) {
    return 'Erro ao convidar usuário: $error';
  }

  @override
  String get newTopic => 'Novo tópico';

  @override
  String get pleaseSpecifyReason => 'Por favor, especifique o motivo';

  @override
  String get selectDate => 'Selecionar data';

  @override
  String get moreOptions => 'Mais opções';

  @override
  String get topicClosed => 'Tópico fechado';

  @override
  String get topicOpened => 'Tópico aberto';

  @override
  String get noConversations => 'Você não tem mensagens';

  @override
  String get noConversationsMessage =>
      'Você ainda não tem mensagens. Escreva uma nova mensagem para começar.';

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
  String get sendMessage => 'Mensagem';

  @override
  String get likesReceived => 'Curtidas Recebidas';

  @override
  String get showMore => 'Mostrar mais';

  @override
  String get failedToSaveConversation => 'Não foi possível salvar a mensagem';

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
  String get signIn => 'Entrar';

  @override
  String get notificationTest => 'Teste de Notificação';

  @override
  String get forum => 'Categoria';

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
      'Você precisa entrar para ver suas mensagens.';

  @override
  String failedToLeaveConversation(String error) {
    return 'Não foi possível sair da mensagem: $error';
  }

  @override
  String errorLoadingMoreConversations(String error) {
    return 'Erro ao carregar mais mensagens: $error';
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
  String get temporary => 'Temporário';

  @override
  String get back => 'Voltar';

  @override
  String get confirm => 'Confirmar';

  @override
  String error(String error) {
    return 'Erro: $error';
  }

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
  String get markAsUnread => 'Marcar não lido';

  @override
  String get invite => 'Convidar';

  @override
  String get enterKeywordsToSearchTopics =>
      'Digite palavras-chave para buscar tópicos...';

  @override
  String get refresh => 'Atualizar';

  @override
  String get share => 'Compartilhar';

  @override
  String get viewOnWeb => 'Ver na Web';

  @override
  String get reply => 'Responder';

  @override
  String get vote => 'Votar';

  @override
  String votesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votos',
      one: '$count voto',
    );
    return '$_temp0';
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
  String get appearance => 'Aparência';

  @override
  String get appearanceSystem => 'Sistema';

  @override
  String version(String version, String buildNumber) {
    return 'versão $version ($buildNumber)';
  }

  @override
  String get unableToLoadProfile => 'Não foi possível carregar o perfil';

  @override
  String get banned => 'BANIDO';

  @override
  String get deleteTopic => 'Excluir tópico';

  @override
  String get home => 'Início';

  @override
  String get notifications => 'Notificações';

  @override
  String get notificationsTab => 'Avisos';

  @override
  String get forums => 'Categorias';

  @override
  String get content => 'Conteúdo';

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
  String get writeYourMessage => 'Escreva sua mensagem...';

  @override
  String get writeYourReply => 'Escreva sua resposta...';

  @override
  String get conversationMarkedAsUnread => 'Mensagem marcada como não lida';

  @override
  String get conversationClosed => 'Mensagem fechada';

  @override
  String get conversationOpened => 'Mensagem aberta';

  @override
  String failedToLoadQuote(String error) {
    return 'Falha ao carregar citação: \n$error';
  }

  @override
  String failedToMarkConversationAsUnread(String error) {
    return 'Não foi possível marcar a mensagem como não lida: $error';
  }

  @override
  String failedToCloseConversation(String error) {
    return 'Não foi possível fechar a mensagem: $error';
  }

  @override
  String failedToOpenConversation(String error) {
    return 'Não foi possível abrir a mensagem: $error';
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
  String get enterConversationTitle => 'Digite o título da mensagem';

  @override
  String enterCode(int count) {
    return 'Insira código de $count dígitos';
  }

  @override
  String get edit => 'Editar';

  @override
  String get remove => 'Remover';

  @override
  String get subject => 'Assunto';

  @override
  String get message => 'Mensagem';

  @override
  String get titleCannotBeEmpty => 'O título não pode estar vazio';

  @override
  String get conversationUpdatedSuccessfully => 'Mensagem atualizada';

  @override
  String get goBack => 'Voltar';

  @override
  String get like => 'curtir';

  @override
  String get download => 'Transferir';

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
  String get chat => 'Chat';

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
  String get checkConnectionAndRetry =>
      'Verifique sua conexão com a internet e tente novamente.';

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
  String get send => 'Enviar';

  @override
  String get changeEmailExplanation =>
      'Enviaremos um link de confirmação para o novo e-mail. A alteração entra em vigor quando você clicar nele.';

  @override
  String get changeEmailSecurityNote =>
      'Por segurança, o Discourse pode exigir confirmação pelo link no e-mail. Verifique a pasta de spam se não o encontrar.';

  @override
  String get noMessagesYetSayHi => 'Nenhuma mensagem ainda — diga oi.';

  @override
  String get edited => 'editado';

  @override
  String get approvedButRelayUnreachable =>
      'Aprovado, mas não foi possível contactar o servidor de notificações para concluir a configuração. Tente novamente mais tarde em Configurações.';

  @override
  String get notificationsAreTurnedOffForThisApp =>
      'As notificações estão desativadas para este app';

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
  String get solution => 'Solução';

  @override
  String get deleted => 'EXCLUÍDO';

  @override
  String get pleaseLoginToViewUserProfiles =>
      'Faça login para ver perfis de usuário.';

  @override
  String get solved => 'Resolvido';

  @override
  String get hot => 'Em alta';

  @override
  String get pinned => 'Fixado';

  @override
  String get locked => 'Bloqueado';

  @override
  String get poll => 'Enquete';

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
  String get editConversation => 'Editar título';

  @override
  String get closeConversation => 'Fechar mensagem';

  @override
  String get openConversation => 'Abrir mensagem';

  @override
  String get leaveConversation2 => 'Sair da mensagem';

  @override
  String get closeConversation2 => 'Fechar mensagem';

  @override
  String get closeConversationConfirmation =>
      'Fechar esta mensagem? Ela não aceitará mais respostas novas.';

  @override
  String get close => 'Fechar';

  @override
  String get openConversation2 => 'Abrir mensagem';

  @override
  String get openConversationConfirmation =>
      'Abrir esta mensagem? Ela voltará a aceitar respostas novas.';

  @override
  String get open => 'Abrir';

  @override
  String get leaveConversation3 => 'Sair da mensagem';

  @override
  String get leaveConversationConfirmation =>
      'Tem certeza de que deseja remover seu nome desta mensagem? Você não poderá mais vê-la nem respondê-la.';

  @override
  String get editConversation2 => 'Editar título';

  @override
  String get failedToLoadMessage2 => 'Não foi possível carregar a mensagem';

  @override
  String get cannotEditThisConversation => 'Você não pode editar esta mensagem';

  @override
  String get options => 'Opções';

  @override
  String get conversationOpen => 'Aberta para respostas';

  @override
  String get messageTitleHint =>
      'Em algumas palavras, sobre o que é esta discussão?';

  @override
  String get messageOpenForReplies => 'Aceitando respostas novas';

  @override
  String get messageClosedForReplies => 'Fechada: sem respostas novas';

  @override
  String get messageSentWithoutId =>
      'A mensagem foi enviada, mas o fórum não a retornou. Confira suas mensagens.';

  @override
  String get messageCouldNotBeSent => 'Não foi possível enviar a mensagem.';

  @override
  String get messageIdMissing =>
      'Não é possível abrir esta mensagem: o ID está ausente.';

  @override
  String get pleaseAddARecipient => 'Adicione pelo menos um destinatário';

  @override
  String get archiveMessage => 'Arquivar';

  @override
  String get moveToInbox => 'Mover para caixa de entrada';

  @override
  String get messageInbox => 'Caixa de entrada';

  @override
  String get messageArchive => 'Arquivo';

  @override
  String get messageListUnread => 'Não Lido';

  @override
  String get messageListNew => 'Novo';

  @override
  String get messageListSent => 'Enviado';

  @override
  String removeFromMessageConfirm(String name) {
    return 'Deseja mesmo remover $name desta mensagem?';
  }

  @override
  String uploadingFilename(String filename) {
    return 'A enviar: $filename';
  }

  @override
  String get messageArchived => 'Mensagem arquivada';

  @override
  String get messageMovedToInbox => 'Movida para a caixa de entrada';

  @override
  String failedToArchiveMessage(Object error) {
    return 'Não foi possível arquivar a mensagem: $error';
  }

  @override
  String failedToMoveMessageToInbox(Object error) {
    return 'Não foi possível mover a mensagem para a caixa de entrada: $error';
  }

  @override
  String get noArchivedMessages => 'Você não tem mensagens arquivadas';

  @override
  String get noArchivedMessagesHint =>
      'Arquive uma mensagem pelo menu ⋮ para guardá-la aqui.';

  @override
  String groupHasBeenInvited(String group) {
    return '$group foi convidado para a mensagem';
  }

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
  String get chatChannels => 'Canais';

  @override
  String get chatDms => 'MDs';

  @override
  String get chatNoChannels => 'Você ainda não entrou em nenhum canal!';

  @override
  String get chatNoDms =>
      'Você ainda não entrou em nenhum canal de mensagem direta!';

  @override
  String get chatNoDmsCta => 'Iniciar uma conversa';

  @override
  String chatPlaceholderChannel(String channel) {
    return 'Converse em $channel';
  }

  @override
  String chatPlaceholderUsers(String names) {
    return 'Conversar com $names';
  }

  @override
  String get chatPlaceholderSelf => 'Anotar algo';

  @override
  String get chatPlaceholderArchived =>
      'Canal arquivado, não é possível enviar novas mensagens no momento.';

  @override
  String get chatPlaceholderClosed =>
      'Canal fechado, não é possível enviar novas mensagens no momento.';

  @override
  String get chatPlaceholderReadOnly =>
      'Canal somente para leitura, não é possível enviar novas mensagens no momento.';

  @override
  String get chatPlaceholderSilenced =>
      'Você não pode enviar mensagens neste momento.';

  @override
  String get chatDeleteConfirm =>
      'Tem certeza de que deseja excluir esta mensagem?';

  @override
  String get chatStartNewDm => 'Iniciar nova DM';

  @override
  String get chatCreatePersonal => 'Criar um chat pessoal';

  @override
  String get chatCreateGroup => 'Criar chat em grupo';

  @override
  String get chatCannotCreate =>
      'Desculpe, você não pode enviar mensagens diretas.';

  @override
  String get chatDisabledUser => 'desativou o chat';

  @override
  String get chatSearchPlaceholder => '@alguém';

  @override
  String get chatAddMorePlaceholder => '... incluir mais membros';

  @override
  String chatUserNotFound(String name) {
    return '@$name não encontrado';
  }

  @override
  String get chatCouldNotStartDm => 'Não foi possível iniciar o chat.';

  @override
  String get chatSignInTitle => 'Entre para usar o chat';

  @override
  String get chatSignInMessage =>
      'Você precisa entrar para ver e participar de canais de chat.';

  @override
  String get chatDirectMessage => 'Mensagem direta';

  @override
  String get chatNotAvailable => 'O chat não está disponível neste fórum.';

  @override
  String get chatAttachFile => 'Anexar arquivo';

  @override
  String get chatRemoveUpload => 'Remover arquivo';

  @override
  String get takePhoto => 'Tirar foto';

  @override
  String get postNeedsApprovalTitle => 'A postagem precisa de aprovação';

  @override
  String get postNeedsApprovalBody =>
      'Nós recebemos sua nova postagem, mas é necessário ter aprovação da moderação antes de ser exibida. Pedimos paciência.';

  @override
  String maximumAttachmentsAllowed(Object count) {
    return 'Máximo de $count anexo(s) permitido(s)';
  }

  @override
  String get noImagesFoundToDisplay => 'Nenhuma imagem encontrada para exibir.';

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
      'Exclua sua conta e suas postagens, se o fórum permitir. Caso contrário, a equipe pode removê-la para você.';

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
  String get errorLoadingNotifications => 'Erro ao carregar notificações';

  @override
  String get noNewNotificationsExplanation =>
      'Neste painel, você receberá notificações sobre atividades relevantes, inclusive respostas aos seus tópicos e postagens, quando você for citado(a) ou mencionado(a) (@mentions) por alguém e quando os tópicos que você estiver acompanhando receberem respostas. As notificações também serão enviadas por e-mail quando você passar algum tempo sem entrar com a conta.';

  @override
  String noTagsMatch(Object filter) {
    return 'Nenhuma tag corresponde a \"$filter\".';
  }

  @override
  String noTopicsTagged(Object tag) {
    return 'Nenhum tópico com a tag \"$tag\"';
  }

  @override
  String get searchUser => 'Pesquisar usuário';

  @override
  String get tapToOpen => 'Toque para abrir';

  @override
  String get imageNotAvailable => 'Imagem indisponível';

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
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return 'Apenas mais $remainingSlots anexo(s) permitido(s). Processando as primeiras $remainingSlots2 imagens.';
  }

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
  String get failedToUpdatePostPleaseTryAgain =>
      'Falha ao atualizar a postagem. Tente novamente.';

  @override
  String get postDeletedSuccessfully => 'Postagem excluída';

  @override
  String failedToDeletePost(Object error) {
    return 'Falha ao excluir a postagem: $error';
  }

  @override
  String get editHistoryNotAvailable =>
      'O histórico de edições não está disponível para esta postagem';

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
  String get suggestedTopics => 'Tópicos sugeridos';

  @override
  String get suggestedMessages => 'Mensagens Sugeridas';

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
  String get tags => 'Tags';

  @override
  String get community => 'Comunidade';

  @override
  String get users => 'Usuários';

  @override
  String get groups => 'Grupos';

  @override
  String get invites => 'Convites';

  @override
  String get account => 'Conta';

  @override
  String get drafts => 'Rascunhos';

  @override
  String get termsOfService => 'Termos de serviço';

  @override
  String get privacyPolicy => 'Política de privacidade';

  @override
  String get notSignedIn => 'Não conectado';

  @override
  String get deviceWillNotShowAlertsUntilAllowedInSettings =>
      'O seu dispositivo não mostrará alertas até que permita as notificações em Configurações.';

  @override
  String get openSettings => 'Abrir configurações';

  @override
  String get notificationsThisDeviceSection => 'Neste dispositivo';

  @override
  String notificationsThisDeviceCaption(Object forumName) {
    return 'Push de $forumName apenas para este dispositivo. Seus outros dispositivos e a web não são afetados.';
  }

  @override
  String notificationsAccountSection(Object forumName) {
    return 'Sua conta em $forumName';
  }

  @override
  String get notificationsAccountCaption =>
      'Valem em todos os lugares: na web, por e-mail e em todos os seus dispositivos.';

  @override
  String pushOnThisDeviceSubtitle(Object forumName) {
    return 'Ativadas: as novas notificações de $forumName chegam a este dispositivo.';
  }

  @override
  String pushOffThisDeviceSubtitle(Object forumName) {
    return 'Desativadas neste dispositivo. Para ativar, você aprova uma vez em $forumName.';
  }

  @override
  String get stopPushOnThisDevice => 'Parar push neste dispositivo';

  @override
  String stopPushTitle(Object forumName) {
    return 'Parar o push de $forumName neste dispositivo?';
  }

  @override
  String get stopPushOnlyThisDevice =>
      'Só este dispositivo para. Seus outros dispositivos continuam recebendo.';

  @override
  String get stopPushNothingElseChanges =>
      'Suas notificações continuam aparecendo no app e na web, e os e-mails do fórum não mudam.';

  @override
  String stopPushPermissionDeleted(Object forumName) {
    return 'A permissão que você deu em $forumName é excluída. Para reativar o push, você precisará aprovar lá novamente.';
  }

  @override
  String get stopPushQuietHint =>
      'Quer só um pouco de silêncio? Desative acima os tipos de que não precisa ou use Não perturbe no seu perfil.';

  @override
  String get stopPush => 'Parar push';

  @override
  String get turnOn => 'Ativar';

  @override
  String get couldNotTurnOffNotifications =>
      'Não foi possível parar o push. Tente novamente mais tarde.';

  @override
  String actionCodeTopicCreated(String when) {
    return 'Criou este tópico $when';
  }

  @override
  String actionCodePublicTopic(String when) {
    return 'Tornou este tópico público $when';
  }

  @override
  String actionCodeOpenTopic(String when) {
    return 'Converteu isto em um tópico $when';
  }

  @override
  String actionCodePrivateTopic(String when) {
    return 'Tornou este tópico em uma mensagem pessoal $when';
  }

  @override
  String actionCodeSplitTopic(String when) {
    return 'Dividiu este tópico $when';
  }

  @override
  String actionCodeInvitedUser(String who, String when) {
    return 'Convidou $who $when';
  }

  @override
  String actionCodeInvitedGroup(String who, String when) {
    return 'Convidou $who $when';
  }

  @override
  String actionCodeUserLeft(String who, String when) {
    return '$who se removeram desta mensagem $when';
  }

  @override
  String actionCodeRemovedUser(String who, String when) {
    return 'Removeu $who $when';
  }

  @override
  String actionCodeRemovedGroup(String who, String when) {
    return 'Removeu $who $when';
  }

  @override
  String actionCodeAutobumped(String when) {
    return 'Automaticamente promovido $when';
  }

  @override
  String actionCodeTagsChanged(String when) {
    return 'Etiquetas atualizadas em $when';
  }

  @override
  String actionCodeCategoryChanged(String when) {
    return 'Categoria atualizada em $when';
  }

  @override
  String get actionCodeForwarded => 'Encaminhou o e-mail acima';

  @override
  String actionCodeAutoclosedEnabled(String when) {
    return 'Fechado $when';
  }

  @override
  String actionCodeAutoclosedDisabled(String when) {
    return 'Aberto $when';
  }

  @override
  String actionCodeClosedEnabled(String when) {
    return 'Fechado $when';
  }

  @override
  String actionCodeClosedDisabled(String when) {
    return 'Aberto $when';
  }

  @override
  String actionCodeArchivedEnabled(String when) {
    return 'Arquivado $when';
  }

  @override
  String actionCodeArchivedDisabled(String when) {
    return 'Desarquivado $when';
  }

  @override
  String actionCodePinnedEnabled(String when) {
    return 'Fixado $when';
  }

  @override
  String actionCodePinnedDisabled(String when) {
    return 'Desafixado $when';
  }

  @override
  String actionCodePinnedGloballyEnabled(String when) {
    return 'Fixado globalmente $when';
  }

  @override
  String actionCodePinnedGloballyDisabled(String when) {
    return 'Desafixado $when';
  }

  @override
  String actionCodeVisibleEnabled(String when) {
    return 'Listado $when';
  }

  @override
  String actionCodeVisibleDisabled(String when) {
    return 'Removeu da lista $when atrás';
  }

  @override
  String actionCodeBannerEnabled(String when) {
    return 'Transformado em banner $when. Ele será mostrado no topo de cada página até que seja descartado pelo(a) usuário(a).';
  }

  @override
  String actionCodeBannerDisabled(String when) {
    return 'Removido este banner $when. Ele não irá mais aparecer no topo de cada página.';
  }

  @override
  String actionCodeAssigned(String who, String when) {
    return 'Atribuiu a $who $when';
  }

  @override
  String actionCodeUnassigned(String who, String when) {
    return 'Cancelou atribuição de $who $when';
  }

  @override
  String actionCodeReassigned(String who, String when) {
    return 'reatribuiu $who $when';
  }

  @override
  String localDateToday(String time) {
    return 'Hoje $time';
  }

  @override
  String localDateTomorrow(String time) {
    return 'Amanhã $time';
  }

  @override
  String localDateYesterday(String time) {
    return 'Ontem $time';
  }

  @override
  String get eventExpired => 'Expirou';

  @override
  String get eventEveryDay => 'Todos os dias';

  @override
  String get eventEveryWeekday => 'Todos os dias da semana';

  @override
  String get eventEveryWeek => 'Toda semana, neste dia da semana';

  @override
  String get eventEveryTwoWeeks => 'A cada duas semanas, neste dia da semana';

  @override
  String get eventEveryFourWeeks =>
      'A cada quatro semanas, neste dia da semana';

  @override
  String get eventEveryMonth => 'Todo mês, neste dia da semana';

  @override
  String get errorNoConnection =>
      'Não foi possível acessar o fórum. Verifique a conexão e tente novamente.';

  @override
  String get errorTimedOut =>
      'O fórum demorou demais para responder. Tente novamente.';

  @override
  String get errorPaywalled =>
      'Isto é exclusivo para membros pagantes do fórum.';

  @override
  String get errorBlocked =>
      'O firewall do fórum bloqueou o aplicativo. Tente mais tarde ou abra o fórum em um navegador.';

  @override
  String get errorNotAllowed =>
      'Sem acesso a este conteúdo. Entrar na conta pode ajudar.';

  @override
  String get errorNotFound => 'Isto não existe ou foi removido.';

  @override
  String get errorRateLimited =>
      'Essa ação está sendo feita com muita frequência. Aguarde um momento e tente novamente.';

  @override
  String get errorForumDown =>
      'O fórum não está respondendo no momento. Tente novamente mais tarde.';

  @override
  String get deleteSpammer => 'Excluir remetente de spam';

  @override
  String get yesDeleteSpammer => 'Sim, excluir remetente de spam';

  @override
  String get deleteSpammerConfirm =>
      'Você está prestes a excluir as postagens e tópicos deste(a) usuário(a), remover sua conta, bloquear cadastros a partir do seu endereço IP e adicionar seu endereço de e-mail a uma lista de bloqueio permanente. Você tem certeza que este(a) usuário(a) é realmente remetente de spam?';

  @override
  String get userWasDeleted => 'O(a) usuário(a) foi excluído(a).';

  @override
  String get deleteMyAccount => 'Excluir minha conta';

  @override
  String get deleteAccountConfirm =>
      'Você tem certeza de que deseja excluir a sua conta permanentemente? Essa ação não pode ser desfeita!';

  @override
  String get deletedYourself => 'Sua conta foi excluída com êxito.';

  @override
  String get deleteYourselfNotAllowed =>
      'Entre em contato com um membro da equipe se você deseja que a sua conta seja excluída.';

  @override
  String get createTopic => 'Criar Tópico';

  @override
  String get discardPostQuestion => 'Você deseja excluir sua postagem?';

  @override
  String get discardChangesQuestion => 'Você deseja descartar suas alterações?';

  @override
  String get discardChanges => 'Descartar alterações';

  @override
  String get saveDraft => 'Salvar rascunho';

  @override
  String get notificationSettings => 'Configurações de notificação';

  @override
  String get topicIsNew => 'Tópico novo';

  @override
  String get noNewTopicsSinceLastVisit =>
      'Nenhum tópico novo desde sua última visita.';

  @override
  String get messageIsNew => 'Mensagem nova';

  @override
  String topicUnreadReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count respostas não lidas',
      one: '1 resposta não lida',
    );
    return '$_temp0';
  }

  @override
  String filterNewWithCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Novos ($count)',
      one: 'Novo ($count)',
    );
    return '$_temp0';
  }

  @override
  String filterUnreadWithCount(int count) {
    return 'Não lidos ($count)';
  }

  @override
  String categoryNewTopics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count novos',
      one: '$count novo',
    );
    return '$_temp0';
  }

  @override
  String categoryUnreadTopics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count não lidos',
      one: '$count não lido',
    );
    return '$_temp0';
  }

  @override
  String get dismissNew => 'Descartar novos';

  @override
  String get dismissUnread => 'Descartar não lidos';

  @override
  String get dismissNewTitle => 'Descartar os tópicos novos?';

  @override
  String get dismissNewMessage => 'Eles não aparecerão mais como novos.';

  @override
  String get dismissUnreadTitle => 'Descartar todos os não lidos?';

  @override
  String get dismissUnreadMessage =>
      'As respostas novas serão marcadas como lidas.';

  @override
  String get dismissUnreadStopTracking =>
      'Parar de monitorar estes tópicos para que eles deixem de aparecer como não lidos para mim';

  @override
  String get dismissNewAndUnread => 'Descartar novos e não lidos';

  @override
  String dismissNewAndUnreadMessage(String category) {
    return 'Os tópicos em $category não aparecerão mais como novos ou não lidos.';
  }

  @override
  String get dismissedTopics => 'Descartados';

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
  String get markAsSolution => 'Marcar como solução';

  @override
  String get unmarkAsSolution => 'Desmarcar como solução';

  @override
  String searchForumName(String forum) {
    return 'Pesquisar em $forum';
  }

  @override
  String countActiveThisMonth(String formatted) {
    return '$formatted ativos este mês';
  }

  @override
  String countMembers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted membros',
      one: '$formatted membro',
    );
    return '$_temp0';
  }

  @override
  String countTopics(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted tópicos',
      one: '$formatted tópico',
    );
    return '$_temp0';
  }

  @override
  String categoryNewThisWeek(int count) {
    return '$count novos esta semana';
  }

  @override
  String get categoriesView => 'Categorias';

  @override
  String get allCategories => 'Todas as categorias';

  @override
  String get allTags => 'Todas as etiquetas';

  @override
  String get myPosts => 'Minhas publicações';

  @override
  String get drawerIntroduction =>
      'As categorias, as tags e a sua conta neste fórum estão todas neste menu. Abra-o de novo quando quiser com o botão de menu.';

  @override
  String trustLevelN(int level) {
    return 'Nível de confiança $level';
  }

  @override
  String get filterNew => 'Novos';

  @override
  String get filterTop => 'Top';

  @override
  String get levelWatching => 'Acompanhando';

  @override
  String get levelWatchingFirstPost => 'Acompanhar primeira publicação';

  @override
  String get levelTracking => 'Monitorando';

  @override
  String get levelNormal => 'Normal';

  @override
  String get levelMuted => 'Silenciado';

  @override
  String get chooseCategory => 'Escolha uma categoria';

  @override
  String get signInToPostAndGetNotifications =>
      'Entre para publicar e receber notificações';

  @override
  String forumBlocksNotificationServer(Object forumName) {
    return '$forumName bloqueia nosso servidor de notificações, então elas podem não chegar. Você pode desativá-las em Configurações.';
  }

  @override
  String get relatedTopics => 'Tópicos relacionados';

  @override
  String get relatedMessages => 'Mensagens relacionadas';

  @override
  String moreInCategory(String category) {
    return 'Mais em $category';
  }

  @override
  String get latestTopics => 'Tópicos recentes';

  @override
  String get pushGroupMessages => 'Mensagens e chat';

  @override
  String get pushGroupMessagesHint =>
      'Mensagens pessoais, caixas de grupo e chat';

  @override
  String get pushGroupReplies => 'Respostas e menções';

  @override
  String get pushGroupRepliesHint =>
      'Respostas, menções, citações e tópicos que você acompanha';

  @override
  String get pushGroupReactions => 'Curtidas e reações';

  @override
  String get pushGroupReactionsHint => 'Curtidas e reações às suas publicações';

  @override
  String get pushGroupOther => 'Todo o resto';

  @override
  String get pushGroupOtherHint =>
      'Emblemas, lembretes, respostas aceitas e mais';

  @override
  String get pushChannelOther => 'Outras notificações';

  @override
  String get couldNotChangePushSetting =>
      'Não foi possível alterar esta configuração. Tente novamente mais tarde.';

  @override
  String neverMissAReplyOn(Object forumName) {
    return 'Não perca nenhuma resposta em $forumName';
  }

  @override
  String get notificationsPitch =>
      'Respostas, menções, mensagens e chat na tela de bloqueio, geralmente em até 10 minutos. Você escolhe quais, quando quiser, em Configurações.';

  @override
  String get notificationsStepAllow => 'Permitir notificações neste telefone';

  @override
  String get notificationsStepAllowed =>
      'As notificações estão permitidas neste telefone';

  @override
  String notificationsStepApprove(Object forumName) {
    return 'Aprovar em $forumName';
  }

  @override
  String get notificationsReadOnlyNote =>
      'Somente leitura: não pode publicar, responder nem ler suas mensagens';

  @override
  String get notificationPreviewReply =>
      'Jane respondeu você: Bem-vindo! Que bom que você nos encontrou.';

  @override
  String get notificationPreviewMessage =>
      'Sam enviou uma mensagem: Você vem na sexta?';

  @override
  String get notificationPreviewNow => 'agora';

  @override
  String get notificationPreviewEarlier => 'há 5 min';

  @override
  String get activityReplied => 'Respondeu';

  @override
  String get activityStartedTopic => 'Iniciou um tópico';

  @override
  String get activityLiked => 'Curtiu';

  @override
  String get activitySolution => 'Solução';

  @override
  String get activityAcceptedBy => 'aceita por';

  @override
  String get activityAwaitingApproval => 'Aguardando aprovação';

  @override
  String get activityFilterTopics => 'Tópicos';

  @override
  String get activityFilterReplies => 'Respostas';

  @override
  String get activityFilterLikes => 'Curtidas';

  @override
  String get activityFilterPending => 'Pendentes';

  @override
  String get sectionToday => 'Hoje';

  @override
  String get sectionThisWeek => 'Esta semana';

  @override
  String get sectionEarlier => 'Antes';

  @override
  String draftsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rascunhos aguardando',
      one: '1 rascunho aguardando',
    );
    return '$_temp0';
  }

  @override
  String get resumeDrafts => 'Retomar';

  @override
  String get myPostsEmpty => 'Nenhuma publicação ainda';

  @override
  String get myPostsEmptyHint =>
      'Os tópicos que você iniciar e as respostas que escrever aparecerão aqui.';

  @override
  String get activityEmptyTopics => 'Nenhum tópico ainda';

  @override
  String get activityEmptyReplies => 'Nenhuma resposta ainda';

  @override
  String get activityEmptyLikes => 'Nenhuma curtida dada ainda';

  @override
  String get activityEmptySolved => 'Nenhuma solução ainda';

  @override
  String get viewProfile => 'Ver perfil';

  @override
  String get yourStuff => 'Suas coisas';

  @override
  String get accountAndPrivacy => 'Conta e privacidade';

  @override
  String profileStatPosts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'publicações',
      one: 'publicação',
    );
    return '$_temp0';
  }

  @override
  String profileStatLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'curtidas',
      one: 'curtida',
    );
    return '$_temp0';
  }

  @override
  String profileStatDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dias',
      one: 'dia',
    );
    return '$_temp0';
  }

  @override
  String get profileStatSolved => 'resolvidos';

  @override
  String joinForum(String forum) {
    return 'Entre em $forum';
  }

  @override
  String get guestBenefitPost => 'Responda e crie tópicos';

  @override
  String get guestBenefitNotify => 'Receba avisos quando responderem';

  @override
  String get guestBenefitSave => 'Salve publicações e rascunhos';

  @override
  String get guestBenefitChat => 'Converse e envie mensagens';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get aboutThisForum => 'Sobre este fórum';

  @override
  String get drawerMore => 'Mais';

  @override
  String get goToYourProfile => 'Ir para seu perfil';

  @override
  String profileJoined(String date) {
    return 'Entrou em $date';
  }

  @override
  String profileSeen(String when) {
    return 'Visto $when';
  }

  @override
  String profileLocalTime(String time) {
    return '$time horário local';
  }

  @override
  String get profileTabSummary => 'Resumo';

  @override
  String get summaryTopReplies => 'Melhores respostas';

  @override
  String get summaryTopTopics => 'Melhores tópicos';

  @override
  String get summaryMostLikedBy => 'Mais curtido por';

  @override
  String get summaryMostLiked => 'Mais curtiu';

  @override
  String get summaryMostRepliedTo => 'Mais respondeu a';

  @override
  String get summaryTopLinks => 'Links principais';

  @override
  String get summaryTopCategories => 'Categorias principais';

  @override
  String get featuredTopic => 'Tópico em destaque';

  @override
  String get profileDetails => 'Detalhes';

  @override
  String get followUser => 'Seguir';

  @override
  String get unfollowUser => 'Deixar de seguir';

  @override
  String get profileSuspended => 'Suspenso';

  @override
  String get searchBookmarks => 'Pesquisar nos favoritos';

  @override
  String get bookmarksFilterReminders => 'Lembretes';

  @override
  String get bookmarkWholeTopic => 'Tópico inteiro';

  @override
  String bookmarkSaved(String when) {
    return 'salvo $when';
  }

  @override
  String bookmarkPostNumber(int number) {
    return 'publicação #$number';
  }

  @override
  String reminderToday(String time) {
    return 'Hoje, $time';
  }

  @override
  String reminderTomorrow(String time) {
    return 'Amanhã, $time';
  }

  @override
  String reminderDue(String when) {
    return 'Vencido · $when';
  }

  @override
  String get addBookmarkLabel => 'Adicionar rótulo';

  @override
  String get editBookmarkLabel => 'Editar rótulo';

  @override
  String get bookmarkLabelHint => 'Para que serve?';

  @override
  String get pinBookmark => 'Fixar no topo';

  @override
  String get unpinBookmark => 'Desafixar';

  @override
  String get bookmarkRemoved => 'Favorito removido';

  @override
  String get undo => 'Desfazer';

  @override
  String get bookmarksNoMatch => 'Nenhum favorito corresponde';

  @override
  String get addReminder => 'Adicionar lembrete';

  @override
  String get bookmarksEmpty => 'Nenhum favorito ainda';

  @override
  String get bookmarksEmptyHint =>
      'Favorite uma publicação pelas ações dela e ela estará esperando aqui.';

  @override
  String get draftKindNewTopic => 'Novo tópico';

  @override
  String draftMessageTo(String names) {
    return 'Mensagem para $names';
  }

  @override
  String get untitledTopic => 'Tópico sem título';

  @override
  String get draftDiscarded => 'Rascunho descartado';

  @override
  String get draftsEmpty => 'Nenhum rascunho ainda';

  @override
  String get draftsEmptyHint =>
      'Rascunhos são salvos enquanto você digita. Comece uma resposta ou um tópico e ele estará esperando aqui.';

  @override
  String get privacySection => 'Privacidade';

  @override
  String get changeEmailSubtitle =>
      'Enviaremos um link de verificação para o novo endereço';

  @override
  String get aboutMe => 'Sobre mim';

  @override
  String get aboutMeHelper => 'Aparece no topo do seu perfil';

  @override
  String get aboutMeMarkdownHint =>
      'Aceita Markdown: **negrito**, links, :emoji:';

  @override
  String get addCover => 'Adicionar capa';

  @override
  String get changeCover => 'Alterar capa';

  @override
  String get birthdayHint => 'O fórum comemora com você. O ano não é guardado.';

  @override
  String get birthdayRemoved => 'Aniversário removido';

  @override
  String get birthdaySaved => 'Aniversário salvo';

  @override
  String get cardBackground => 'Fundo do cartão';

  @override
  String get cardBackgroundExplanation =>
      'Atrás do seu cartão de usuário quando alguém toca na sua foto';

  @override
  String get cardBackgroundRemoved => 'Fundo do cartão removido';

  @override
  String get cardBackgroundSheetHint =>
      'Aparece atrás do seu cartão de usuário. Fotos largas ficam melhores.';

  @override
  String get changeProfilePicture => 'Alterar foto do perfil';

  @override
  String get changeUsername => 'Alterar nome de usuário';

  @override
  String changeUsernameExplanation(String username) {
    return 'Menções e citações de @$username nas publicações passam para o novo nome. Links antigos para o seu perfil deixam de funcionar.';
  }

  @override
  String get chooseFromLibrary => 'Escolher da galeria';

  @override
  String get coverPhoto => 'Foto de capa';

  @override
  String get coverPhotoSheetHint =>
      'Aparece no topo do seu perfil, atrás da sua foto. Fotos largas ficam melhores, cerca de 3 por 1.';

  @override
  String get coverRemoved => 'Capa removida';

  @override
  String get day => 'Dia';

  @override
  String get month => 'Mês';

  @override
  String get displayName => 'Nome de exibição';

  @override
  String displayNameHelper(String username) {
    return 'Aparece com suas publicações. Seu nome de usuário continua @$username.';
  }

  @override
  String get emailPasswordInAccount => 'E-mail, senha e login';

  @override
  String get featureATopic => 'Destacar um tópico';

  @override
  String get featureATopicHint =>
      'Fixe um dos seus tópicos no topo do seu perfil.';

  @override
  String get featuredTopicChanged => 'Tópico em destaque alterado';

  @override
  String get featuredTopicNone =>
      'Nenhum. Fixe um dos seus tópicos no seu perfil.';

  @override
  String get featuredTopicRemoved => 'Tópico em destaque removido';

  @override
  String get featuredTopicRules =>
      'Mensagens e tópicos em categorias privadas não podem ser destacados.';

  @override
  String get fieldManagedBySignIn =>
      'Este fórum gerencia isso pelo próprio login. Altere lá.';

  @override
  String get flair => 'Distintivo';

  @override
  String flairChangedTo(String group) {
    return 'Distintivo alterado para $group';
  }

  @override
  String get flairRemoved => 'Distintivo removido';

  @override
  String get flairSheetHint =>
      'Um pequeno distintivo na sua foto, de um grupo do qual você faz parte.';

  @override
  String forumPictureN(int number) {
    return 'Imagem do fórum $number';
  }

  @override
  String forumQuestionNeedsAnswer(String question) {
    return '$question precisa de uma resposta';
  }

  @override
  String get forumQuestionRequired => 'Este fórum pede que todos respondam';

  @override
  String get forumQuestionSetByStaff => 'Definido pela equipe do fórum';

  @override
  String get forumQuestionsIntro =>
      'Perguntas deste fórum. * indica obrigatório.';

  @override
  String get forumQuestionsNoneAnswered => 'Ainda não respondido';

  @override
  String get fromThisForum => 'Deste fórum';

  @override
  String get hideMyProfile => 'Ocultar meu perfil público';

  @override
  String get hideMyProfileExplanation =>
      'Os outros veem apenas seu nome, sua foto e suas publicações';

  @override
  String get letterAvatar => 'Inicial';

  @override
  String get moreAboutYou => 'Mais sobre você';

  @override
  String namesAndMore(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mais $count',
      one: 'mais 1',
    );
    return '$names e $_temp0';
  }

  @override
  String get newUsername => 'Novo nome de usuário';

  @override
  String get noFlair => 'Sem distintivo';

  @override
  String noGravatarFound(String service) {
    return '$service não tem imagem para o seu e-mail';
  }

  @override
  String get noTitle => 'Sem título';

  @override
  String get noTopicsMatch => 'Nenhum dos seus tópicos corresponde';

  @override
  String get noTopicsToFeature => 'Você ainda não criou nenhum tópico';

  @override
  String get notSet => 'Não definido';

  @override
  String get orUse => 'Ou use';

  @override
  String get pictureManagedBySignIn =>
      'Este fórum define sua foto pelo próprio login';

  @override
  String get primaryGroup => 'Grupo principal';

  @override
  String primaryGroupChangedTo(String group) {
    return 'Grupo principal alterado para $group';
  }

  @override
  String get primaryGroupRemoved => 'Grupo principal removido';

  @override
  String get primaryGroupSheetHint =>
      'Seu grupo principal, exibido no seu cartão de usuário.';

  @override
  String get profileLoadFailed => 'Não foi possível carregar seu perfil';

  @override
  String get profileNowHidden => 'Seu perfil está oculto';

  @override
  String get profileNowPublic => 'Seu perfil está público';

  @override
  String get profilePicture => 'Foto do perfil';

  @override
  String get profilePictureChanged => 'Foto do perfil alterada';

  @override
  String get profileSaveFailed => 'Não foi possível salvar. Tente novamente.';

  @override
  String get profileSectionNameAndAbout => 'Nome e sobre';

  @override
  String get profileSectionNextToName => 'Ao lado do seu nome';

  @override
  String get profileSectionOnProfile => 'No seu perfil';

  @override
  String get profileSectionPrivacyAndTime => 'Privacidade e horário';

  @override
  String get removeCardBackground => 'Remover fundo do cartão';

  @override
  String get removeCover => 'Remover capa';

  @override
  String get removeFeaturedTopic => 'Remover tópico em destaque';

  @override
  String get searchTimezones => 'Buscar fusos horários';

  @override
  String get searchYourTopics => 'Buscar nos seus tópicos';

  @override
  String get seeProfileAsOthersDo => 'Ver seu perfil como os outros veem';

  @override
  String get timezone => 'Fuso horário';

  @override
  String timezoneChangedTo(String zone) {
    return 'Fuso horário alterado para $zone';
  }

  @override
  String timezoneWithTime(String zone, String time) {
    return '$zone · agora $time';
  }

  @override
  String timezonesMatchingPhone(String offset) {
    return 'Igual ao relógio deste telefone ($offset)';
  }

  @override
  String titleChangedTo(String title) {
    return 'Título alterado para $title';
  }

  @override
  String get titleFromBadge => 'Emblema';

  @override
  String titleFromBadgeEarned(String date) {
    return 'Emblema · conquistado em $date';
  }

  @override
  String titleFromGroup(String group) {
    return 'Grupo $group';
  }

  @override
  String get titleGrantedByStaff => 'Concedido pela equipe do fórum';

  @override
  String get titleRemoved => 'Título removido';

  @override
  String get titleSheetHint =>
      'Aparece depois do seu nome no seu perfil e nas suas publicações.';

  @override
  String get username => 'Nome de usuário';

  @override
  String get usernameAvailable => 'Disponível';

  @override
  String usernameChanged(String username) {
    return 'Seu nome de usuário agora é @$username';
  }

  @override
  String get usernameLockedExplanation =>
      'Este fórum só permite que membros alterem o nome de usuário pouco depois de entrar. Um moderador pode alterá-lo para você.';

  @override
  String get yourPhoto => 'Sua foto';

  @override
  String get chooseEmoji => 'Escolher emoji';

  @override
  String get clearStatus => 'Limpar status';

  @override
  String get clearText => 'Limpar';

  @override
  String get inOneHour => 'Em uma hora';

  @override
  String get never => 'Nunca';

  @override
  String get pauseNotifications => 'Pausar notificações';

  @override
  String get pauseNotificationsUntilStatusClears =>
      'Até seu status ser removido';

  @override
  String get pickATime => 'Escolher horário';

  @override
  String get removeStatusAfter => 'Remover status';

  @override
  String get searchEmoji => 'Buscar emoji';

  @override
  String get setStatus => 'Definir status';

  @override
  String get setAStatus => 'Definir um status';

  @override
  String get statusUpdated => 'Status atualizado';

  @override
  String get whatAreYouDoing => 'O que você está fazendo?';

  @override
  String cardPosted(String when) {
    return 'Publicou $when';
  }

  @override
  String get change => 'Alterar';

  @override
  String get copyProfileLink => 'Copiar link do perfil';

  @override
  String get ignore => 'Ignorar';

  @override
  String memberOfGroup(String group) {
    return 'Membro de $group';
  }

  @override
  String get mute => 'Silenciar';

  @override
  String get unmute => 'Deixar de silenciar';

  @override
  String openProfileOf(String username) {
    return 'Abrir o perfil de @$username';
  }

  @override
  String profileIsPrivate(String username) {
    return '$username mantém o perfil privado.';
  }

  @override
  String showOnlyTheirPostsHere(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'as $count publicações',
      one: 'a publicação',
    );
    return 'Mostrar só $_temp0 de $name neste tópico';
  }

  @override
  String showOnlyYourPostsHere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'suas $count publicações',
      one: 'sua publicação',
    );
    return 'Mostrar só $_temp0 neste tópico';
  }

  @override
  String userIgnoredFor4Months(String username) {
    return 'Você vai ignorar @$username por 4 meses';
  }

  @override
  String userMuted(String username) {
    return 'Você silenciou @$username';
  }

  @override
  String userUnmuted(String username) {
    return 'Você deixou de silenciar @$username';
  }

  @override
  String get youParenthetical => '(você)';

  @override
  String get topicStatusClosedHelp =>
      'Este tópico está fechado. Não serão aceitas respostas novas';

  @override
  String get topicStatusArchivedHelp =>
      'Este tópico foi arquivado. Está congelado e não pode ser alterado';

  @override
  String get topicStatusClosedArchivedHelp =>
      'Este tópico está fechado e foi arquivado. Não é permitido enviar respostas nem alterar.';

  @override
  String get topicStatusPinnedTitle => 'Fixado';

  @override
  String get topicStatusPinnedHelp =>
      'Este tópico está fixado para você. Será exibido no topo de sua categoria';

  @override
  String get topicStatusPinnedGloballyTitle => 'Fixado globalmente';

  @override
  String get topicStatusPinnedGloballyHelp =>
      'Este tópico está fixado globalmente. Será exibido no topo da aba dos mais recentes e da sua categoria';

  @override
  String get topicStatusUnpinnedTitle => 'Desafixado';

  @override
  String get topicStatusUnpinnedHelp =>
      'Este tópico foi desfixado para você. Será mostrado em ordem normal';

  @override
  String get topicStatusUnlistedHelp =>
      'Este tópico não está listado. Não será exibido nas listas de tópicos e só poderá ser acessado por meio de um link direto.';

  @override
  String get topicStatusWarningHelp => 'Este é um aviso oficial.';

  @override
  String get notificationReasonWatchingTag =>
      'Você receberá notificações porque está acompanhando uma etiqueta neste tópico.';

  @override
  String get notificationReasonWatchingCategory =>
      'Você receberá notificações porque você está acompanhando esta categoria.';

  @override
  String get notificationReasonWatchingAuto =>
      'Você receberá notificações porque começou a acompanhar este tópico automaticamente.';

  @override
  String get notificationReasonWatching =>
      'Você receberá notificações porque está acompanhando este tópico.';

  @override
  String get notificationReasonWatchingCreated =>
      'Você receberá notificações porque criou este tópico.';

  @override
  String get notificationReasonTrackingCategory =>
      'Você verá uma contagem de respostas novas porque está monitorando esta categoria.';

  @override
  String get notificationReasonTrackingReplied =>
      'Você verá uma contagem de respostas novas porque postou uma resposta a este tópico.';

  @override
  String get notificationReasonTracking =>
      'Você verá uma contagem de respostas novas porque está monitorando este tópico.';

  @override
  String get notificationReasonTrackingRead =>
      'Você verá uma contagem de respostas novas porque leu este tópico.';

  @override
  String get notificationReasonNormal =>
      'Você será notificado(a) se alguém mencionar seu @nome ou responder às suas mensagens.';

  @override
  String get notificationReasonMutedCategory =>
      'Você está ignorando todas as notificações nesta categoria.';

  @override
  String get notificationReasonMuted =>
      'Você está ignorando todas as notificações deste tópico.';

  @override
  String get notificationLevelWatching => 'Acompanhando';

  @override
  String get notificationLevelWatchingFirstPost =>
      'Acompanhando a primeira postagem';

  @override
  String get notificationLevelTracking => 'Monitorando';

  @override
  String get notificationLevelNormal => 'Normal';

  @override
  String get notificationLevelMuted => 'Silenciados(as)';

  @override
  String get topicWatchingDescription =>
      'Você será notificado(a) sobre cada resposta nova neste tópico. Um contador de respostas novas será exibido.';

  @override
  String get topicTrackingDescription =>
      'Um contador de respostas novas será exibido para este tópico. Você será notificado(a) se alguém mencionar seu @nome ou responder às suas mensagens.';

  @override
  String get topicNormalDescription =>
      'Você será notificado(a) se alguém mencionar seu @nome ou responder às suas mensagens.';

  @override
  String get topicMutedDescription =>
      'Você nunca receberá nenhuma notificação sobre este tópico, e ele não aparecerá nos mais recentes.';

  @override
  String get messageWatchingDescription =>
      'Você será notificado(a) sobre cada resposta nova nesta mensagem. Um contador de respostas novas será exibido.';

  @override
  String get messageTrackingDescription =>
      'Um contador de respostas novas será exibido para esta mensagem. Você será notificado(a) se alguém mencionar seu @nome ou responder às suas mensagens.';

  @override
  String get messageNormalDescription =>
      'Você será notificado(a) se alguém mencionar seu @nome ou responder às suas mensagens.';

  @override
  String get messageMutedDescription =>
      'Você nunca receberá nenhuma notificação sobre esta mensagem.';

  @override
  String get categoryWatchingDescription =>
      'Você acompanhará automaticamente todos os tópicos nesta categoria. Você será notificado(a) de todas as novas postagens em todos os tópicos. Além disso, uma contagem de novas respostas será exibida.';

  @override
  String get categoryWatchingFirstPostDescription =>
      'Você será notificado(a) sobre novos tópicos nesta categoria, mas não sobre respostas dos tópicos.';

  @override
  String get categoryTrackingDescription =>
      'Você vai monitorar automaticamente todos os tópicos nesta categoria. Você será notificado(a) se alguém mencionar o seu @nome ou responder para você. Além disso, uma contagem de novas respostas será exibida.';

  @override
  String get categoryNormalDescription =>
      'Você será notificado(a) se alguém mencionar o seu @nome ou responder às suas mensagens.';

  @override
  String get categoryMutedDescription =>
      'Você nunca será notificado(a) sobre novos tópicos nesta categoria e eles não aparecerão nos mais recentes.';

  @override
  String get tagWatchingDescription =>
      'Você acompanhará automaticamente todos os tópicos com esta etiqueta e será notificado(a) sobre todas as novas postagens e tópicos. Além disso, a contagem das postagens novas e não lidas também será exibida ao lado do tópico.';

  @override
  String get tagWatchingFirstPostDescription =>
      'Você será notificado(a) sobre novos tópicos com esta etiqueta, mas não sobre as respostas dos tópicos.';

  @override
  String get tagTrackingDescription =>
      'Você irá monitorar automaticamente todos os tópicos com esta etiqueta. Uma contagem de postagens novas e não lidas será exibida ao lado do tópico.';

  @override
  String get tagNormalDescription =>
      'Você será notificado(a) se alguém mencionar o seu @nome ou responder à sua postagem.';

  @override
  String get tagMutedDescription =>
      'Você não receberá nenhuma notificação sobre novos tópicos com esta etiqueta, e eles não serão exibidos na aba de não lidos.';

  @override
  String topicTimerAutoOpen(String timeLeft) {
    return 'Este tópico abrirá automaticamente $timeLeft.';
  }

  @override
  String topicTimerAutoClose(String timeLeft) {
    return 'Este tópico fechará automaticamente $timeLeft.';
  }

  @override
  String topicTimerAutoPublish(String categoryName, String timeLeft) {
    return 'Este tópico será publicado em #$categoryName $timeLeft.';
  }

  @override
  String topicTimerAutoCloseAfterLastPost(String duration) {
    return 'Este tópico fechará $duration após a última resposta.';
  }

  @override
  String topicTimerAutoDeleteAfterLastPost(String duration) {
    return 'Este tópico será excluído $duration após a última resposta.';
  }

  @override
  String topicTimerAutoDelete(String timeLeft) {
    return 'Este tópico será automaticamente excluído $timeLeft.';
  }

  @override
  String topicTimerAutoBump(String timeLeft) {
    return 'Este tópico será automaticamente promovido $timeLeft.';
  }

  @override
  String topicTimerAutoDeleteReplies(String duration) {
    return 'As respostas deste tópico são excluídas automaticamente após $duration.';
  }

  @override
  String slowModeNotice(String duration) {
    return 'Aguarde $duration entre suas postagens neste tópico.';
  }

  @override
  String get closeTopic => 'Fechar tópico';

  @override
  String get openTopic => 'Abrir tópico';

  @override
  String get pinTopic => 'Fixar tópico';

  @override
  String get unpinTopic => 'Desafixar tópico';

  @override
  String get archiveTopic => 'Arquivar tópico';

  @override
  String get unarchiveTopic => 'Desarquivar tópico';

  @override
  String get unlistTopic => 'Tópico removido da lista';

  @override
  String get listTopic => 'Tópico na lista';

  @override
  String get permanentlyDelete => 'Excluir permanentemente';

  @override
  String get permanentlyDeleteTopicConfirmation =>
      'Esta ação não pode ser desfeita. Este tópico será excluído permanentemente e removido do banco de dados.';

  @override
  String get deleteTopicConfirmYes => 'Sim, excluir este tópico';

  @override
  String get deleteTopicConfirmNo => 'Não, manter este tópico';

  @override
  String get topicPinned => 'Tópico fixado';

  @override
  String get topicUnpinned => 'Tópico desafixado';

  @override
  String get topicArchived => 'Tópico arquivado';

  @override
  String get topicUnarchived => 'Tópico desarquivado';

  @override
  String get topicUnlisted => 'Tópico removido da lista';

  @override
  String get topicListed => 'Tópico de volta à lista';

  @override
  String get topicRecovered => 'Tópico restaurado';

  @override
  String topicActionFailed(String error) {
    return 'Não foi possível atualizar o tópico: $error';
  }

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horas',
      one: '1 hora',
    );
    return '$_temp0';
  }

  @override
  String durationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String timeLeftMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'em $count minutos',
      one: 'em 1 minuto',
    );
    return '$_temp0';
  }

  @override
  String timeLeftHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'em $count horas',
      one: 'em 1 hora',
    );
    return '$_temp0';
  }

  @override
  String timeLeftDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'em $count dias',
      one: 'em 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get topicStatusDeletedHelp =>
      'Este tópico foi excluído e está oculto para outros usuários';

  @override
  String get flagAction => 'Sinalização';

  @override
  String get flagPost => 'Sinalizar resposta';

  @override
  String get signUp => 'Cadastrar-se';

  @override
  String get suspendUser => 'Suspender usuário(a)';

  @override
  String get unsuspend => 'Readmitir';

  @override
  String get suspendUntil => 'Suspender usuário até';

  @override
  String get suspendForever => 'Suspender para sempre';

  @override
  String failedToSuspendUser(String error) {
    return 'Algo deu errado ao suspender este(a) usuário(a): $error';
  }

  @override
  String failedToUnsuspendUser(String error) {
    return 'Algo deu errado ao reativar este(a) usuário(a): $error';
  }

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
  String get flaggingPost => 'Sinalizando a postagem…';

  @override
  String get pleaseSelectSuspensionEndDate =>
      'Escolha quando a suspensão termina';

  @override
  String get suspendingUser => 'Suspendendo usuário…';

  @override
  String get unsuspendingUser => 'Readmitindo usuário…';

  @override
  String get userSuspended => 'Usuário suspenso';

  @override
  String get userUnsuspended => 'Usuário readmitido';

  @override
  String unsuspendUserConfirmation(String username) {
    return 'Readmitir $username? A pessoa poderá entrar novamente.';
  }

  @override
  String get noCategoriesToDisplay => 'Não há categorias para exibir.';

  @override
  String get noPermissionToViewCategory =>
      'Você não tem permissão para ver os tópicos desta categoria.';

  @override
  String get featureTopicTitle => 'Destacar este tópico';

  @override
  String get pinTopicMenu => 'Fixar tópico...';

  @override
  String pinInCategoryUntil(String category) {
    return 'Fazer que este tópico apareça no topo da categoria $category até';
  }

  @override
  String get pinGloballyUntil =>
      'Fazer com que este tópico apareça no topo de todas listas de tópicos até';

  @override
  String get pinNote =>
      'Usuários(as) podem desafixar o tópico individualmente para si.';

  @override
  String get pinUntil => 'Fixar até';

  @override
  String get pinDateRequired => 'Uma data é necessária para fixar este tópico.';

  @override
  String get pinTopicGlobally => 'Fixar tópico globalmente';

  @override
  String get flagThanks =>
      'Agradecemos por manter a nossa comunidade um ambiente saudável!';

  @override
  String get flagReviewProcess =>
      'Todas as denúncias serão recebidas pela moderação e analisadas o mais rápido possível.';

  @override
  String get flagCant =>
      'Desculpe, não é possível colocar um sinalizador neste momento.';

  @override
  String get flagSendMessage => 'Mensagem';

  @override
  String get flagMessageForUser => 'Mensagem para o(a) usuário(a)';

  @override
  String get flagMessageForModerators => 'Mensagem para os(as) moderadores(as)';

  @override
  String get flagPlaceholderNotifyUser =>
      'Seja objetivo(a), positivo(a) e sempre gentil.';

  @override
  String get flagPlaceholderNotifyModerators =>
      'Diga-nos o motivo da sua preocupação e envie links e eventos relevantes sempre que for possível.';

  @override
  String get flagPlaceholderIllegal =>
      'Diga-nos o motivo específico por que você acredita que este conteúdo é ilegal e envie links e exemplos relevantes quando possível.';

  @override
  String get flagConfirmIllegal =>
      'O que eu escrevi acima está completo e preciso.';

  @override
  String flagMessageAtLeast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'insira pelo menos $count caracteres',
      one: 'insira pelo menos $count carácter',
    );
    return '$_temp0';
  }

  @override
  String get flagMessageSent => 'Sua mensagem foi enviada.';

  @override
  String get mergeTopicError =>
      'Ocorreu um erro ao mover as postagens para esse tópico.';

  @override
  String get topicTitlePlaceholder =>
      'Em algumas palavras, sobre o que é esta discussão?';

  @override
  String get topicMoved => 'Tópico movido';

  @override
  String get topicMerged => 'Tópico mesclado';

  @override
  String get mergeTopicExplanation =>
      'Todas as postagens deste tópico serão movidas para o tópico escolhido. Não é possível desfazer pelo aplicativo.';

  @override
  String get destinationTopicId => 'ID do tópico de destino';

  @override
  String get topicAuthorUnknown => 'Desconhecido';

  @override
  String get noHotTopics => 'Não há tópicos principais.';

  @override
  String get signInToViewNewTopics => 'Entre para ver tópicos novos';

  @override
  String get newTopicsSignInMessage =>
      'Os tópicos novos mostram o que foi criado desde a sua última visita.';

  @override
  String get topPeriodAllTime => 'Desde o início';

  @override
  String get topPeriodYear => 'Ano';

  @override
  String get topPeriodQuarter => 'Trimestre';

  @override
  String get topPeriodMonth => 'Mês';

  @override
  String get topPeriodWeek => 'Semana';

  @override
  String get topPeriodToday => 'Hoje';

  @override
  String noTopTopicsForPeriod(String period) {
    String _temp0 = intl.Intl.selectLogic(
      period,
      {
        'all': 'Não há melhores tópicos de todos os tempos.',
        'yearly': 'Não há melhores tópicos este ano.',
        'quarterly': 'Não há melhores tópicos neste trimestre.',
        'monthly': 'Não há melhores tópicos este mês.',
        'weekly': 'Não há melhores tópicos esta semana.',
        'daily': 'Não há melhores tópicos hoje.',
        'other': 'Não há melhores tópicos.',
      },
    );
    return '$_temp0';
  }

  @override
  String get connectionTimedOutSiteUnreachable =>
      'A conexão expirou. O site pode estar fora do ar ou inacessível.';

  @override
  String get failedToMarkNotificationsRead =>
      'Não foi possível marcar as notificações como lidas';

  @override
  String get forumNameFallback => 'Fórum';

  @override
  String get noForumDescription => 'Nenhuma descrição disponível.';

  @override
  String get dismissAllNotifications => 'Descartar tudo';

  @override
  String get notificationPostIdMissing =>
      'O ID da postagem está faltando. Não é possível ir para a postagem.';

  @override
  String get notificationTopicIdMissingForPost =>
      'O ID do tópico está faltando. Não é possível ir para a postagem.';

  @override
  String get notificationTopicIdMissing =>
      'O ID do tópico está faltando. Não é possível abrir o tópico.';

  @override
  String get notificationUsernameMissing =>
      'O nome de usuário está faltando. Não é possível abrir o perfil.';

  @override
  String get notificationChannelIdMissing =>
      'O ID do canal está faltando. Não é possível abrir o chat.';

  @override
  String get notificationGroupNameMissingForInbox =>
      'O nome do grupo está faltando. Não é possível abrir a caixa de entrada.';

  @override
  String get notificationGroupNameMissing =>
      'O nome do grupo está faltando. Não é possível abrir o grupo.';

  @override
  String get notificationNoActionUrl =>
      'Nenhuma URL de ação disponível para este tipo de notificação.';

  @override
  String get notificationBadgeUnavailable =>
      'Os detalhes do emblema não estão disponíveis.';

  @override
  String get notificationBadgeLoadFailed =>
      'Não foi possível carregar este emblema.';

  @override
  String get personalMessageTitleFallback => 'Mensagem pessoal';

  @override
  String get topicTitleFallback => 'Tópico';

  @override
  String get signInToViewNotifications => 'Entre para ver as notificações';

  @override
  String get youNeedToBeSignedInToViewNotifications =>
      'Você precisa estar conectado para ver suas notificações.';

  @override
  String get noUnreadNotifications => 'Nenhuma notificação não lida';

  @override
  String get noNotificationsYet => 'Nenhuma notificação ainda';

  @override
  String get newNotificationFallbackBody => 'Nova notificação';

  @override
  String get unableToOpenNotification => 'Não é possível abrir a notificação';

  @override
  String get notificationMissingSiteInfo =>
      'Faltam informações do site (site_id).';

  @override
  String get notificationInvalidSiteInfo =>
      'Informações do site inválidas (site_id).';

  @override
  String get notificationMissingPostInfo =>
      'Faltam informações da postagem (content_id).';

  @override
  String get notificationMissingMessageInfo =>
      'Faltam informações da mensagem (conversation_id).';

  @override
  String get notificationMissingUserInfo =>
      'Faltam informações do usuário (sender_id).';

  @override
  String get notificationUnsupportedType =>
      'Tipo de notificação não suportado.';

  @override
  String get notificationForumNotFound =>
      'Fórum não encontrado para este site.';

  @override
  String get notificationForumOpenFailed =>
      'Não foi possível inicializar o fórum.';

  @override
  String get notificationMissingTopicInfo =>
      'Faltam informações do tópico (topic_id).';

  @override
  String get failedToLoadTags => 'Não foi possível carregar as etiquetas.';

  @override
  String get searchTagsHint => 'Pesquisar etiquetas…';

  @override
  String get tagsSortedByCountTooltip =>
      'Ordenadas por número de tópicos — toque para mudar para A→Z';

  @override
  String get tagsSortedAlphabeticallyTooltip =>
      'Ordenadas alfabeticamente — toque para mudar para popularidade';

  @override
  String get noTagsYet => 'Ainda não há etiquetas neste fórum.';

  @override
  String get tagNotificationLevelTooltip => 'Nível de notificação';

  @override
  String get tagTopicsLoadFailed => 'Falha ao carregar';

  @override
  String searchFailedWithError(String error) {
    return 'Busca falhou: $error';
  }

  @override
  String get searchFiltersButtonTooltip => 'Filtros';

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
  String get bookmarksUnavailable => 'Os favoritos não estão disponíveis';

  @override
  String get failedToLoadBookmarks => 'Não foi possível carregar os favoritos';

  @override
  String get failedToRemoveBookmark => 'Não foi possível remover o favorito';

  @override
  String get failedToUpdateBookmark => 'Não foi possível atualizar o favorito';

  @override
  String get bookmarkWithReminder => 'Favorito com lembrete';

  @override
  String get noReminder => 'Sem lembrete';

  @override
  String get failedToLoadDrafts => 'Não foi possível carregar os rascunhos.';

  @override
  String get failedToDiscardDraft => 'Não foi possível descartar o rascunho';

  @override
  String get messagesLoadFailed => 'Não foi possível carregar as mensagens';

  @override
  String get moreMessagesLoadFailed =>
      'Não foi possível carregar mais mensagens';

  @override
  String get messageUnknownUser => 'Desconhecido';

  @override
  String get unknownErrorFallback => 'Erro desconhecido';

  @override
  String get chatComposerDefaultHint => 'Digite uma mensagem…';

  @override
  String chatChannelNumbered(Object id) {
    return 'canal $id';
  }

  @override
  String get chatSendFailed => 'Não foi possível enviar a mensagem.';

  @override
  String get chatEditFailed => 'Não foi possível editar a mensagem.';

  @override
  String get chatDeleteFailed => 'Não foi possível excluir a mensagem.';

  @override
  String get chatReactionsUnsupported => 'Reações não são suportadas aqui.';

  @override
  String get chatReactionFailed => 'Não foi possível atualizar a reação.';

  @override
  String get attachmentDefaultName => 'Anexo';

  @override
  String get fileTypeAudio => 'Áudio';

  @override
  String get fileTypeText => 'Texto';

  @override
  String get fileTypeArchive => 'Arquivo compactado';

  @override
  String get fileTypeFile => 'Arquivo';

  @override
  String downloadFailedHttpStatus(String status) {
    return 'Falha ao baixar o arquivo: HTTP $status';
  }

  @override
  String get downloadedFileEmpty => 'O arquivo baixado está vazio';

  @override
  String downloadFileFailed(String error) {
    return 'Falha ao baixar o arquivo: $error';
  }

  @override
  String attachmentTypeNotAllowed(String extension, String allowed) {
    return 'O tipo de arquivo .$extension não é permitido. Tipos permitidos: $allowed';
  }

  @override
  String attachmentFileTooLarge(String size, String max) {
    return 'O tamanho do arquivo ($size) excede o máximo de $max';
  }

  @override
  String get attachmentValidationFailed => 'Falha na validação do arquivo';

  @override
  String get uploadMissingReference =>
      'O envio foi concluído, mas o servidor não retornou nenhuma referência para o arquivo.';

  @override
  String get imageFileNotFound => 'Arquivo de imagem não encontrado';

  @override
  String get failedToLoadVideo => 'Não foi possível carregar o vídeo';

  @override
  String get userInfoLoadFailed =>
      'Não foi possível carregar as informações do usuário.';

  @override
  String userInfoLoadFailedWithError(String error) {
    return 'Não foi possível carregar as informações do usuário: $error';
  }

  @override
  String get profileMenuIgnoreUser => 'Ignorar usuário';

  @override
  String get profileMenuUnignoreUser => 'Parar de ignorar usuário';

  @override
  String get ignoreStateUpdateFailed =>
      'Não foi possível atualizar o estado de ignorado';

  @override
  String profileNowIgnoringUser(String username) {
    return 'Você está ignorando @$username. As postagens dessa pessoa ficarão ocultas.';
  }

  @override
  String get profileIgnoreToggleFailed =>
      'Não foi possível alternar a opção de ignorar.';

  @override
  String get profileStatsLoadFailed =>
      'Não foi possível carregar as estatísticas.';

  @override
  String get profileFollowFailed => 'Não foi possível seguir';

  @override
  String get profileUnfollowFailed => 'Não foi possível deixar de seguir';

  @override
  String get profileChatOpenFailed =>
      'Não foi possível abrir um chat com este usuário.';

  @override
  String summaryLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count curtidas',
      one: '1 curtida',
    );
    return '$_temp0';
  }

  @override
  String summaryLinkClicks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cliques',
      one: '1 clique',
    );
    return '$_temp0';
  }

  @override
  String get directoryPeriodAllTime => 'Desde o início';

  @override
  String get directoryPeriodYear => 'Ano';

  @override
  String get directoryPeriodQuarter => 'Trimestre';

  @override
  String get directoryPeriodMonth => 'Mês';

  @override
  String get directoryPeriodWeek => 'Semana';

  @override
  String get directoryPeriodToday => 'Hoje';

  @override
  String get directoryOrderReceived => 'Recebidos';

  @override
  String get directoryOrderReplies => 'Respostas';

  @override
  String get directoryOrderTopics => 'Tópicos';

  @override
  String get directoryOrderVisits => 'Acessos';

  @override
  String get directoryLoadFailed => 'Não foi possível carregar o diretório.';

  @override
  String get directoryNoUsersMatch => 'Nenhum usuário corresponde a esse nome.';

  @override
  String get directoryNoUsersForPeriod =>
      'Nenhum usuário encontrado neste período.';

  @override
  String get userSearchNoResults => 'Nenhum usuário encontrado';

  @override
  String get userSearchTryDifferentUsername =>
      'Tente pesquisar com outro nome de usuário';

  @override
  String get userSearchPromptTitle => 'Buscar usuários';

  @override
  String get userSearchPromptHint =>
      'Digite um nome de usuário para encontrar e convidar usuários';

  @override
  String get ignoredUsersUnignoreFailed => 'Não foi possível parar de ignorar.';

  @override
  String get ignoredUsersEmpty => 'Você não está ignorando ninguém.';

  @override
  String get ignoredUsersEmptyHint =>
      'Abra o perfil de um usuário e use \"Ignorar usuário\" no menu para ocultar as postagens e notificações dessa pessoa.';

  @override
  String get badgesLoadFailed => 'Não foi possível carregar os emblemas.';

  @override
  String get badgesEmpty => 'Não há emblemas neste fórum.';

  @override
  String get badgeTierGold => 'Ouro';

  @override
  String get badgeTierSilver => 'Prata';

  @override
  String get badgeTierBronze => 'Bronze';

  @override
  String badgeEarnedAgo(String time) {
    return 'Conquistado $time';
  }

  @override
  String badgeEarnedByUsers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Conquistado por $formatted usuários',
      one: 'Conquistado por $formatted usuário',
    );
    return '$_temp0';
  }

  @override
  String get trustLevelNameNewUser => 'Usuário novo';

  @override
  String get trustLevelNameBasic => 'Usuário básico';

  @override
  String get trustLevelNameMember => 'Membro';

  @override
  String get trustLevelNameRegular => 'Regular';

  @override
  String get trustLevelNameLeader => 'Líder';

  @override
  String get trustLevelSummary0 =>
      'Acabou de entrar. Pode ler e postar, com limites para links, imagens e mensagens.';

  @override
  String get trustLevelSummary1 =>
      'Libera os recursos principais de postagem: imagens e anexos, mais links e sinalizar postagens.';

  @override
  String get trustLevelSummary2 =>
      'Pode enviar convites, ignorar usuários e editar as próprias postagens por mais tempo.';

  @override
  String get trustLevelSummary3 =>
      'Pode recategorizar e renomear tópicos, criar etiquetas, e suas sinalizações de spam têm mais peso.';

  @override
  String get trustLevelSummary4 =>
      'Concedido pela equipe. Pode editar qualquer postagem e fixar, fechar, dividir ou mesclar tópicos.';

  @override
  String trustLevelRowTitle(int level, String name) {
    return 'TL$level · $name';
  }

  @override
  String get profileNoUserSpecified => 'Nenhum usuário especificado';

  @override
  String get userTopicsLoadFailed => 'Não foi possível carregar os tópicos';

  @override
  String get userTopicsEmpty => 'Nenhum tópico criado ainda.';

  @override
  String get userRecentPostsLoadFailed =>
      'Não foi possível carregar as postagens recentes';

  @override
  String get activityUnknownTopic => 'Tópico desconhecido';

  @override
  String groupJoinedSnack(String group) {
    return 'Você entrou em $group';
  }

  @override
  String get groupJoinFailed => 'Não foi possível entrar no grupo';

  @override
  String groupLeftSnack(String group) {
    return 'Você saiu de $group';
  }

  @override
  String get groupLeaveFailed => 'Não foi possível sair do grupo';

  @override
  String get groupMembershipRequestHint =>
      'Por que você quer entrar? Os proprietários do grupo verão isso junto com sua solicitação.';

  @override
  String get groupMembershipReasonRequired =>
      'É necessário um motivo para solicitar a entrada';

  @override
  String get groupMembershipRequestSent =>
      'Solicitação enviada — um proprietário do grupo precisa aprová-la';

  @override
  String get groupMembershipRequestFailed =>
      'Não foi possível enviar a solicitação de entrada';

  @override
  String get groupMemberBadge => 'Membro';

  @override
  String get groupRequestPending => 'Solicitação pendente';

  @override
  String get groupJoining => 'Entrando…';

  @override
  String get groupJoinButton => 'Entrar no grupo';

  @override
  String get groupsLoadFailed => 'Não foi possível carregar os grupos.';

  @override
  String get groupBuiltIn => 'Grupo integrado';

  @override
  String invitesPendingWithCount(int count) {
    return 'Pendentes ($count)';
  }

  @override
  String invitesExpiredWithCount(int count) {
    return 'Expirados ($count)';
  }

  @override
  String invitesRedeemedWithCount(int count) {
    return 'Resgatados ($count)';
  }

  @override
  String get invitesLoadFailed => 'Não foi possível carregar os convites.';

  @override
  String get inviteLinkCreateFailed =>
      'Não foi possível criar o link de convite';

  @override
  String get inviteEmailAddressLabel => 'Endereço de e-mail';

  @override
  String get inviteEmailInvalid => 'Digite um endereço de e-mail válido';

  @override
  String get inviteMessageOptionalLabel => 'Mensagem (opcional)';

  @override
  String get inviteSendFailed => 'Não foi possível enviar o convite';

  @override
  String get revokeInviteLinkWarning =>
      'O link de convite deixará de funcionar.';

  @override
  String revokeInviteEmailWarning(String email) {
    return 'O convite para $email deixará de funcionar.';
  }

  @override
  String get inviteRevokeFailed => 'Não foi possível revogar o convite';

  @override
  String get inviteNoPermission => 'Você não tem permissão para convidar';

  @override
  String get invitesEmptyPending => 'Nenhum convite pendente';

  @override
  String get invitesEmptyExpired => 'Nenhum convite expirado';

  @override
  String get invitesEmptyRedeemed => 'Nenhum convite resgatado';

  @override
  String get invitesEmptyPendingHint =>
      'Crie um link de convite para trazer pessoas ao fórum.';

  @override
  String get inviteLinkFallbackTitle => 'Link de convite';

  @override
  String inviteRedeemedOn(String date) {
    return 'Resgatado em $date';
  }

  @override
  String inviteRedemptions(int count, int max) {
    return 'Resgatados $count de $max';
  }

  @override
  String get inviteEmailSent => 'E-mail enviado';

  @override
  String get inviteEmailNotSent => 'E-mail não enviado';

  @override
  String inviteExpiredOn(String date) {
    return 'Expirou em $date';
  }

  @override
  String get inviteRevokeTooltip => 'Revogar convite';

  @override
  String get reviewStatusPending => 'Pendentes';

  @override
  String get reviewStatusApproved => 'Aprovado';

  @override
  String get reviewStatusRejected => 'Rejeitado';

  @override
  String get reviewStatusAll => 'Tudo';

  @override
  String get reviewStatusIgnored => 'Sinalizador ignorado';

  @override
  String get reviewStatusDeleted => 'Tópico ou postagem excluída';

  @override
  String get reviewQueueUnavailable =>
      'A fila de revisão não está disponível neste fórum.';

  @override
  String get reviewQueueLoadFailed =>
      'Não foi possível carregar a fila de revisão';

  @override
  String get reviewableChangedByOther =>
      'Este item foi alterado por outro moderador. Atualizando…';

  @override
  String get reviewActionFailed => 'Não foi possível executar a ação';

  @override
  String reviewActionDone(String action) {
    return '$action — concluído';
  }

  @override
  String get reviewRejectReasonHint => 'Por que isto está sendo rejeitado?';

  @override
  String get reviewTypeFlaggedPost => 'Postagem sinalizada';

  @override
  String get reviewTypeQueuedPost => 'Postagem na fila';

  @override
  String get reviewTypeQueuedTopic => 'Tópico na fila';

  @override
  String get reviewTypeUser => 'Usuário';

  @override
  String get reviewTypePost => 'Postagem';

  @override
  String get reviewTypeChatMessage => 'Mensagem de chat sinalizada';

  @override
  String get reviewModeratorAccessRequired => 'Acesso de moderador necessário';

  @override
  String reviewableScore(String score) {
    return 'Pontuação $score';
  }

  @override
  String get postRepliesLoadFailed => 'Não foi possível carregar as respostas.';

  @override
  String get postMakeWiki => 'Tornar Wiki';

  @override
  String get postRemoveWiki => 'Remover Wiki';

  @override
  String get postBookmarkRemoveFailed => 'Falha ao remover o favorito';

  @override
  String get postBookmarkFailed =>
      'Falha ao adicionar a postagem aos favoritos';

  @override
  String get postBookmarkReminderUpdateFailed =>
      'Falha ao atualizar o lembrete';

  @override
  String get postBookmarkReminderSet => 'Lembrete definido';

  @override
  String get postBookmarkReminderCleared => 'Lembrete liberado';

  @override
  String get solutionMarkFailed => 'Falha ao marcar a resposta como solução';

  @override
  String get solutionUnmarkFailed => 'Falha ao desmarcar a solução';

  @override
  String get postUnknownDate => 'Data desconhecida';

  @override
  String get postBookmarkAction => 'Adicionar postagem aos favoritos';

  @override
  String get reactionButtonRemoveLike =>
      'Você curtiu. Toque para remover sua curtida.';

  @override
  String reactionButtonRemove(String reaction) {
    return 'Sua reação: $reaction. Toque para removê-la.';
  }

  @override
  String reactionButtonLocked(String reaction) {
    return 'Sua reação: $reaction. Ela não pode mais ser alterada.';
  }

  @override
  String get reactionHoldHint => 'Pressione e segure para mais reações';

  @override
  String reactionSummarySemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reações. Toque para ver quem reagiu.',
      one: '1 reação. Toque para ver quem reagiu.',
    );
    return '$_temp0';
  }

  @override
  String get reactionLockedMessage =>
      'Você não pode mais alterar sua reação a esta postagem.';

  @override
  String get reactionHoldTip =>
      'Dica: pressione e segure o coração para mais reações.';

  @override
  String reactionsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reações',
      one: '1 reação',
    );
    return '$_temp0';
  }

  @override
  String get reactionsAll => 'Todas';

  @override
  String get reactionYou => 'Você';

  @override
  String get changeYourReaction => 'Alterar sua reação';

  @override
  String get reactionTapAgainToRemove =>
      'Toque na sua reação de novo para removê-la.';

  @override
  String reactionFilterSemantics(String reaction, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$reaction, $count pessoas',
      one: '$reaction, 1 pessoa',
    );
    return '$_temp0';
  }

  @override
  String get postLikeAction => 'Curtir a postagem';

  @override
  String get postUnlikeAction => 'Desfazer curtida';

  @override
  String get postVoteRemoveFailed =>
      'Não foi possível remover o voto (o prazo para desfazer expirou?)';

  @override
  String get postVoteCastFailed => 'Não foi possível votar';

  @override
  String get postUpvote => 'Votar a favor';

  @override
  String get postDownvote => 'Votar contra';

  @override
  String get pollVoteFailed => 'Falha ao votar. Tente novamente.';

  @override
  String get pollRemoveVoteFailed =>
      'Não foi possível remover seu voto. Tente novamente.';

  @override
  String get pollVotersLoadFailed => 'Não foi possível carregar os votantes.';

  @override
  String get pollVotersNotVisible =>
      'Os votantes desta enquete não são visíveis.';

  @override
  String get pollRankedChoiceHint =>
      'Toque nas opções em ordem de preferência. Opções sem posição contam como abstenção.';

  @override
  String get pollRankAbstain => 'Abstenção';

  @override
  String pollRank(int rank) {
    return 'Posição $rank';
  }

  @override
  String get pollRankedChoiceWinner => 'Vencedor';

  @override
  String get pollRankedChoiceTied => 'Empate';

  @override
  String solutionSolvedByInPost(String name, int postNumber) {
    return 'Resolvido por $name na postagem #$postNumber';
  }

  @override
  String solutionMarkedBy(String name) {
    return 'marcado por $name';
  }

  @override
  String reactAgainInSeconds(int seconds) {
    return 'Você pode reagir a esta postagem novamente em ${seconds}s';
  }

  @override
  String get reactionUpdateFailed => 'Não foi possível atualizar a reação.';

  @override
  String get reactionsNotSupported =>
      'Este fórum não oferece suporte a reações.';

  @override
  String get reactionsLoadFailed => 'Não foi possível carregar as reações.';

  @override
  String viewProfileOfUser(String username) {
    return 'Ver o perfil de $username';
  }

  @override
  String get failedToSavePost => 'Falha ao salvar a postagem';

  @override
  String failedToSavePostWithError(String error) {
    return 'Falha ao salvar a postagem: $error';
  }

  @override
  String get failedToRemoveAttachmentCheckPermissions =>
      'Falha ao remover o anexo. Verifique suas permissões.';

  @override
  String get editPostTitle => 'Editar postagem';

  @override
  String get editYourPostHint => 'Edite sua postagem...';

  @override
  String get failedToPostReply => 'Falha ao publicar a resposta';

  @override
  String failedToPostReplyWithError(String error) {
    return 'Falha ao publicar a resposta: $error';
  }

  @override
  String get failedToCreateTopic => 'Falha ao criar o tópico';

  @override
  String get writeYourTopicTitle => 'Escreva o título do seu tópico...';

  @override
  String get writeYourTopicContent => 'Escreva o conteúdo do seu tópico...';

  @override
  String get composerTitleHint => 'Escreva seu título...';

  @override
  String get composerContentHint => 'Escreva seu conteúdo...';

  @override
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit) {
    return '$fileName: grande demais ($size) e não pôde ser redimensionado. O limite é $limit.';
  }

  @override
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit) {
    return '$fileName redimensionado para $size$dimensions para caber no limite de $limit.';
  }

  @override
  String get composerAttachFileHint => 'Anexar um arquivo a esta postagem';

  @override
  String get composerUploadImageHint => 'Enviar uma imagem para esta postagem';

  @override
  String get composerFormattingHint => 'Abrir opções de formatação';

  @override
  String get whisperStaffOnly => 'Sussurro (apenas equipe)';

  @override
  String get whisperOnStaffOnly => 'Sussurro ativado (apenas equipe)';

  @override
  String get tagInputMaxReached => 'Máximo de etiquetas atingido';

  @override
  String get tagInputAddTag => 'Adicionar uma etiqueta…';

  @override
  String get tagInputAddAnother => '+ etiqueta';

  @override
  String get editHistoryUnavailable =>
      'O histórico de edições não está disponível neste fórum.';

  @override
  String get editHistoryLoadFailed =>
      'Falha ao carregar o histórico de edições.';

  @override
  String get previousRevision => 'Revisão anterior';

  @override
  String get nextRevision => 'Próxima revisão';

  @override
  String get notificationPrefsLoadFailed =>
      'Não foi possível carregar as preferências de notificação.';

  @override
  String get notificationPrefsSaveFailed =>
      'Não foi possível salvar — verifique sua conexão';

  @override
  String get signInToManageNotificationPrefs =>
      'Entre para gerenciar suas preferências de notificação.';

  @override
  String get emailWhenAwayTitle => 'E-mail quando ausente';

  @override
  String get emailLevelDescription =>
      'Me enviar e-mail quando eu for citado(a), receber resposta, meu @username for mencionado, ou quando houver atividades novas nas categorias, etiquetas ou tópicos que acompanho.';

  @override
  String get notificationPrefAlways => 'Sempre';

  @override
  String get notificationPrefOnlyWhenAway => 'Somente quando estiver longe';

  @override
  String get notificationPrefNever => 'Nunca';

  @override
  String get emailForMessagesTitle => 'E-mail de mensagens';

  @override
  String get emailMessagesLevelDescription =>
      'Me enviar e-mail quando eu receber uma mensagem pessoal';

  @override
  String get activitySummaryTitle => 'Resumo de atividades';

  @override
  String get activitySummaryDescription =>
      'Quando eu não acessar o site, envie um resumo por e-mail de tópicos e respostas mais acessadas';

  @override
  String get activitySummaryFrequencyTitle =>
      'Frequência do resumo de atividades';

  @override
  String get activitySummaryDaily => 'A cada dia';

  @override
  String get activitySummaryWeekly => 'A cada semana';

  @override
  String get activitySummaryMonthly => 'A cada mês';

  @override
  String get mailingListModeTitle => 'Modo lista de endereçamento';

  @override
  String get mailingListModeDescription =>
      'Me enviar cada postagem por e-mail (desativa o resumo de atividades). Não recomendado em fóruns movimentados.';

  @override
  String get likeNotificationFrequencyTitle => 'Notificar ao receber curtida';

  @override
  String get likeNotificationFirstTimeAndDaily =>
      'Primeira vez que uma postagem é curtida diariamente';

  @override
  String get likeNotificationFirstTime =>
      'Primeira vez que uma postagem é curtida';

  @override
  String get whenPostingTitle => 'Ao postar';

  @override
  String get whenPostingDescription =>
      'O que acontece com um tópico ao qual você responde';

  @override
  String get whenPostingWatchTopic => 'Acompanhar tópico';

  @override
  String get whenPostingTrackTopic => 'Monitorar tópico';

  @override
  String get whenPostingDoNothing => 'Não fazer nada';

  @override
  String get pauseNotificationsUntilTomorrow => 'Até amanhã';

  @override
  String get couldNotEnableDoNotDisturb =>
      'Não foi possível ativar o Não perturbe';

  @override
  String get couldNotTurnOffDoNotDisturb =>
      'Não foi possível desativar o Não perturbe';

  @override
  String get passwordResetEmailSent =>
      'E-mail de redefinição de senha enviado.';

  @override
  String get couldNotSendResetEmail =>
      'Não foi possível enviar o e-mail de redefinição';

  @override
  String get accountRequestFailed => 'A solicitação falhou.';

  @override
  String get forumUrlUnavailable => 'A URL do fórum não está disponível.';

  @override
  String get couldNotOpenPreferencesPage =>
      'Não foi possível abrir a página de preferências.';

  @override
  String get couldNotOpenForumUrl => 'Não foi possível abrir a URL do fórum.';

  @override
  String get couldNotRequestEmailChange =>
      'Não foi possível solicitar a alteração de e-mail';

  @override
  String get newEmailLabel => 'Novo e-mail';

  @override
  String get enterAnEmailAddress => 'Insira um endereço de e-mail';

  @override
  String get emailLooksInvalid => 'Isso não parece um e-mail';

  @override
  String get emailNoSpaces => 'E-mails não podem ter espaços';

  @override
  String get allowNotificationsSheetTitle => 'Permitir notificações';

  @override
  String get notificationsGrantNoPayload =>
      'A autorização não retornou nenhuma resposta.';

  @override
  String get thisForumFallback => 'este fórum';

  @override
  String signInToDomain(String domain) {
    return 'Entrar em $domain';
  }

  @override
  String get loginResultTitle => 'Resultado do login';

  @override
  String get invalidAuthenticationCode => 'Código de autenticação inválido';

  @override
  String get tfaVerificationError =>
      'Ocorreu um erro durante a verificação. Tente novamente.';

  @override
  String get passwordFieldLabel => 'Senha';

  @override
  String get somethingWentWrongTryAgain => 'Algo deu errado. Tente novamente.';

  @override
  String get unexpectedErrorTryAgain =>
      'Ocorreu um erro inesperado. Tente novamente.';

  @override
  String get errorNoInternetConnection =>
      'Sem conexão com a internet. Verifique suas configurações de rede.';

  @override
  String get errorRequestTimedOut => 'A solicitação expirou. Tente novamente.';

  @override
  String get errorServerTryLater =>
      'Ocorreu um erro no servidor. Tente novamente mais tarde.';

  @override
  String get errorInvalidCredentials => 'Nome de usuário ou senha inválidos.';

  @override
  String get errorSessionExpired => 'Sua sessão expirou. Entre novamente.';

  @override
  String get errorAccountSuspended =>
      'Sua conta foi suspensa. Entre em contato com a equipe do fórum.';

  @override
  String get errorForumNotFound => 'Fórum não encontrado.';

  @override
  String get errorForumAccessDenied =>
      'Você não tem permissão para acessar este fórum.';

  @override
  String get errorForumUnavailable =>
      'O fórum está indisponível no momento. Tente novamente mais tarde.';

  @override
  String get errorDataNotFound => 'Dados solicitados não encontrados.';

  @override
  String get errorDataCorrupted =>
      'Os dados parecem estar corrompidos. Atualize a página.';

  @override
  String get errorCacheLoadFailed =>
      'Não foi possível carregar os dados em cache. Tente novamente.';

  @override
  String errorInvalidField(String field) {
    return 'Valor inválido para $field.';
  }

  @override
  String errorFieldRequired(String field) {
    return '$field é obrigatório.';
  }

  @override
  String errorPermissionDeniedFor(String action) {
    return 'Você não tem permissão para: $action.';
  }

  @override
  String errorFeatureNotAvailable(String feature) {
    return '$feature não está disponível neste fórum.';
  }

  @override
  String get errorStorageFull =>
      'O armazenamento está cheio. Libere algum espaço.';

  @override
  String get errorStorageAccessDenied =>
      'Acesso ao armazenamento negado. Verifique as permissões do app.';

  @override
  String get errorNetworkTryAgain =>
      'Ocorreu um erro de rede. Tente novamente.';

  @override
  String get errorAuthenticationTryAgain =>
      'Falha na autenticação. Tente novamente.';

  @override
  String get errorForumTryAgain => 'Ocorreu um erro no fórum. Tente novamente.';

  @override
  String get connectionErrorTitle => 'Erro de conexão';

  @override
  String get authenticationErrorTitle => 'Erro de autenticação';

  @override
  String get forumErrorTitle => 'Erro do fórum';

  @override
  String get permissionErrorTitle => 'Erro de permissão';

  @override
  String errorRemovingFromMessage(String name) {
    return 'Não foi possível remover $name desta mensagem.';
  }

  @override
  String get chatNewMessage => 'Nova mensagem';

  @override
  String get chatStarred => 'Marcado como favorito';

  @override
  String get chatBrowseChannels => 'Navegar por canais';

  @override
  String get chatBrowseAllChannels => 'Navegar por todos os canais';

  @override
  String get chatFilterAll => 'Tudo';

  @override
  String get chatFilterOpen => 'Aberto';

  @override
  String get chatFilterClosed => 'Fechados';

  @override
  String get chatFilterArchived => 'Arquivados';

  @override
  String get chatBrowseSearch => 'Pesquisar canal por nome';

  @override
  String get chatJoin => 'Participar';

  @override
  String get chatJoined => 'Entrou';

  @override
  String get chatLeave => 'Sair';

  @override
  String chatMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membros',
      one: '$count membro',
    );
    return '$_temp0';
  }

  @override
  String get chatYesterday => 'Ontem';

  @override
  String get chatNoChannelsFound => 'Nenhum canal encontrado';

  @override
  String get chatCloseDm => 'Fechar este chat pessoal';

  @override
  String get chatToday => 'Hoje';

  @override
  String get chatLastVisit => 'último acesso';

  @override
  String chatNewMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count novas mensagens',
      one: '$count nova mensagem',
    );
    return '$_temp0';
  }

  @override
  String get chatScrollToBottom => 'Rolar para a parte inferior';

  @override
  String get chatInReplyTo => 'Em resposta a';

  @override
  String get chatCopyText => 'Copiar texto';

  @override
  String get chatTextCopied => 'Texto copiado para área de transferência';

  @override
  String get chatBookmark => 'Marcador';

  @override
  String get chatPinMessage => 'Fixar mensagem';

  @override
  String get chatUnpinMessage => 'Desafixar mensagem';

  @override
  String get chatFlag => 'Sinalizar';

  @override
  String get chatReactWithEmoji => 'Reagir com emoji';

  @override
  String chatReplyingTo(String username) {
    return 'Respondendo a $username';
  }

  @override
  String get chatEditingMessage => 'Editando mensagem';

  @override
  String chatTypingOne(String username) {
    return '$username está digitando';
  }

  @override
  String chatTypingTwo(String commaSeparatedUsernames, String lastUsername) {
    return '$commaSeparatedUsernames e $lastUsername estão digitando';
  }

  @override
  String chatTypingMany(String commaSeparatedUsernames, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$commaSeparatedUsernames e mais $count estão digitando',
      one: '$commaSeparatedUsernames e mais $count estão digitando',
    );
    return '$_temp0';
  }

  @override
  String get chatOpenThread => 'Linha de discussão aberta';

  @override
  String get chatMembers => 'Membros';

  @override
  String get chatAddMember => 'Adicionar membro';

  @override
  String get chatFindMembers => 'Encontrar membros';

  @override
  String get chatRemoveMember => 'Remover';

  @override
  String get chatNotifyNever => 'Nunca';

  @override
  String get chatNotifyMention => 'Apenas para menções';

  @override
  String get chatNotifyAlways => 'Para todas as atividades';

  @override
  String get chatNotificationLevel => 'Enviar notificações por push';

  @override
  String get chatMuteChannel => 'Silenciar canal';

  @override
  String get chatStarChannel => 'Adicionar canal aos favoritos';

  @override
  String get chatLeaveChannel => 'Sair do canal';

  @override
  String get chatSearchTitle => 'Pesquisar no chat';

  @override
  String get chatSearchNoResults => 'Nenhum resultado encontrado';

  @override
  String get chatMyThreads => 'Meus tópicos';

  @override
  String chatThreadReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count respostas',
      one: '$count resposta',
    );
    return '$_temp0';
  }

  @override
  String get chatNoThreads =>
      'Você não está participando de nenhuma linha de discussão neste canal.';

  @override
  String get chatGroupName => 'Nome do chat em grupo (opcional)';

  @override
  String chatMembersCounter(int count, int max) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count/$max membros',
      one: '$count/$max membro',
    );
    return '$_temp0';
  }

  @override
  String get chatTooManyMembers => 'Número máximo de membros alcançado';

  @override
  String get chatThread => 'Linha de discussão';

  @override
  String get chatChannelSettings => 'Configurações do canal';

  @override
  String get chatSearchMessagesHint => 'Pesquisar mensagens';

  @override
  String get chatMyThreadsEmpty =>
      'Você ainda não tem nenhum tópico. Os tópicos de que você participa serão exibidos aqui.';

  @override
  String get chatLeaveGroupInfo =>
      'Ao sair do chat em grupo, você não terá mais acesso a ele nem receberá as notificações relacionadas. Para entrar novamente, você precisa ser convidado(a) novamente por um membro do chat em grupo.';

  @override
  String get chatPlaceholderThread => 'Conversar na linha de discussão';

  @override
  String get chatLastReply => 'última resposta';

  @override
  String messageListUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Não lidos ($count)',
      one: 'Não lido ($count)',
    );
    return '$_temp0';
  }

  @override
  String messageListNewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Novos ($count)',
      one: 'Novo ($count)',
    );
    return '$_temp0';
  }

  @override
  String get messagePersonal => 'Pessoal';

  @override
  String messageListIncoming(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Veja $count tópicos novos ou atualizados',
      one: 'Veja $count tópico novo ou atualizado',
    );
    return '$_temp0';
  }

  @override
  String get chatPlaceholderGroup => 'Chat em grupo';

  @override
  String get notificationAccountMismatch =>
      'Esta notificação não pode ser aberta com a conta atual. Abra Notificações para ver as atualizações desta conta.';

  @override
  String get chatJoinedChannels => 'Canais em que participa';

  @override
  String get chatAvailableChannels => 'Canais disponíveis';

  @override
  String get chatAvailableChannelsDescription =>
      'Canais que pode ver ou aos quais pode aderir.';

  @override
  String get chatAllChannelsJoined => 'Aderiu a todos os canais disponíveis.';

  @override
  String get chatViewChannel => 'Ver';

  @override
  String get mediaPlay => 'Reproduzir';

  @override
  String get mediaPause => 'Pausar';
}
