import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/views/screens/files/file_card.dart';

class DashboardModel {
  final int actionRequiredCount;
  final int myFilesCount;
  final int pendingFilesCount;
  final int disposedOffCount;
  final bool loading;

  DashboardModel({
    this.actionRequiredCount = 0,
    this.myFilesCount = 0,
    this.pendingFilesCount = 0,
    this.disposedOffCount = 0,
    this.loading = false,
  });

  DashboardModel copyWith({
    bool? loading,
    int? actionRequiredCount,
    int? myFilesCount,
    int? pendingFilesCount,
    int? disposedOffCount,
  }) {
    return DashboardModel(
      actionRequiredCount: actionRequiredCount ?? this.actionRequiredCount,
      myFilesCount: myFilesCount ?? this.myFilesCount,
      pendingFilesCount: pendingFilesCount ?? this.pendingFilesCount,
      disposedOffCount: disposedOffCount ?? this.disposedOffCount,
      loading: loading ?? this.loading,
    );
  }
}

class DashboardController extends BaseControllerState<DashboardModel> {
  DashboardController(super.state, super.ref);

  Future initData() async {
    await Future.delayed(Duration.zero);
    state = state.copyWith(loading: true);
    final controller = ref.read(filesController.notifier);
    final ar = await controller.fetchFiles(
      FileType.actionRequired,
      showLoader: false,
    );
    int actionRequiredCount = ar.length;
    final mf = await controller.fetchFiles(
      FileType.my,
      showLoader: false,
    );
    int myFilesCount = mf.length;
    final pf = await controller.fetchFiles(
      FileType.pending,
      showLoader: false,
    );
    int pendingFilesCount = pf.length;
    final df = await controller.fetchFiles(
      FileType.archived,
      showLoader: false,
    );
    int disposedOffCount = df.length;
    state = state.copyWith(
      actionRequiredCount: actionRequiredCount,
      myFilesCount: myFilesCount,
      pendingFilesCount: pendingFilesCount,
      disposedOffCount: disposedOffCount,
      loading: false,
    );
  }
}
