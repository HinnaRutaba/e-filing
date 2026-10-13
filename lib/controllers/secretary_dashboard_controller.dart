import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/secretary_dashboard_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecretaryDashboardState {
  final SecretaryDashboardModel? data;
  final bool loading;
  final String? error;

  const SecretaryDashboardState({this.data, this.loading = false, this.error});

  SecretaryDashboardState copyWith({
    SecretaryDashboardModel? data,
    bool? loading,
    String? error,
  }) {
    return SecretaryDashboardState(
      data: data ?? this.data,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}

class SecretaryDashboardController
    extends BaseControllerState<SecretaryDashboardState> {
  SecretaryDashboardController(super.state, super.ref);

  Future<void> initData() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final userDesgId =
          ref.read(authController).currentDesignation?.userDesgId;
      final result = await ref
          .read(dashboardRepo)
          .getSecretaryDashboard(userDesgId: userDesgId);
      state = state.copyWith(data: result, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: handleException(e));
    }
  }
}

final secretaryDashboardController =
    StateNotifierProvider<SecretaryDashboardController, SecretaryDashboardState>(
      (ref) => SecretaryDashboardController(
        const SecretaryDashboardState(),
        ref,
      ),
    );
