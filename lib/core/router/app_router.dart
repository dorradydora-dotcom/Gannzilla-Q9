import 'package:go_router/go_router.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/whale_feed_screen.dart';
import '../../features/home/screens/signals_screen.dart';
import '../widgets/exit_confirmation_wrapper.dart';
import '../../features/splash/no_internet_screen.dart';

class AppRouter {
  static GoRouter router(AuthController authController) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final isAuthenticated = authController.isAuthenticated;
        final isAuthRoute = state.matchedLocation == '/register';
        final isSplash = state.matchedLocation == '/splash';
        final isNoInternet = state.matchedLocation == '/no-internet';

        if (isSplash || isNoInternet) return null;
        if (!isAuthenticated && !isAuthRoute) return '/register';
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
          path: '/no-internet',
          builder: (context, state) => const NoInternetScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) =>
              const ExitConfirmationWrapper(child: RegisterScreen()),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) =>
              const ExitConfirmationWrapper(child: HomeScreen()),
        ),
        GoRoute(
          path: '/whale-feed',
          builder: (context, state) {
            final tab = int.tryParse(
                    state.uri.queryParameters['tab'] ?? '0') ??
                0;
            return WhaleFeedScreen(initialTab: tab);
          },
        ),
        GoRoute(
          path: '/signals',
          builder: (context, state) {
            final tab = int.tryParse(
                    state.uri.queryParameters['tab'] ?? '0') ??
                0;
            return SignalsScreen(initialTab: tab);
          },
        ),
      ],
    );
  }
}
