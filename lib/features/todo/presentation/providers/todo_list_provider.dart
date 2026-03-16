import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app_2/features/todo/domain/models/todo.dart';
import 'package:todo_app_2/features/todo/presentation/providers/todo_repository_provider.dart';
import 'package:todo_app_2/features/user/presentation/providers/user_provider.dart';

class TodoListNotifier extends AsyncNotifier<List<Todo>> {
  @override
  FutureOr<List<Todo>> build() async {
    final user = await ref.watch(userProvider.future);
    if (user == null) return [];
    return ref.read(todoRepositoryProvider).getTodos(user.id);
  }

  Future<void> add(Todo todo) async {
    await ref.read(todoRepositoryProvider).saveTodo(todo);
    ref.invalidateSelf();
  }

  Future<void> edit(Todo todo) async {
    await ref.read(todoRepositoryProvider).updateTodo(todo);
    ref.invalidateSelf();
  }

  Future<void> remove(String id) async {
    await ref.read(todoRepositoryProvider).deleteTodo(id);
    ref.invalidateSelf();
  }

  Future<void> toggleComplete(Todo todo) async {
    final updated = Todo(
      userId: todo.userId,
      id: todo.id,
      title: todo.title,
      imageUrl: todo.imageUrl,
      tagIds: todo.tagIds,
      createdAt: todo.createdAt,
      updatedAt: DateTime.now(),
      isCompleted: !todo.isCompleted,
    );
    await edit(updated);
  }
}

final todoListProvider = AsyncNotifierProvider<TodoListNotifier, List<Todo>>(
  TodoListNotifier.new,
);
