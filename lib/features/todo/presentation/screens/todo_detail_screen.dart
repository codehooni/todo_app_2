import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app_2/core/services/time_service.dart';
import 'package:todo_app_2/core/widgets/app_button.dart';
import 'edit_todo_screen.dart';
import 'package:todo_app_2/features/todo/domain/models/tag.dart';
import 'package:todo_app_2/features/todo/domain/models/todo.dart';
import 'package:todo_app_2/features/todo/presentation/providers/tag_list_provider.dart';
import 'package:todo_app_2/features/todo/presentation/providers/todo_list_provider.dart';
import 'package:todo_app_2/features/todo/presentation/widgets/todo_tag.dart';
import 'package:velocity_x/velocity_x.dart';

class TodoDetailScreen extends ConsumerWidget {
  const TodoDetailScreen({super.key, required this.todoId});

  final String todoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final todosAsync = ref.watch(todoListProvider);
    final tagsAsync = ref.watch(tagListProvider);
    final tags = tagsAsync.asData?.value ?? [];

    final todos = todosAsync.asData?.value ?? [];
    final matching = todos.where((t) => t.id == todoId);
    if (matching.isEmpty) return const Scaffold(body: SizedBox.shrink());
    final todo = matching.first;

    Tag? findTag(String id) {
      for (final t in tags) {
        if (t.id == id) return t;
      }
      return null;
    }

    final todoTags = todo.tagIds.map(findTag).whereType<Tag>().toList();

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        leading: BackButton(),
        title: '예약 상세'.text.xl2.bold.color(colors.onSurface).make(),
        centerTitle: true,
        actions: [
          // Edit
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditTodoScreen(todo: todo)),
            ),
          ),

          // Delete
          IconButton(
            icon: Icon(Icons.delete_outline, color: colors.error),
            onPressed: () => _confirmDelete(context, ref, todo),
          ),
        ],
      ),
      body: VStack([
        // Image
        if (todo.imageUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              todo.imageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                final total = loadingProgress.expectedTotalBytes;
                final loaded = loadingProgress.cumulativeBytesLoaded;
                final percent = total != null ? loaded / total : null;
                return SizedBox(
                  width: double.infinity,
                  height: 240,
                  child: VStack([
                    CircularProgressIndicator(
                      value: percent,
                      color: colors.primary,
                    ).centered(),
                    8.heightBox,
                    (percent != null
                            ? '${(percent * 100).toStringAsFixed(0)}%'
                            : '이미지 로딩 중...')
                        .text
                        .sm
                        .color(colors.onPrimaryContainer)
                        .make()
                        .centered(),
                  ]).centered(),
                ).box.color(colors.primaryContainer).make();
              },
            ),
          ),
          8.heightBox,
        ],

        // Title
        (todo.isCompleted
                ? todo.title.text.xl3.bold.color(colors.onPrimary).lineThrough
                : todo.title.text.xl3.bold.color(colors.onPrimary))
            .make(),
        8.heightBox,

        // Tags
        if (todoTags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: todoTags.map((tag) => TodoTag(tag: tag)).toList(),
          ),
          24.heightBox,
        ],

        // Time info
        _infoChip(
          colors,
          Icons.access_time_filled,
          TimeService.formatFull(todo.createdAt),
          context,
        ),

        Spacer(),

        if (!todo.isCompleted)
          AppButton(
            label: '완료하기',
            icon: Icons.check_circle_outline,
            onPressed: () {
              ref.read(todoListProvider.notifier).toggleComplete(todo);
              Navigator.pop(context);
            },
          ),
      ]).px16().safeArea(),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Todo todo,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dialogColors = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: const Text(
            '삭제하시겠어요?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('이 작업은 되돌릴 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('삭제', style: TextStyle(color: dialogColors.error)),
            ),
          ],
        );
      },
    );
    if (confirmed == true && context.mounted) {
      await ref.read(todoListProvider.notifier).remove(todo.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  Widget _infoChip(
    ColorScheme colors,
    IconData icon,
    String label,
    BuildContext context,
  ) {
    return VStack([
          'CREATED'.text.base.semiBold
              .color(colors.onSecondaryContainer)
              .make(),
          4.heightBox,
          HStack([
            Icon(icon, size: 20, color: colors.onSecondaryContainer),
            4.widthBox,
            label.text.xl.bold.color(colors.onSurface).make(),
          ]),
        ])
        .py12()
        .px16()
        .box
        .rounded
        .color(colors.secondaryContainer.withAlpha(120))
        .border(color: colors.tertiary)
        .make()
        .wFull(context);
  }
}
