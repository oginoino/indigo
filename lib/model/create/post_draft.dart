import 'content_type.dart';

/// Modelo mutável de rascunho de publicação.
///
/// Mantido pelo [CreatePostProvider] durante a sessão de edição. Não é
/// persistido — ao fechar o editor, o rascunho é descartado.
class PostDraft {
  PostDraft({
    this.type = ContentType.post,
    this.title = '',
    this.body = '',
    List<DraftPollOption> pollOptions = const [],
    this.eventDate,
    this.eventLocation,
    this.audioDuration = Duration.zero,
  }) : pollOptions = List<DraftPollOption>.of(pollOptions);

  ContentType type;
  String title;
  String body;
  List<DraftPollOption> pollOptions;
  String? eventDate;
  String? eventLocation;
  Duration audioDuration;

  /// Número de itens de mídia adicionados (simulado — sem upload real).
  int mediaCount = 0;

  /// Visibilidade selecionada (simplificado: público ou somente amigos).
  DraftVisibility visibility = DraftVisibility.public;

  bool get hasContent {
    return switch (type) {
      ContentType.post || ContentType.story => body.trim().isNotEmpty,
      ContentType.article =>
        title.trim().isNotEmpty || body.trim().isNotEmpty,
      ContentType.photo || ContentType.video =>
        mediaCount > 0 || body.trim().isNotEmpty,
      ContentType.audio =>
        audioDuration.inSeconds > 0 || mediaCount > 0,
      ContentType.poll =>
        body.trim().isNotEmpty &&
            pollOptions.where((o) => o.text.trim().isNotEmpty).length >= 2,
      ContentType.event => title.trim().isNotEmpty,
      ContentType.live => title.trim().isNotEmpty,
    };
  }

  bool get requiresMedia =>
      type == ContentType.photo ||
      type == ContentType.video ||
      type == ContentType.audio;

  bool get hasTitle =>
      type == ContentType.article ||
      type == ContentType.event ||
      type == ContentType.live;

  bool get hasPollOptions => type == ContentType.poll;

  bool get hasEventFields => type == ContentType.event;
}

class DraftPollOption {
  DraftPollOption({this.text = ''});
  String text;
}

enum DraftVisibility { public, friendsOnly }
