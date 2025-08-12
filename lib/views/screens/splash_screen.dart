import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/assets_constants.dart';
import 'package:efiling_balochistan/constants/hero_tags.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/web_view/file_support_web_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  final bool navigate;
  const SplashScreen({super.key, this.navigate = true});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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

  @override
  void initState() {
    //navigateToWebView();
    navigateToApp();
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
    return GradientScaffold(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
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
            ],
          ),
        ),
      ),
    );
  }
}
