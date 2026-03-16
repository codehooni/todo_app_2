import 'auth_datasource.dart';

class AuthDatasourceFake implements AuthDatasource {
  @override
  Stream<String?> authStateChanges() => Stream.value('fake-1');

  @override
  Future<String> signUp({required String email, required String password}) async => 'fake-1';

  @override
  Future<String> signIn({required String email, required String password}) async => 'fake-1';

  @override
  Future<void> signOut() async {}

  @override
  String? get currentUid => 'fake-1';
}
