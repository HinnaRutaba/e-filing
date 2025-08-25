import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/views/screens/chats/file_chat_screen.dart';
import 'package:efiling_balochistan/views/screens/dashboard/dashboard_screen.dart';
import 'package:efiling_balochistan/views/screens/files/action_required_files_screen.dart';
import 'package:efiling_balochistan/views/screens/files/archived_files_screen.dart';
import 'package:efiling_balochistan/views/screens/files/create_new_file_screen.dart';
import 'package:efiling_balochistan/views/screens/files/file_card.dart';
import 'package:efiling_balochistan/views/screens/files/file_details_screen.dart';
import 'package:efiling_balochistan/views/screens/files/forwarded_files_screen.dart';
import 'package:efiling_balochistan/views/screens/files/my_files_screen.dart';
import 'package:efiling_balochistan/views/screens/files/pending_files_screen.dart';
import 'package:efiling_balochistan/views/screens/login_screen.dart';
import 'package:efiling_balochistan/views/screens/settings/change_password_screen.dart';
import 'package:efiling_balochistan/views/screens/settings/designations_screen.dart';
import 'package:efiling_balochistan/views/screens/settings/sections_screen.dart';
import 'package:efiling_balochistan/views/screens/settings/settings_screen.dart';
import 'package:efiling_balochistan/views/screens/settings/users_screen.dart';
import 'package:efiling_balochistan/views/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:go_transitions/go_transitions.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static GoRouter get router => _router;

  static final List<RouteBase> _routes = [
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: Routes.login,
      pageBuilder: GoTransitions.fadeUpwards.build(
        settings: GoTransitionSettings(duration: 500.ms),
        builder: (context, state) => const LoginScreen(),
      ),
    ),
    GoRoute(
      path: Routes.dashboard,
      pageBuilder: GoTransitions.slide.toRight.withFade.build(
        settings: GoTransitionSettings(duration: 300.ms),
        builder: (context, state) => const DashboardScreen(),
      ),
    ),
    GoRoute(
      path: Routes.createFile,
      pageBuilder: GoTransitions.slide.toRight.withFade.build(
        settings: GoTransitionSettings(duration: 300.ms),
        builder: (context, state) => const CreateNewFileScreen(),
      ),
    ),
    GoRoute(
      path: Routes.fileDetails(),
      pageBuilder: GoTransitions.slide.toTop.build(
        settings: GoTransitionSettings(duration: 300.ms),
        builder: (context, state) => FileDetailsScreen(
          fileId:
              int.tryParse(state.pathParameters[PathParams.fileId] ?? '-1') ??
                  -1,
          fileType: state.extra as FileType,
        ),
      ),
      redirect: (context, state) {
        if (state.pathParameters[PathParams.fileId] == null) {
          return Routes.dashboard;
        }
        return null;
      },
    ),
    GoRoute(
      path: Routes.fileChat(),
      pageBuilder: GoTransitions.slide.toTop.build(
        settings: GoTransitionSettings(duration: 300.ms),
        builder: (context, state) => FileChatScreen(
          fileId:
              int.tryParse(state.pathParameters[PathParams.fileId] ?? '-1') ??
                  -1,
        ),
      ),
      redirect: (context, state) {
        if (state.pathParameters[PathParams.fileId] == null) {
          return Routes.dashboard;
        }
        return null;
      },
    ),
    GoRoute(
      path: Routes.pendingFiles,
      pageBuilder: GoTransitions.slide.toRight.withFade.build(
        settings: GoTransitionSettings(duration: 300.ms),
        builder: (context, state) => const PendingFilesScreen(),
      ),
    ),
    GoRoute(
      path: Routes.myFiles,
      pageBuilder: GoTransitions.slide.toRight.withFade.build(
        settings: GoTransitionSettings(duration: 300.ms),
        builder: (context, state) => const MyFilesScreen(),
      ),
    ),
    GoRoute(
      path: Routes.actionRequiredFiles,
      pageBuilder: GoTransitions.slide.toRight.withFade.build(
        settings: GoTransitionSettings(duration: 300.ms),
        builder: (context, state) => const ActionRequiredFilesScreen(),
      ),
    ),
    GoRoute(
      path: Routes.archived,
      pageBuilder: GoTransitions.slide.toRight.withFade.build(
        settings: GoTransitionSettings(duration: 300.ms),
        builder: (context, state) => const ArchivedFilesScreen(),
      ),
    ),
    GoRoute(
      path: Routes.forwarded,
      pageBuilder: GoTransitions.slide.toRight.withFade.build(
        settings: GoTransitionSettings(duration: 300.ms),
        builder: (context, state) => const ForwardedFilesScreen(),
      ),
    ),
    GoRoute(
      path: Routes.settings,
      pageBuilder: GoTransitions.slide.toRight.withFade.build(
        settings: GoTransitionSettings(duration: 300.ms),
        builder: (context, state) => const SettingsScreen(),
      ),
    ),
    GoRoute(
      path: Routes.users,
      pageBuilder: GoTransitions.slide.toRight.withFade.build(
        settings: GoTransitionSettings(duration: 300.ms),
        builder: (context, state) => const UsersScreen(),
      ),
    ),
    GoRoute(
      path: Routes.sections,
      pageBuilder: GoTransitions.slide.toRight.withFade.build(
        settings: GoTransitionSettings(duration: 300.ms),
        builder: (context, state) => const SectionsScreen(),
      ),
    ),
    GoRoute(
      path: Routes.designations,
      pageBuilder: GoTransitions.slide.toRight.withFade.build(
        settings: GoTransitionSettings(duration: 300.ms),
        builder: (context, state) => const DesignationsScreen(),
      ),
    ),
    GoRoute(
      path: Routes.changePassword,
      pageBuilder: GoTransitions.slide.toRight.withFade.build(
        settings: GoTransitionSettings(duration: 300.ms),
        builder: (context, state) => const ChangePasswordScreen(),
      ),
    ),
  ];

  static final GoRouter _router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: Routes.splash,
    routes: _routes,
    redirect: (BuildContext context, GoRouterState state) async {
      if (state.uri.path == Routes.splash) {
        return null;
      }
      final bool isOnBoardingRoute = state.uri.path == Routes.login;
      //|| state.uri.path == Routes.resetPassword ||
      //state.uri.path == Routes.onboarding;
      final bool isSignedIn = await ProviderScope.containerOf(context)
          .read(authController)
          .isLoggedIn();

      if (!isSignedIn) {
        if (isOnBoardingRoute) {
          return null;
        }
        return Routes.login;
      } else {
        if (isOnBoardingRoute) {
          return Routes.dashboard;
        }
        return null;
      }
    },
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: const Scaffold(
        body: Center(
          child: Text('Page not found'),
        ),
      ),
    ),
  );
}
