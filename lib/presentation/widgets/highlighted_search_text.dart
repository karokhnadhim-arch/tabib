import 'package:flutter/material.dart';

/// Renders [text] with the first [query] match highlighted (Google-style).
class HighlightedSearchText extends StatelessWidget {
  const HighlightedSearchText({
    super.key,
    required this.text,
    required this.query,
    this.style,
    this.highlightStyle,
    this.maxLines,
  });

  final String text;
  final String query;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? DefaultTextStyle.of(context).style;
    final q = query.trim().toLowerCase();
    if (q.length < 2 || text.isEmpty) {
      return Text(text, style: baseStyle, maxLines: maxLines, overflow: TextOverflow.ellipsis);
    }

    final lower = text.toLowerCase();
    final index = lower.indexOf(q);
    if (index < 0) {
      return Text(text, style: baseStyle, maxLines: maxLines, overflow: TextOverflow.ellipsis);
    }

    final highlight = highlightStyle ??
        baseStyle.copyWith(
          fontWeight: FontWeight.w700,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.18),
        );

    return RichText(
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(text: text.substring(index, index + q.length), style: highlight),
          TextSpan(text: text.substring(index + q.length)),
        ],
      ),
    );
  }
}
