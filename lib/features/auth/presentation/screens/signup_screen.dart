import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/services/app_snack_bar.dart';
import '../providers/auth_repository_provider.dart';
import '../widgets/signup_card.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      AppSnackBar.showError(context, '모든 항목을 입력해주세요.');
      return;
    }

    if (password != confirm) {
      AppSnackBar.showError(context, '비밀번호가 일치하지 않습니다.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signUp(email: email, password: password);

      // authStateProvider emits uid → app.dart detects userProvider == null
      // → automatically routes to ProfileSetupScreen
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, _signUpErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SignupCard(
        emailController: _emailController,
        passwordController: _passwordController,
        confirmController: _confirmController,
        isLoading: _isLoading,
        onSignUp: _signUp,
      ),
    );
  }
}

String _signUpErrorMessage(Object e) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'invalid-email':
        return '이메일 형식이 올바르지 않습니다.';
      case 'weak-password':
        return '비밀번호는 6자리 이상이어야 합니다.';
      case 'network-request-failed':
        return '네트워크 연결을 확인해주세요.';
      case 'too-many-requests':
        return '너무 많은 시도가 있었습니다. 잠시 후 다시 시도해주세요.';
    }
  }
  return '회원가입 중 오류가 발생했습니다. 다시 시도해주세요.';
}