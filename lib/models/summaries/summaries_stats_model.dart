import 'package:efiling_balochistan/controllers/summaries_controller.dart';
import 'package:efiling_balochistan/models/active_user_desg_model.dart';

class SummariesStatsModel {
  final SummariesTabCountsModel? tabCounts;
  final SummariesDepartmentTotalsModel? departmentTotals;
  final SummariesRoleFlagsModel? roleFlags;

  SummariesStatsModel({this.tabCounts, this.departmentTotals, this.roleFlags});

  SummariesStatsModel copyWith({
    SummariesTabCountsModel? tabCounts,
    SummariesDepartmentTotalsModel? departmentTotals,
    SummariesRoleFlagsModel? roleFlags,
  }) {
    return SummariesStatsModel(
      tabCounts: tabCounts ?? this.tabCounts,
      departmentTotals: departmentTotals ?? this.departmentTotals,
      roleFlags: roleFlags ?? this.roleFlags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SummariesStatsSchema.tabCounts: tabCounts?.toJson(),
      SummariesStatsSchema.departmentTotals: departmentTotals?.toJson(),
      SummariesStatsSchema.roleFlags: roleFlags?.toJson(),
    };
  }

  factory SummariesStatsModel.fromJson(Map<String, dynamic> map) {
    return SummariesStatsModel(
      tabCounts: map[SummariesStatsSchema.tabCounts] != null
          ? SummariesTabCountsModel.fromJson(
              Map<String, dynamic>.from(map[SummariesStatsSchema.tabCounts]),
            )
          : null,
      departmentTotals: map[SummariesStatsSchema.departmentTotals] is Map
          ? SummariesDepartmentTotalsModel.fromJson(
              Map<String, dynamic>.from(
                map[SummariesStatsSchema.departmentTotals],
              ),
            )
          : null,
      roleFlags: map[SummariesStatsSchema.roleFlags] != null
          ? SummariesRoleFlagsModel.fromJson(
              Map<String, dynamic>.from(map[SummariesStatsSchema.roleFlags]),
            )
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SummariesStatsModel &&
        other.tabCounts == tabCounts &&
        other.departmentTotals == departmentTotals &&
        other.roleFlags == roleFlags;
  }

  @override
  int get hashCode =>
      tabCounts.hashCode ^ departmentTotals.hashCode ^ roleFlags.hashCode;
}

class SummariesStatsSchema {
  static const String tabCounts = 'tab_counts';
  static const String departmentTotals = 'department_totals';
  static const String roleFlags = 'role_flags';
}

// ---------------------------------------------------------------------------

class SummariesTabCountsModel {
  final int? inbox;
  final int? myDrafts;
  final int? drafts;
  final int? internal;
  final int? pendingDisposal;
  final int? disposed;
  final int? psInbox;
  final int? withCm;
  final int? internalForwarded;
  final int? sent;
  final int? heldByPs;
  final int? cmReturned;

  SummariesTabCountsModel({
    this.inbox,
    this.myDrafts,
    this.drafts,
    this.internal,
    this.pendingDisposal,
    this.disposed,
    this.psInbox,
    this.withCm,
    this.internalForwarded,
    this.sent,
    this.heldByPs,
    this.cmReturned,
  });

  SummariesTabCountsModel copyWith({
    int? inbox,
    int? myDrafts,
    int? drafts,
    int? internal,
    int? pendingDisposal,
    int? disposed,
    int? psInbox,
    int? withCm,
    int? internalForwarded,
    int? sent,
    int? heldByPs,
    int? cmReturned,
  }) {
    return SummariesTabCountsModel(
      inbox: inbox ?? this.inbox,
      myDrafts: myDrafts ?? this.myDrafts,
      drafts: drafts ?? this.drafts,
      internal: internal ?? this.internal,
      pendingDisposal: pendingDisposal ?? this.pendingDisposal,
      disposed: disposed ?? this.disposed,
      psInbox: psInbox ?? this.psInbox,
      withCm: withCm ?? this.withCm,
      internalForwarded: internalForwarded ?? this.internalForwarded,
      sent: sent ?? this.sent,
      heldByPs: heldByPs ?? this.heldByPs,
      cmReturned: cmReturned ?? this.cmReturned,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SummariesTabCountsSchema.inbox: inbox,
      SummariesTabCountsSchema.myDrafts: myDrafts,
      SummariesTabCountsSchema.drafts: drafts,
      SummariesTabCountsSchema.internal: internal,
      SummariesTabCountsSchema.pendingDisposal: pendingDisposal,
      SummariesTabCountsSchema.disposed: disposed,
      SummariesTabCountsSchema.psInbox: psInbox,
      SummariesTabCountsSchema.withCm: withCm,
      SummariesTabCountsSchema.internalForwarded: internalForwarded,
      SummariesTabCountsSchema.sent: sent,
      SummariesTabCountsSchema.heldByPs: heldByPs,
      SummariesTabCountsSchema.cmReturned: cmReturned,
    };
  }

  int? countForSubTab(SummarySubTab subTab, {ActiveUserDesgRole? role}) {
    switch (subTab) {
      case SummarySubTab.inbox:
        return inbox;
      case SummarySubTab.sharedToMe:
        return internal;
      case SummarySubTab.drafts:
        return role == ActiveUserDesgRole.deo ? myDrafts : drafts;
      case SummarySubTab.disposal:
        return pendingDisposal;
      case SummarySubTab.sentOut:
        return sent;
      case SummarySubTab.sharedInternally:
        return internalForwarded;
      case SummarySubTab.disposed:
        return disposed;
      case SummarySubTab.cmReturned:
        return cmReturned;
      case SummarySubTab.withCm:
        return withCm;
      case SummarySubTab.cmApprovedReturned:
        return null;
    }
  }

  factory SummariesTabCountsModel.fromJson(Map<String, dynamic> map) {
    return SummariesTabCountsModel(
      inbox: map[SummariesTabCountsSchema.inbox]?.toInt(),
      myDrafts: map[SummariesTabCountsSchema.myDrafts]?.toInt(),
      drafts: map[SummariesTabCountsSchema.drafts]?.toInt(),
      internal: map[SummariesTabCountsSchema.internal]?.toInt(),
      pendingDisposal: map[SummariesTabCountsSchema.pendingDisposal]?.toInt(),
      disposed: map[SummariesTabCountsSchema.disposed]?.toInt(),
      psInbox: map[SummariesTabCountsSchema.psInbox]?.toInt(),
      withCm: map[SummariesTabCountsSchema.withCm]?.toInt(),
      internalForwarded: map[SummariesTabCountsSchema.internalForwarded]
          ?.toInt(),
      sent: map[SummariesTabCountsSchema.sent]?.toInt(),
      heldByPs: map[SummariesTabCountsSchema.heldByPs]?.toInt(),
      cmReturned: map[SummariesTabCountsSchema.cmReturned]?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SummariesTabCountsModel &&
        other.inbox == inbox &&
        other.myDrafts == myDrafts &&
        other.drafts == drafts &&
        other.internal == internal &&
        other.pendingDisposal == pendingDisposal &&
        other.disposed == disposed &&
        other.psInbox == psInbox &&
        other.withCm == withCm &&
        other.internalForwarded == internalForwarded &&
        other.sent == sent &&
        other.heldByPs == heldByPs &&
        other.cmReturned == cmReturned;
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
      withCm.hashCode ^
      internalForwarded.hashCode ^
      sent.hashCode ^
      heldByPs.hashCode ^
      cmReturned.hashCode;
}

class SummariesTabCountsSchema {
  static const String inbox = 'inbox';
  static const String myDrafts = 'my_drafts';
  static const String drafts = 'drafts';
  static const String internal = 'internal';
  static const String pendingDisposal = 'pending_disposal';
  static const String disposed = 'disposed';
  static const String psInbox = 'ps_inbox';
  static const String withCm = 'with_cm';
  static const String internalForwarded = 'internal_forwarded';
  static const String sent = 'sent';
  static const String heldByPs = 'held_by_ps';
  static const String cmReturned = 'cm_returned';
}

// ---------------------------------------------------------------------------

class SummariesDepartmentTotalsModel {
  final int? createdTotal;
  final int? currentlyInDepartment;
  final int? forwardedExternally;
  final int? disposedTotal;
  final int? withCm;

  SummariesDepartmentTotalsModel({
    this.createdTotal,
    this.currentlyInDepartment,
    this.forwardedExternally,
    this.disposedTotal,
    this.withCm,
  });

  SummariesDepartmentTotalsModel copyWith({
    int? createdTotal,
    int? currentlyInDepartment,
    int? forwardedExternally,
    int? disposedTotal,
    int? withCm,
  }) {
    return SummariesDepartmentTotalsModel(
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
      SummariesDepartmentTotalsSchema.createdTotal: createdTotal,
      SummariesDepartmentTotalsSchema.currentlyInDepartment:
          currentlyInDepartment,
      SummariesDepartmentTotalsSchema.forwardedExternally: forwardedExternally,
      SummariesDepartmentTotalsSchema.disposedTotal: disposedTotal,
      SummariesDepartmentTotalsSchema.withCm: withCm,
    };
  }

  factory SummariesDepartmentTotalsModel.fromJson(Map<String, dynamic> map) {
    return SummariesDepartmentTotalsModel(
      createdTotal: map[SummariesDepartmentTotalsSchema.createdTotal]?.toInt(),
      currentlyInDepartment:
          map[SummariesDepartmentTotalsSchema.currentlyInDepartment]?.toInt(),
      forwardedExternally:
          map[SummariesDepartmentTotalsSchema.forwardedExternally]?.toInt(),
      disposedTotal: map[SummariesDepartmentTotalsSchema.disposedTotal]
          ?.toInt(),
      withCm: map[SummariesDepartmentTotalsSchema.withCm]?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SummariesDepartmentTotalsModel &&
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

class SummariesDepartmentTotalsSchema {
  static const String createdTotal = 'created_total';
  static const String currentlyInDepartment = 'currently_in_department';
  static const String forwardedExternally = 'forwarded_externally';
  static const String disposedTotal = 'disposed_total';
  static const String withCm = 'with_cm';
}

// ---------------------------------------------------------------------------

class SummariesRoleFlagsModel {
  final bool? isSecretary;
  final bool? isPstocm;
  final bool? isCm;
  final bool? isPsForSomeone;

  SummariesRoleFlagsModel({
    this.isSecretary,
    this.isPstocm,
    this.isCm,
    this.isPsForSomeone,
  });

  SummariesRoleFlagsModel copyWith({
    bool? isSecretary,
    bool? isPstocm,
    bool? isCm,
    bool? isPsForSomeone,
  }) {
    return SummariesRoleFlagsModel(
      isSecretary: isSecretary ?? this.isSecretary,
      isPstocm: isPstocm ?? this.isPstocm,
      isCm: isCm ?? this.isCm,
      isPsForSomeone: isPsForSomeone ?? this.isPsForSomeone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SummariesRoleFlagsSchema.isSecretary: isSecretary,
      SummariesRoleFlagsSchema.isPstocm: isPstocm,
      SummariesRoleFlagsSchema.isCm: isCm,
      SummariesRoleFlagsSchema.isPsForSomeone: isPsForSomeone,
    };
  }

  factory SummariesRoleFlagsModel.fromJson(Map<String, dynamic> map) {
    return SummariesRoleFlagsModel(
      isSecretary: map[SummariesRoleFlagsSchema.isSecretary],
      isPstocm: map[SummariesRoleFlagsSchema.isPstocm],
      isCm: map[SummariesRoleFlagsSchema.isCm],
      isPsForSomeone: map[SummariesRoleFlagsSchema.isPsForSomeone],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SummariesRoleFlagsModel &&
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

class SummariesRoleFlagsSchema {
  static const String isSecretary = 'is_secretary';
  static const String isPstocm = 'is_pstocm';
  static const String isCm = 'is_cm';
  static const String isPsForSomeone = 'is_ps_for_someone';
}
