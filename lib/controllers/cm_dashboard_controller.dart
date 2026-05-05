import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CMDashboardModel {
  final int awaitingApprovalCount;
  final int activeInProgressCount;
  final int totalSummariesCount;
  final int closedDisposedCount;
  final bool loading;

  CMDashboardModel({
    this.awaitingApprovalCount = 0,
    this.activeInProgressCount = 0,
    this.totalSummariesCount = 0,
    this.closedDisposedCount = 0,
    this.loading = false,
  });

  CMDashboardModel copyWith({
    int? awaitingApprovalCount,
    int? activeInProgressCount,
    int? totalSummariesCount,
    int? closedDisposedCount,
    bool? loading,
  }) {
    return CMDashboardModel(
      awaitingApprovalCount:
          awaitingApprovalCount ?? this.awaitingApprovalCount,
      activeInProgressCount:
          activeInProgressCount ?? this.activeInProgressCount,
      totalSummariesCount: totalSummariesCount ?? this.totalSummariesCount,
      closedDisposedCount: closedDisposedCount ?? this.closedDisposedCount,
      loading: loading ?? this.loading,
    );
  }
}

class CMDashboardController extends BaseControllerState<CMDashboardModel> {
  CMDashboardController(super.state, super.ref);

  Future<void> initData() async {
    state = state.copyWith(loading: true);

    // TODO: Replace with real API calls
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      awaitingApprovalCount: 14,
      activeInProgressCount: 27,
      totalSummariesCount: 63,
      closedDisposedCount: 102,
      loading: false,
    );
  }
}

final cmDashboardController =
    StateNotifierProvider<CMDashboardController, CMDashboardModel>(
      (ref) => CMDashboardController(CMDashboardModel(), ref),
    );
