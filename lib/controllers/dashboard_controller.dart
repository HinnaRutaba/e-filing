import 'dart:developer';

import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/daak/daak_model.dart';
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

  final List<DaakModel> daakLetters;

  final bool loadingActionFiles;
  final bool loadingPendingFiles;
  final bool loadingForwardedFiles;
  final bool loadingDaakLetters;

  final bool animated;

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
    this.daakLetters = const [],
    this.loadingDaakLetters = false,
    this.animated = false,
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
    List<DaakModel>? daakLetters,
    bool? loadingActionFiles,
    bool? loadingPendingFiles,
    bool? loadingForwardedFiles,
    bool? loadingDaakLetters,
    bool? backdropAnimated,
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
      daakLetters: daakLetters ?? this.daakLetters,
      loadingDaakLetters: loadingDaakLetters ?? this.loadingDaakLetters,
      animated: backdropAnimated ?? this.animated,
    );
  }
}

class DashboardController extends BaseControllerState<DashboardModel> {
  DashboardController(super.state, super.ref);

  void markBackdropAnimated() {
    if (state.animated) return;
    state = state.copyWith(backdropAnimated: true);
  }

  Future<void> initData() async {
    await Future.delayed(Duration.zero);
    state = state.copyWith(loading: true, loadingPendingFiles: true);

    try {
      final filesCtrl = ref.read(filesController.notifier);

      final ar = await filesCtrl.getFilesForDashboard(FileType.actionRequired);
      final mf = await filesCtrl.getFilesForDashboard(FileType.my);
      final pf = await filesCtrl.getFilesForDashboard(FileType.pending);
      final df = await filesCtrl.getFilesForDashboard(FileType.archived);
      final ff = await filesCtrl.getFilesForDashboard(FileType.forwarded);

      state = state.copyWith(
        actionRequiredCount: ar.length,
        myFilesCount: mf.length,
        pendingFilesCount: pf.length,
        disposedOffCount: df.length,
        pendingFiles: pf,
        forwardedFiles: ff,
        loading: false,
        loadingPendingFiles: false,
      );
    } catch (e) {
      state = state.copyWith(loading: false, loadingPendingFiles: false);
    }
  }

  Future<void> fetchActionRequiredFiles() async {
    state = state.copyWith(loadingActionFiles: true);

    try {
      final filesCtrl = ref.read(filesController.notifier);
      final files = await filesCtrl.getFilesForDashboard(
        FileType.actionRequired,
      );

      state = state.copyWith(
        actionRequiredFiles: files,
        loadingActionFiles: false,
      );
    } catch (e) {
      state = state.copyWith(loadingActionFiles: false);
    }
  }

  Future<void> fetchPendingFiles() async {
    state = state.copyWith(loadingPendingFiles: true);

    try {
      final filesCtrl = ref.read(filesController.notifier);
      final files = await filesCtrl.getFilesForDashboard(FileType.pending);

      state = state.copyWith(pendingFiles: files, loadingPendingFiles: false);
    } catch (e) {
      state = state.copyWith(loadingPendingFiles: false);
    }
  }

  Future<void> fetchForwardedFiles() async {
    state = state.copyWith(loadingForwardedFiles: true);

    try {
      final filesCtrl = ref.read(filesController.notifier);
      final files = await filesCtrl.getFilesForDashboard(FileType.forwarded);

      state = state.copyWith(
        forwardedFiles: files,
        loadingForwardedFiles: false,
      );
    } catch (e) {
      state = state.copyWith(loadingForwardedFiles: false);
    }
  }

  Future<void> fetchDaakLetters() async {
    state = state.copyWith(loadingDaakLetters: true);

    try {
      final daakCtrl = ref.read(daakController.notifier);
      daakCtrl.resetData();

      int? desId = ref.read(authController).currentDesignation?.userDesgId;
      daakCtrl.fetchDaakMeta(desId);
      final List<DaakModel>? daak = await daakCtrl.fetchDaakInbox(desId: desId);

      state = state.copyWith(
        daakLetters: daak ?? [],
        loadingDaakLetters: false,
      );
    } catch (e, s) {
      state = state.copyWith(loadingDaakLetters: false);
    }
  }
}
