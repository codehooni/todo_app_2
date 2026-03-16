abstract class AuthDatasource {
  Stream<String?> authStateChanges();
  Future<String> signUp({required String email, required String password});
  Future<String> signIn({required String email, required String password});
  Future<void> signOut();
  String? get currentUid;
}
