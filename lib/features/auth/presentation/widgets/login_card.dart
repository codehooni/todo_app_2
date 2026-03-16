import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_header.dart';
import '../../../../../core/widgets/app_text_field.dart';
import 'auth_card.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onSignIn,
    required this.onSignUpTap,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onSignIn;
  final VoidCallback onSignUpTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AuthCard(
      child: VStack(
        [
          const AppHeader(
            title: 'Sign In',
            subtitle: '효율적으로 할 일을 관리해보세요!',
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
          32.heightBox,

          AppButton(label: '로그인', onPressed: onSignIn, isLoading: isLoading),
          28.heightBox,

          HStack([
            '계정이 없으신가요? '.text.color(colors.onPrimaryContainer).make(),
            '회원가입'.text.bold.color(colors.primary).make().onTap(onSignUpTap),
          ]).centered(),
        ],
        alignment: MainAxisAlignment.center,
        axisSize: MainAxisSize.min,
      ),
    );
  }
}
