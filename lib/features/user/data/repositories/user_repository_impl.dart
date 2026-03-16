import '../../domain/models/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_datasource.dart';
import '../datasources/user_datasource_firebase.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDatasource _datasource;

  UserRepositoryImpl([UserDatasource? datasource])
    : _datasource = datasource ?? UserDatasourceFirebase();

  @override
  Future<User?> getUser(String id) => _datasource.fetchUser(id);

  @override
  Future<void> saveUser(User user) => _datasource.createOrUpdateUser(user);

  @override
  Future<void> deleteUser(String id) => _datasource.deleteUser(id);
}
