import '../../model/post/post_comment.dart';
import '../../model/post/post_content.dart';
import '../../model/post/post_engagement_summary.dart';
import '../../model/post/post_interaction.dart';
import '../../model/post/post_media.dart';
import '../../util/const/app/app_strings.dart';
import '../social_data_service.dart';

/// Mapeia o JSON bruto de um comentário para [PostComment].
///
/// Segue o mesmo padrão de [PostJsonMapper]: chaves como constantes privadas,
/// métodos estáticos de parsing com lançamento de [FormatException] tipado.
class CommentJsonMapper {
  const CommentJsonMapper._();

  // ---- JSON keys -------------------------------------------------------------

  static const _idKey = 'id';
  static const _postIdKey = 'post_id';
  static const _parentCommentIdKey = 'parent_comment_id';
  static const _authorPartyRoleIdKey = 'author_party_role_id';
  static const _contentKey = 'content';
  static const _segmentsKey = 'segments';
  static const _textKey = 'text';
  static const _stylesKey = 'styles';
  static const _entityKey = 'entity';
  static const _entityTypeKey = 'type';
  static const _valueKey = 'value';
  static const _mediaKey = 'media';
  static const _mediaTypeKey = 'type';
  static const _sourceUrlKey = 'source_url';
  static const _thumbnailUrlKey = 'thumbnail_url';
  static const _altTextKey = 'alt_text';
  static const _mimeTypeKey = 'mime_type';
  static const _widthKey = 'width';
  static const _heightKey = 'height';
  static const _durationSecondsKey = 'duration_seconds';
  static const _waveformKey = 'waveform';
  static const _engagementKey = 'engagement';
  static const _reactionCountKey = 'reaction_count';
  static const _replyCountKey = 'reply_count';
  static const _viewerReactionKey = 'viewer_reaction';
  static const _createdAtKey = 'created_at';
  static const _objectFieldName = 'object';

  // ---- Public API ------------------------------------------------------------

  static PostComment fromJson(JsonObject json) {
    return PostComment(
      id: _string(json, _idKey),
      postId: _string(json, _postIdKey),
      parentCommentId: _optionalString(json, _parentCommentIdKey),
      authorPartyRoleId: _string(json, _authorPartyRoleIdKey),
      content: _content(_object(json, _contentKey)),
      media: _objects(json, _mediaKey).map(_media).toList(growable: false),
      engagement: _engagement(_object(json, _engagementKey)),
      createdAt: _dateTime(json, _createdAtKey),
    );
  }

  // ---- Private parsers -------------------------------------------------------

  static PostContent _content(JsonObject json) {
    final segments = _objects(json, _segmentsKey)
        .map(_segment)
        .toList(growable: false);
    return PostContent(segments: segments);
  }

  static PostTextSegment _segment(JsonObject json) {
    final entityJson = _optionalObject(json, _entityKey);
    return PostTextSegment(
      text: _string(json, _textKey),
      styles: _enumSet(PostTextStyle.values, json[_stylesKey], _stylesKey),
      entity: entityJson == null ? null : _entity(entityJson),
    );
  }

  static PostTextEntity _entity(JsonObject json) {
    return PostTextEntity(
      type: _enumValue(
        PostTextEntityType.values,
        json[_entityTypeKey],
        _entityTypeKey,
      ),
      value: _string(json, _valueKey),
      id: _optionalString(json, _idKey),
    );
  }

  static PostMedia _media(JsonObject json) {
    return PostMedia(
      id: _string(json, _idKey),
      type: _enumValue(PostMediaType.values, json[_mediaTypeKey], _mediaTypeKey),
      sourceUrl: _string(json, _sourceUrlKey),
      thumbnailUrl: _optionalString(json, _thumbnailUrlKey),
      altText: _optionalString(json, _altTextKey),
      mimeType: _optionalString(json, _mimeTypeKey),
      width: _optionalInt(json, _widthKey),
      height: _optionalInt(json, _heightKey),
      duration: _duration(json),
      waveform: _waveform(json),
    );
  }

  static Duration? _duration(JsonObject json) {
    final seconds = _optionalInt(json, _durationSecondsKey);
    return seconds == null ? null : Duration(seconds: seconds);
  }

  static List<double> _waveform(JsonObject json) {
    final raw = json[_waveformKey];
    if (raw is! List) return const [];
    return [
      for (final value in raw)
        if (value is num) value.toDouble(),
    ];
  }

  static CommentEngagementSummary _engagement(JsonObject json) {
    return CommentEngagementSummary(
      reactionCount: _optionalInt(json, _reactionCountKey) ?? 0,
      replyCount: _optionalInt(json, _replyCountKey) ?? 0,
      viewerReaction: _optionalEnumValue(
        PostReactionType.values,
        json[_viewerReactionKey],
        _viewerReactionKey,
      ),
    );
  }

  // ---- Primitive helpers -----------------------------------------------------

  static JsonObject _object(JsonObject json, String key) {
    final value = json[key];
    if (value is! JsonObject) throw _invalidField(key);
    return value;
  }

  static JsonObject? _optionalObject(JsonObject json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! JsonObject) throw _invalidField(key);
    return value;
  }

  static JsonObject _asObject(Object? value) {
    if (value is! JsonObject) throw _invalidField(_objectFieldName);
    return value;
  }

  static List<JsonObject> _objects(JsonObject json, String key) {
    final value = json[key];
    if (value == null) return const [];
    if (value is! List) throw _invalidField(key);
    return value.map(_asObject).toList(growable: false);
  }

  static String _string(JsonObject json, String key) {
    final value = json[key];
    if (value is! String) throw _invalidField(key);
    return value;
  }

  static String? _optionalString(JsonObject json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String) throw _invalidField(key);
    return value;
  }

  static int? _optionalInt(JsonObject json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! int) throw _invalidField(key);
    return value;
  }

  static DateTime _dateTime(JsonObject json, String key) {
    final value = _string(json, key);
    return DateTime.tryParse(value) ?? (throw _invalidField(key));
  }

  static T _enumValue<T extends Enum>(
    List<T> values,
    Object? rawValue,
    String key,
  ) {
    if (rawValue is String) {
      for (final value in values) {
        if (value.name == rawValue) return value;
      }
    }
    throw _invalidField(key);
  }

  static T? _optionalEnumValue<T extends Enum>(
    List<T> values,
    Object? rawValue,
    String key,
  ) =>
      rawValue == null ? null : _enumValue(values, rawValue, key);

  static Set<T> _enumSet<T extends Enum>(
    List<T> values,
    Object? rawValues,
    String key,
  ) {
    if (rawValues == null) return const {};
    if (rawValues is! List) throw _invalidField(key);
    return Set.unmodifiable(
      rawValues.map((value) => _enumValue(values, value, key)),
    );
  }

  static FormatException _invalidField(String field) => FormatException(
    AppStrings.invalidCommentField.replaceAll('{field}', field),
  );
}
