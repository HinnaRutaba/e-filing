import 'app_router.dart';

class RouteHelper {
  static String? launchUrl;

  static String _currentLocation() {
    Uri uri = AppRouter.router.routeInformationProvider.value.uri;
    return uri.path;
  }

  static String get currentLocation => _currentLocation();

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
