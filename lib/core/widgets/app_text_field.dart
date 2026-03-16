import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType,
    this.autocorrect = true,
    this.textInputAction,
    this.borderRadius = 8,
    this.contentPadding,
  });

  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final Widget? prefixIcon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final bool autocorrect;
  final TextInputAction? textInputAction;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final field = TextField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscureText,
      keyboardType: widget.keyboardType,
      autocorrect: widget.autocorrect,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        filled: true,
        fillColor: colors.secondaryContainer.withAlpha(120),
        hintText: widget.hintText,
        hintStyle: TextStyle(color: colors.onSecondaryContainer),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.isPassword
            ? Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: colors.onSecondaryContainer,
                size: 22,
              ).onTap(() => setState(() => _obscureText = !_obscureText))
            : null,
        contentPadding: widget.contentPadding,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: colors.outline),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.outline),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.primary, width: 2),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );

    if (widget.label == null) return field;

    return VStack([
      widget.label!.text.base.semiBold.color(colors.onSurface).make(),
      8.heightBox,
      field,
    ]);
  }
}
