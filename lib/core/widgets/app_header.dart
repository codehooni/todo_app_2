import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.alignment = CrossAxisAlignment.center,
    this.titleStyle,
    this.subtitleStyle,
  });

  final String title;
  final String? subtitle;
  final CrossAxisAlignment alignment;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textAlign = alignment == CrossAxisAlignment.center
        ? TextAlign.center
        : TextAlign.start;

    final effectiveTitleStyle = TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: colors.onPrimary,
    ).merge(titleStyle);

    final effectiveSubtitleStyle = TextStyle(
      fontSize: 18,
      color: colors.onPrimaryContainer,
    ).merge(subtitleStyle);

    return VStack(
      [
        Text(title, style: effectiveTitleStyle, textAlign: textAlign),
        if (subtitle != null) ...[
          4.heightBox,
          Text(subtitle!, style: effectiveSubtitleStyle, textAlign: textAlign),
        ],
      ],
      crossAlignment: alignment,
    );
  }
}
