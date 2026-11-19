import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../model/hashtag.dart';
import '../../../model/post/post_content.dart';
import '../../../provider/feed/feeds_list_provider.dart';
import '../../../util/const/ui/ui_constants.dart';

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
      return hashtag == null
          ? segment.text
          : _HashtagTextParts(hashtag, segment.text).fullText;
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
        theme.brightness,
        hashtag,
      );
      if (hashtag == null || segment.text.trim().isEmpty) {
        spans.add(TextSpan(text: segment.text, style: style));
        continue;
      }

      final parts = _HashtagTextParts(hashtag, segment.text);
      if (parts.leading.isNotEmpty) {
        spans.add(TextSpan(text: parts.leading, style: baseStyle));
      }
      spans.add(
        TextSpan(
          text: parts.linkedText,
          style: style,
          recognizer: _recognizerFor(
            index,
            hashtag,
            context,
            activeRecognizers,
          ),
        ),
      );
      if (parts.trailing.isNotEmpty) {
        spans.add(TextSpan(text: parts.trailing, style: baseStyle));
      }
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
    Brightness brightness,
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

    final color = brightness == Brightness.dark
        ? UIConstants.darkHashtagLinkColor
        : UIConstants.lightHashtagLinkColor;
    return style?.copyWith(
      color: color,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.none,
    );
  }
}

class _HashtagTextParts {
  _HashtagTextParts(Hashtag hashtag, String rawText)
    : _rawText = rawText,
      _leadingLength = rawText.length - rawText.trimLeft().length,
      _trailingLength = rawText.length - rawText.trimRight().length,
      text = rawText.trim(),
      emoji = hashtag.emoji == null ? '' : '${hashtag.emoji}\u00A0';

  final String _rawText;
  final int _leadingLength;
  final int _trailingLength;
  final String text;
  final String emoji;

  String get leading => _rawText.substring(0, _leadingLength);
  String get trailing => _trailingLength == 0
      ? ''
      : _rawText.substring(_rawText.length - _trailingLength);
  String get linkedText => '$emoji$text';
  String get fullText => '$leading$linkedText$trailing';
}
