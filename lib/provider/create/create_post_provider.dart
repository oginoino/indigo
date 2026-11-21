import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../model/create/content_type.dart';
import '../../model/create/post_draft.dart';

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

  void removePollOption(int i) {
    if (i < 0 || i >= _draft.pollOptions.length) return;
    _draft.pollOptions.removeAt(i);
    notifyListeners();
  }

  void setPollOptionText(int i, String text) {
    if (i < 0 || i >= _draft.pollOptions.length) return;
    _draft.pollOptions[i].text = text;
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
  Future<bool> publish() async {
    if (!_draft.hasContent || _isPublishing) return false;

    _isPublishing = true;
    notifyListeners();

    // Simula latência de rede.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    _isPublishing = false;
    notifyListeners();

    reset();
    return true;
  }

  void reset() {
    _draft = PostDraft();
    _mediaItems.clear();
    _draft.pollOptions
      ..add(DraftPollOption())
      ..add(DraftPollOption());
    notifyListeners();
  }
}
