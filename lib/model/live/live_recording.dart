enum LiveRecordingStatus { processing, ready, failed, unavailable }

class LiveRecording {
  const LiveRecording({
    required this.id,
    required this.liveSessionId,
    required this.status,
    required this.createdAt,
    this.mediaUrl,
    this.thumbnailUrl,
    this.duration,
    this.replayPostId,
    this.readyAt,
  });

  final String id;
  final String liveSessionId;
  final LiveRecordingStatus status;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final Duration? duration;
  final String? replayPostId;
  final DateTime createdAt;
  final DateTime? readyAt;
}
