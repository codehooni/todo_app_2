import 'package:todo_app_2/features/user/data/datasources/user_datasource.dart';
import 'package:todo_app_2/features/user/domain/models/user.dart';

class UserDatasourceHive extends UserDatasource {
  @override
  Future<void> createOrUpdateUser(User user) {
    // TODO: implement createOrUpdateUser
    throw UnimplementedError();
  }

  @override
  Future<void> deleteUser(String id) {
    // TODO: implement deleteUser
    throw UnimplementedError();
  }

  @override
  Future<User?> fetchUser(String id) {
    // TODO: implement fetchUser
    throw UnimplementedError();
  }
}
