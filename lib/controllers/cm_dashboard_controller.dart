import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CMPendingApprovalItem {
  final String summaryId;
  final String title;
  final String department;
  final String? date;

  const CMPendingApprovalItem({
    required this.summaryId,
    required this.title,
    required this.department,
    this.date,
  });
}

class CMRecentApprovalItem {
  final String summaryId;
  final String title;
  final String department;
  final String? date;

  const CMRecentApprovalItem({
    required this.summaryId,
    required this.title,
    required this.department,
    this.date,
  });
}

class CMDepartmentStat {
  final String name;
  final int total;
  final int active;
  final int closed;

  const CMDepartmentStat({
    required this.name,
    required this.total,
    required this.active,
    required this.closed,
  });
}

class CMTopDepartmentItem {
  final int rank;
  final String name;
  final int count;

  const CMTopDepartmentItem({
    required this.rank,
    required this.name,
    required this.count,
  });
}

class CMDashboardModel {
  final int awaitingApprovalCount;
  final int activeInProgressCount;
  final int totalSummariesCount;
  final int closedDisposedCount;
  final bool loading;
  final List<CMPendingApprovalItem> pendingApprovals;
  final List<CMRecentApprovalItem> recentApprovals;
  final List<CMDepartmentStat> departmentStats;
  final List<CMTopDepartmentItem> topDepartments;

  CMDashboardModel({
    this.awaitingApprovalCount = 0,
    this.activeInProgressCount = 0,
    this.totalSummariesCount = 0,
    this.closedDisposedCount = 0,
    this.loading = false,
    this.pendingApprovals = const [],
    this.recentApprovals = const [],
    this.departmentStats = const [],
    this.topDepartments = const [],
  });

  CMDashboardModel copyWith({
    int? awaitingApprovalCount,
    int? activeInProgressCount,
    int? totalSummariesCount,
    int? closedDisposedCount,
    bool? loading,
    List<CMPendingApprovalItem>? pendingApprovals,
    List<CMRecentApprovalItem>? recentApprovals,
    List<CMDepartmentStat>? departmentStats,
    List<CMTopDepartmentItem>? topDepartments,
  }) {
    return CMDashboardModel(
      awaitingApprovalCount:
          awaitingApprovalCount ?? this.awaitingApprovalCount,
      activeInProgressCount:
          activeInProgressCount ?? this.activeInProgressCount,
      totalSummariesCount: totalSummariesCount ?? this.totalSummariesCount,
      closedDisposedCount: closedDisposedCount ?? this.closedDisposedCount,
      loading: loading ?? this.loading,
      pendingApprovals: pendingApprovals ?? this.pendingApprovals,
      recentApprovals: recentApprovals ?? this.recentApprovals,
      departmentStats: departmentStats ?? this.departmentStats,
      topDepartments: topDepartments ?? this.topDepartments,
    );
  }
}

class CMDashboardController extends BaseControllerState<CMDashboardModel> {
  CMDashboardController(super.state, super.ref);

  Future<void> initData() async {
    state = state.copyWith(loading: true);

    // TODO: Replace with real API calls
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      awaitingApprovalCount: 0,
      activeInProgressCount: 27,
      totalSummariesCount: 63,
      closedDisposedCount: 102,
      loading: false,
      pendingApprovals: const [],
      recentApprovals: const [
        CMRecentApprovalItem(
          summaryId: 'SUM/HD/2026/000010',
          title: 'PS To Cm Test',
          department: 'Home Department',
          date: '2026-05-01',
        ),
        CMRecentApprovalItem(
          summaryId: 'SUM/HD/2026/000009',
          title: 'Summary for approval of vehicles',
          department: 'Home Department',
          date: '2026-04-28',
        ),
        CMRecentApprovalItem(
          summaryId: 'SUM/HD/2026/000008',
          title: 'asdasd',
          department: 'Home Department',
          date: '2026-04-25',
        ),
        CMRecentApprovalItem(
          summaryId: 'SUM/HD/2026/000006',
          title: 'Summary For CM',
          department: 'Home Department',
          date: '2026-04-20',
        ),
      ],
      departmentStats: const [
        CMDepartmentStat(
          name: 'Information Department',
          total: 5,
          active: 5,
          closed: 0,
        ),
        CMDepartmentStat(
          name: 'Chief Minister Secretariat',
          total: 3,
          active: 3,
          closed: 0,
        ),
        CMDepartmentStat(
          name: 'Home Department',
          total: 2,
          active: 1,
          closed: 0,
        ),
      ],
      topDepartments: const [
        CMTopDepartmentItem(rank: 1, name: 'Home Department', count: 10),
        CMTopDepartmentItem(rank: 2, name: 'Information Department', count: 5),
        CMTopDepartmentItem(rank: 3, name: 'CM Secretariat', count: 3),
      ],
    );
  }
}

final cmDashboardController =
    StateNotifierProvider<CMDashboardController, CMDashboardModel>(
      (ref) => CMDashboardController(CMDashboardModel(), ref),
    );
