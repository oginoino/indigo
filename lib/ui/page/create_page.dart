import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../model/create/content_type.dart';
import '../../provider/create/create_post_provider.dart';
import '../../service/media_picker_service.dart';
import '../../util/const/app/app_strings.dart';
import '../../util/const/ui/ui_constants.dart';
import '../components/create/create_post_editor.dart';

/// Tela de criação de conteúdo — UX em duas fases estilo Instagram/TikTok.
///
/// **Fase 1 — Câmera fullscreen**: câmera em tela cheia com chips de tipo,
/// botão galeria e shutter. Para tipos sem mídia vai direto à fase 2.
///
/// **Fase 2 — Editor**: compositor estilo Twitter/Instagram com AppBar,
/// strip de mídia e campos adaptados ao tipo escolhido.
class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreatePostProvider(),
      child: const _CreatePageContent(),
    );
  }
}

// ---------------------------------------------------------------------------
// Conteúdo interno (stateful para controlar fases e câmera)
// ---------------------------------------------------------------------------

enum _Phase { camera, editor }

class _CreatePageContent extends StatefulWidget {
  const _CreatePageContent();

  @override
  State<_CreatePageContent> createState() => _CreatePageContentState();
}

class _CreatePageContentState extends State<_CreatePageContent>
    with SingleTickerProviderStateMixin {
  _Phase _phase = _Phase.camera;

  // Camera
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _cameraReady = false;
  int _cameraIndex = 0;
  FlashMode _flashMode = FlashMode.auto;

  // Editor slide animation
  late final AnimationController _slideController = AnimationController(
    vsync: this,
    duration: UIConstants.bottomNavigationAnimationDuration,
  );
  late final Animation<Offset> _slideAnimation = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

  final _pickerService = MediaPickerService();

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
      // Câmera indisponível (simulador ou permissão negada).
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

  void _selectType(ContentType type) {
    final provider = context.read<CreatePostProvider>();
    provider.selectType(type);

    // Tipos sem mídia vão direto ao editor.
    final noCamera = type == ContentType.post ||
        type == ContentType.article ||
        type == ContentType.poll ||
        type == ContentType.event ||
        type == ContentType.live;

    if (noCamera) {
      _goToEditor();
    }
    // Para foto/vídeo/áudio/story permanece na câmera.
  }

  void _goToEditor() {
    setState(() => _phase = _Phase.editor);
    _slideController.forward(from: 0);
  }

  Future<void> _goBackToCamera(CreatePostProvider provider) async {
    if (provider.draft.hasContent || provider.mediaItems.isNotEmpty) {
      final discard = await _confirmDiscard();
      if (!discard) return;
    }
    provider.reset();
    _slideController.reverse();
    setState(() => _phase = _Phase.camera);
  }

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.createEditorDiscard),
        content: const Text(AppStrings.createEditorDiscardConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.createEditorDiscardConfirmNo),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(AppStrings.createEditorDiscardConfirmYes),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _capturePhoto() async {
    if (!_cameraReady || _cameraController == null) return;
    try {
      final file = await _cameraController!.takePicture();
      if (!mounted) return;
      context.read<CreatePostProvider>().addMediaItems([file]);
      _goToEditor();
    } catch (_) {}
  }

  Future<void> _pickFromGallery() async {
    final provider = context.read<CreatePostProvider>();
    final type = provider.draft.type;
    final allowVideo = type == ContentType.video;
    final files = allowVideo
        ? await _pickerService.pickMedia()
        : await _pickerService.pickPhotos();
    if (!mounted) return;
    if (files.isNotEmpty) {
      provider.addMediaItems(files);
      _goToEditor();
    }
  }

  void _onPublished() {
    _slideController.reverse();
    setState(() => _phase = _Phase.camera);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreatePostProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // ── Fase 1: câmera fullscreen ──────────────────────────────
              _CameraPhase(
                cameraController: _cameraController,
                cameraReady: _cameraReady,
                flashMode: _flashMode,
                hasMultipleCameras: _cameras.length > 1,
                selectedType: provider.draft.type,
                onTypeSelect: _selectType,
                onCapture: _capturePhoto,
                onGallery: _pickFromGallery,
                onFlip: _flipCamera,
                onFlash: _cycleFlash,
                onClose: () => Navigator.of(context).maybePop(),
              ),

              // ── Fase 2: editor deslizante ──────────────────────────────
              if (_phase == _Phase.editor)
                SlideTransition(
                  position: _slideAnimation,
                  child: _EditorPhase(
                    provider: provider,
                    onBack: () => _goBackToCamera(provider),
                    onPublished: _onPublished,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Fase 1 — câmera fullscreen
// ---------------------------------------------------------------------------

class _CameraPhase extends StatelessWidget {
  const _CameraPhase({
    required this.cameraController,
    required this.cameraReady,
    required this.flashMode,
    required this.hasMultipleCameras,
    required this.selectedType,
    required this.onTypeSelect,
    required this.onCapture,
    required this.onGallery,
    required this.onFlip,
    required this.onFlash,
    required this.onClose,
  });

  final CameraController? cameraController;
  final bool cameraReady;
  final FlashMode flashMode;
  final bool hasMultipleCameras;
  final ContentType selectedType;
  final ValueChanged<ContentType> onTypeSelect;
  final VoidCallback onCapture;
  final VoidCallback onGallery;
  final VoidCallback onFlip;
  final VoidCallback onFlash;
  final VoidCallback onClose;

  IconData get _flashIcon => switch (flashMode) {
    FlashMode.always => Icons.flash_on_rounded,
    FlashMode.off => Icons.flash_off_rounded,
    _ => Icons.flash_auto_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview (or black background)
        if (cameraReady && cameraController != null)
          CameraPreview(cameraController!)
        else
          const ColoredBox(color: Colors.black),

        // ── Top bar ────────────────────────────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.spaceSm,
                vertical: UIConstants.spaceXs,
              ),
              child: Row(
                children: [
                  // X close
                  _CameraIconButton(
                    icon: Icons.close_rounded,
                    onTap: onClose,
                    tooltip: AppStrings.mediaPickerCancel,
                  ),
                  const Spacer(),
                  // Flash
                  _CameraIconButton(
                    icon: _flashIcon,
                    onTap: onFlash,
                    tooltip: switch (flashMode) {
                      FlashMode.always => AppStrings.mediaPickerFlashOn,
                      FlashMode.off => AppStrings.mediaPickerFlashOff,
                      _ => AppStrings.mediaPickerFlashAuto,
                    },
                  ),
                  if (hasMultipleCameras) ...[
                    const SizedBox(width: UIConstants.spaceSm),
                    // Flip
                    _CameraIconButton(
                      icon: Icons.flip_camera_ios_rounded,
                      onTap: onFlip,
                      tooltip: AppStrings.mediaPickerFlipCamera,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // ── Type chips (horizontal scroll, below top bar) ───────────────
        Positioned(
          top: UIConstants.minimumInteractiveTargetSize +
              UIConstants.spaceMd +
              MediaQuery.of(context).padding.top,
          left: 0,
          right: 0,
          child: SizedBox(
            height: UIConstants.composerTypeChipHeight + UIConstants.spaceSm,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.spaceSm,
              ),
              children: [
                for (final type in ContentType.values)
                  Padding(
                    padding: const EdgeInsets.only(right: UIConstants.spaceXs),
                    child: _TypeChip(
                      type: type,
                      selected: selectedType == type,
                      onTap: () => onTypeSelect(type),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ── Bottom controls ─────────────────────────────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: UIConstants.spaceXl,
                left: UIConstants.spaceLg,
                right: UIConstants.spaceLg,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Gallery button
                  _CameraIconButton(
                    icon: Icons.photo_library_rounded,
                    onTap: onGallery,
                    tooltip: AppStrings.mediaPickerGallery,
                    size: UIConstants.composerAvatarSize,
                  ),

                  // Shutter
                  Semantics(
                    button: true,
                    label: AppStrings.mediaPickerTakePhoto,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        onCapture();
                      },
                      child: Container(
                      width: UIConstants.mediaPickerCameraButtonSize,
                      height: UIConstants.mediaPickerCameraButtonSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
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

                  // Spacer (balances gallery button)
                  SizedBox(width: UIConstants.composerAvatarSize),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Chip de tipo de conteúdo (câmera)
// ---------------------------------------------------------------------------

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final ContentType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: UIConstants.composerTypeChipHeight,
        padding: const EdgeInsets.symmetric(horizontal: UIConstants.spaceMd),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(UIConstants.composerTypeChipRadius),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            type.label,
            style: TextStyle(
              color: selected ? Colors.black : Colors.white,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Botão de ícone overlay (câmera)
// ---------------------------------------------------------------------------

class _CameraIconButton extends StatelessWidget {
  const _CameraIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.size = UIConstants.minimumInteractiveTargetSize,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.45),
          ),
          child: Icon(icon, color: Colors.white, size: UIConstants.composerAttachIconSize),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fase 2 — Editor (slide up como bottom sheet)
// ---------------------------------------------------------------------------

class _EditorPhase extends StatelessWidget {
  const _EditorPhase({
    required this.provider,
    required this.onBack,
    required this.onPublished,
  });

  final CreatePostProvider provider;
  final VoidCallback onBack;
  final VoidCallback onPublished;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: AppStrings.createEditorDiscard,
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: onBack,
          ),
        title: Text(
          provider.draft.type.label,
          style: theme.textTheme.titleMedium,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: UIConstants.spaceSm),
            child: _PublishButton(provider: provider, onPublished: onPublished),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 0.5,
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
        body: const CreatePostEditor(),
        bottomNavigationBar: _PublishToolbar(provider: provider),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Botão Publicar (AppBar)
// ---------------------------------------------------------------------------

class _PublishButton extends StatelessWidget {
  const _PublishButton({
    required this.provider,
    required this.onPublished,
  });

  final CreatePostProvider provider;
  final VoidCallback onPublished;

  @override
  Widget build(BuildContext context) {
    final canPublish = provider.draft.hasContent && !provider.isPublishing;

    return AnimatedSwitcher(
      duration: UIConstants.engagementColorDuration,
      child: provider.isPublishing
          ? const SizedBox(
              key: ValueKey('loading'),
              width: UIConstants.createEditorAvatarSize,
              height: UIConstants.createEditorAvatarSize,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : FilledButton(
              key: const ValueKey('publish'),
              onPressed: canPublish ? () => _publish(context) : null,
              child: const Text(AppStrings.createEditorPublish),
            ),
    );
  }

  Future<void> _publish(BuildContext context) async {
    final success = await provider.publish();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? AppStrings.createPublishSuccess
              : AppStrings.createPublishFailed,
        ),
        behavior: SnackBarBehavior.floating,
        duration: UIConstants.createPublishFeedback,
      ),
    );

    if (success) onPublished();
  }
}

// ---------------------------------------------------------------------------
// Toolbar inferior (editor)
// ---------------------------------------------------------------------------

class _PublishToolbar extends StatelessWidget {
  const _PublishToolbar({required this.provider});

  final CreatePostProvider provider;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final type = provider.draft.type;

    final actions = <_ToolbarAction>[
      if (type == ContentType.poll)
        _ToolbarAction(
          icon: Icons.add_circle_outline,
          tooltip: AppStrings.createEditorAddPollOption,
          onTap: provider.addPollOption,
        ),
      _ToolbarAction(
        icon: type.icon,
        tooltip: type.label,
        onTap: null,
        isLabel: true,
      ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: UIConstants.createEditorToolbarHeight,
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            for (final action in actions)
              if (action.isLabel)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.spaceSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(action.icon, size: 18, color: colors.onSurfaceVariant),
                      const SizedBox(width: UIConstants.space2xs),
                      Text(
                        action.tooltip,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              else
                IconButton(
                  tooltip: action.tooltip,
                  icon: Icon(action.icon),
                  onPressed: action.onTap,
                ),
            const Spacer(),
            if (type == ContentType.post || type == ContentType.story)
              Padding(
                padding: const EdgeInsets.only(right: UIConstants.spaceMd),
                child: _CharCounter(body: provider.draft.body),
              ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarAction {
  const _ToolbarAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isLabel = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool isLabel;
}

// ---------------------------------------------------------------------------
// Contador de caracteres
// ---------------------------------------------------------------------------

class _CharCounter extends StatelessWidget {
  const _CharCounter({required this.body});

  final String body;


  @override
  Widget build(BuildContext context) {
    final count = body.length;
    final colors = Theme.of(context).colorScheme;

    final color = switch (count) {
      > UIConstants.postBodyHardLimit => colors.error,
      > UIConstants.postBodySoftLimit => colors.tertiary,
      _ => colors.onSurfaceVariant,
    };

    return Text(
      '$count / ${UIConstants.postBodyHardLimit}',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
    );
  }
}
