import 'dart:io';

import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:efiling_balochistan/config/router/app_router.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/connectivity_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tap_canvas/tap_canvas.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => const ProviderScope(
        child: MyApp(),
      ), // Wrap your app
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: TapCanvas(
        child: MaterialApp.router(
          builder: EasyLoading.init(builder: (context, child) {
            configLoading();
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.noScaling),
              child: ConnectivityScaffold(body: child!),
            );
          }),
          debugShowCheckedModeBanner: false,
          title: "E-Filing",
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}

void configLoading() {
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorType = EasyLoadingIndicatorType.threeBounce
    ..userInteractions = false
    ..dismissOnTap = false
    ..radius = 12
    ..boxShadow = [const BoxShadow()]
    ..backgroundColor = AppColors.cardColor
    ..indicatorColor = AppColors.secondary
    ..maskColor = Colors.transparent
    ..indicatorWidget = const SizedBox(
      width: 80,
      height: 80,
      child: SpinKitWanderingCubes(color: AppColors.secondaryDark),
    )
    ..contentPadding = const EdgeInsets.all(8)
    ..indicatorSize = 24
    ..textColor = AppColors.textPrimary;
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
