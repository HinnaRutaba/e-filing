import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/views/screens/summaries/summaries_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CMSummariesListScreen extends ConsumerWidget {
  const CMSummariesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 24.0),
          child: SummariesListScreen(skipInitialLoad: true),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: IconButton(
            padding: const EdgeInsets.all(8),
            visualDensity: VisualDensity.compact,
            onPressed: () => ref.read(authController.notifier).logout(context),
            icon: Icon(Icons.power_settings_new, color: Colors.amber[800]),
          ),
        ),
      ],
    );
  }
}
