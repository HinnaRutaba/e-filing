import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CMNavTab { dashboard, summaries }

class CMNavController extends StateNotifier<CMNavTab> {
  CMNavController() : super(CMNavTab.dashboard);

  void select(CMNavTab tab) => state = tab;
}

final cmNavController = StateNotifierProvider<CMNavController, CMNavTab>(
  (ref) => CMNavController(),
);
