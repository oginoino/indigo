import 'post_content.dart';
import 'post_location.dart';

enum StickerAssetType { image, gif, emoji }

class StickerAsset {
  const StickerAsset({
    required this.id,
    required this.type,
    required this.assetUri,
    this.accessibilityLabel,
  });

  final String id;
  final StickerAssetType type;
  final String assetUri;
  final String? accessibilityLabel;
}

class PostStickerPosition {
  PostStickerPosition({
    required this.x,
    required this.y,
    this.scale = defaultScale,
    this.rotationDegrees = defaultRotationDegrees,
    this.layerOrder = defaultLayerOrder,
  }) {
    if (!x.isFinite || x < minimumCoordinate || x > maximumCoordinate) {
      throw ArgumentError.value(x, 'x');
    }
    if (!y.isFinite || y < minimumCoordinate || y > maximumCoordinate) {
      throw ArgumentError.value(y, 'y');
    }
    if (!scale.isFinite || scale <= minimumScale) {
      throw ArgumentError.value(scale, 'scale');
    }
    if (!rotationDegrees.isFinite) {
      throw ArgumentError.value(rotationDegrees, 'rotationDegrees');
    }
  }

  static const double minimumCoordinate = 0;
  static const double maximumCoordinate = 1;
  static const double minimumScale = 0;
  static const double defaultScale = 1;
  static const double defaultRotationDegrees = 0;
  static const int defaultLayerOrder = 0;

  final double x;
  final double y;
  final double scale;
  final double rotationDegrees;
  final int layerOrder;
}

sealed class PostStickerPayload {
  const PostStickerPayload();
}

class AssetStickerPayload extends PostStickerPayload {
  const AssetStickerPayload({required this.assetId});

  final String assetId;
}

class TextStickerPayload extends PostStickerPayload {
  const TextStickerPayload({required this.content});

  final PostContent content;
}

class LocationStickerPayload extends PostStickerPayload {
  const LocationStickerPayload({required this.location});

  final PostLocation location;
}

class MentionStickerPayload extends PostStickerPayload {
  const MentionStickerPayload({required this.partyRoleId});

  final String partyRoleId;
}

class TagStickerPayload extends PostStickerPayload {
  const TagStickerPayload({required this.tagId});

  final String tagId;
}

class PostSticker {
  const PostSticker({
    required this.id,
    required this.payload,
    required this.position,
    this.targetMediaId,
  });

  final String id;
  final PostStickerPayload payload;
  final PostStickerPosition position;
  final String? targetMediaId;

  bool get isAttachedToMedia => targetMediaId != null;
}
