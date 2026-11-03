import 'package:efiling_balochistan/config/router/app_router.dart';
import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionExpiredHandler {
  static final SessionExpiredHandler _instance =
      SessionExpiredHandler._internal();

  factory SessionExpiredHandler() {
    return _instance;
  }

  SessionExpiredHandler._internal();

  static bool showingSessionExpiredDialog = false;

  static handleExpiration() {
    try {
      if (showingSessionExpiredDialog ||
          RouteHelper.currentLocation == Routes.login ||
          RouteHelper.currentLocation == Routes.splash) {
        return;
      }
      // Set before the delay so concurrent 401/403s don't stack dialogs.
      showingSessionExpiredDialog = true;
      Future.delayed(Duration.zero, () {
        final BuildContext? context = AppRouter.navigatorKey.currentContext;
        if (context == null || !context.mounted) {
          showingSessionExpiredDialog = false;
          return;
        }
        showDialog(
          context: context,
          useRootNavigator: true,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return PopScope(
              canPop: false,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                backgroundColor: AppColors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText.headlineMedium("Session Expired"),
                      const SizedBox(height: 8),
                      AppText.bodyMedium(
                        "Your session has been expired. Please login in again to continue on this device.",
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      AppSolidButton(
                        onPressed: () async {
                          final container = ProviderScope.containerOf(
                            dialogContext,
                          );
                          Navigator.of(dialogContext).pop();
                          await container
                              .read(authController.notifier)
                              .forceLogout();
                          showingSessionExpiredDialog = false;
                        },
                        text: "OK",
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      });
    } catch (e, s) {
      showingSessionExpiredDialog = false;
      AppLogger.error(e, s, 'SESSION HANDLE CATCH');
    }
  }
}
