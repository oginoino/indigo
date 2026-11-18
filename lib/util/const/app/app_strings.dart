class AppStrings {
  const AppStrings._();

  static const empty = '';
  static const genericError = 'Error';
  static const startupFailed = 'App startup failed';

  static const noFeedsAvailable = 'Nenhum feed encontrado';
  static const videosTitle = 'Vídeos';
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
