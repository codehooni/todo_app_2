import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return child
        .py32()
        .px24()
        .box
        .roundedLg
        .color(colors.primaryContainer)
        .makeCentered()
        .p16();
  }
}