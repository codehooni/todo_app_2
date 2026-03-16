import 'package:flutter/material.dart';
import 'package:todo_app_2/features/todo/domain/models/tag.dart';
import 'package:velocity_x/velocity_x.dart';

class TodoTag extends StatelessWidget {
  const TodoTag({super.key, required this.tag});

  final Tag tag;

  @override
  Widget build(BuildContext context) {
    return tag.title.text.base.bold
        .color(tag.color)
        .letterSpacing(-1.5)
        .make()
        .px8()
        .py4()
        .box
        .roundedSM
        .color(tag.color.withAlpha(60))
        .make();
  }
}
