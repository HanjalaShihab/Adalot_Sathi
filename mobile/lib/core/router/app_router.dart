import 'package:flutter/material.dart';

import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/cases/case_detail_screen.dart';
import '../../presentation/screens/cases/case_form_screen.dart';
import '../../presentation/screens/deadlines/deadline_form_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/shell/main_shell.dart';
import '../../presentation/screens/upgrade/upgrade_screen.dart';

/// Route names.
abstract class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const shell = '/';
  static const home = '/home';
  static const cases = '/cases';
  static const profile = '/profile';
  static const caseDetail = '/cases/:id';
  static const caseCreate = '/cases/new';
  static const caseEdit = '/cases/:id/edit';
  static const deadlineCreate = '/cases/:caseId/deadlines/new';
  static const deadlineEdit = '/cases/:caseId/deadlines/:deadlineId/edit';
  static const upgrade = '/upgrade';

  /// Deep-link route for a deadline/case (used by push notification taps).
  static const deepLink = '/deeplink';
}

/// Central route table. Deep links resolve here so a push-notification tap can
/// navigate to a specific case/deadline without new navigation logic.
class AppRouter {
  AppRouter._();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    final args = settings.arguments;

    switch (name) {
      case AppRoutes.login:
        return _page(const LoginScreen());
      case AppRoutes.register:
        return _page(const RegisterScreen());
      case AppRoutes.shell:
        return _page(const MainShell());
      case AppRoutes.home:
        return _page(const HomeScreen());
      case AppRoutes.cases:
        return _page(const MainShell(initialIndex: 1));
      case AppRoutes.profile:
        return _page(const MainShell(initialIndex: 2));
      case AppRoutes.caseDetail:
        return _page(CaseDetailScreen(caseId: (args as int)));
      case AppRoutes.caseCreate:
        return _page(const CaseFormScreen());
      case AppRoutes.caseEdit:
        final map = args as Map<String, dynamic>;
        return _page(CaseFormScreen(caseId: map['id'] as int));
      case AppRoutes.deadlineCreate:
        final map = args as Map<String, dynamic>;
        return _page(DeadlineFormScreen(caseId: map['caseId'] as int));
      case AppRoutes.deadlineEdit:
        final map = args as Map<String, dynamic>;
        return _page(DeadlineFormScreen(
          caseId: map['caseId'] as int,
          deadlineId: map['deadlineId'] as int,
        ));
      case AppRoutes.upgrade:
        return _page(const UpgradeScreen());
      case AppRoutes.deepLink:
        final map = args as Map<String, dynamic>? ?? const {};
        final type = map['type'];
        if (type == 'deadline') {
          return _page(DeadlineFormScreen(
            caseId: map['caseId'] as int,
            deadlineId: map['deadlineId'] as int,
          ));
        }
        return _page(CaseDetailScreen(caseId: map['caseId'] as int));
      default:
        return null;
    }
  }

  static MaterialPageRoute<dynamic> _page(Widget screen) {
    return MaterialPageRoute(builder: (_) => screen);
  }
}


