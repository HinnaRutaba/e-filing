import 'dart:developer';

import 'package:efiling_balochistan/config/router/app_router.dart';
import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:flutter/material.dart';

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
      final BuildContext context = AppRouter.navigatorKey.currentContext!;
      Future.delayed(Duration.zero, () {
        showingSessionExpiredDialog = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
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
                      onPressed: () {
                        // ProviderScope.containerOf(context)
                        //     .read(authController)
                        //     .logout();
                        showingSessionExpiredDialog = false; // Close the dialog
                      },
                      text: "OK",
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      });
    } catch (e, s) {
      log("SESSION HANDLE CATCH_____${e}_____$s");
    }
  }
}
