import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'todo_repository_provider.dart';

class DraftNotifier extends AsyncNotifier<Map<String, dynamic>?> {
  @override
  Future<Map<String, dynamic>?> build() =>
      ref.read(todoRepositoryProvider).getDraft();

  Future<void> save(Map<String, dynamic> data) async {
    await ref.read(todoRepositoryProvider).saveDraft(data);
    ref.invalidateSelf();
  }

  Future<void> clear() async {
    await ref.read(todoRepositoryProvider).clearDraft();
    ref.invalidateSelf();
  }
}

final draftProvider =
    AsyncNotifierProvider<DraftNotifier, Map<String, dynamic>?>(
      DraftNotifier.new,
    );
