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
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  static const List<double> _fallbackWaveform = [
    0.2, 0.4, 0.6, 0.35, 0.7, 0.5, 0.8, 0.45, 0.6, 0.3, 0.55, 0.75, 0.4, 0.65,
    0.5, 0.85, 0.35, 0.6, 0.45, 0.7, 0.55, 0.3, 0.5, 0.65, 0.4, 0.75, 0.6,
    0.35, 0.55, 0.8,
  ];

  @override
  void initState() {
    super.initState();
    _controller = _createController();
    _initialization = _initialize(_controller, _generation);
  }

  @override
  void didUpdateWidget(PostAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.media.sourceUrl != widget.media.sourceUrl) {
      _replaceController();
    }
  }

  VideoPlayerController _createController() =>
      VideoPlayerController.networkUrl(Uri.parse(widget.media.sourceUrl));

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
        _hasError = controller.value.hasError;
      });
    } catch (_) {
      if (!mounted || generation != _generation) return;
      setState(() => _hasError = true);
    }
  }

  void _replaceController() {
    final previous = _controller;
    previous.removeListener(_onControllerUpdate);
    final generation = ++_generation;
    final controller = _createController();
    _controller = controller;
    _AudioPlaybackHub.release(this);
    setState(() {
      _hasError = false;
      _isPlaying = false;
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
    } catch (_) {}
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    final value = _controller.value;
    final hasError = _hasError || value.hasError;
    if (value.position == _position &&
        value.isPlaying == _isPlaying &&
        value.duration == _duration &&
        hasError == _hasError) {
      return;
    }
    setState(() {
      _position = value.position;
      _isPlaying = value.isPlaying;
      _duration = value.duration;
      _hasError = hasError;
    });
  }

  @override
  void dispose() {
    _generation++;
    _AudioPlaybackHub.release(this);
    _controller
      ..removeListener(_onControllerUpdate)
      ..dispose();
    super.dispose();
  }

  void pauseFromCoordinator() {
    if (!_controller.value.isInitialized || !_controller.value.isPlaying) {
      return;
    }
    unawaited(_controller.pause());
  }

  Future<void> _togglePlayback() async {
    if (_hasError) {
      _replaceController();
      return;
    }
    await _initialization;
    if (!mounted || _hasError || !_controller.value.isInitialized) return;
    if (_controller.value.isPlaying) {
      await _controller.pause();
      return;
    }
    _AudioPlaybackHub.claim(this);
    final duration = _controller.value.duration;
    if (duration > Duration.zero && _controller.value.position >= duration) {
      await _controller.seekTo(Duration.zero);
    }
    await _controller.play();
  }

  Future<void> _seekBy(Duration offset) async {
    await _initialization;
    if (!mounted || _hasError || !_controller.value.isInitialized) return;
    final duration = _controller.value.duration;
    if (duration <= Duration.zero) return;
    var target = _controller.value.position + offset;
    if (target < Duration.zero) target = Duration.zero;
    if (target > duration) target = duration;
    await _controller.seekTo(target);
  }

  Future<void> _seekToFraction(double fraction) async {
    await _initialization;
    if (!mounted || _hasError || !_controller.value.isInitialized) return;
    final duration = _controller.value.duration;
    if (duration <= Duration.zero) return;
    final clamped = fraction.clamp(0.0, 1.0);
    await _controller.seekTo(duration * clamped);
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return AppStrings.audioDurationFormat
        .replaceAll('{minutes}', '$minutes')
        .replaceAll('{seconds}', seconds.toString().padLeft(2, '0'));
  }

  double get _progress {
    final durationMs = _duration.inMilliseconds;
    if (durationMs == 0) return 0;
    final positionMs = _position.inMilliseconds.clamp(0, durationMs);
    return positionMs / durationMs;
  }

  Duration get _displayedDuration {
    if (_position > Duration.zero || _isPlaying) return _position;
    if (_duration > Duration.zero) return _duration;
    return widget.media.duration ?? Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(UIConstants.postMediaRadius),
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
                    if (_hasError) ...[
                      const SizedBox(width: UIConstants.audioPlayerSpacing),
                      Expanded(
                        child: Text(
                          AppStrings.audioPlaybackFailed,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(width: UIConstants.audioPlayerSpacing),
                      _SeekButton(
                        tooltip: AppStrings.rewindAudio,
                        icon: Icons.replay_5,
                        onPressed: canSeek
                            ? () => _seekBy(-UIConstants.audioPlayerSeekStep)
                            : null,
                      ),
                      const SizedBox(width: UIConstants.audioPlayerSpacing),
                      Expanded(
                        child: _WaveformProgress(
                          key: PostAudioPlayer.waveformKey,
                          waveform: waveform,
                          progress: _progress,
                          color: theme.colorScheme.primary,
                          trackColor: theme.colorScheme.outlineVariant,
                          onSeek: canSeek ? _seekToFraction : null,
                        ),
                      ),
                      const SizedBox(width: UIConstants.audioPlayerSpacing),
                      _SeekButton(
                        tooltip: AppStrings.forwardAudio,
                        icon: Icons.forward_5,
                        onPressed: canSeek
                            ? () => _seekBy(UIConstants.audioPlayerSeekStep)
                            : null,
                      ),
                      const SizedBox(width: UIConstants.audioPlayerSpacing),
                      Text(
                        _formatDuration(_displayedDuration),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ],
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
    final color = theme.colorScheme.primary;
    return SizedBox(
      width: UIConstants.audioPlayerButtonSize,
      height: UIConstants.audioPlayerButtonSize,
      child: isLoading
          ? Center(
              child: SizedBox(
                width: UIConstants.audioPlayerIconSize,
                height: UIConstants.audioPlayerIconSize,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              ),
            )
          : IconButton(
              tooltip: hasError
                  ? AppStrings.retry
                  : (isPlaying ? AppStrings.pauseAudio : AppStrings.playAudio),
              onPressed: onPressed,
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: const Size(
                  UIConstants.audioPlayerButtonSize,
                  UIConstants.audioPlayerButtonSize,
                ),
                padding: EdgeInsets.zero,
              ),
              icon: Icon(
                hasError
                    ? Icons.refresh
                    : (isPlaying ? Icons.pause : Icons.play_arrow),
                size: UIConstants.audioPlayerIconSize,
                color: color,
              ),
            ),
    );
  }
}

class _SeekButton extends StatelessWidget {
  const _SeekButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: const Size(
          UIConstants.audioPlayerButtonSize,
          UIConstants.audioPlayerButtonSize,
        ),
        padding: EdgeInsets.zero,
      ),
      icon: Icon(
        icon,
        size: UIConstants.audioPlayerIconSize,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _WaveformProgress extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final barCount = waveform.length;
    final playedBars = (progress * barCount).round().clamp(0, barCount);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: onSeek == null
          ? null
          : (details) => onSeek!(_fraction(context, details.localPosition.dx)),
      onHorizontalDragUpdate: onSeek == null
          ? null
          : (details) => onSeek!(_fraction(context, details.localPosition.dx)),
      child: SizedBox(
        height: UIConstants.audioPlayerButtonSize,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var i = 0; i < barCount; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: i == barCount - 1
                        ? 0
                        : UIConstants.audioPlayerWaveformBarSpacing,
                  ),
                  child: Align(
                    child: Container(
                      width: double.infinity,
                      height:
                          UIConstants.audioPlayerWaveformHeight *
                          waveform[i].clamp(0.15, 1.0),
                      decoration: BoxDecoration(
                        color: i < playedBars ? color : trackColor,
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
    );
  }

  double _fraction(BuildContext context, double dx) {
    final box = context.findRenderObject() as RenderBox?;
    final width = box?.size.width ?? 0;
    if (width <= 0) return 0;
    return (dx / width).clamp(0.0, 1.0);
  }
}
