import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>(
  (_) => UserRepositoryImpl(),
);
