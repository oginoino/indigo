import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../model/create/content_type.dart';
import '../../model/create/post_draft.dart';
import '../../model/post/post.dart';
import '../../model/post/post_content.dart';
import '../../model/post/post_media.dart';

/// Estado da sessão de criação de conteúdo.
///
/// Gerencia o rascunho ativo e coordena as transições entre etapas do editor.
/// É descartado ao fechar a tela de criação.
class CreatePostProvider extends ChangeNotifier {
  CreatePostProvider() : _draft = PostDraft() {
    _draft.pollOptions
      ..add(DraftPollOption())
      ..add(DraftPollOption());
  }

  PostDraft _draft;
  bool _isPublishing = false;
  final List<XFile> _mediaItems = [];

  PostDraft get draft => _draft;
  bool get isPublishing => _isPublishing;
  List<XFile> get mediaItems => List.unmodifiable(_mediaItems);
  int get mediaCount => _mediaItems.length;

  // ---------------------------------------------------------------------------
  // Tipo de conteúdo
  // ---------------------------------------------------------------------------

  void selectType(ContentType type) {
    if (_draft.type == type) return;
    _draft = PostDraft(type: type);
    _mediaItems.clear();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Campos de texto
  // ---------------------------------------------------------------------------

  void setTitle(String v) {
    _draft.title = v;
    notifyListeners();
  }

  void setBody(String v) {
    _draft.body = v;
    notifyListeners();
  }

  void setVisibility(DraftVisibility v) {
    _draft.visibility = v;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Mídia real
  // ---------------------------------------------------------------------------

  void addMediaItems(List<XFile> files) {
    _mediaItems.addAll(files);
    _draft.mediaCount = _mediaItems.length;
    notifyListeners();
  }

  void removeMediaAt(int index) {
    if (index < 0 || index >= _mediaItems.length) return;
    _mediaItems.removeAt(index);
    _draft.mediaCount = _mediaItems.length;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Opções de enquete
  // ---------------------------------------------------------------------------

  void addPollOption() {
    _draft.pollOptions.add(DraftPollOption());
    notifyListeners();
  }

  void removePollOption(int index) {
    if (index < 0 || index >= _draft.pollOptions.length) return;
    _draft.pollOptions.removeAt(index);
    notifyListeners();
  }

  void setPollOptionText(int index, String text) {
    if (index < 0 || index >= _draft.pollOptions.length) return;
    _draft.pollOptions[index].text = text;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Campos de evento
  // ---------------------------------------------------------------------------

  void setEventDate(String? v) {
    _draft.eventDate = v;
    notifyListeners();
  }

  void setSubtitle(String v) {
    _draft.subtitle = v;
    notifyListeners();
  }

  void setLocation(String v) {
    _draft.location = v;
    notifyListeners();
  }

  void setPollDurationDays(int d) {
    _draft.pollDurationDays = d;
    notifyListeners();
  }

  void setEventEndDate(String? v) {
    _draft.eventEndDate = v;
    notifyListeners();
  }

  void setEventTime(String? v) {
    _draft.eventTime = v;
    notifyListeners();
  }

  void setEventIsOnline(bool v) {
    _draft.eventIsOnline = v;
    notifyListeners();
  }

  void setLiveCategory(String v) {
    _draft.liveCategory = v;
    notifyListeners();
  }

  void setIsLiveNow(bool v) {
    _draft.isLiveNow = v;
    notifyListeners();
  }

  void setLiveScheduledDate(String? v) {
    _draft.liveScheduledDate = v;
    notifyListeners();
  }

  void setAudioDuration(Duration d) {
    _draft.audioDuration = d;
    notifyListeners();
  }

  void setEventLocation(String? v) {
    _draft.eventLocation = v;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Publicação
  // ---------------------------------------------------------------------------

  /// Simula o envio do rascunho (sem backend real).
  ///
  /// Retorna o [Post] construído a partir do rascunho em caso de sucesso,
  /// ou `null` se a publicação falhar ou o provider já tiver sido descartado.
  Future<Post?> publish() async {
    if (!_draft.hasContent || _isPublishing) return null;

    _isPublishing = true;
    notifyListeners();

    // Simula latência de rede.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!hasListeners) return null;
    _isPublishing = false;
    notifyListeners();

    final post = _buildPostFromDraft(_draft);
    reset();
    return post;
  }

  /// Converte o [PostDraft] atual em um [Post] local para exibição imediata
  /// no feed enquanto a confirmação do servidor não chega.
  Post _buildPostFromDraft(PostDraft draft) {
    // ID único baseado em timestamp — suficiente para o feed local.
    final id = 'local-${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();

    // Mapeia ContentType para feeds que devem receber o post.
    final feeds = switch (draft.type) {
      ContentType.story => <String>[],
      ContentType.video => ['/discover', '/friends', '/appbar-videos'],
      ContentType.photo => ['/discover', '/friends', '/photos'],
      ContentType.event => ['/discover', '/friends', '/events'],
      _ => ['/discover', '/friends'],
    };

    // Monta o conteúdo textual principal.
    final body = draft.body.trim();
    final segments = body.isNotEmpty
        ? [PostTextSegment(text: body)]
        : [PostTextSegment(text: '')];

    // Monta mídia de áudio local se houver duração gravada.
    final media = <PostMedia>[];
    if (draft.type == ContentType.audio && draft.audioDuration > Duration.zero) {
      media.add(PostMedia(
        id: '$id-audio',
        type: PostMediaType.audio,
        sourceUrl: '',
        duration: draft.audioDuration,
        waveform: const <double>[0.5, 0.8, 0.6, 0.9, 0.4, 0.7, 0.5, 0.8],
      ));
    }

    // Converte XFiles em PostMedia para foto/vídeo/story.
    if (draft.type != ContentType.audio) {
      for (var i = 0; i < _mediaItems.length; i++) {
        final file = _mediaItems[i];
        final isVideo = file.mimeType?.startsWith('video/') == true ||
            file.path.toLowerCase().endsWith('.mp4') ||
            file.path.toLowerCase().endsWith('.mov');
        media.add(PostMedia(
          id: '$id-media-$i',
          type: isVideo ? PostMediaType.video : PostMediaType.image,
          sourceUrl: file.path,
          mimeType: file.mimeType,
        ));
      }
    }

    return Post(
      id: id,
      // Usa um partyRoleId sentinela — a tela de feed resolve o autor atual
      // via FriendsProvider se não encontrar no cache.
      authorPartyRoleId: kLocalAuthorRoleId,
      content: PostContent(segments: segments),
      title: draft.hasTitle && draft.title.trim().isNotEmpty
          ? draft.title.trim()
          : null,
      media: media,
      feeds: feeds,
      status: PostStatus.published,
      createdAt: now,
      // Story expira em 24 horas.
      expiresAt: draft.type == ContentType.story
          ? now.add(const Duration(hours: 24))
          : null,
    );
  }

  /// ID sentinela usado como `authorPartyRoleId` para posts locais.
  /// O [PostsProvider.authorFor] retorna `null` para IDs desconhecidos e a UI
  /// usa [AppStrings.unknownPostAuthor] como fallback.
  static const String kLocalAuthorRoleId = 'local-current-user';

  void reset() {
    _draft = PostDraft();
    _mediaItems.clear();
    _draft.pollOptions
      ..add(DraftPollOption())
      ..add(DraftPollOption());
    notifyListeners();
  }
}
