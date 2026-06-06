import 'package:go_router/go_router.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';

class AppRouter {
  static GoRouter router(AuthController authController) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final isAuthenticated = authController.isAuthenticated;
        final isAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';
        final isSplash = state.matchedLocation == '/splash';

        if (isSplash) return null;
        if (!isAuthenticated && !isAuthRoute) return '/login';
        if (isAuthenticated && isAuthRoute) return '/home';
        return null;
      },
      refreshListenable: authController,
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
    );
  }
}
