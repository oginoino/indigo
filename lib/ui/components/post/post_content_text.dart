import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../model/hashtag.dart';
import '../../../model/post/post_content.dart';
import '../../../provider/feed/feeds_list_provider.dart';

class PostContentText extends StatefulWidget {
  const PostContentText({
    required this.content,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.selectable = false,
    super.key,
  });

  final PostContent content;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;
  final bool selectable;

  static String displayText(BuildContext context, PostContent content) {
    final feeds = Provider.of<FeedsListProvider?>(context, listen: false);
    if (feeds == null) return content.plainText;

    return content.segments.map((segment) {
      final entity = segment.entity;
      if (entity?.type != PostTextEntityType.hashtag) return segment.text;

      final hashtag = feeds.hashtagById(entity!.id ?? entity.value);
      return '${hashtag?.emoji == null ? '' : '${hashtag!.emoji} '}${segment.text}';
    }).join();
  }

  @override
  State<PostContentText> createState() => _PostContentTextState();
}

class _PostContentTextState extends State<PostContentText> {
  final Map<int, TapGestureRecognizer> _recognizers = {};

  @override
  void dispose() {
    for (final recognizer in _recognizers.values) {
      recognizer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = widget.style ?? theme.textTheme.bodyLarge;
    final activeRecognizers = <int>{};
    final spans = <InlineSpan>[];

    for (var index = 0; index < widget.content.segments.length; index++) {
      final segment = widget.content.segments[index];
      final entity = segment.entity;
      Hashtag? hashtag;
      if (entity?.type == PostTextEntityType.hashtag) {
        hashtag = Provider.of<FeedsListProvider?>(
          context,
          listen: false,
        )?.hashtagById(entity!.id ?? entity.value);
      }

      final style = _styleFor(
        baseStyle,
        segment.styles,
        theme.colorScheme,
        hashtag,
      );
      final recognizer = hashtag == null
          ? null
          : _recognizerFor(index, hashtag, context, activeRecognizers);
      final displayText =
          '${hashtag?.emoji == null ? '' : '${hashtag!.emoji} '}${segment.text}';
      spans.add(
        TextSpan(text: displayText, style: style, recognizer: recognizer),
      );
    }

    for (final index in _recognizers.keys.toList()) {
      if (activeRecognizers.contains(index)) continue;
      _recognizers.remove(index)!.dispose();
    }

    final text = TextSpan(style: baseStyle, children: spans);
    if (widget.selectable) {
      return SelectableText.rich(
        text,
        maxLines: widget.maxLines,
        textAlign: TextAlign.start,
      );
    }

    return Text.rich(
      text,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      textAlign: TextAlign.start,
      textScaler: MediaQuery.textScalerOf(context),
    );
  }

  TapGestureRecognizer _recognizerFor(
    int index,
    Hashtag hashtag,
    BuildContext context,
    Set<int> activeRecognizers,
  ) {
    activeRecognizers.add(index);
    final recognizer = _recognizers.putIfAbsent(
      index,
      TapGestureRecognizer.new,
    );
    recognizer.onTap = () {
      context.read<FeedsListProvider>().openHashtag(hashtag);
      context.go(hashtag.route);
    };
    return recognizer;
  }

  TextStyle? _styleFor(
    TextStyle? baseStyle,
    Set<PostTextStyle> styles,
    ColorScheme colorScheme,
    Hashtag? hashtag,
  ) {
    var style = baseStyle;
    if (styles.contains(PostTextStyle.bold)) {
      style = style?.copyWith(fontWeight: FontWeight.bold);
    }
    if (styles.contains(PostTextStyle.italic)) {
      style = style?.copyWith(fontStyle: FontStyle.italic);
    }
    if (styles.contains(PostTextStyle.underline)) {
      style = style?.copyWith(decoration: TextDecoration.underline);
    }
    if (styles.contains(PostTextStyle.strikethrough)) {
      style = style?.copyWith(decoration: TextDecoration.lineThrough);
    }
    if (styles.contains(PostTextStyle.code)) {
      style = style?.copyWith(fontFamily: 'monospace');
    }
    if (hashtag == null) return style;

    final color = switch (hashtag.type) {
      HashtagType.user => colorScheme.primary,
      HashtagType.official => colorScheme.tertiary,
      HashtagType.community => colorScheme.secondary,
    };
    return style?.copyWith(
      color: color,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: color,
    );
  }
}
