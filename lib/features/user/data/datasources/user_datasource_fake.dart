import 'package:todo_app_2/features/user/domain/models/user.dart';

import 'user_datasource.dart';

class UserDatasourceFake implements UserDatasource {
  final User _fakeUser = User(id: 'fake-1', name: 'Ceyhun');

  @override
  Future<User?> fetchUser(String id) async => _fakeUser;

  @override
  Future<void> createOrUpdateUser(User user) async {}

  @override
  Future<void> deleteUser(String id) async {}
}
