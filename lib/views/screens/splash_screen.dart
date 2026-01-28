import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/assets_constants.dart';
import 'package:efiling_balochistan/constants/hero_tags.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/user_model.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/web_view/file_support_web_view.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final bool navigate;
  const SplashScreen({super.key, this.navigate = true});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  navigateToWebView() {
    if (widget.navigate) {
      try {
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  const InAppWebViewWithFileUpload(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        });
      } catch (e, s) {
        print("ERRR_______${e}_____$s");
      }
    }
  }

  navigateToApp() {
    Future.delayed(const Duration(milliseconds: 500), () {
      RouteHelper.navigateTo(Routes.login);
    });
  }

  fetchData() async {
    final ctrl = ref.read(authController.notifier);
    final loggedIn = await ctrl.isLoggedIn();
    if (!loggedIn) {
      RouteHelper.navigateTo(Routes.login);
      return;
    }
    await ctrl.fetchLoggedInUser();
    ctrl.getOpenAIToken();
    DesignationModel? designation = await ctrl.fetchDesignation();
    if (designation == null) {
      RouteHelper.navigateTo(Routes.login);
      return;
    }
    RouteHelper.navigateTo(Routes.dashboard);
  }

  @override
  void initState() {
    //navigateToWebView();

    fetchData();
    super.initState();
  }

  Widget logo() {
    return Hero(
      tag: HeroTags.logo,
      child: Image.asset(
        AssetsConstants.logo,
        height: 200,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GradientScaffold(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Spacer(),
                widget.navigate
                    ? logo()
                        .animate()
                        // .scale(
                        //   duration: const Duration(milliseconds: 600),
                        // )
                        .fade(
                          // delay: const Duration(milliseconds: 100),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        )
                    : logo(),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      AppText.titleSmall("Powered By"),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              AssetsConstants.cmduLogo,
                              height: 72,
                            ),
                          ),
                          const SizedBox(width: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(1.0),
                            child: Image.asset(
                              AssetsConstants.govtLogo,
                              height: 64,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
