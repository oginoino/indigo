import 'dart:async';

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
  const PostAudioPlayer({required this.media, super.key});

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
    return VideoPlayerController.networkUrl(Uri.parse(widget.media.sourceUrl));
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

  Duration get _totalDuration => _duration > Duration.zero
      ? _duration
      : widget.media.duration ?? Duration.zero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    // Usa somente as amostras reais associadas ao áudio. Sem dados de waveform,
    // não inventa um padrão visual que possa representar incorretamente o som.
    final waveform = widget.media.waveform;

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
            shape:
                theme.cardTheme.shape ??
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    UIConstants.postMediaRadius,
                  ),
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
                      _formatDuration(
                        _position > Duration.zero || _isPlaying
                            ? _position
                            : _totalDuration,
                      ),
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
  static const double _height = 28;

  double? _previewProgress;

  double _fraction(double dx, double width) =>
      width <= 0 ? 0.0 : (dx / width).clamp(0.0, 1.0).toDouble();

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
    final isDragging = _previewProgress != null;
    final progress = (_previewProgress ?? widget.progress)
        .clamp(0.0, 1.0)
        .toDouble();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: widget.onSeek == null
              ? null
              : (details) =>
                    widget.onSeek!(_fraction(details.localPosition.dx, width)),
          onHorizontalDragStart: widget.onSeek == null
              ? null
              : (details) =>
                    _updatePreview(_fraction(details.localPosition.dx, width)),
          onHorizontalDragUpdate: widget.onSeek == null
              ? null
              : (details) =>
                    _updatePreview(_fraction(details.localPosition.dx, width)),
          onHorizontalDragEnd: widget.onSeek == null
              ? null
              : (_) => _commitSeek(),
          onHorizontalDragCancel: _cancelPreview,
          child: SizedBox(
            width: width,
            height: _height,
            // Entrada: as barras crescem em cascata da esquerda para a direita.
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: reduceMotion ? 1 : 0, end: 1),
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 700),
              builder: (context, intro, _) => TweenAnimationBuilder<double>(
                // Suaviza o avanço; durante o arraste acompanha o dedo.
                tween: Tween<double>(end: progress),
                duration: isDragging || reduceMotion
                    ? Duration.zero
                    : UIConstants.engagementColorDuration,
                curve: Curves.linear,
                builder: (context, animatedProgress, _) =>
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: isDragging ? 1 : 0),
                      duration: const Duration(milliseconds: 160),
                      builder: (context, playhead, _) => CustomPaint(
                        painter: _WaveformPainter(
                          waveform: widget.waveform,
                          progress: animatedProgress,
                          intro: intro,
                          playhead: playhead,
                          color: widget.color,
                          trackColor: widget.trackColor,
                        ),
                      ),
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.waveform,
    required this.progress,
    required this.intro,
    required this.playhead,
    required this.color,
    required this.trackColor,
  });

  final List<double> waveform;
  final double progress;

  /// 0..1 — animação de entrada das barras.
  final double intro;

  /// 0..1 — opacidade do marcador (visível apenas durante o arraste).
  final double playhead;
  final Color color;
  final Color trackColor;

  static const double _barWidth = 2.5;
  static const double _barGap = 1.8;
  static const double _minBarHeight = 3;
  static const double _verticalInset = 4;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    if (waveform.isEmpty) {
      _paintLinear(canvas, size);
    } else {
      _paintBars(canvas, size);
    }

    if (playhead > 0) _paintPlayhead(canvas, size);
  }

  void _paintBars(Canvas canvas, Size size) {
    final barCount = ((size.width + _barGap) / (_barWidth + _barGap))
        .floor()
        .clamp(1, 1000)
        .toInt();
    final peak = waveform.reduce((a, b) => a > b ? a : b).abs();
    final normalizer = peak <= 0 ? 1.0 : peak;

    final restPaint = Paint()..color = color.withValues(alpha: 0.28);
    final playedPaint = Paint()..color = color;
    final centerY = size.height / 2;
    final step = size.width / barCount;
    final maxBarHeight = size.height - _verticalInset;

    for (var i = 0; i < barCount; i++) {
      // Reamostra as amostras reais para a quantidade de barras que cabe.
      final start = (i * waveform.length / barCount).floor();
      final end = ((i + 1) * waveform.length / barCount)
          .ceil()
          .clamp(start + 1, waveform.length)
          .toInt();

      var sum = 0.0;
      for (var j = start; j < end; j++) {
        sum += waveform[j].abs();
      }
      final amplitude = (sum / (end - start) / normalizer).clamp(0.0, 1.0);

      // Entrada em cascata.
      final reveal = Curves.easeOutCubic.transform(
        (intro * UIConstants.audioPlayerWaveformIntroScale -
                (i / barCount) * UIConstants.audioPlayerWaveformIntroSweep)
            .clamp(0.0, 1.0),
      );

      var barHeight =
          (_minBarHeight + (maxBarHeight - _minBarHeight) * amplitude) *
          reveal;

      // Leve "respiro" nas barras próximas ao marcador durante o arraste.
      if (playhead > 0) {
        final distance = ((i + 0.5) / barCount - progress).abs();
        final lift = (1 - (distance * 8).clamp(0.0, 1.0)) * 0.18 * playhead;
        barHeight *= 1 + lift;
      }
      barHeight = barHeight.clamp(0.0, size.height).toDouble();
      if (barHeight < 0.5) continue;

      final x = i * step + (step - _barWidth) / 2;
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, centerY - barHeight / 2, _barWidth, barHeight),
        const Radius.circular(_barWidth / 2),
      );

      // Preenchimento fracionado: a barra sob o marcador é preenchida
      // parcialmente, o que deixa o avanço contínuo em vez de "em degraus".
      final fill = (progress * barCount - i).clamp(0.0, 1.0).toDouble();
      if (fill >= 1) {
        canvas.drawRRect(rrect, playedPaint);
      } else {
        canvas.drawRRect(rrect, restPaint);
        if (fill > 0) {
          canvas
            ..save()
            ..clipRect(Rect.fromLTWH(x, 0, _barWidth * fill, size.height))
            ..drawRRect(rrect, playedPaint)
            ..restore();
        }
      }
    }
  }

  void _paintLinear(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final stroke = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      stroke..color = trackColor,
    );
    if (progress > 0) {
      canvas.drawLine(
        Offset(0, centerY),
        Offset(size.width * progress, centerY),
        stroke..color = color,
      );
    }
  }

  void _paintPlayhead(Canvas canvas, Size size) {
    final x = (size.width * progress).clamp(1.0, size.width - 1);
    canvas.drawLine(
      Offset(x, 1),
      Offset(x, size.height - 1),
      Paint()
        ..color = color.withValues(alpha: playhead)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.progress != progress ||
      old.intro != intro ||
      old.playhead != playhead ||
      old.color != color ||
      old.trackColor != trackColor ||
      !identical(old.waveform, waveform);
}