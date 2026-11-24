import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/application/otp_flow_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/verify_code_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../ui/splash_screen.dart';
import 'routes.dart';

/// Where a user may be, given their session.
/// Kept pure so it can be tested without a router.
String? authRedirect({
  required AsyncValue<Object?> auth,
  required String location,
  required bool codeSent,
}) {
  final restoring = auth.isLoading && !auth.hasValue;
  if (restoring) return location == Routes.splash ? null : Routes.splash;

  final signedIn = auth.value != null;
  final inAuth = location.startsWith(Routes.login);

  if (!signedIn) {
    if (location == Routes.verify && !codeSent) return Routes.login;
    return inAuth ? null : Routes.login;
  }
  if (inAuth || location == Routes.splash) return Routes.home;
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) => authRedirect(
      auth: ref.read(authControllerProvider),
      location: state.matchedLocation,
      codeSent: ref.read(otpFlowControllerProvider).codeSent,
    ),
    routes: [
      GoRoute(
        path: Routes.splash,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SplashScreen()),
      ),
      GoRoute(
        path: Routes.home,
        pageBuilder: (context, state) =>
            const CupertinoPage(child: HomeScreen()),
      ),
      GoRoute(
        path: Routes.login,
        pageBuilder: (context, state) =>
            const CupertinoPage(child: LoginScreen()),
        routes: [
          GoRoute(
            path: 'verify',
            pageBuilder: (context, state) =>
                const CupertinoPage(child: VerifyCodeScreen()),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
