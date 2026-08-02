import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application/auth/auth_controller.dart';
import 'core/config/app_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/shell/main_shell.dart';
import 'presentation/widgets/state_widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AdalotSathiApp()));
}

class AdalotSathiApp extends StatelessWidget {
  const AdalotSathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const AuthGate(),
    );
  }
}

/// Routes to Login or the MainShell based on auth session state.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (authState.isInitializing) {
      return const Scaffold(
        body: LoadingState(message: 'Adalot Sathi…'),
      );
    }

    if (authState.isAuthenticated) {
      return const MainShell();
    }

    return const LoginScreen();
  }
}


