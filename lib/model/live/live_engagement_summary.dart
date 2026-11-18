import 'live_reaction.dart';

class LiveEngagementSummary {
  LiveEngagementSummary({
    required this.liveSessionId,
    this.viewerCount = 0,
    this.peakViewerCount = 0,
    this.messageCount = 0,
    Map<LiveReactionType, int> reactionCounts = const {},
  }) : reactionCounts = Map.unmodifiable(reactionCounts);

  final String liveSessionId;
  final int viewerCount;
  final int peakViewerCount;
  final int messageCount;
  final Map<LiveReactionType, int> reactionCounts;
}
