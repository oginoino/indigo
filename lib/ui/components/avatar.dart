import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../service/persistence/avatar_image_service.dart';
import '../../util/const/ui/ui_constants.dart';

enum AvatarSize {
  small(UIConstants.avatarSmallSize),
  medium(UIConstants.avatarMediumSize),
  large(UIConstants.avatarLargeSize);

  const AvatarSize(this.diameter);

  final double diameter;
}

class Avatar extends StatefulWidget {
  const Avatar({
    this.size = AvatarSize.medium,
    this.diameter,
    this.imageProvider,
    this.useSavedImage = true,
    this.badge,
    this.badgeAlignment = Alignment.bottomRight,
    this.decoration,
    this.placeholder,
    super.key,
  });

  final AvatarSize size;
  final double? diameter;
  final ImageProvider<Object>? imageProvider;
  final bool useSavedImage;
  final Widget? badge;
  final AlignmentGeometry badgeAlignment;
  final Decoration? decoration;
  final Widget? placeholder;

  double get resolvedDiameter => diameter ?? size.diameter;

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  AvatarImageService? _imageService;
  Future<File?>? _savedImage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.imageProvider != null || !widget.useSavedImage) return;

    final service = context.read<AvatarImageService>();
    if (!identical(service, _imageService)) {
      _imageService = service;
      _savedImage = service.loadImage();
    }
  }

  @override
  void didUpdateWidget(covariant Avatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageProvider == widget.imageProvider &&
        oldWidget.useSavedImage == widget.useSavedImage) {
      return;
    }

    _savedImage = widget.imageProvider == null && widget.useSavedImage
        ? context.read<AvatarImageService>().loadImage()
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decoration =
        widget.decoration ??
        BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          shape: BoxShape.circle,
        );

    return SizedBox.square(
      dimension: widget.resolvedDiameter,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: decoration,
              child: ClipOval(
                child: _buildImage(context, widget.imageProvider),
              ),
            ),
          ),
          if (widget.badge != null)
            Align(alignment: widget.badgeAlignment, child: widget.badge),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context, ImageProvider<Object>? image) {
    if (image != null) return _buildImageView(image);

    return FutureBuilder<File?>(
      future: _savedImage,
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (file == null) return _buildPlaceholder(context);
        return _buildImageView(FileImage(file));
      },
    );
  }

  Widget _buildImageView(ImageProvider<Object> image) {
    return Image(
      image: image,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return widget.placeholder ??
        ColoredBox(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Center(
            child: Icon(
              Icons.person,
              size:
                  widget.resolvedDiameter *
                  UIConstants.avatarPlaceholderIconScale,
            ),
          ),
        );
  }
}
