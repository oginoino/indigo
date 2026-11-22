import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../model/create/content_type.dart';
import '../../provider/create/create_post_provider.dart';
import '../../route/routes.dart';
import '../../service/media_picker_service.dart';
import '../../util/const/app/app_strings.dart';
import '../../util/const/ui/ui_constants.dart';
import '../components/create/create_post_editor.dart';

/// Tela de criação de conteúdo — UX contextual por tipo.
///
/// **Fase 1 — Captura**: UI adaptada ao tipo selecionado via swipe horizontal.
///   - Foto/Story: câmera fullscreen + shutter
///   - Vídeo: câmera + hold-to-record
///   - Áudio: gravador de microfone
///   - Post/Artigo/Enquete/Evento/Live: vai direto ao editor
///
/// **Fase 2 — Editor**: compositor com AppBar, strip de mídia e campos
///   adaptados ao tipo. PopScope protege contra saída acidental.
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
// Enums internos
// ---------------------------------------------------------------------------

enum _Phase { capture, editor }

// ---------------------------------------------------------------------------
// Conteúdo interno (stateful — fases + câmera + pageview)
// ---------------------------------------------------------------------------

class _CreatePageContent extends StatefulWidget {
  const _CreatePageContent();

  @override
  State<_CreatePageContent> createState() => _CreatePageContentState();
}

class _CreatePageContentState extends State<_CreatePageContent>
    with TickerProviderStateMixin {
  _Phase _phase = _Phase.capture;

  // ── Câmera ────────────────────────────────────────────────────────────────
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _cameraReady = false;
  int _cameraIndex = 0;
  FlashMode _flashMode = FlashMode.auto;
  bool _isRecordingVideo = false;

  // ── Áudio ─────────────────────────────────────────────────────────────────
  bool _isRecordingAudio = false;
  Duration _audioDuration = Duration.zero;
  Timer? _audioTimer;

  // ── Type PageView (swipe horizontal) ──────────────────────────────────────
  late final PageController _typePageController = PageController(
    initialPage: ContentType.values.indexOf(ContentType.photo),
    viewportFraction: 1,
  );
  int _typePageIndex = ContentType.values.indexOf(ContentType.photo);

  // ── Editor slide-up ───────────────────────────────────────────────────────
  late final AnimationController _slideController = AnimationController(
    vsync: this,
    duration: UIConstants.bottomNavigationAnimationDuration,
  );
  late final Animation<Offset> _slideAnimation = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
  );

  final _pickerService = MediaPickerService();

  // ── Getters ───────────────────────────────────────────────────────────────

  ContentType get _currentType => ContentType.values[_typePageIndex];

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    unawaited(_initCamera());
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _slideController.dispose();
    _typePageController.dispose();
    _audioTimer?.cancel();
    super.dispose();
  }

  // ── Câmera ────────────────────────────────────────────────────────────────

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty || !mounted) return;
      await _startCamera(_cameras[_cameraIndex]);
    } catch (_) {}
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

  // ── Captura de foto ───────────────────────────────────────────────────────

  Future<void> _capturePhoto() async {
    if (!_cameraReady || _cameraController == null) return;
    HapticFeedback.mediumImpact();
    try {
      final file = await _cameraController!.takePicture();
      if (!mounted) return;
      context.read<CreatePostProvider>().addMediaItems([file]);
      _goToEditor();
    } catch (_) {}
  }

  // ── Gravação de vídeo ────────────────────────────────────────────────────

  Future<void> _startVideoRecording() async {
    if (!_cameraReady || _cameraController == null || _isRecordingVideo) return;
    HapticFeedback.mediumImpact();
    try {
      await _cameraController!.startVideoRecording();
      setState(() => _isRecordingVideo = true);
    } catch (_) {}
  }

  Future<void> _stopVideoRecording() async {
    if (!_cameraReady || _cameraController == null || !_isRecordingVideo) {
      return;
    }
    HapticFeedback.heavyImpact();
    try {
      final file = await _cameraController!.stopVideoRecording();
      if (!mounted) return;
      setState(() => _isRecordingVideo = false);
      context.read<CreatePostProvider>().addMediaItems([file]);
      _goToEditor();
    } catch (_) {
      setState(() => _isRecordingVideo = false);
    }
  }

  // ── Gravação de áudio (simulada — sem package de record) ──────────────────

  void _toggleAudioRecording() {
    HapticFeedback.mediumImpact();
    if (_isRecordingAudio) {
      _stopAudioRecording();
    } else {
      _startAudioRecording();
    }
  }

  void _startAudioRecording() {
    setState(() {
      _isRecordingAudio = true;
      _audioDuration = Duration.zero;
    });
    _audioTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _audioDuration += const Duration(seconds: 1));
    });
  }

  void _stopAudioRecording() {
    _audioTimer?.cancel();
    _audioTimer = null;
    // Áudio simulado: gera XFile fictício com duração registrada
    // (backend real substituirá por arquivo real)
    setState(() => _isRecordingAudio = false);
    // Vai direto ao editor com duração registrada no provider
    context.read<CreatePostProvider>().setAudioDuration(_audioDuration);
    _goToEditor();
  }

  void _resetAudio() {
    _audioTimer?.cancel();
    _audioTimer = null;
    setState(() {
      _isRecordingAudio = false;
      _audioDuration = Duration.zero;
    });
  }

  // ── Galeria ───────────────────────────────────────────────────────────────

  Future<void> _pickFromGallery() async {
    final provider = context.read<CreatePostProvider>();
    final type = provider.draft.type;
    final allowVideo =
        type == ContentType.video || type == ContentType.story;
    final files = allowVideo
        ? await _pickerService.pickMedia()
        : await _pickerService.pickPhotos();
    if (!mounted) return;
    if (files.isNotEmpty) {
      provider.addMediaItems(files);
      _goToEditor();
    }
  }

  // ── Navegação de tipo (PageView) ──────────────────────────────────────────

  void _onTypePageChanged(int index) {
    final type = ContentType.values[index];
    // Atualiza o tipo no provider sem notifyListeners durante o swipe.
    // selectType chama notifyListeners — fazemos via post-frame para não
    // interferir no gesto de scroll do PageView.
    setState(() => _typePageIndex = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CreatePostProvider>().selectType(type);
    });
  }

  void _selectTypeByChip(ContentType type) {
    final index = ContentType.values.indexOf(type);
    _typePageController.animateToPage(
      index,
      duration: UIConstants.createTypeSwipeDuration,
      curve: Curves.easeInOut,
    );
  }

  // ── Fases ─────────────────────────────────────────────────────────────────

  void _goToEditor() {
    setState(() => _phase = _Phase.editor);
    _slideController.forward(from: 0);
  }

  Future<void> _goBackToCapture(CreatePostProvider provider) async {
    if (provider.draft.hasContent || provider.mediaItems.isNotEmpty) {
      final discard = await _confirmDiscard();
      if (!discard) return;
    }
    provider.reset();
    _resetAudio();
    _slideController.reverse();
    setState(() => _phase = _Phase.capture);
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

  // ── Navegação de saída (GoRouter-safe) ───────────────────────────────────

  /// Fecha a página de criação.
  ///
  /// Usa [GoRouter.pop] quando há algo na pilha (ex.: o usuário chegou via
  /// push interno). Caso contrário, navega com [GoRouter.go] para [Routes.home]
  /// porque `/create` é uma rota raiz no GoRouter e não tem nada para fazer
  /// pop — chamar [GoRouter.pop] sem canPop lança [GoError].
  void _closeCreate() {
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.home);
    }
  }

  // ── Publicação ────────────────────────────────────────────────────────────

  void _onPublished() {
    _resetAudio();
    _slideController.reverse();
    setState(() => _phase = _Phase.capture);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<CreatePostProvider>(
      builder: (context, provider, _) {
        // PopScope no nível raiz — intercepta back em ambas as fases
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (_phase == _Phase.editor) {
              await _goBackToCapture(provider);
            } else {
              // Fase capture: sai normalmente (GoRouter)
              _closeCreate();
            }
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              fit: StackFit.expand,
              children: [
                // ── Fase 1: Capture contextual ─────────────────────────
                // Mantém o widget na árvore para preservar estado da câmera,
                // mas não pinta quando o editor estiver visível.
                Visibility(
                  visible: _phase == _Phase.capture,
                  maintainState: true,
                  child: _CapturePhase(
                  typePageController: _typePageController,
                  currentType: _currentType,
                  onTypePageChanged: _onTypePageChanged,
                  onTypeChipTap: _selectTypeByChip,
                  onClose: _closeCreate,
                  // Camera props
                  cameraController: _cameraController,
                  cameraReady: _cameraReady,
                  flashMode: _flashMode,
                  hasMultipleCameras: _cameras.length > 1,
                  isRecordingVideo: _isRecordingVideo,
                  onCapture: _capturePhoto,
                  onStartVideo: _startVideoRecording,
                  onStopVideo: _stopVideoRecording,
                  onFlip: _flipCamera,
                  onFlash: _cycleFlash,
                  onGallery: _pickFromGallery,
                  // Audio props
                  isRecordingAudio: _isRecordingAudio,
                  audioDuration: _audioDuration,
                  onToggleAudio: _toggleAudioRecording,
                  // Text-only types — go to editor directly
                  onDirectToEditor: _goToEditor,
                  ),
                ),

                // ── Fase 2: Editor slide-up ────────────────────────────
                if (_phase == _Phase.editor)
                  SlideTransition(
                    position: _slideAnimation,
                    child: _EditorPhase(
                      provider: provider,
                      onBack: () => _goBackToCapture(provider),
                      onPublished: _onPublished,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ===========================================================================
// FASE 1 — Captura contextual (PageView por tipo)
// ===========================================================================

class _CapturePhase extends StatelessWidget {
  const _CapturePhase({
    required this.typePageController,
    required this.currentType,
    required this.onTypePageChanged,
    required this.onTypeChipTap,
    required this.onClose,
    required this.cameraController,
    required this.cameraReady,
    required this.flashMode,
    required this.hasMultipleCameras,
    required this.isRecordingVideo,
    required this.onCapture,
    required this.onStartVideo,
    required this.onStopVideo,
    required this.onFlip,
    required this.onFlash,
    required this.onGallery,
    required this.isRecordingAudio,
    required this.audioDuration,
    required this.onToggleAudio,
    required this.onDirectToEditor,
  });

  final PageController typePageController;
  final ContentType currentType;
  final ValueChanged<int> onTypePageChanged;
  final ValueChanged<ContentType> onTypeChipTap;
  final VoidCallback onClose;

  // Camera
  final CameraController? cameraController;
  final bool cameraReady;
  final FlashMode flashMode;
  final bool hasMultipleCameras;
  final bool isRecordingVideo;
  final VoidCallback onCapture;
  final VoidCallback onStartVideo;
  final VoidCallback onStopVideo;
  final VoidCallback onFlip;
  final VoidCallback onFlash;
  final VoidCallback onGallery;

  // Audio
  final bool isRecordingAudio;
  final Duration audioDuration;
  final VoidCallback onToggleAudio;

  // Direct-to-editor
  final VoidCallback onDirectToEditor;

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
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── PageView: cada página é a UI de um tipo ────────────────────
        PageView.builder(
          controller: typePageController,
          onPageChanged: onTypePageChanged,
          itemCount: ContentType.values.length,
          itemBuilder: (context, index) {
            final type = ContentType.values[index];
            return _TypeCapturePage(
              type: type,
              cameraController: cameraController,
              cameraReady: cameraReady,
              isRecordingVideo: isRecordingVideo,
              isRecordingAudio: isRecordingAudio,
              audioDuration: audioDuration,
              onCapture: onCapture,
              onStartVideo: onStartVideo,
              onStopVideo: onStopVideo,
              onGallery: onGallery,
              onToggleAudio: onToggleAudio,
              onDirectToEditor: onDirectToEditor,
            );
          },
        ),

        // ── Top bar (sobreposta) ───────────────────────────────────────
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
                  // X para fechar toda a tela
                  _CameraIconButton(
                    icon: Icons.close_rounded,
                    onTap: onClose,
                    tooltip: AppStrings.mediaPickerCancel,
                  ),
                  const Spacer(),
                  // Flash (só para tipos com câmera)
                  if (currentType == ContentType.photo ||
                      currentType == ContentType.video ||
                      currentType == ContentType.story) ...[
                    _CameraIconButton(
                      icon: _flashIcon,
                      onTap: onFlash,
                      tooltip: _flashTooltip,
                    ),
                    if (hasMultipleCameras) ...[
                      const SizedBox(width: UIConstants.spaceSm),
                      _CameraIconButton(
                        icon: Icons.flip_camera_ios_rounded,
                        onTap: onFlip,
                        tooltip: AppStrings.mediaPickerFlipCamera,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),

        // ── Chips de tipo (swipe indicator) ───────────────────────────
        Positioned(
          top: MediaQuery.paddingOf(context).top +
              UIConstants.minimumInteractiveTargetSize +
              UIConstants.spaceXs,
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
                    padding:
                        const EdgeInsets.only(right: UIConstants.spaceXs),
                    child: _TypeChip(
                      type: type,
                      selected: currentType == type,
                      onTap: () => onTypeChipTap(type),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Página de captura de cada tipo (dentro do PageView)
// ---------------------------------------------------------------------------

class _TypeCapturePage extends StatelessWidget {
  const _TypeCapturePage({
    required this.type,
    required this.cameraController,
    required this.cameraReady,
    required this.isRecordingVideo,
    required this.isRecordingAudio,
    required this.audioDuration,
    required this.onCapture,
    required this.onStartVideo,
    required this.onStopVideo,
    required this.onGallery,
    required this.onToggleAudio,
    required this.onDirectToEditor,
  });

  final ContentType type;
  final CameraController? cameraController;
  final bool cameraReady;
  final bool isRecordingVideo;
  final bool isRecordingAudio;
  final Duration audioDuration;
  final VoidCallback onCapture;
  final VoidCallback onStartVideo;
  final VoidCallback onStopVideo;
  final VoidCallback onGallery;
  final VoidCallback onToggleAudio;
  final VoidCallback onDirectToEditor;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      ContentType.photo => _PhotoCapturePage(
          cameraController: cameraController,
          cameraReady: cameraReady,
          onCapture: onCapture,
          onGallery: onGallery,
        ),
      ContentType.video => _VideoCapturePage(
          cameraController: cameraController,
          cameraReady: cameraReady,
          isRecording: isRecordingVideo,
          onStartVideo: onStartVideo,
          onStopVideo: onStopVideo,
          onGallery: onGallery,
        ),
      ContentType.story => _StoryCapturePage(
          cameraController: cameraController,
          cameraReady: cameraReady,
          onCapture: onCapture,
          onGallery: onGallery,
        ),
      ContentType.audio => _AudioCapturePage(
          isRecording: isRecordingAudio,
          duration: audioDuration,
          onToggle: onToggleAudio,
        ),
      _ => _DirectEditorPage(type: type, onTap: onDirectToEditor),
    };
  }
}

// ---------------------------------------------------------------------------
// Foto — câmera + shutter
// ---------------------------------------------------------------------------

class _PhotoCapturePage extends StatelessWidget {
  const _PhotoCapturePage({
    required this.cameraController,
    required this.cameraReady,
    required this.onCapture,
    required this.onGallery,
  });

  final CameraController? cameraController;
  final bool cameraReady;
  final VoidCallback onCapture;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _CameraPreviewOrBlack(
          controller: cameraController,
          ready: cameraReady,
        ),
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
                  _CameraIconButton(
                    icon: Icons.photo_library_rounded,
                    onTap: onGallery,
                    tooltip: AppStrings.mediaPickerGallery,
                    size: UIConstants.composerAvatarSize,
                  ),
                  _ShutterButton(onTap: onCapture),
                  const SizedBox(width: UIConstants.composerAvatarSize),
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
// Vídeo — câmera + hold-to-record
// ---------------------------------------------------------------------------

class _VideoCapturePage extends StatelessWidget {
  const _VideoCapturePage({
    required this.cameraController,
    required this.cameraReady,
    required this.isRecording,
    required this.onStartVideo,
    required this.onStopVideo,
    required this.onGallery,
  });

  final CameraController? cameraController;
  final bool cameraReady;
  final bool isRecording;
  final VoidCallback onStartVideo;
  final VoidCallback onStopVideo;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _CameraPreviewOrBlack(
          controller: cameraController,
          ready: cameraReady,
        ),
        // Recording indicator
        if (isRecording)
          Positioned(
            top: MediaQuery.paddingOf(context).top +
                UIConstants.minimumInteractiveTargetSize +
                UIConstants.composerTypeChipHeight +
                UIConstants.spaceLg,
            left: 0,
            right: 0,
            child: const Center(child: _RecordingIndicator()),
          ),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isRecording
                        ? AppStrings.createVideoRecordingHint
                        : AppStrings.createVideoRecordHint,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: UIConstants.createTypeChipFontSize,
                    ),
                  ),
                  const SizedBox(height: UIConstants.spaceMd),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!isRecording)
                        _CameraIconButton(
                          icon: Icons.photo_library_rounded,
                          onTap: onGallery,
                          tooltip: AppStrings.mediaPickerGallery,
                          size: UIConstants.composerAvatarSize,
                        )
                      else
                        const SizedBox(width: UIConstants.composerAvatarSize),
                      // Hold-to-record shutter (vermelho quando gravando)
                      _VideoShutterButton(
                        isRecording: isRecording,
                        onStart: onStartVideo,
                        onStop: onStopVideo,
                      ),
                      const SizedBox(width: UIConstants.composerAvatarSize),
                    ],
                  ),
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
// Story — câmera fullscreen + shutter + galeria (como Instagram)
// ---------------------------------------------------------------------------

class _StoryCapturePage extends StatelessWidget {
  const _StoryCapturePage({
    required this.cameraController,
    required this.cameraReady,
    required this.onCapture,
    required this.onGallery,
  });

  final CameraController? cameraController;
  final bool cameraReady;
  final VoidCallback onCapture;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        _CameraPreviewOrBlack(
          controller: cameraController,
          ready: cameraReady,
        ),
        // Story hint label
        Positioned(
          top: MediaQuery.paddingOf(context).top +
              UIConstants.minimumInteractiveTargetSize +
              UIConstants.composerTypeChipHeight +
              UIConstants.spaceLg,
          left: UIConstants.spaceLg,
          right: UIConstants.spaceLg,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.spaceMd,
              vertical: UIConstants.spaceXs,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius:
                  BorderRadius.circular(UIConstants.createEditorFieldRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: UIConstants.createStoryBadgeIconSize,
                  color: colors.onInverseSurface,
                ),
                const SizedBox(width: UIConstants.spaceXs),
                Text(
                  AppStrings.createStoryExpiry,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: UIConstants.createStoryBadgeFontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
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
                  _CameraIconButton(
                    icon: Icons.photo_library_rounded,
                    onTap: onGallery,
                    tooltip: AppStrings.mediaPickerGallery,
                    size: UIConstants.composerAvatarSize,
                  ),
                  _ShutterButton(onTap: onCapture),
                  const SizedBox(width: UIConstants.composerAvatarSize),
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
// Áudio — gravador de microfone
// ---------------------------------------------------------------------------

class _AudioCapturePage extends StatelessWidget {
  const _AudioCapturePage({
    required this.isRecording,
    required this.duration,
    required this.onToggle,
  });

  final bool isRecording;
  final Duration duration;
  final VoidCallback onToggle;

  String get _durationLabel {
    final m = duration.inMinutes.toString().padLeft(2, '0');
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone do microfone com pulso animado
          _MicPulse(isRecording: isRecording),
          const SizedBox(height: UIConstants.spaceXl),
          // Duração
          AnimatedOpacity(
            opacity: isRecording ? 1 : 0,
            duration: UIConstants.createAudioPulse,
            child: Text(
              _durationLabel,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ),
          const SizedBox(height: UIConstants.spaceLg),
          // Hint
          Text(
            isRecording
                ? AppStrings.createAudioRecording
                : AppStrings.createAudioRecordHint,
            style: TextStyle(
              color: isRecording ? colors.error : Colors.white70,
              fontSize: UIConstants.createAudioHintFontSize,
            ),
          ),
          const SizedBox(height: UIConstants.space2xl),
          // Botão gravar / parar
          Semantics(
            button: true,
            label: isRecording
                ? AppStrings.createAudioStop
                : AppStrings.createAudioRecordHint,
            child: GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: UIConstants.engagementColorDuration,
                width: UIConstants.createAudioRecorderSize,
                height: UIConstants.createAudioRecorderSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRecording
                      ? colors.error
                      : Colors.white.withValues(alpha: 0.15),
                  border: Border.all(color: Colors.white, width: UIConstants.createCameraShutterBorderWidth),
                ),
                child: Icon(
                  isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: UIConstants.createAudioRecorderSize * UIConstants.createAudioRecorderIconScale,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tipos textuais (Post/Artigo/Enquete/Evento/Live) — tela de CTA
// ---------------------------------------------------------------------------

class _DirectEditorPage extends StatelessWidget {
  const _DirectEditorPage({required this.type, required this.onTap});

  final ContentType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.activeIcon, size: UIConstants.createDirectEditorIconSize, color: Colors.white),
            const SizedBox(height: UIConstants.spaceLg),
            Text(
              type.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: UIConstants.createDirectEditorLabelFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.spaceXs),
            Text(
              type.description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: UIConstants.createDirectEditorDescFontSize,
              ),
            ),
            const SizedBox(height: UIConstants.space2xl),
            FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.edit_rounded),
              label: Text(
                AppStrings.createDirectEditorCta.replaceFirst(
                  '{type}',
                  type.label,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// WIDGETS COMPARTILHADOS — Captura
// ===========================================================================

class _CameraPreviewOrBlack extends StatelessWidget {
  const _CameraPreviewOrBlack({required this.controller, required this.ready});

  final CameraController? controller;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    if (ready && controller != null) {
      return CameraPreview(controller!);
    }
    return const ColoredBox(color: Colors.black);
  }
}

/// Shutter para foto (círculo branco).
class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppStrings.mediaPickerTakePhoto,
      child: GestureDetector(
        onTap: onTap,
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
    );
  }
}

/// Shutter para vídeo (vermelho quando gravando, branco parado).
class _VideoShutterButton extends StatelessWidget {
  const _VideoShutterButton({
    required this.isRecording,
    required this.onStart,
    required this.onStop,
  });

  final bool isRecording;
  final VoidCallback onStart;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isRecording
          ? AppStrings.createAudioStop
          : AppStrings.createVideoRecordHint,
      child: GestureDetector(
        onTapDown: (_) => onStart(),
        onTapUp: (_) => onStop(),
        onTapCancel: onStop,
        child: AnimatedContainer(
          duration: UIConstants.engagementColorDuration,
          width: UIConstants.mediaPickerCameraButtonSize,
          height: UIConstants.mediaPickerCameraButtonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: UIConstants.createCameraShutterBorderWidth),
          ),
          child: Center(
            child: AnimatedContainer(
              duration: UIConstants.engagementColorDuration,
              width: isRecording
                  ? UIConstants.mediaPickerCameraButtonSize * UIConstants.createVideoShutterRecordingScale
                  : UIConstants.mediaPickerCameraButtonInner,
              height: isRecording
                  ? UIConstants.mediaPickerCameraButtonSize * UIConstants.createVideoShutterRecordingScale
                  : UIConstants.mediaPickerCameraButtonInner,
              decoration: BoxDecoration(
                shape: isRecording ? BoxShape.rectangle : BoxShape.circle,
                borderRadius:
                    isRecording ? BorderRadius.circular(UIConstants.createVideoShutterRecordingRadius) : null,
                color: isRecording ? Theme.of(context).colorScheme.error : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Indicador de gravação (ponto vermelho pulsante + "REC").
class _RecordingIndicator extends StatefulWidget {
  const _RecordingIndicator();

  @override
  State<_RecordingIndicator> createState() => _RecordingIndicatorState();
}

class _RecordingIndicatorState extends State<_RecordingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: UIConstants.createAudioPulse,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _pulse,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spaceSm,
          vertical: UIConstants.space2xs,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(UIConstants.createEditorFieldRadius),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: Colors.white, size: UIConstants.createRecordingDotSize),
            SizedBox(width: UIConstants.space2xs),
            Text(
              AppStrings.createVideoRecLabel,
              style: TextStyle(
                color: Colors.white,
                fontSize: UIConstants.createRecordingLabelFontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: UIConstants.createRecordingLabelLetterSpacing,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Microfone com pulso animado quando gravando.
class _MicPulse extends StatefulWidget {
  const _MicPulse({required this.isRecording});

  final bool isRecording;

  @override
  State<_MicPulse> createState() => _MicPulseState();
}

class _MicPulseState extends State<_MicPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: UIConstants.createAudioPulse,
  );

  @override
  void didUpdateWidget(_MicPulse old) {
    super.didUpdateWidget(old);
    if (widget.isRecording && !old.isRecording) {
      _pulse.repeat(reverse: true);
    } else if (!widget.isRecording && old.isRecording) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final scale = widget.isRecording ? 1.0 + _pulse.value * UIConstants.createMicPulseScaleAmplitude : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: UIConstants.createAudioRecorderSize,
            height: UIConstants.createAudioRecorderSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isRecording
                  ? colors.error.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
            ),
            child: Icon(
              widget.isRecording ? Icons.mic_rounded : Icons.mic_outlined,
              size: UIConstants.createAudioRecorderSize * UIConstants.createMicIconScale,
              color: widget.isRecording ? colors.error : Colors.white,
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Chip de tipo
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
    return Semantics(
      button: true,
      selected: selected,
      label: type.label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: UIConstants.createTypeChipAnimationDuration,
          height: UIConstants.composerTypeChipHeight,
          padding: const EdgeInsets.symmetric(horizontal: UIConstants.spaceMd),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white
                : Colors.black.withValues(alpha: 0.45),
            borderRadius:
                BorderRadius.circular(UIConstants.composerTypeChipRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: UIConstants.createTypeChipBorderWidth,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? type.activeIcon : type.icon,
                  size: UIConstants.createTypeChipIconSize,
                  color: selected ? Colors.black : Colors.white,
                ),
                const SizedBox(width: UIConstants.space2xs),
                Text(
                  type.label,
                  style: TextStyle(
                    color: selected ? Colors.black : Colors.white,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: UIConstants.createTypeChipFontSize,
                  ),
                ),
              ],
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

// ===========================================================================
// FASE 2 — Editor
// ===========================================================================

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

    return Scaffold(
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
          preferredSize: const Size.fromHeight(UIConstants.createEditorAppBarDividerHeight),
          child: Divider(
            height: UIConstants.createEditorAppBarDividerHeight,
            thickness: UIConstants.createEditorDividerThickness,
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      body: const CreatePostEditor(),
      bottomNavigationBar: _PublishToolbar(provider: provider),
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
              child: CircularProgressIndicator(strokeWidth: UIConstants.createPublishProgressStrokeWidth),
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
              width: UIConstants.createEditorDividerThickness,
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
                      Icon(
                        action.icon,
                        size: UIConstants.createToolbarIconSize,
                        color: colors.onSurfaceVariant,
                      ),
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
                padding:
                    const EdgeInsets.only(right: UIConstants.spaceMd),
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
