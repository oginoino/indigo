import 'package:material_ui/material_ui.dart';

import '../../model/create/content_type.dart';
import '../../model/create/post_draft.dart';

/// Estado da sessão de criação de conteúdo.
///
/// Gerencia o rascunho ativo e coordena as transições entre etapas do editor.
/// É descartado ao fechar a tela de criação.
class CreatePostProvider extends ChangeNotifier {
  CreatePostProvider() : _draft = PostDraft();

  PostDraft _draft;
  bool _isPublishing = false;

  PostDraft get draft => _draft;
  bool get isPublishing => _isPublishing;

  // ---------------------------------------------------------------------------
  // Tipo de conteúdo
  // ---------------------------------------------------------------------------

  void selectType(ContentType type) {
    if (_draft.type == type) return;
    _draft = PostDraft(type: type);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Campos de texto
  // ---------------------------------------------------------------------------

  void setTitle(String value) {
    _draft.title = value;
    notifyListeners();
  }

  void setBody(String value) {
    _draft.body = value;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Visibilidade
  // ---------------------------------------------------------------------------

  void setVisibility(DraftVisibility visibility) {
    _draft.visibility = visibility;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Mídia (simulado)
  // ---------------------------------------------------------------------------

  void addMedia() {
    _draft.mediaCount++;
    notifyListeners();
  }

  void removeMedia() {
    if (_draft.mediaCount <= 0) return;
    _draft.mediaCount--;
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

  void setEventDate(String? value) {
    _draft.eventDate = value;
    notifyListeners();
  }

  void setEventLocation(String? value) {
    _draft.eventLocation = value;
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

    // Reseta para novo rascunho após publicação.
    reset();
    return true;
  }

  void reset() {
    _draft = PostDraft();
    notifyListeners();
  }
}
