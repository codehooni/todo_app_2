import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.borderRadius = 8.0,
    this.backgroundColor,
    this.icon,
    this.textColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        backgroundColor: backgroundColor,
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const CircularProgressIndicator(
              strokeWidth: 2,
            ).box.size(25, 25).make()
          : icon != null
          ? HStack([
              Icon(icon, size: 20),
              8.widthBox,
              label.text.xl.bold
                  .color(Theme.of(context).colorScheme.onSecondary)
                  .make(),
            ], axisSize: MainAxisSize.min)
          : label.text.xl.bold
                .color(textColor ?? Theme.of(context).colorScheme.onSecondary)
                .make(),
    ).wFull(context);
  }
}
