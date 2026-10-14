import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/active_user_desg_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';

class RouteHelper {
  static String? launchUrl;

  static String _currentLocation() {
    Uri uri = AppRouter.router.routeInformationProvider.value.uri;
    return uri.path;
  }

  static String get currentLocation => _currentLocation();

  /// The landing dashboard for [role]: CM and secretary have their own, every
  /// other role uses the standard one.
  static String homeRouteFor(ActiveUserDesgRole? role) => switch (role) {
    ActiveUserDesgRole.cm => Routes.cmDashboard,
    ActiveUserDesgRole.secretary => Routes.secretaryDashboard,
    _ => Routes.dashboard,
  };

  /// [homeRouteFor] the signed-in user's current role. Usable from anywhere
  /// (controllers, redirects) because it reads the role through the app's
  /// provider container rather than needing a `ref`.
  static String get homeRoute {
    final context = AppRouter.navigatorKey.currentContext;
    if (context == null) return Routes.dashboard;
    final role = ProviderScope.containerOf(
      context,
    ).read(authController).userDesgRole;
    return homeRouteFor(role);
  }

  /// Replace the stack with the current role's dashboard.
  static void navigateHome() => navigateTo(homeRoute);

  static bool isSubRoute() {
    return currentLocation.split('/').length > 2;
  }

  static navigateToLaunchUrl({bool clearUrl = true}) {
    if (launchUrl != null) {
      AppRouter.router.go('$launchUrl');
      if (clearUrl) launchUrl = null;
    }
  }

  static navigateTo(String path, {Object? extra}) {
    AppRouter.router.go(path, extra: extra);
  }

  static Future<dynamic> push(String path, {Object? extra}) {
    return AppRouter.router.push(path, extra: extra);
  }

  static Future<dynamic> pushWithExistingUri(String path, {Object? extra}) {
    return push('$currentLocation/$path', extra: extra);
  }

  static navigateWithExistingUri(String path, {Object? extra}) {
    navigateTo('$currentLocation/$path', extra: extra);
  }

  static pop([T]) {
    if (AppRouter.router.canPop()) {
      Uri.parse(currentLocation).replace(queryParameters: {}).toString();
      AppRouter.router.pop(T);
    }
  }
}
