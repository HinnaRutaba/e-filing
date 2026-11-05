import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/controllers/daak_report_controller.dart';
import 'package:efiling_balochistan/controllers/secretary_dashboard_controller.dart';
import 'package:efiling_balochistan/controllers/secretary_users_controller.dart';
import 'package:efiling_balochistan/models/active_user_desg_model.dart';
import 'package:efiling_balochistan/models/daak/daak_model.dart';
import 'package:efiling_balochistan/models/dashboard_stats_model.dart';
import 'package:efiling_balochistan/models/file/file_model.dart';
import 'package:efiling_balochistan/models/user_model.dart';
import 'package:efiling_balochistan/services/notification_service.dart';
import 'package:efiling_balochistan/views/screens/files/file_card.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

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

  final DashboardStatsModel? stats;
  final bool loadingStats;

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
    this.stats,
    this.loadingStats = false,
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
    DashboardStatsModel? stats,
    bool? loadingStats,
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
      animated: backdropAnimated ?? animated,
      stats: stats ?? this.stats,
      loadingStats: loadingStats ?? this.loadingStats,
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
    state = state.copyWith(
      loading: true,
      loadingPendingFiles: true,
      loadingActionFiles: true,
      loadingForwardedFiles: true,
    );

    fetchDaakLetters();

    try {
      await _loadFiles();
    } catch (e) {
      state = state.copyWith(
        loading: false,
        loadingPendingFiles: false,
        loadingActionFiles: false,
        loadingForwardedFiles: false,
      );
    }
  }

  Future<void>? _refreshing;

  /// Reloads all dashboard data in the background, for the dashboard's auto
  /// refresh: no loading shimmers or error toasts, and a failed request keeps
  /// what is already on screen. For a secretary this also reloads the
  /// department E-Files and E-Daak dashboards.
  Future<void> refresh() async {
    if (_refreshing != null || state.loading) return;
    final isSecretary =
        ref.read(authController).userDesgRole == ActiveUserDesgRole.secretary;
    final refreshing = Future.wait([
      _loadFiles(silent: true).catchError((_) {}),
      _refreshDaakLetters(),
      if (isSecretary) ...[
        ref.read(secretaryDashboardController.notifier).refresh(),
        ref.read(secretaryUsersController.notifier).refresh(),
        ref.read(daakReportController.notifier).refresh(),
      ],
    ]);
    _refreshing = refreshing;
    try {
      await refreshing;
    } finally {
      _refreshing = null;
    }
  }

  /// Switches the signed-in user to [designation] and reloads the dashboard
  /// for it. The role comes with the designation, so the user is reloaded too
  /// and the dashboard may change between the standard and secretary layouts.
  Future<void> switchDesignation(DesignationModel designation) async {
    final auth = ref.read(authController.notifier);
    final wasSecretary =
        ref.read(authController).userDesgRole == ActiveUserDesgRole.secretary;

    final name = designation.designation;
    EasyLoading.show(
      status: name == null || name.trim().isEmpty
          ? 'Switching designation...'
          : 'Switching to $name...',
    );
    try {
      // Don't let a background refresh for the old designation land on top of
      // the new one.
      await _refreshing;
      if (await auth.setDesignation(designation) == null) return;
      await auth.fetchLoggedInUser();
    } finally {
      EasyLoading.dismiss();
    }

    NotificationService().saveFcmToken(designation.userDesgId);
    ref.read(daakController.notifier).fetchDaakMeta();
    RouteHelper.navigateHome();

    initData();
    // A secretary's tabs load themselves when they first appear, so they only
    // need reloading if they were already on screen.
    final isSecretary =
        ref.read(authController).userDesgRole == ActiveUserDesgRole.secretary;
    if (wasSecretary && isSecretary) {
      ref.read(secretaryDashboardController.notifier).initData();
      ref.read(secretaryUsersController.notifier).initData();
      ref.read(daakReportController.notifier).load();
    }
  }

  /// With [silent], throws if any request fails instead of treating it as an
  /// empty list, so the caller can keep the current data.
  Future<void> _loadFiles({bool silent = false}) async {
    final filesCtrl = ref.read(filesController.notifier);

    final results = await Future.wait([
      for (final type in const [
        FileType.actionRequired,
        FileType.my,
        FileType.pending,
        FileType.archived,
        FileType.forwarded,
      ])
        filesCtrl.getFilesForDashboard(type, rethrowErrors: silent),
    ]);

    final ar = results[0];
    final mf = results[1];
    final pf = results[2];
    final df = results[3];
    final ff = results[4];

    final kpis = DashboardEfileKpisModel(
      pending: pf.length,
      archive: df.length,
      filesSent: ff.length,
      filesActionRequired: ar.length,
      myFiles: mf.length,
    );

    state = state.copyWith(
      actionRequiredCount: ar.length,
      myFilesCount: mf.length,
      pendingFilesCount: pf.length,
      disposedOffCount: df.length,
      actionRequiredFiles: ar,
      pendingFiles: pf,
      forwardedFiles: ff,
      stats: (state.stats ?? DashboardStatsModel()).copyWith(efileKpis: kpis),
      loading: false,
      loadingPendingFiles: false,
      loadingActionFiles: false,
      loadingForwardedFiles: false,
    );
  }

  /// Unlike [fetchDaakLetters], leaves the Daak screen's state alone.
  Future<void> _refreshDaakLetters() async {
    try {
      final desId = ref.read(authController).currentDesignation?.userDesgId;
      final daak = await ref.read(daakRepo).fetchDaakInbox(desId: desId);
      state = state.copyWith(daakLetters: daak);
    } catch (_) {}
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

  Future<void> fetchStats() async {
    state = state.copyWith(loadingStats: true);
    try {
      final userDesgId = ref
          .read(authController)
          .currentDesignation
          ?.userDesgId;
      final result = await ref
          .read(dashboardRepo)
          .getDashboardStats(userDesgId: userDesgId);
      state = state.copyWith(stats: result, loadingStats: false);
    } catch (e) {
      state = state.copyWith(loadingStats: false);
    }
  }

  Future<void> fetchDaakLetters() async {
    state = state.copyWith(loadingDaakLetters: true);

    try {
      final daakCtrl = ref.read(daakController.notifier);
      daakCtrl.resetData();

      int? desId = ref.read(authController).currentDesignation?.userDesgId;
      daakCtrl.fetchDaakMeta();
      final List<DaakModel>? daak = await daakCtrl.fetchDaakInbox(desId: desId);

      state = state.copyWith(
        daakLetters: daak ?? [],
        loadingDaakLetters: false,
      );
    } catch (e) {
      state = state.copyWith(loadingDaakLetters: false);
    }
  }
}
