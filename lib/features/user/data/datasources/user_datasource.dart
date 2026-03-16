import '../../domain/models/user.dart';

abstract class UserDatasource {
  Future<User?> fetchUser(String id);
  Future<void> createOrUpdateUser(User user);
  Future<void> deleteUser(String id);
}
