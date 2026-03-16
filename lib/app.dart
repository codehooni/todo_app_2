import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app_2/core/theme/dark_mode.dart';
import 'package:todo_app_2/core/theme/light_mode.dart';

import 'core/providers/theme_provider.dart';
import 'features/auth/presentation/providers/auth_state_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/todo/presentation/screens/list_screen.dart';
import 'features/user/presentation/providers/user_provider.dart';
import 'features/user/presentation/screens/profile_setup_screen.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final auth = ref.watch(authStateProvider);
    final user = ref.watch(userProvider);

    return MaterialApp(
      /// Theme
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: themeMode,

      /// Screen
      home: auth.when(
        data: (uid) {
          debugPrint('[App] auth uid=$uid');
          if (uid == null) return const LoginScreen();
          debugPrint(
            '[App] user state=${user.runtimeType}, isLoading=${user.isLoading}, hasValue=${user.hasValue}, value=${user.value}',
          );
          return user.when(
            data: (u) =>
                u == null ? const ProfileSetupScreen() : const ListScreen(),
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) {
              debugPrint('[App] userProvider error: $e');
              return const LoginScreen();
            },
          );
        },

        // Loading
        loading: () {
          debugPrint('[App] auth loading...');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },

        // Error
        error: (e, _) {
          debugPrint('[App] auth error: $e');
          return const LoginScreen();
        },
      ),
    );
  }
}
