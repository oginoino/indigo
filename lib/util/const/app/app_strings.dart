class AppStrings {
  const AppStrings._();

  static const empty = '';
  static const genericError = 'Error';
  static const startupFailed = 'App startup failed';

  static const noFeedsAvailable = 'Nenhum feed encontrado';
  static const videosTitle = 'Vídeos';
  static const postsLoadFailed = 'Não foi possível carregar as publicações.';
  static const noPostsAvailable = 'Nenhuma publicação disponível.';
  static const retry = 'Tentar novamente';
  static const videoPlaybackFailed = 'Não foi possível reproduzir este vídeo.';
  static const noVideosAvailable = 'Nenhum vídeo disponível.';
  static const postEngagementSeparator = '  ·  ';
  static const viewPostImage = 'Visualizar imagem {index}';
  static const closeImageViewer = 'Fechar visualização';
  static const imageViewerCounter = '{current} / {total}';
  static const imageLoadFailed = 'Não foi possível carregar esta imagem.';
  static const playVideo = 'Reproduzir vídeo';
  static const pauseVideo = 'Pausar vídeo';
  static const muteVideo = 'Silenciar vídeo';
  static const unmuteVideo = 'Ativar som do vídeo';
  static const createTitle = 'Criar';
  static const messagesTitle = 'Mensagens';
  static const profileTitle = 'Perfil';

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
}
