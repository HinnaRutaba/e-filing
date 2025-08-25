import 'package:efiling_balochistan/controllers/auth_controller.dart';
import 'package:efiling_balochistan/controllers/connectivity_controller.dart';
import 'package:efiling_balochistan/controllers/files_controller.dart';
import 'package:efiling_balochistan/controllers/local_storage_controller.dart';
import 'package:efiling_balochistan/repository/auth/auth_repo.dart';
import 'package:efiling_balochistan/repository/files/files_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepo = Provider((ref) => AuthRepo());
final filesRepo = Provider((ref) => FileRepo());

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

final authController = Provider<AuthController>(
  (ref) => AuthController(ref),
);
