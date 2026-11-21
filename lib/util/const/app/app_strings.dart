class AppStrings {
  const AppStrings._();

  static const empty = '';
  static const genericError = 'Error';
  static const startupFailed = 'App startup failed';
  static const scrollToTopLabel = 'Voltar ao topo';

  static const noFeedsAvailable = 'Nenhum feed encontrado';
  static const videosTitle = 'Vídeos';
  static const postsLoadFailed = 'Não foi possível carregar as publicações.';
  static const noPostsAvailable = 'Nenhuma publicação disponível.';
  static const postsEndReached = 'Você chegou ao fim das publicações.';
  static const videosEndReached = 'Você chegou ao fim dos vídeos.';
  static const loadingMorePosts = 'Carregando mais publicações...';
  static const loadMorePosts = 'Carregar mais publicações';
  static const retry = 'Tentar novamente';
  static const videoPlaybackFailed = 'Não foi possível reproduzir este vídeo.';
  static const noVideosAvailable = 'Nenhum vídeo disponível.';
  static const postEngagementSeparator = '·';
  static const unknownPostAuthor = 'Usuário desconhecido';
  static const unknownUsername = '@usuario';
  static const postTimeNow = 'agora';
  static const postTimeMinute = 'há 1 min';
  static const postTimeMinutes = 'há {count} min';
  static const postTimeHour = 'há 1 h';
  static const postTimeHours = 'há {count} h';
  static const postTimeDay = 'há 1 dia';
  static const postTimeDays = 'há {count} dias';
  static const postTimeWeek = 'há 1 sem';
  static const postTimeWeeks = 'há {count} sem';
  static const postTimeMonth = 'há 1 mês';
  static const postTimeMonths = 'há {count} meses';
  static const postTimeYear = 'há 1 ano';
  static const postTimeYears = 'há {count} anos';
  static const postPublishedOn = 'Publicado em {date}';
  static const postLocation = 'Localização: {location}';
  static const postComments = 'Comentários';
  static const postLikes = 'Curtidas';
  static const postReposts = 'Republicações';
  static const postSaves = 'Salvamentos';
  /// Chave de persistência usada pelo [StorySeenProvider].
  static const storySeenStorageKey = 'seen_story_ids';

  static const invalidSocialUserProfileField =
      'Invalid {field} in social user profile data.';
  static const invalidSocialFriendshipField =
      'Invalid {field} in social friendship data.';
  static const viewPostImage = 'Visualizar imagem {index}';
  static const closeImageViewer = 'Fechar visualização';
  static const imageViewerCounter = '{current} / {total}';
  static const imageLoadFailed = 'Não foi possível carregar esta imagem.';
  static const postReadMore = 'Ler mais';
  static const postArticleTitle = 'Publicação';
  static const playVideo = 'Reproduzir vídeo';
  static const pauseVideo = 'Pausar vídeo';
  static const muteVideo = 'Silenciar vídeo';
  static const unmuteVideo = 'Ativar som do vídeo';
  static const playAudio = 'Reproduzir áudio';
  static const pauseAudio = 'Pausar áudio';
  static const rewindAudio = 'Retroceder áudio';
  static const forwardAudio = 'Avançar áudio';
  static const audioPlaybackFailed = 'Não foi possível reproduzir este áudio.';
  static const audioDurationFormat = '{minutes}:{seconds}';
  static const createTitle = 'Criar';
  static const messagesTitle = 'Mensagens';
  static const profileTitle = 'Perfil';
  static const pinHashtag = 'Fixar hashtag';
  static const unpinHashtag = 'Desfixar hashtag';
  static const hashtagOptions = 'Opções da hashtag';
  static const hashtagPinSaveFailed =
      'Não foi possível salvar a hashtag fixada.';
  static const navFeedOrderSaveFailed =
      'Não foi possível salvar a ordem da navegação.';
  static const noHashtagPosts = 'Ainda não há publicações com esta hashtag.';
  static const addFriends = 'Adicionar amigos';
  static const avatarGroupOverflow = '+{count}';
  static const yourStory = 'Seu story';
  static const addStory = 'Adicionar story';
  static const openStory = 'Abrir story de {name}';
  static const closeStoryViewer = 'Fechar story';
  static const storyViewerPrevious = 'Story anterior';
  static const storyViewerNext = 'Próximo story';
  static const storyMediaUnavailable = 'Este story não possui mídia.';
  static const storyViewerCounter = '{current} de {total}';

  static const invalidAppData = 'App data must be a JSON object.';
  static const missingAppDataSection = 'App data is missing {section}.';
  static const invalidAppDataItems = 'Items in {section} must be JSON objects.';
  static const appDataNotLoaded = 'App data has not been loaded yet.';
  static const invalidSocialMockData =
      'Social mock data must be a JSON object.';
  static const missingSocialMockDataSection =
      'Social mock data is missing {section}.';
  static const invalidSocialMockDataItems =
      'Items in social mock data section {section} must be JSON objects.';
  static const socialMockDataNotLoaded =
      'Social mock data has not been loaded yet.';
  static const invalidSocialPostField = 'Invalid {field} in social post data.';
  static const invalidSocialPostCache = 'Invalid local social post cache.';
  static const socialPostCacheSaveFailed =
      'Could not save the local social post cache.';
  static const socialPostCacheClearFailed =
      'Could not clear the local social post cache.';
  static const invalidOrDuplicateFeedRoute =
      'Invalid or duplicate feed route: {route}';
  static const unknownFeedAppBar = 'Unknown feed app bar: {appBar}';

  static const avatarImageMissing = 'Avatar image does not exist.';
  static const missingAvatarPathClearFailed =
      'Could not clear the missing avatar image path.';
  static const avatarPathSaveFailed = 'Could not save the avatar image path.';
  static const avatarPathRemoveFailed =
      'Could not remove the avatar image path.';

  // ---------------------------------------------------------------------------
  // Comment section strings
  // ---------------------------------------------------------------------------
  static const comments = 'Comentários';
  static const commentInputHint = 'Adicionar comentário…';
  static const commentReply = 'Responder';
  static const commentLike = 'Curtir comentário';
  static const commentUnlike = 'Descurtir comentário';
  /// Substitua {count} pelo número de respostas.
  static const commentLoadReplies = 'Ver {count} respostas';
  static const commentHideReplies = 'Ocultar respostas';
  static const commentDeleteTooltip = 'Excluir comentário';
  static const commentNoComments = 'Seja o primeiro a comentar.';
  static const commentSend = 'Publicar';
  /// Substitua {username} pelo @username do autor do comentário pai.
  static const commentReplyingTo = 'Respondendo a @{username}';

  // ---------------------------------------------------------------------------
  // Comment mapper error strings
  // ---------------------------------------------------------------------------
  static const invalidCommentField = 'Invalid {field} in comment data.';

  // ---------------------------------------------------------------------------
  // Post interaction strings
  // ---------------------------------------------------------------------------
  static const postLiked = 'Publicação curtida';
  static const postUnliked = 'Curtida removida';
  static const postSaved = 'Publicação salva';
  static const postUnsaved = 'Publicação removida dos salvos';
  static const postReposted = 'Publicação republicada';
  static const postUnreposted = 'Republicação desfeita';
  static const postShareSheet = 'Compartilhar publicação';
  static const closeComments = 'Fechar comentários';
  static const commentsTitle = 'Comentários';

  // ---------------------------------------------------------------------------
  // Criação de conteúdo
  // ---------------------------------------------------------------------------
  static const createPageTitle = 'Criar';
  static const createTypeSelectionTitle = 'O que você quer criar?';
  static const createEditorPublish = 'Publicar';
  static const createEditorPublishing = 'Publicando…';
  static const createEditorDiscard = 'Descartar';
  static const createEditorDiscardConfirm =
      'Tem certeza que quer descartar este rascunho?';
  static const createEditorDiscardConfirmYes = 'Descartar';
  static const createEditorDiscardConfirmNo = 'Continuar editando';
  static const createEditorTitleHint = 'Título';
  static const createEditorBodyHint = 'No que você está pensando?';
  static const createEditorArticleBodyHint = 'Escreva o seu artigo…';
  static const createEditorAddMedia = 'Adicionar mídia';
  static const createEditorMediaCount = '{count} mídia(s) selecionada(s)';
  static const createEditorAddPollOption = 'Adicionar opção';
  static const createEditorPollOptionHint = 'Opção {number}';
  static const createEditorEventDateHint = 'Data e hora do evento';
  static const createEditorEventLocationHint = 'Local do evento';
  static const createEditorVisibilityPublic = 'Público';
  static const createEditorVisibilityFriends = 'Somente amigos';
  static const createEditorVisibilityLabel = 'Visibilidade';
  static const createEditorLiveTitleHint = 'Título da live';
  static const createPublishSuccess = 'Publicado com sucesso!';
  static const createPublishFailed = 'Não foi possível publicar. Tente novamente.';
  static const createMediaSimulatedHint =
      'Seleção de mídia disponível no app completo.';
  static const createPollMinOptions = 'Adicione pelo menos 2 opções.';
  static const createFieldRequired = 'Campo obrigatório.';
}