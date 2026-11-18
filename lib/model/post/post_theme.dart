class PostTheme {
  const PostTheme({
    required this.id,
    required this.name,
    this.backgroundColorHex,
    this.foregroundColorHex,
    this.accentColorHex,
    this.backgroundAssetUri,
  });

  final String id;
  final String name;
  final String? backgroundColorHex;
  final String? foregroundColorHex;
  final String? accentColorHex;
  final String? backgroundAssetUri;
}
