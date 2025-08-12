import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:efiling_balochistan/controllers/base_controller.dart';

class ConnectivityViewModel {
  final ConnectivityResult? connectivity;
  final ConnectivityResult? lastState;
  final bool showToast;

  ConnectivityViewModel({
    this.connectivity,
    this.lastState,
    this.showToast = false,
  });

  ConnectivityViewModel copyWith({
    ConnectivityResult? connectivity,
    ConnectivityResult? lastState,
    bool? showToast,
  }) {
    return ConnectivityViewModel(
      connectivity: connectivity ?? this.connectivity,
      lastState: lastState ?? this.lastState,
      showToast: showToast ?? this.showToast,
    );
  }
}

class ConnectivityController
    extends BaseControllerState<ConnectivityViewModel> {
  ConnectivityController(super.state, super.ref);

  final Connectivity _connectivity = Connectivity();

  Stream<ConnectivityViewModel> connectivityStream() =>
      _connectivity.onConnectivityChanged.map((c) {
        state = state.copyWith(
          showToast: state.lastState != null && state.connectivity != c.first,
          connectivity: c.first,
          lastState: state.connectivity,
        );
        return state;
      });
}
