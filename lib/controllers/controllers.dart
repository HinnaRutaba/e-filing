import 'package:efiling_balochistan/controllers/connectivity_controller.dart';
import 'package:efiling_balochistan/controllers/local_storage_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityController =
    StateNotifierProvider<ConnectivityController, ConnectivityViewModel>(
  (ref) => ConnectivityController(ConnectivityViewModel(), ref),
);

final localStorageController = Provider<LocalStorageController>(
  (ref) => LocalStorageController(),
);
