import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../domain/models/user.dart';
import 'user_repository_provider.dart';

class UserNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    debugPrint('[UserProvider] build() start');
    final uid = await ref.watch(authStateProvider.future);
    debugPrint('[UserProvider] uid resolved: $uid');
    if (uid == null) return null;
    debugPrint('[UserProvider] calling getUser($uid)...');
    final result = await ref.read(userRepositoryProvider).getUser(uid);
    debugPrint('[UserProvider] getUser result: $result');
    return result;
  }

  Future<void> save(User user) async {
    await ref.read(userRepositoryProvider).saveUser(user);
    state = AsyncData(user);
  }

  Future<void> delete(String id) async {
    await ref.read(userRepositoryProvider).deleteUser(id);
    state = const AsyncData(null);
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, User?>(
  UserNotifier.new,
);
