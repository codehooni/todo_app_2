import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app_2/features/todo/domain/models/tag.dart';
import 'package:todo_app_2/features/todo/presentation/providers/tag_list_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:velocity_x/velocity_x.dart';

class TagDialogService {
  TagDialogService._();

  static const _presetColors = [
    Color(0xFFEF5350),
    Color(0xFFFF7043),
    Color(0xFFFFCA28),
    Color(0xFF66BB6A),
    Color(0xFF26C6DA),
    Color(0xFF42A5F5),
    Color(0xFF7E57C2),
    Color(0xFFEC407A),
  ];

  static void showAddTagDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    var selectedColor = _presetColors[5];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('태그 추가'),
          content: VStack([
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: '태그 이름'),
              autofocus: true,
            ),
            16.heightBox,
            Wrap(
              spacing: 8,
              children: _presetColors.map((color) {
                final isSelected = color == selectedColor;
                return Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                    boxShadow: isSelected
                        ? [BoxShadow(color: color.withAlpha(160), blurRadius: 6)]
                        : null,
                  ),
                )
                    .animate(target: isSelected ? 1.0 : 0.0)
                    .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.1, 1.1), duration: 150.ms)
                    .onTap(() => setState(() => selectedColor = color));
              }).toList(),
            ),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final tag = Tag(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: name,
                  color: selectedColor,
                );
                ref.read(tagListProvider.notifier).add(tag);
                Navigator.pop(ctx);
              },
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }
}