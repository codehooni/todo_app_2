import '../datasource/auth_datasource.dart';
import '../datasource/auth_datasource_firebase.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _datasource;

  AuthRepositoryImpl([AuthDatasource? datasource])
    : _datasource = datasource ?? AuthDatasourceFirebase();

  @override
  Stream<String?> authStateChanges() => _datasource.authStateChanges();

  @override
  Future<String> signUp({required String email, required String password}) =>
      _datasource.signUp(email: email, password: password);

  @override
  Future<String> signIn({required String email, required String password}) =>
      _datasource.signIn(email: email, password: password);

  @override
  Future<void> signOut() => _datasource.signOut();

  @override
  String? get currentUid => _datasource.currentUid;
}
