import '../models/user.dart';

abstract class UserRepository {
  Future<User?> getUser(String id);
  Future<void> saveUser(User user);
  Future<void> deleteUser(String id);
}
