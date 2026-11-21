import 'package:camera/camera.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../provider/create/create_post_provider.dart';
import '../../../service/media_picker_service.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';

/// Chama o sheet de mídia em modal bottom.
/// Retorna quando o usuário fecha (seleciona ou cancela).
Future<void> showMediaPickerSheet(
  BuildContext context, {
  bool allowVideo = true,
  int maxItems = 10,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<CreatePostProvider>(),
      child: _MediaPickerSheet(allowVideo: allowVideo, maxItems: maxItems),
    ),
  );
}

class _MediaPickerSheet extends StatefulWidget {
  const _MediaPickerSheet({required this.allowVideo, required this.maxItems});
  final bool allowVideo;
  final int maxItems;

  @override
  State<_MediaPickerSheet> createState() => _MediaPickerSheetState();
}

class _MediaPickerSheetState extends State<_MediaPickerSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);
  final _pickerService = MediaPickerService();

  // Camera state
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _cameraReady = false;
  final bool _isRecording = false;
  int _cameraIndex = 0;
  FlashMode _flashMode = FlashMode.auto;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;
      await _startCamera(_cameras[_cameraIndex]);
    } catch (_) {
      // Câmera indisponível (simulador ou permissão negada)
    }
  }

  Future<void> _startCamera(CameraDescription camera) async {
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );
    try {
      await controller.initialize();
      await controller.setFlashMode(_flashMode);
      if (!mounted) return;
      await _cameraController?.dispose();
      setState(() {
        _cameraController = controller;
        _cameraReady = true;
      });
    } catch (_) {
      await controller.dispose();
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    setState(() => _cameraReady = false);
    await _startCamera(_cameras[_cameraIndex]);
  }

  Future<void> _cycleFlash() async {
    final next = switch (_flashMode) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.always,
      _ => FlashMode.off,
    };
    _flashMode = next;
    await _cameraController?.setFlashMode(next);
    setState(() {});
  }

  Future<void> _capturePhoto() async {
    if (!_cameraReady || _cameraController == null) return;
    try {
      final file = await _cameraController!.takePicture();
      if (!mounted) return;
      context.read<CreatePostProvider>().addMediaItems([file]);
      Navigator.of(context).pop();
    } catch (_) {}
  }

  Future<void> _pickFromGallery() async {
    final provider = context.read<CreatePostProvider>();
    final remaining = widget.maxItems - provider.mediaCount;
    if (remaining <= 0) {
      _showMaxSnack();
      return;
    }
    final files = widget.allowVideo
        ? await _pickerService.pickMedia(maxItems: remaining)
        : await _pickerService.pickPhotos(maxItems: remaining);
    if (!mounted) return;
    if (files.isNotEmpty) {
      provider.addMediaItems(files);
      Navigator.of(context).pop();
    }
  }

  void _showMaxSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.mediaPickerMaxSelection.replaceAll(
            '{max}',
            '${widget.maxItems}',
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _tab.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: UIConstants.mediaPickerSheetInitialFraction,
      minChildSize: UIConstants.mediaPickerSheetMinFraction,
      maxChildSize: UIConstants.mediaPickerSheetMaxFraction,
      expand: false,
      snap: true,
      snapSizes: const [
        UIConstants.mediaPickerSheetInitialFraction,
        UIConstants.mediaPickerSheetMaxFraction,
      ],
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(UIConstants.radiusLg),
        ),
        child: Scaffold(
          backgroundColor: colors.surface,
          body: Column(
            children: [
              // ── Drag handle ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: UIConstants.spaceSm,
                ),
                child: Center(
                  child: Container(
                    width: UIConstants.mediaPickerDragHandleWidth,
                    height: UIConstants.mediaPickerDragHandleHeight,
                    decoration: BoxDecoration(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(
                        UIConstants.mediaPickerDragHandleRadius,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Tab bar ──
              TabBar(
                controller: _tab,
                tabs: const [
                  Tab(text: AppStrings.mediaPickerCamera),
                  Tab(text: AppStrings.mediaPickerGallery),
                ],
              ),

              // ── Tab views ──
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _CameraTab(
                      cameraController: _cameraController,
                      cameraReady: _cameraReady,
                      isRecording: _isRecording,
                      flashMode: _flashMode,
                      hasMultipleCameras: _cameras.length > 1,
                      onCapture: _capturePhoto,
                      onFlip: _flipCamera,
                      onFlash: _cycleFlash,
                    ),
                    _GalleryTab(onPick: _pickFromGallery),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Aba Câmera
// ---------------------------------------------------------------------------

class _CameraTab extends StatelessWidget {
  const _CameraTab({
    required this.cameraController,
    required this.cameraReady,
    required this.isRecording,
    required this.flashMode,
    required this.hasMultipleCameras,
    required this.onCapture,
    required this.onFlip,
    required this.onFlash,
  });

  final CameraController? cameraController;
  final bool cameraReady;
  final bool isRecording;
  final FlashMode flashMode;
  final bool hasMultipleCameras;
  final VoidCallback onCapture;
  final VoidCallback onFlip;
  final VoidCallback onFlash;

  IconData get _flashIcon => switch (flashMode) {
    FlashMode.always => Icons.flash_on_rounded,
    FlashMode.off => Icons.flash_off_rounded,
    _ => Icons.flash_auto_rounded,
  };

  String get _flashTooltip => switch (flashMode) {
    FlashMode.always => AppStrings.mediaPickerFlashOn,
    FlashMode.off => AppStrings.mediaPickerFlashOff,
    _ => AppStrings.mediaPickerFlashAuto,
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Preview
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (cameraReady && cameraController != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                  child: CameraPreview(cameraController!),
                )
              else
                ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      AppStrings.mediaPickerCameraError,
                      style: TextStyle(color: colors.onInverseSurface),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              // Flash + flip buttons
              Positioned(
                top: UIConstants.spaceSm,
                right: UIConstants.spaceSm,
                child: Column(
                  children: [
                    _OverlayIconButton(
                      icon: _flashIcon,
                      tooltip: _flashTooltip,
                      onTap: onFlash,
                    ),
                    if (hasMultipleCameras) ...[
                      const SizedBox(height: UIConstants.spaceSm),
                      _OverlayIconButton(
                        icon: Icons.flip_camera_ios_rounded,
                        tooltip: AppStrings.mediaPickerFlipCamera,
                        onTap: onFlip,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        // Shutter
        Padding(
          padding: const EdgeInsets.symmetric(vertical: UIConstants.spaceLg),
          child: GestureDetector(
            onTap: onCapture,
            child: Container(
              width: UIConstants.mediaPickerCameraButtonSize,
              height: UIConstants.mediaPickerCameraButtonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.onSurface,
                  width: UIConstants.mediaPickerSelectionBorderWidth,
                ),
              ),
              child: Center(
                child: Container(
                  width: UIConstants.mediaPickerCameraButtonInner,
                  height: UIConstants.mediaPickerCameraButtonInner,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Aba Galeria
// ---------------------------------------------------------------------------

class _GalleryTab extends StatelessWidget {
  const _GalleryTab({required this.onPick});

  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.photo_library_outlined,
          size: 64,
          color: colors.onSurfaceVariant,
        ),
        const SizedBox(height: UIConstants.spaceMd),
        Text(
          AppStrings.mediaPickerGallery,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: UIConstants.spaceXs),
        Text(
          AppStrings.mediaPickerGalleryHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: UIConstants.spaceLg),
        FilledButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.photo_library_rounded),
          label: const Text(AppStrings.mediaPickerDone),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Botão overlay para controles da câmera
// ---------------------------------------------------------------------------

class _OverlayIconButton extends StatelessWidget {
  const _OverlayIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: UIConstants.minimumInteractiveTargetSize,
          height: UIConstants.minimumInteractiveTargetSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.5),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: UIConstants.composerAttachIconSize,
          ),
        ),
      ),
    );
  }
}
