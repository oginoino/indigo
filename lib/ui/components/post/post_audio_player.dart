import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:video_player/video_player.dart';

import '../../../model/post/post_media.dart';
import '../../../util/const/app/app_strings.dart';
import '../../../util/const/ui/ui_constants.dart';

class PostAudioPlayer extends StatefulWidget {
  const PostAudioPlayer({required this.media, super.key});

  final PostMedia media;

  @override
  State<PostAudioPlayer> createState() => _PostAudioPlayerState();
}

class _PostAudioPlayerState extends State<PostAudioPlayer> {
  late final VideoPlayerController _controller;
  late final Future<void> _initialization;
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
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.media.sourceUrl),
    );
    _initialization = _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _controller.initialize();
      if (!mounted) return;
      setState(() {
        _duration = _controller.value.duration;
      });
      _controller.addListener(_onControllerUpdate);
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    final value = _controller.value;
    setState(() {
      _position = value.position;
      _isPlaying = value.isPlaying;
    });
    if (value.hasError && !_hasError) {
      setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerUpdate)
      ..dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_hasError) return;
    await _initialization;
    if (!mounted) return;
    if (_controller.value.isPlaying) {
      await _controller.pause();
    } else {
      if (_controller.value.position >= _controller.value.duration) {
        await _controller.seekTo(Duration.zero);
      }
      await _controller.play();
    }
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
    final duration = _duration.inMilliseconds;
    if (duration == 0) return 0;
    final position = _position.inMilliseconds.clamp(0, duration);
    return position / duration;
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
        final durationText = _formatDuration(
          _duration > Duration.zero ? _duration : widget.media.duration ?? Duration.zero,
        );

        return Semantics(
          label: _isPlaying
              ? AppStrings.pauseAudio
              : AppStrings.playAudio,
          child: Material(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(UIConstants.postMediaRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(UIConstants.postMediaRadius),
              onTap: isLoading ? null : _togglePlayback,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.audioPlayerHorizontalPadding,
                  vertical: UIConstants.audioPlayerSpacing,
                ),
                child: Row(
                  children: [
                    _PlayButton(
                      isPlaying: _isPlaying,
                      isLoading: isLoading,
                      hasError: _hasError,
                    ),
                    const SizedBox(width: UIConstants.audioPlayerSpacing),
                    Expanded(
                      child: _WaveformProgress(
                        waveform: waveform,
                        progress: _progress,
                        color: theme.colorScheme.primary,
                        trackColor: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    const SizedBox(width: UIConstants.audioPlayerSpacing),
                    Text(
                      durationText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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
  });

  final bool isPlaying;
  final bool isLoading;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: UIConstants.audioPlayerButtonSize,
      height: UIConstants.audioPlayerButtonSize,
      child: isLoading
          ? Center(
              child: SizedBox(
                width: UIConstants.audioPlayerIconSize,
                height: UIConstants.audioPlayerIconSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
            )
          : Icon(
              hasError
                  ? Icons.error_outline
                  : (isPlaying ? Icons.pause : Icons.play_arrow),
              size: UIConstants.audioPlayerIconSize,
              color: theme.colorScheme.primary,
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
  });

  final List<double> waveform;
  final double progress;
  final Color color;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    final barCount = waveform.length;
    final playedBars = (progress * barCount).round().clamp(0, barCount);

    return SizedBox(
      height: UIConstants.audioPlayerWaveformHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < barCount; i++)
            Padding(
              padding: EdgeInsets.only(
                right: i == barCount - 1
                    ? 0
                    : UIConstants.audioPlayerWaveformBarSpacing,
              ),
              child: Container(
                width: UIConstants.audioPlayerWaveformBarWidth,
                height: UIConstants.audioPlayerWaveformHeight *
                    waveform[i].clamp(0.15, 1.0),
                decoration: BoxDecoration(
                  color: i < playedBars ? color : trackColor,
                  borderRadius: BorderRadius.circular(
                    UIConstants.audioPlayerWaveformBarWidth / 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
