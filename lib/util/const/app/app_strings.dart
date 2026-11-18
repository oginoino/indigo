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
  static const invalidOrDuplicateFeedRoute =
      'Invalid or duplicate feed route: {route}';
  static const unknownFeedAppBar = 'Unknown feed app bar: {appBar}';
}
