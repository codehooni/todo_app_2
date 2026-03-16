import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app_2/features/todo/domain/models/tag.dart';
import 'package:todo_app_2/features/todo/presentation/providers/todo_repository_provider.dart';

class TagListNotifier extends AsyncNotifier<List<Tag>> {
  @override
  FutureOr<List<Tag>> build() => ref.read(todoRepositoryProvider).getTags();

  Future<void> add(Tag tag) async {
    await ref.read(todoRepositoryProvider).saveTag(tag);
    ref.invalidateSelf();
  }

  Future<void> remove(String id) async {
    await ref.read(todoRepositoryProvider).deleteTag(id);
    ref.invalidateSelf();
  }
}

final tagListProvider = AsyncNotifierProvider<TagListNotifier, List<Tag>>(
  TagListNotifier.new,
);
