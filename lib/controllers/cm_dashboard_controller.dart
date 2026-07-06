import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/summaries/cm_dashboard_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CMDashboardState {
  final CMDashboardModel? data;
  final bool loading;
  final String? error;

  const CMDashboardState({this.data, this.loading = false, this.error});

  CMDashboardState copyWith({
    CMDashboardModel? data,
    bool? loading,
    String? error,
  }) {
    return CMDashboardState(
      data: data ?? this.data,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}

class CMDashboardController
    extends BaseControllerState<CMDashboardState> {
  CMDashboardController(super.state, super.ref);

  Future<void> initData() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final userDesgId =
          ref.read(authController).currentDesignation?.userDesgId;
      final result = await ref
          .read(dashboardRepo)
          .getCmDashboard(userDesgId: userDesgId);
      state = state.copyWith(data: result, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: handleException(e));
    }
  }
}

final cmDashboardController =
    StateNotifierProvider<CMDashboardController, CMDashboardState>(
      (ref) => CMDashboardController(const CMDashboardState(), ref),
    );
