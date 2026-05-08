import 'package:efiling_balochistan/models/file/file_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_model.dart';
import 'package:efiling_balochistan/models/user_model.dart';

class DashboardStatsModel {
  final UserModel? user;
  final DashboardEfileKpisModel? efileKpis;
  final DashboardSummaryStatsModel? summaryStats;
  final List<FileModel> recentPendingFiles;
  final List<FileModel> recentMyFiles;
  final List<SummaryModel> recentSummaries;
  final bool? isCm;
  final bool? isPstocm;

  DashboardStatsModel({
    this.user,
    this.efileKpis,
    this.summaryStats,
    this.recentPendingFiles = const [],
    this.recentMyFiles = const [],
    this.recentSummaries = const [],
    this.isCm,
    this.isPstocm,
  });

  DashboardStatsModel copyWith({
    UserModel? user,
    DashboardEfileKpisModel? efileKpis,
    DashboardSummaryStatsModel? summaryStats,
    List<FileModel>? recentPendingFiles,
    List<FileModel>? recentMyFiles,
    List<SummaryModel>? recentSummaries,
    bool? isCm,
    bool? isPstocm,
  }) {
    return DashboardStatsModel(
      user: user ?? this.user,
      efileKpis: efileKpis ?? this.efileKpis,
      summaryStats: summaryStats ?? this.summaryStats,
      recentPendingFiles: recentPendingFiles ?? this.recentPendingFiles,
      recentMyFiles: recentMyFiles ?? this.recentMyFiles,
      recentSummaries: recentSummaries ?? this.recentSummaries,
      isCm: isCm ?? this.isCm,
      isPstocm: isPstocm ?? this.isPstocm,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DashboardStatsSchema.user: user?.toJson(),
      DashboardStatsSchema.efileKpis: efileKpis?.toJson(),
      DashboardStatsSchema.summaryStats: summaryStats?.toJson(),
      DashboardStatsSchema.recentPendingFiles: recentPendingFiles
          .map((e) => e.toJson())
          .toList(),
      DashboardStatsSchema.recentMyFiles: recentMyFiles
          .map((e) => e.toJson())
          .toList(),
      DashboardStatsSchema.recentSummaries: recentSummaries
          .map((e) => e.toJson())
          .toList(),
      DashboardStatsSchema.isCm: isCm,
      DashboardStatsSchema.isPstocm: isPstocm,
    };
  }

  factory DashboardStatsModel.fromJson(Map<String, dynamic> map) {
    return DashboardStatsModel(
      user: map[DashboardStatsSchema.user] != null
          ? UserModel.fromJson(
              Map<String, dynamic>.from(map[DashboardStatsSchema.user]),
            )
          : null,
      efileKpis: map[DashboardStatsSchema.efileKpis] != null
          ? DashboardEfileKpisModel.fromJson(
              Map<String, dynamic>.from(map[DashboardStatsSchema.efileKpis]),
            )
          : null,
      summaryStats: map[DashboardStatsSchema.summaryStats] != null
          ? DashboardSummaryStatsModel.fromJson(
              Map<String, dynamic>.from(map[DashboardStatsSchema.summaryStats]),
            )
          : null,
      recentPendingFiles: map[DashboardStatsSchema.recentPendingFiles] != null
          ? List<FileModel>.from(
              (map[DashboardStatsSchema.recentPendingFiles] as List).map(
                (e) => FileModel.fromJson(Map<String, dynamic>.from(e)),
              ),
            )
          : [],
      recentMyFiles: map[DashboardStatsSchema.recentMyFiles] != null
          ? List<FileModel>.from(
              (map[DashboardStatsSchema.recentMyFiles] as List).map(
                (e) => FileModel.fromJson(Map<String, dynamic>.from(e)),
              ),
            )
          : [],
      recentSummaries: map[DashboardStatsSchema.recentSummaries] != null
          ? List<SummaryModel>.from(
              (map[DashboardStatsSchema.recentSummaries] as List).map(
                (e) => SummaryModel.fromJson(Map<String, dynamic>.from(e)),
              ),
            )
          : [],
      isCm: map[DashboardStatsSchema.isCm],
      isPstocm: map[DashboardStatsSchema.isPstocm],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardStatsModel &&
        other.user == user &&
        other.efileKpis == efileKpis &&
        other.summaryStats == summaryStats &&
        other.recentPendingFiles == recentPendingFiles &&
        other.recentMyFiles == recentMyFiles &&
        other.recentSummaries == recentSummaries &&
        other.isCm == isCm &&
        other.isPstocm == isPstocm;
  }

  @override
  int get hashCode =>
      user.hashCode ^
      efileKpis.hashCode ^
      summaryStats.hashCode ^
      recentPendingFiles.hashCode ^
      recentMyFiles.hashCode ^
      recentSummaries.hashCode ^
      isCm.hashCode ^
      isPstocm.hashCode;
}

class DashboardStatsSchema {
  static const String user = 'user';
  static const String efileKpis = 'efile_kpis';
  static const String summaryStats = 'summary_stats';
  static const String recentPendingFiles = 'recent_pending_files';
  static const String recentMyFiles = 'recent_my_files';
  static const String recentSummaries = 'recent_summaries';
  static const String isCm = 'is_cm';
  static const String isPstocm = 'is_pstocm';
}

// ---------------------------------------------------------------------------

class DashboardEfileKpisModel {
  final int? pending;
  final int? archive;
  final int? filesSent;
  final int? filesReceived;
  final int? filesActionRequired;
  final int? myFiles;

  DashboardEfileKpisModel({
    this.pending,
    this.archive,
    this.filesSent,
    this.filesReceived,
    this.filesActionRequired,
    this.myFiles,
  });

  DashboardEfileKpisModel copyWith({
    int? pending,
    int? archive,
    int? filesSent,
    int? filesReceived,
    int? filesActionRequired,
    int? myFiles,
  }) {
    return DashboardEfileKpisModel(
      pending: pending ?? this.pending,
      archive: archive ?? this.archive,
      filesSent: filesSent ?? this.filesSent,
      filesReceived: filesReceived ?? this.filesReceived,
      filesActionRequired: filesActionRequired ?? this.filesActionRequired,
      myFiles: myFiles ?? this.myFiles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DashboardEfileKpisSchema.pending: pending,
      DashboardEfileKpisSchema.archive: archive,
      DashboardEfileKpisSchema.filesSent: filesSent,
      DashboardEfileKpisSchema.filesReceived: filesReceived,
      DashboardEfileKpisSchema.filesActionRequired: filesActionRequired,
      DashboardEfileKpisSchema.myFiles: myFiles,
    };
  }

  factory DashboardEfileKpisModel.fromJson(Map<String, dynamic> map) {
    return DashboardEfileKpisModel(
      pending: map[DashboardEfileKpisSchema.pending]?.toInt(),
      archive: map[DashboardEfileKpisSchema.archive]?.toInt(),
      filesSent: map[DashboardEfileKpisSchema.filesSent]?.toInt(),
      filesReceived: map[DashboardEfileKpisSchema.filesReceived]?.toInt(),
      filesActionRequired: map[DashboardEfileKpisSchema.filesActionRequired]
          ?.toInt(),
      myFiles: map[DashboardEfileKpisSchema.myFiles]?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardEfileKpisModel &&
        other.pending == pending &&
        other.archive == archive &&
        other.filesSent == filesSent &&
        other.filesReceived == filesReceived &&
        other.filesActionRequired == filesActionRequired &&
        other.myFiles == myFiles;
  }

  @override
  int get hashCode =>
      pending.hashCode ^
      archive.hashCode ^
      filesSent.hashCode ^
      filesReceived.hashCode ^
      filesActionRequired.hashCode ^
      myFiles.hashCode;
}

class DashboardEfileKpisSchema {
  static const String pending = 'pending';
  static const String archive = 'archive';
  static const String filesSent = 'files_sent';
  static const String filesReceived = 'files_received';
  static const String filesActionRequired = 'files_action_required';
  static const String myFiles = 'my_files';
}

// ---------------------------------------------------------------------------

class DashboardSummaryStatsModel {
  final DashboardTabCountsModel? tabCounts;
  final DashboardDepartmentTotalsModel? departmentTotals;
  final DashboardRoleFlagsModel? roleFlags;

  DashboardSummaryStatsModel({
    this.tabCounts,
    this.departmentTotals,
    this.roleFlags,
  });

  DashboardSummaryStatsModel copyWith({
    DashboardTabCountsModel? tabCounts,
    DashboardDepartmentTotalsModel? departmentTotals,
    DashboardRoleFlagsModel? roleFlags,
  }) {
    return DashboardSummaryStatsModel(
      tabCounts: tabCounts ?? this.tabCounts,
      departmentTotals: departmentTotals ?? this.departmentTotals,
      roleFlags: roleFlags ?? this.roleFlags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DashboardSummaryStatsSchema.tabCounts: tabCounts?.toJson(),
      DashboardSummaryStatsSchema.departmentTotals: departmentTotals?.toJson(),
      DashboardSummaryStatsSchema.roleFlags: roleFlags?.toJson(),
    };
  }

  factory DashboardSummaryStatsModel.fromJson(Map<String, dynamic> map) {
    return DashboardSummaryStatsModel(
      tabCounts: map[DashboardSummaryStatsSchema.tabCounts] != null
          ? DashboardTabCountsModel.fromJson(
              Map<String, dynamic>.from(
                map[DashboardSummaryStatsSchema.tabCounts],
              ),
            )
          : null,
      departmentTotals:
          map[DashboardSummaryStatsSchema.departmentTotals] != null
          ? DashboardDepartmentTotalsModel.fromJson(
              Map<String, dynamic>.from(
                map[DashboardSummaryStatsSchema.departmentTotals],
              ),
            )
          : null,
      roleFlags: map[DashboardSummaryStatsSchema.roleFlags] != null
          ? DashboardRoleFlagsModel.fromJson(
              Map<String, dynamic>.from(
                map[DashboardSummaryStatsSchema.roleFlags],
              ),
            )
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardSummaryStatsModel &&
        other.tabCounts == tabCounts &&
        other.departmentTotals == departmentTotals &&
        other.roleFlags == roleFlags;
  }

  @override
  int get hashCode =>
      tabCounts.hashCode ^ departmentTotals.hashCode ^ roleFlags.hashCode;
}

class DashboardSummaryStatsSchema {
  static const String tabCounts = 'tab_counts';
  static const String departmentTotals = 'department_totals';
  static const String roleFlags = 'role_flags';
}

// ---------------------------------------------------------------------------

class DashboardTabCountsModel {
  final int? inbox;
  final int? myDrafts;
  final int? drafts;
  final int? internal;
  final int? pendingDisposal;
  final int? disposed;
  final int? psInbox;
  final int? internalForwarded;
  final int? sent;
  final int? heldByPs;

  DashboardTabCountsModel({
    this.inbox,
    this.myDrafts,
    this.drafts,
    this.internal,
    this.pendingDisposal,
    this.disposed,
    this.psInbox,
    this.internalForwarded,
    this.sent,
    this.heldByPs,
  });

  DashboardTabCountsModel copyWith({
    int? inbox,
    int? myDrafts,
    int? drafts,
    int? internal,
    int? pendingDisposal,
    int? disposed,
    int? psInbox,
    int? internalForwarded,
    int? sent,
    int? heldByPs,
  }) {
    return DashboardTabCountsModel(
      inbox: inbox ?? this.inbox,
      myDrafts: myDrafts ?? this.myDrafts,
      drafts: drafts ?? this.drafts,
      internal: internal ?? this.internal,
      pendingDisposal: pendingDisposal ?? this.pendingDisposal,
      disposed: disposed ?? this.disposed,
      psInbox: psInbox ?? this.psInbox,
      internalForwarded: internalForwarded ?? this.internalForwarded,
      sent: sent ?? this.sent,
      heldByPs: heldByPs ?? this.heldByPs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DashboardTabCountsSchema.inbox: inbox,
      DashboardTabCountsSchema.myDrafts: myDrafts,
      DashboardTabCountsSchema.drafts: drafts,
      DashboardTabCountsSchema.internal: internal,
      DashboardTabCountsSchema.pendingDisposal: pendingDisposal,
      DashboardTabCountsSchema.disposed: disposed,
      DashboardTabCountsSchema.psInbox: psInbox,
      DashboardTabCountsSchema.internalForwarded: internalForwarded,
      DashboardTabCountsSchema.sent: sent,
      DashboardTabCountsSchema.heldByPs: heldByPs,
    };
  }

  factory DashboardTabCountsModel.fromJson(Map<String, dynamic> map) {
    return DashboardTabCountsModel(
      inbox: map[DashboardTabCountsSchema.inbox]?.toInt(),
      myDrafts: map[DashboardTabCountsSchema.myDrafts]?.toInt(),
      drafts: map[DashboardTabCountsSchema.drafts]?.toInt(),
      internal: map[DashboardTabCountsSchema.internal]?.toInt(),
      pendingDisposal: map[DashboardTabCountsSchema.pendingDisposal]?.toInt(),
      disposed: map[DashboardTabCountsSchema.disposed]?.toInt(),
      psInbox: map[DashboardTabCountsSchema.psInbox]?.toInt(),
      internalForwarded: map[DashboardTabCountsSchema.internalForwarded]
          ?.toInt(),
      sent: map[DashboardTabCountsSchema.sent]?.toInt(),
      heldByPs: map[DashboardTabCountsSchema.heldByPs]?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardTabCountsModel &&
        other.inbox == inbox &&
        other.myDrafts == myDrafts &&
        other.drafts == drafts &&
        other.internal == internal &&
        other.pendingDisposal == pendingDisposal &&
        other.disposed == disposed &&
        other.psInbox == psInbox &&
        other.internalForwarded == internalForwarded &&
        other.sent == sent &&
        other.heldByPs == heldByPs;
  }

  @override
  int get hashCode =>
      inbox.hashCode ^
      myDrafts.hashCode ^
      drafts.hashCode ^
      internal.hashCode ^
      pendingDisposal.hashCode ^
      disposed.hashCode ^
      psInbox.hashCode ^
      internalForwarded.hashCode ^
      sent.hashCode ^
      heldByPs.hashCode;
}

class DashboardTabCountsSchema {
  static const String inbox = 'inbox';
  static const String myDrafts = 'my_drafts';
  static const String drafts = 'drafts';
  static const String internal = 'internal';
  static const String pendingDisposal = 'pending_disposal';
  static const String disposed = 'disposed';
  static const String psInbox = 'ps_inbox';
  static const String internalForwarded = 'internal_forwarded';
  static const String sent = 'sent';
  static const String heldByPs = 'held_by_ps';
}

// ---------------------------------------------------------------------------

class DashboardDepartmentTotalsModel {
  final int? createdTotal;
  final int? currentlyInDepartment;
  final int? forwardedExternally;
  final int? disposedTotal;
  final int? withCm;

  DashboardDepartmentTotalsModel({
    this.createdTotal,
    this.currentlyInDepartment,
    this.forwardedExternally,
    this.disposedTotal,
    this.withCm,
  });

  DashboardDepartmentTotalsModel copyWith({
    int? createdTotal,
    int? currentlyInDepartment,
    int? forwardedExternally,
    int? disposedTotal,
    int? withCm,
  }) {
    return DashboardDepartmentTotalsModel(
      createdTotal: createdTotal ?? this.createdTotal,
      currentlyInDepartment:
          currentlyInDepartment ?? this.currentlyInDepartment,
      forwardedExternally: forwardedExternally ?? this.forwardedExternally,
      disposedTotal: disposedTotal ?? this.disposedTotal,
      withCm: withCm ?? this.withCm,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DashboardDepartmentTotalsSchema.createdTotal: createdTotal,
      DashboardDepartmentTotalsSchema.currentlyInDepartment:
          currentlyInDepartment,
      DashboardDepartmentTotalsSchema.forwardedExternally: forwardedExternally,
      DashboardDepartmentTotalsSchema.disposedTotal: disposedTotal,
      DashboardDepartmentTotalsSchema.withCm: withCm,
    };
  }

  factory DashboardDepartmentTotalsModel.fromJson(Map<String, dynamic> map) {
    return DashboardDepartmentTotalsModel(
      createdTotal: map[DashboardDepartmentTotalsSchema.createdTotal]?.toInt(),
      currentlyInDepartment:
          map[DashboardDepartmentTotalsSchema.currentlyInDepartment]?.toInt(),
      forwardedExternally:
          map[DashboardDepartmentTotalsSchema.forwardedExternally]?.toInt(),
      disposedTotal: map[DashboardDepartmentTotalsSchema.disposedTotal]
          ?.toInt(),
      withCm: map[DashboardDepartmentTotalsSchema.withCm]?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardDepartmentTotalsModel &&
        other.createdTotal == createdTotal &&
        other.currentlyInDepartment == currentlyInDepartment &&
        other.forwardedExternally == forwardedExternally &&
        other.disposedTotal == disposedTotal &&
        other.withCm == withCm;
  }

  @override
  int get hashCode =>
      createdTotal.hashCode ^
      currentlyInDepartment.hashCode ^
      forwardedExternally.hashCode ^
      disposedTotal.hashCode ^
      withCm.hashCode;
}

class DashboardDepartmentTotalsSchema {
  static const String createdTotal = 'created_total';
  static const String currentlyInDepartment = 'currently_in_department';
  static const String forwardedExternally = 'forwarded_externally';
  static const String disposedTotal = 'disposed_total';
  static const String withCm = 'with_cm';
}

// ---------------------------------------------------------------------------

class DashboardRoleFlagsModel {
  final bool? isSecretary;
  final bool? isPstocm;
  final bool? isCm;
  final bool? isPsForSomeone;

  DashboardRoleFlagsModel({
    this.isSecretary,
    this.isPstocm,
    this.isCm,
    this.isPsForSomeone,
  });

  DashboardRoleFlagsModel copyWith({
    bool? isSecretary,
    bool? isPstocm,
    bool? isCm,
    bool? isPsForSomeone,
  }) {
    return DashboardRoleFlagsModel(
      isSecretary: isSecretary ?? this.isSecretary,
      isPstocm: isPstocm ?? this.isPstocm,
      isCm: isCm ?? this.isCm,
      isPsForSomeone: isPsForSomeone ?? this.isPsForSomeone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DashboardRoleFlagsSchema.isSecretary: isSecretary,
      DashboardRoleFlagsSchema.isPstocm: isPstocm,
      DashboardRoleFlagsSchema.isCm: isCm,
      DashboardRoleFlagsSchema.isPsForSomeone: isPsForSomeone,
    };
  }

  factory DashboardRoleFlagsModel.fromJson(Map<String, dynamic> map) {
    return DashboardRoleFlagsModel(
      isSecretary: map[DashboardRoleFlagsSchema.isSecretary],
      isPstocm: map[DashboardRoleFlagsSchema.isPstocm],
      isCm: map[DashboardRoleFlagsSchema.isCm],
      isPsForSomeone: map[DashboardRoleFlagsSchema.isPsForSomeone],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardRoleFlagsModel &&
        other.isSecretary == isSecretary &&
        other.isPstocm == isPstocm &&
        other.isCm == isCm &&
        other.isPsForSomeone == isPsForSomeone;
  }

  @override
  int get hashCode =>
      isSecretary.hashCode ^
      isPstocm.hashCode ^
      isCm.hashCode ^
      isPsForSomeone.hashCode;
}

class DashboardRoleFlagsSchema {
  static const String isSecretary = 'is_secretary';
  static const String isPstocm = 'is_pstocm';
  static const String isCm = 'is_cm';
  static const String isPsForSomeone = 'is_ps_for_someone';
}
