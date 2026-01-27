import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:efiling_balochistan/controllers/connectivity_controller.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityScaffold extends ConsumerWidget {
  final Widget body;
  const ConnectivityScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool showingToast = false;
    final controller = ref.read(connectivityController.notifier);
    return StreamBuilder<ConnectivityViewModel>(
        stream: controller.connectivityStream(),
        builder: (context, ss) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ss.data?.showToast == true && showingToast == false) {
              showingToast = true;
              if (ss.data?.connectivity == ConnectivityResult.none) {
                showNoConnectionToast();
              } else {
                //showConnectionRestoredToast();
              }
            }
          });
          return body;
        });
  }

  showNoConnectionToast() {
    Toast.error(
        message:
            "Internet connection lost, some feature might be unavailable,");
  }

  showConnectionRestoredToast() {
    Toast.success(message: "You're back online");
  }
}
