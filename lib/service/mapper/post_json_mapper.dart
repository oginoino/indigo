import '../../model/post/post.dart';
import '../../model/post/post_content.dart';
import '../../model/post/post_engagement_summary.dart';
import '../../model/post/post_interaction.dart';
import '../../model/post/post_location.dart';
import '../../model/post/post_media.dart';
import '../../model/post/post_relationship.dart';
import '../../model/post/post_sticker.dart';
import '../../model/post/post_tag.dart';
import '../../util/const/app/app_strings.dart';
import '../social_data_service.dart';

class PostJsonMapper {
  const PostJsonMapper._();

  static const _idKey = 'id';
  static const _authorPartyRoleIdKey = 'author_party_role_id';
  static const _contentKey = 'content';
  static const _segmentsKey = 'segments';
  static const _textKey = 'text';
  static const _stylesKey = 'styles';
  static const _entityKey = 'entity';
  static const _entityTypeKey = 'type';
  static const _valueKey = 'value';
  static const _titleKey = 'title';
  static const _themeIdKey = 'theme_id';
  static const _locationKey = 'location';
  static const _placeIdKey = 'place_id';
  static const _nameKey = 'name';
  static const _localityKey = 'locality';
  static const _regionKey = 'region';
  static const _countryCodeKey = 'country_code';
  static const _precisionKey = 'precision';
  static const _coordinatesKey = 'coordinates';
  static const _latitudeKey = 'latitude';
  static const _longitudeKey = 'longitude';
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
  static const _tagsKey = 'tags';
  static const _feedsKey = 'feeds';
  static const _labelKey = 'label';
  static const _stickersKey = 'stickers';
  static const _positionKey = 'position';
  static const _xKey = 'x';
  static const _yKey = 'y';
  static const _scaleKey = 'scale';
  static const _rotationDegreesKey = 'rotation_degrees';
  static const _layerOrderKey = 'layer_order';
  static const _targetMediaIdKey = 'target_media_id';
  static const _payloadKey = 'payload';
  static const _assetIdKey = 'asset_id';
  static const _partyRoleIdKey = 'party_role_id';
  static const _tagIdKey = 'tag_id';
  static const _engagementKey = 'engagement';
  static const _reactionCountKey = 'reaction_count';
  static const _commentCountKey = 'comment_count';
  static const _saveCountKey = 'save_count';
  static const _shareCountKey = 'share_count';
  static const _viewCountKey = 'view_count';
  static const _viewerKey = 'viewer';
  static const _reactionKey = 'reaction';
  static const _isSavedKey = 'is_saved';
  static const _isSharedKey = 'is_shared';
  static const _relationshipKey = 'relationship';
  static const _targetPostIdKey = 'target_post_id';
  static const _visibilityKey = 'visibility';
  static const _statusKey = 'status';
  static const _createdAtKey = 'created_at';
  static const _updatedAtKey = 'updated_at';
  static const _expiresAtKey = 'expires_at';
  static const _assetStickerType = 'asset';
  static const _textStickerType = 'text';
  static const _locationStickerType = 'location';
  static const _mentionStickerType = 'mention';
  static const _tagStickerType = 'tag';
  static const _objectFieldName = 'object';

  static Post fromJson(JsonObject json) {
    final location = json[_locationKey];
    final relationship = json[_relationshipKey];

    return Post(
      id: _string(json, _idKey),
      authorPartyRoleId: _string(json, _authorPartyRoleIdKey),
      content: _content(_object(json, _contentKey)),
      title: _optionalString(json, _titleKey),
      themeId: _optionalString(json, _themeIdKey),
      location: location == null ? null : _location(_asObject(location)),
      media: _objects(json, _mediaKey).map(_media).toList(growable: false),
      stickers: _objects(
        json,
        _stickersKey,
      ).map(_sticker).toList(growable: false),
      tags: _objects(json, _tagsKey).map(_tag).toList(growable: false),
      feeds: _stringList(json, _feedsKey),
      engagement: _engagement(_object(json, _engagementKey)),
      relationship: relationship == null
          ? null
          : _relationship(_asObject(relationship)),
      visibility: _enumValue(
        PostVisibility.values,
        json[_visibilityKey],
        _visibilityKey,
      ),
      status: _enumValue(PostStatus.values, json[_statusKey], _statusKey),
      createdAt: _dateTime(json, _createdAtKey),
      updatedAt: _optionalDateTime(json, _updatedAtKey),
      expiresAt: _optionalDateTime(json, _expiresAtKey),
    );
  }

  static PostContent _content(JsonObject json) => PostContent(
    segments: _objects(json, _segmentsKey)
        .map((segment) {
          final entity = segment[_entityKey];
          return PostTextSegment(
            text: _string(segment, _textKey),
            styles: _enumSet(
              PostTextStyle.values,
              segment[_stylesKey],
              _stylesKey,
            ),
            entity: entity == null ? null : _textEntity(_asObject(entity)),
          );
        })
        .toList(growable: false),
  );

  static PostTextEntity _textEntity(JsonObject json) => PostTextEntity(
    type: _enumValue(
      PostTextEntityType.values,
      json[_entityTypeKey],
      _entityTypeKey,
    ),
    value: _string(json, _valueKey),
    id: _optionalString(json, _idKey),
  );

  static PostMedia _media(JsonObject json) => PostMedia(
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

  static List<double> _waveform(JsonObject json) {
    final raw = json[_waveformKey];
    if (raw is! List) return const [];
    return [
      for (final value in raw)
        if (value is num) value.toDouble(),
    ];
  }

  static Duration? _duration(JsonObject json) {
    final seconds = _optionalInt(json, _durationSecondsKey);
    return seconds == null ? null : Duration(seconds: seconds);
  }

  static PostTag _tag(JsonObject json) => PostTag(
    id: _string(json, _idKey),
    label: _string(json, _labelKey),
    type: _enumValue(PostTagType.values, json[_entityTypeKey], _entityTypeKey),
  );

  static PostSticker _sticker(JsonObject json) {
    final position = _object(json, _positionKey);
    final payload = _object(json, _payloadKey);

    return PostSticker(
      id: _string(json, _idKey),
      payload: _stickerPayload(payload),
      position: PostStickerPosition(
        x: _number(position, _xKey),
        y: _number(position, _yKey),
        scale:
            _optionalNumber(position, _scaleKey) ??
            PostStickerPosition.defaultScale,
        rotationDegrees:
            _optionalNumber(position, _rotationDegreesKey) ??
            PostStickerPosition.defaultRotationDegrees,
        layerOrder:
            _optionalInt(position, _layerOrderKey) ??
            PostStickerPosition.defaultLayerOrder,
      ),
      targetMediaId: _optionalString(json, _targetMediaIdKey),
    );
  }

  static PostStickerPayload _stickerPayload(JsonObject json) {
    final type = _string(json, _entityTypeKey);
    return switch (type) {
      _assetStickerType => AssetStickerPayload(
        assetId: _string(json, _assetIdKey),
      ),
      _textStickerType => TextStickerPayload(
        content: _content(_object(json, _contentKey)),
      ),
      _locationStickerType => LocationStickerPayload(
        location: _location(_object(json, _locationKey)),
      ),
      _mentionStickerType => MentionStickerPayload(
        partyRoleId: _string(json, _partyRoleIdKey),
      ),
      _tagStickerType => TagStickerPayload(tagId: _string(json, _tagIdKey)),
      _ => throw _invalidField(_payloadKey),
    };
  }

  static PostLocation _location(JsonObject json) {
    final coordinates = json[_coordinatesKey];
    return PostLocation(
      name: _string(json, _nameKey),
      placeId: _optionalString(json, _placeIdKey),
      locality: _optionalString(json, _localityKey),
      region: _optionalString(json, _regionKey),
      countryCode: _optionalString(json, _countryCodeKey),
      precision: _enumValue(
        PostLocationPrecision.values,
        json[_precisionKey],
        _precisionKey,
      ),
      coordinates: coordinates == null
          ? null
          : _coordinates(_asObject(coordinates)),
    );
  }

  static GeoCoordinates _coordinates(JsonObject json) => GeoCoordinates(
    latitude: _number(json, _latitudeKey),
    longitude: _number(json, _longitudeKey),
  );

  static PostEngagementSummary _engagement(JsonObject json) {
    final viewer = _optionalObject(json, _viewerKey);
    return PostEngagementSummary(
      reactionCount:
          _optionalInt(json, _reactionCountKey) ??
          PostEngagementSummary.defaultCount,
      commentCount:
          _optionalInt(json, _commentCountKey) ??
          PostEngagementSummary.defaultCount,
      saveCount:
          _optionalInt(json, _saveCountKey) ??
          PostEngagementSummary.defaultCount,
      shareCount:
          _optionalInt(json, _shareCountKey) ??
          PostEngagementSummary.defaultCount,
      viewCount:
          _optionalInt(json, _viewCountKey) ??
          PostEngagementSummary.defaultCount,
      viewer: viewer == null
          ? const PostViewerEngagement()
          : PostViewerEngagement(
              reaction: _optionalEnumValue(
                PostReactionType.values,
                viewer[_reactionKey],
                _reactionKey,
              ),
              isSaved:
                  viewer[_isSavedKey] as bool? ??
                  PostViewerEngagement.defaultIsSaved,
              isShared:
                  viewer[_isSharedKey] as bool? ??
                  PostViewerEngagement.defaultIsShared,
            ),
    );
  }

  static PostRelationship _relationship(JsonObject json) => PostRelationship(
    type: _enumValue(
      PostRelationshipType.values,
      json[_entityTypeKey],
      _entityTypeKey,
    ),
    targetPostId: _string(json, _targetPostIdKey),
  );

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

  static List<String> _stringList(JsonObject json, String key) {
    final value = json[key];
    if (value == null) return const [];
    if (value is! List) throw _invalidField(key);
    return List.unmodifiable(
      value.map((item) {
        if (item is! String) throw _invalidField(key);
        return item;
      }),
    );
  }

  static int? _optionalInt(JsonObject json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! int) throw _invalidField(key);
    return value;
  }

  static double _number(JsonObject json, String key) {
    final value = json[key];
    if (value is! num) throw _invalidField(key);
    return value.toDouble();
  }

  static double? _optionalNumber(JsonObject json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! num) throw _invalidField(key);
    return value.toDouble();
  }

  static DateTime _dateTime(JsonObject json, String key) {
    final value = _string(json, key);
    return DateTime.tryParse(value) ?? (throw _invalidField(key));
  }

  static DateTime? _optionalDateTime(JsonObject json, String key) {
    final value = _optionalString(json, key);
    if (value == null) return null;
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
  ) => rawValue == null ? null : _enumValue(values, rawValue, key);

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
    AppStrings.invalidSocialPostField.replaceAll('{field}', field),
  );
}
