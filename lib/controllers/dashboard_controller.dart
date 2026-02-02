import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/file_model.dart';
import 'package:efiling_balochistan/views/screens/files/file_card.dart';

class DashboardModel {
  final int actionRequiredCount;
  final int myFilesCount;
  final int pendingFilesCount;
  final int disposedOffCount;
  final bool loading;

  final List<FileModel> actionRequiredFiles;
  final List<FileModel> pendingFiles;
  final List<FileModel> forwardedFiles;

  final bool loadingActionFiles;
  final bool loadingPendingFiles;
  final bool loadingForwardedFiles;

  DashboardModel({
    this.actionRequiredCount = 0,
    this.myFilesCount = 0,
    this.pendingFilesCount = 0,
    this.disposedOffCount = 0,
    this.loading = false,
    this.actionRequiredFiles = const [],
    this.pendingFiles = const [],
    this.forwardedFiles = const [],
    this.loadingActionFiles = false,
    this.loadingPendingFiles = false,
    this.loadingForwardedFiles = false,
  });

  DashboardModel copyWith({
    bool? loading,
    int? actionRequiredCount,
    int? myFilesCount,
    int? pendingFilesCount,
    int? disposedOffCount,
    List<FileModel>? actionRequiredFiles,
    List<FileModel>? pendingFiles,
    List<FileModel>? forwardedFiles,
    bool? loadingActionFiles,
    bool? loadingPendingFiles,
    bool? loadingForwardedFiles,
  }) {
    return DashboardModel(
      actionRequiredCount: actionRequiredCount ?? this.actionRequiredCount,
      myFilesCount: myFilesCount ?? this.myFilesCount,
      pendingFilesCount: pendingFilesCount ?? this.pendingFilesCount,
      disposedOffCount: disposedOffCount ?? this.disposedOffCount,
      loading: loading ?? this.loading,
      actionRequiredFiles: actionRequiredFiles ?? this.actionRequiredFiles,
      pendingFiles: pendingFiles ?? this.pendingFiles,
      forwardedFiles: forwardedFiles ?? this.forwardedFiles,
      loadingActionFiles: loadingActionFiles ?? this.loadingActionFiles,
      loadingPendingFiles: loadingPendingFiles ?? this.loadingPendingFiles,
      loadingForwardedFiles:
          loadingForwardedFiles ?? this.loadingForwardedFiles,
    );
  }
}

class DashboardController extends BaseControllerState<DashboardModel> {
  DashboardController(super.state, super.ref);

  Future<void> initData() async {
    await Future.delayed(Duration.zero);
    state = state.copyWith(loading: true);

    try {
      final filesdashmethods = ref.read(filesController.notifier);

      final ar =
          await filesdashmethods.getFilesForDashboard(FileType.actionRequired);
      final mf = await filesdashmethods.getFilesForDashboard(FileType.my);
      final pf = await filesdashmethods.getFilesForDashboard(FileType.pending);
      final df = await filesdashmethods.getFilesForDashboard(FileType.archived);

      state = state.copyWith(
        actionRequiredCount: ar.length,
        myFilesCount: mf.length,
        pendingFilesCount: pf.length,
        disposedOffCount: df.length,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> fetchActionRequiredFiles() async {
    state = state.copyWith(loadingActionFiles: true);

    try {
      final filesdashmethods = ref.read(filesController.notifier);
      final files =
          await filesdashmethods.getFilesForDashboard(FileType.actionRequired);

      state = state.copyWith(
        actionRequiredFiles: files,
        loadingActionFiles: false,
      );
    } catch (e) {
      state = state.copyWith(
        loadingActionFiles: false,
      );
    }
  }

  Future<void> fetchPendingFiles() async {
    state = state.copyWith(loadingPendingFiles: true);

    try {
      final filesdashmethods = ref.read(filesController.notifier);
      final files =
          await filesdashmethods.getFilesForDashboard(FileType.pending);

      state = state.copyWith(
        pendingFiles: files,
        loadingPendingFiles: false,
      );
    } catch (e) {
      state = state.copyWith(
        loadingPendingFiles: false,
      );
    }
  }

  Future<void> fetchForwardedFiles() async {
    state = state.copyWith(loadingForwardedFiles: true);

    try {
      final filesdashmethods = ref.read(filesController.notifier);
      final files =
          await filesdashmethods.getFilesForDashboard(FileType.forwarded);

      state = state.copyWith(
        forwardedFiles: files,
        loadingForwardedFiles: false,
      );
    } catch (e) {
      state = state.copyWith(
        loadingForwardedFiles: false,
      );
    }
  }
}
