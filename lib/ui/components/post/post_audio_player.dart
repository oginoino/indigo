import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:material_ui/material_ui.dart';
import 'package:video_player/video_player.dart';

import '../../../model/post/post_media.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';

class _AudioPlaybackHub {
  static _PostAudioPlayerState? _active;

  static void claim(_PostAudioPlayerState player) {
    final previous = _active;
    _active = player;

    if (previous != null && !identical(previous, player)) {
      previous.pauseFromCoordinator();
    }
  }

  static void release(_PostAudioPlayerState player) {
    if (identical(_active, player)) _active = null;
  }
}

class PostAudioPlayer extends StatefulWidget {
  const PostAudioPlayer({
    required this.media,
    super.key,
  });

  static const waveformKey = Key('postAudioWaveform');

  final PostMedia media;

  @override
  State<PostAudioPlayer> createState() => _PostAudioPlayerState();
}

class _PostAudioPlayerState extends State<PostAudioPlayer> {
  late VideoPlayerController _controller;
  late Future<void> _initialization;

  int _generation = 0;
  bool _isPlaying = false;
  bool _hasError = false;
  bool _isPlaybackActionInProgress = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  static const List<double> _fallbackWaveform = [
    0.2, 0.4, 0.6, 0.35, 0.7, 0.5, 0.8, 0.45, 0.6, 0.3,
    0.55, 0.75, 0.4, 0.65, 0.5, 0.85, 0.35, 0.6, 0.45, 0.7,
    0.55, 0.3, 0.5, 0.65, 0.4, 0.75, 0.6, 0.35, 0.55, 0.8,
  ];

  @override
  void initState() {
    super.initState();
    _controller = _createController();
    _initialization = _initialize(_controller, _generation);
  }

  @override
  void didUpdateWidget(covariant PostAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.media.sourceUrl != widget.media.sourceUrl) {
      _replaceController();
    }
  }

  VideoPlayerController _createController() {
    return VideoPlayerController.networkUrl(
      Uri.parse(widget.media.sourceUrl),
    );
  }

  Future<void> _initialize(
    VideoPlayerController controller,
    int generation,
  ) async {
    try {
      await controller.initialize();
      if (!mounted || generation != _generation) return;

      controller.addListener(_onControllerUpdate);
      setState(() {
        _duration = controller.value.duration;
        _position = controller.value.position;
        _isPlaying = controller.value.isPlaying;
        _hasError = controller.value.hasError;
      });
    } catch (error, stackTrace) {
      debugPrint('[PostAudioPlayer] Initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted || generation != _generation) return;
      setState(() => _hasError = true);
    }
  }

  void _replaceController() {
    final previous = _controller..removeListener(_onControllerUpdate);
    final generation = ++_generation;
    final controller = _createController();

    _controller = controller;
    _AudioPlaybackHub.release(this);

    setState(() {
      _hasError = false;
      _isPlaying = false;
      _isPlaybackActionInProgress = false;
      _position = Duration.zero;
      _duration = Duration.zero;
      _initialization = _initialize(controller, generation);
    });

    unawaited(_disposeController(previous));
  }

  Future<void> _disposeController(VideoPlayerController controller) async {
    controller.removeListener(_onControllerUpdate);
    try {
      await controller.dispose();
    } catch (error) {
      debugPrint('[PostAudioPlayer] Controller disposal failed: $error');
    }
  }

  void _onControllerUpdate() {
    if (!mounted) return;

    final value = _controller.value;
    if (value.position == _position &&
        value.isPlaying == _isPlaying &&
        value.duration == _duration &&
        value.hasError == _hasError) {
      return;
    }

    setState(() {
      _position = value.position;
      _isPlaying = value.isPlaying;
      _duration = value.duration;
      _hasError = value.hasError;
    });

    if (value.hasError ||
        (!value.isPlaying &&
            value.duration > Duration.zero &&
            value.position >= value.duration)) {
      _AudioPlaybackHub.release(this);
    }
  }

  @override
  void dispose() {
    _generation++;
    _AudioPlaybackHub.release(this);
    unawaited(_disposeController(_controller));
    super.dispose();
  }

  void pauseFromCoordinator() {
    if (!_controller.value.isInitialized || !_controller.value.isPlaying) {
      return;
    }
    unawaited(_controller.pause());
  }

  Future<void> _togglePlayback() async {
    if (_isPlaybackActionInProgress) return;

    if (_hasError) {
      _replaceController();
      return;
    }

    _isPlaybackActionInProgress = true;
    try {
      await _initialization;
      if (!mounted || _hasError || !_controller.value.isInitialized) return;

      if (_controller.value.isPlaying) {
        await _controller.pause();
        return;
      }

      _AudioPlaybackHub.claim(this);
      final value = _controller.value;

      if (value.duration > Duration.zero && value.position >= value.duration) {
        await _controller.seekTo(Duration.zero);
      }

      await _controller.play();
    } catch (error, stackTrace) {
      debugPrint('[PostAudioPlayer] Playback failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) setState(() => _hasError = true);
    } finally {
      _isPlaybackActionInProgress = false;
    }
  }

  Future<void> _seekToFraction(double fraction) async {
    try {
      await _initialization;
      if (!mounted || _hasError || !_controller.value.isInitialized) return;

      final duration = _controller.value.duration;
      if (duration <= Duration.zero) return;

      final normalized = fraction.clamp(0.0, 1.0);
      await _controller.seekTo(duration * normalized);
    } catch (error) {
      debugPrint('[PostAudioPlayer] Seeking failed: $error');
    }
  }

  String _formatDuration(Duration duration) {
    final seconds = duration.inSeconds;
    return AppStrings.audioDurationFormat
        .replaceAll('{minutes}', '${seconds ~/ 60}')
        .replaceAll('{seconds}', (seconds % 60).toString().padLeft(2, '0'));
  }

  double get _progress {
    final durationMs = _duration.inMilliseconds;
    if (durationMs <= 0) return 0;
    return _position.inMilliseconds.clamp(0, durationMs) / durationMs;
  }

  Duration get _totalDuration =>
      _duration > Duration.zero ? _duration : widget.media.duration ?? Duration.zero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final waveform = widget.media.waveform.isNotEmpty
        ? widget.media.waveform
        : _fallbackWaveform;

    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        final isLoading =
            snapshot.connectionState == ConnectionState.waiting && !_hasError;
        final canSeek = !isLoading && !_hasError;

        return Semantics(
          container: true,
          label: widget.media.altText,
          child: Material(
            color: theme.cardTheme.color ?? colors.surface,
            shape: theme.cardTheme.shape ??
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIConstants.postMediaRadius),
                ),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: UIConstants.audioPlayerHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.audioPlayerHorizontalPadding,
                ),
                child: Row(
                  children: [
                    _PlayButton(
                      isPlaying: _isPlaying,
                      isLoading: isLoading,
                      hasError: _hasError,
                      onPressed: isLoading ? null : _togglePlayback,
                    ),
                    SizedBox(width: UIConstants.audioPlayerSpacing),
                    Expanded(
                      child: _hasError
                          ? Text(
                              AppStrings.audioPlaybackFailed,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            )
                          : _WaveformProgress(
                              key: PostAudioPlayer.waveformKey,
                              waveform: waveform,
                              progress: _progress,
                              color: colors.primary,
                              trackColor: colors.outlineVariant,
                              onSeek: canSeek ? _seekToFraction : null,
                            ),
                    ),
                    SizedBox(width: UIConstants.audioPlayerSpacing),
                    Text(
                      _formatDuration(_position > Duration.zero || _isPlaying
                          ? _position
                          : _totalDuration),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.isPlaying,
    required this.isLoading,
    required this.hasError,
    required this.onPressed,
  });

  final bool isPlaying;
  final bool isLoading;
  final bool hasError;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = UIConstants.audioPlayerButtonSize;

    return SizedBox.square(
      dimension: size,
      child: isLoading
          ? Center(
              child: SizedBox.square(
                dimension: UIConstants.audioPlayerIconSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
            )
          : IconButton(
              tooltip: hasError
                  ? AppStrings.retry
                  : isPlaying
                      ? AppStrings.pauseAudio
                      : AppStrings.playAudio,
              onPressed: onPressed,
              constraints: BoxConstraints.tightFor(width: size, height: size),
              padding: EdgeInsets.zero,
              icon: Icon(
                hasError
                    ? Icons.refresh
                    : isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                size: UIConstants.audioPlayerIconSize,
              ),
            ),
    );
  }
}

class _WaveformProgress extends StatefulWidget {
  const _WaveformProgress({
    required this.waveform,
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.onSeek,
    super.key,
  });

  final List<double> waveform;
  final double progress;
  final Color color;
  final Color trackColor;
  final ValueChanged<double>? onSeek;

  @override
  State<_WaveformProgress> createState() => _WaveformProgressState();
}

class _WaveformProgressState extends State<_WaveformProgress> {
  double? _previewProgress;

  double _fraction(double dx, double width) =>
      width <= 0 ? 0 : (dx / width).clamp(0.0, 1.0);

  void _updatePreview(double value) {
    setState(() => _previewProgress = value);
  }

  void _commitSeek() {
    final value = _previewProgress;
    setState(() => _previewProgress = null);
    if (value != null) widget.onSeek?.call(value);
  }

  void _cancelPreview() {
    if (_previewProgress != null) {
      setState(() => _previewProgress = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (_previewProgress ?? widget.progress).clamp(0.0, 1.0);
    final playedBars =
        (progress * widget.waveform.length).round().clamp(0, widget.waveform.length);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return Semantics(
          label: 'Audio progress',
          value: '${(progress * 100).round()}%',
          slider: true,
          onIncrease: widget.onSeek == null
              ? null
              : () => widget.onSeek!((progress + 0.05).clamp(0.0, 1.0)),
          onDecrease: widget.onSeek == null
              ? null
              : () => widget.onSeek!((progress - 0.05).clamp(0.0, 1.0)),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: widget.onSeek == null
                ? null
                : (details) => widget.onSeek!(
                      _fraction(details.localPosition.dx, width),
                    ),
            onHorizontalDragStart: widget.onSeek == null
                ? null
                : (details) => _updatePreview(
                      _fraction(details.localPosition.dx, width),
                    ),
            onHorizontalDragUpdate: widget.onSeek == null
                ? null
                : (details) => _updatePreview(
                      _fraction(details.localPosition.dx, width),
                    ),
            onHorizontalDragEnd: widget.onSeek == null ? null : (_) => _commitSeek(),
            onHorizontalDragCancel: _cancelPreview,
            child: SizedBox(
              height: UIConstants.audioPlayerButtonSize,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (var i = 0; i < widget.waveform.length; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: i == widget.waveform.length - 1
                              ? 0
                              : UIConstants.audioPlayerWaveformBarSpacing,
                        ),
                        child: Align(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 90),
                            width: double.infinity,
                            height: UIConstants.audioPlayerWaveformHeight *
                                widget.waveform[i].clamp(0.15, 1.0),
                            decoration: BoxDecoration(
                              color: i < playedBars
                                  ? widget.color
                                  : widget.trackColor,
                              borderRadius: BorderRadius.circular(
                                UIConstants.audioPlayerWaveformBarWidth / 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
