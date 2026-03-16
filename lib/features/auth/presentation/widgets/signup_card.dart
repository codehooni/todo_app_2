import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_header.dart';
import '../../../../../core/widgets/app_text_field.dart';
import 'auth_card.dart';

class SignupCard extends StatelessWidget {
  const SignupCard({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.isLoading,
    required this.onSignUp,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool isLoading;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AuthCard(
      child: VStack(
        [
          const AppHeader(
            title: 'Sign Up',
            subtitle: '지금 바로 시작해보세요!',
          ).centered(),
          48.heightBox,

          AppTextField(
            controller: emailController,
            label: 'Email Address',
            hintText: 'name@example.com',
            prefixIcon: Icon(Icons.email, color: colors.onSecondaryContainer),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
          ),
          16.heightBox,

          AppTextField(
            controller: passwordController,
            label: 'Password',
            hintText: '비밀번호',
            prefixIcon: Icon(Icons.lock, color: colors.onSecondaryContainer),
            isPassword: true,
          ),
          16.heightBox,

          AppTextField(
            controller: confirmController,
            label: 'Confirm Password',
            hintText: '비밀번호 확인',
            prefixIcon: Icon(
              Icons.lock_outline,
              color: colors.onSecondaryContainer,
            ),
            isPassword: true,
          ),
          32.heightBox,

          AppButton(label: '회원가입', onPressed: onSignUp, isLoading: isLoading),
        ],
        alignment: MainAxisAlignment.center,
        axisSize: MainAxisSize.min,
      ),
    );
  }
}
