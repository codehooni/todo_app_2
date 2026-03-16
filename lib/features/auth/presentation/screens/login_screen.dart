import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/services/app_snack_bar.dart';
import '../providers/auth_repository_provider.dart';
import '../widgets/login_card.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      AppSnackBar.showError(context, '이메일과 비밀번호를 입력해주세요.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, _authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginCard(
        emailController: _emailController,
        passwordController: _passwordController,
        isLoading: _isLoading,
        onSignIn: _signIn,
        onSignUpTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SignupScreen()),
        ),
      ),
    );
  }
}

String _authErrorMessage(Object e) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
      case 'invalid-email':
        return '이메일 형식이 올바르지 않습니다.';
      case 'user-disabled':
        return '비활성화된 계정입니다. 고객센터에 문의해주세요.';
      case 'too-many-requests':
        return '로그인 시도가 너무 많습니다. 잠시 후 다시 시도해주세요.';
      case 'network-request-failed':
        return '네트워크 연결을 확인해주세요.';
    }
  }
  return '로그인 중 오류가 발생했습니다. 다시 시도해주세요.';
}
