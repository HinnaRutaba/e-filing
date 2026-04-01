import 'package:efiling_balochistan/controllers/auth_controller.dart';
import 'package:efiling_balochistan/controllers/connectivity_controller.dart';
import 'package:efiling_balochistan/controllers/daak_controller.dart';
import 'package:efiling_balochistan/controllers/dashboard_controller.dart';
import 'package:efiling_balochistan/controllers/files_controller.dart';
import 'package:efiling_balochistan/controllers/local_storage_controller.dart';
import 'package:efiling_balochistan/models/user_model.dart';
import 'package:efiling_balochistan/repository/auth/auth_repo.dart';
import 'package:efiling_balochistan/repository/chat/chat_repo.dart';
import 'package:efiling_balochistan/repository/daak/daak_repo.dart';
import 'package:efiling_balochistan/repository/files/files_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/speech_to_text_service.dart';

final authRepo = Provider((ref) => AuthRepo());
final filesRepo = Provider((ref) => FileRepo());
final chatRepo = Provider((ref) => ChatRepo());
final daakRepo = Provider((ref) => DaakRepo());

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

final daakController = StateNotifierProvider<DaakController, DaakState>(
  (ref) => DaakController(DaakState(allDaak: []), ref),
);

final speechToTextController =
    StateNotifierProvider<SpeechToTextService, STTModel>(
  (ref) => SpeechToTextService(STTModel(), ref),
);
