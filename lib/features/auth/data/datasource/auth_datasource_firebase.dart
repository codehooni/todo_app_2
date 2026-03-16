import 'package:firebase_auth/firebase_auth.dart';

import 'auth_datasource.dart';

class AuthDatasourceFirebase implements AuthDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Stream<String?> authStateChanges() =>
      _auth.authStateChanges().map((user) => user?.uid);

  @override
  Future<String> signUp({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user!.uid;
  }

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user!.uid;
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  String? get currentUid => _auth.currentUser?.uid;
}
