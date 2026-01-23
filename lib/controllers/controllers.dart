import 'package:efiling_balochistan/controllers/auth_controller.dart';
import 'package:efiling_balochistan/controllers/connectivity_controller.dart';
import 'package:efiling_balochistan/controllers/dashboard_controller.dart';
import 'package:efiling_balochistan/controllers/files_controller.dart';
import 'package:efiling_balochistan/controllers/local_storage_controller.dart';
import 'package:efiling_balochistan/models/user_model.dart';
import 'package:efiling_balochistan/repository/auth/auth_repo.dart';
import 'package:efiling_balochistan/repository/chat/chat_repo.dart';
import 'package:efiling_balochistan/repository/files/files_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepo = Provider((ref) => AuthRepo());
final filesRepo = Provider((ref) => FileRepo());
final chatRepo = Provider((ref) => ChatRepo());

final connectivityController =
    StateNotifierProvider<ConnectivityController, ConnectivityViewModel>(
  (ref) => ConnectivityController(ConnectivityViewModel(), ref),
);

final filesController = StateNotifierProvider<FilesController, FileViewModel>(
  (ref) => FilesController(FileViewModel(), ref),
);

final localStorageController = Provider<LocalStorageController>(
  (ref) => LocalStorageController(),
);

final authController = StateNotifierProvider<AuthController, UserModel>(
  (ref) => AuthController(UserModel(), ref),
);

final dashboardController =
    StateNotifierProvider<DashboardController, DashboardModel>(
  (ref) => DashboardController(DashboardModel(), ref),
);
