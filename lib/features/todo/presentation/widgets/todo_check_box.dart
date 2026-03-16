import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class TodoCheckBox extends StatelessWidget {
  final ColorScheme colors;
  final bool isSelected;
  final VoidCallback? onTap;

  const TodoCheckBox({
    super.key,
    required this.colors,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
          Icons.check,
          color: isSelected ? colors.primary : colors.surface,
          size: 16,
          // 두 껍게 하기 위해
          shadows: [
            Shadow(
              color: isSelected ? colors.primary : colors.surface,
              offset: const Offset(0.6, 0),
              blurRadius: 0,
            ),
            Shadow(
              color: isSelected ? colors.primary : colors.surface,
              offset: const Offset(-0.6, 0),
              blurRadius: 0,
            ),
            Shadow(
              color: isSelected ? colors.primary : colors.surface,
              offset: const Offset(0, 0.6),
              blurRadius: 0,
            ),
            Shadow(
              color: isSelected ? colors.primary : colors.surface,
              offset: const Offset(0, -0.6),
              blurRadius: 0,
            ),
          ],
        )
        .centered()
        .box
        .size(26, 26)
        .roundedSM
        .color(isSelected ? colors.primary.withAlpha(80) : colors.surface)
        .border(
          color: isSelected
              ? colors.primary
              : colors.onSecondaryContainer.withAlpha(180),
          width: 2.0,
        )
        .make()
        .pOnly(top: 3)
        .onTap(onTap);
  }
}
