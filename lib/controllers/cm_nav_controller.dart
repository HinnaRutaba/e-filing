import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CMNavTab { dashboard, summaries, approvals }

class CMNavController extends StateNotifier<CMNavTab> {
  CMNavController() : super(CMNavTab.dashboard);

  void select(CMNavTab tab) => state = tab;
}

final cmNavController = StateNotifierProvider<CMNavController, CMNavTab>(
  (ref) => CMNavController(),
);

/// Incrementing this triggers a reload of the CM Approval Desk.
final cmApprovalDeskRefreshProvider = StateProvider<int>((ref) => 0);

/// True once the launch-time auto-navigation to approvals has been handled
/// (either executed or blocked by a manual nav-bar tap).
final cmAutoNavConsumedProvider = StateProvider<bool>((ref) => false);
