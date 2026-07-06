class CMDashboardModel {
  final CMDashboardKpisModel? kpis;
  final List<CMDepartmentStatModel> departmentStats;
  final List<CMOriginatingDeptModel> topOriginating;
  final List<CMPendingForCmModel> pendingForCm;
  final List<CMRecentlyApprovedModel> recentlyApproved;
  final List<CMStatusDistributionModel> statusDistribution;

  CMDashboardModel({
    this.kpis,
    this.departmentStats = const [],
    this.topOriginating = const [],
    this.pendingForCm = const [],
    this.recentlyApproved = const [],
    this.statusDistribution = const [],
  });

  CMDashboardModel copyWith({
    CMDashboardKpisModel? kpis,
    List<CMDepartmentStatModel>? departmentStats,
    List<CMOriginatingDeptModel>? topOriginating,
    List<CMPendingForCmModel>? pendingForCm,
    List<CMRecentlyApprovedModel>? recentlyApproved,
    List<CMStatusDistributionModel>? statusDistribution,
  }) {
    return CMDashboardModel(
      kpis: kpis ?? this.kpis,
      departmentStats: departmentStats ?? this.departmentStats,
      topOriginating: topOriginating ?? this.topOriginating,
      pendingForCm: pendingForCm ?? this.pendingForCm,
      recentlyApproved: recentlyApproved ?? this.recentlyApproved,
      statusDistribution: statusDistribution ?? this.statusDistribution,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      CMDashboardSchema.kpis: kpis?.toJson(),
      CMDashboardSchema.departmentStats:
          departmentStats.map((e) => e.toJson()).toList(),
      CMDashboardSchema.topOriginating:
          topOriginating.map((e) => e.toJson()).toList(),
      CMDashboardSchema.pendingForCm:
          pendingForCm.map((e) => e.toJson()).toList(),
      CMDashboardSchema.recentlyApproved:
          recentlyApproved.map((e) => e.toJson()).toList(),
      CMDashboardSchema.statusDistribution:
          statusDistribution.map((e) => e.toJson()).toList(),
    };
  }

  factory CMDashboardModel.fromJson(Map<String, dynamic> map) {
    return CMDashboardModel(
      kpis: map[CMDashboardSchema.kpis] != null
          ? CMDashboardKpisModel.fromJson(
              Map<String, dynamic>.from(map[CMDashboardSchema.kpis]),
            )
          : null,
      departmentStats: map[CMDashboardSchema.departmentStats] != null
          ? List<CMDepartmentStatModel>.from(
              (map[CMDashboardSchema.departmentStats] as List).map(
                (e) => CMDepartmentStatModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              ),
            )
          : [],
      topOriginating: map[CMDashboardSchema.topOriginating] != null
          ? List<CMOriginatingDeptModel>.from(
              (map[CMDashboardSchema.topOriginating] as List).map(
                (e) => CMOriginatingDeptModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              ),
            )
          : [],
      pendingForCm: map[CMDashboardSchema.pendingForCm] != null
          ? List<CMPendingForCmModel>.from(
              (map[CMDashboardSchema.pendingForCm] as List).map(
                (e) => CMPendingForCmModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              ),
            )
          : [],
      recentlyApproved: map[CMDashboardSchema.recentlyApproved] != null
          ? List<CMRecentlyApprovedModel>.from(
              (map[CMDashboardSchema.recentlyApproved] as List).map(
                (e) => CMRecentlyApprovedModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              ),
            )
          : [],
      statusDistribution: map[CMDashboardSchema.statusDistribution] != null
          ? List<CMStatusDistributionModel>.from(
              (map[CMDashboardSchema.statusDistribution] as List).map(
                (e) => CMStatusDistributionModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              ),
            )
          : [],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CMDashboardModel &&
        other.kpis == kpis &&
        other.departmentStats == departmentStats &&
        other.topOriginating == topOriginating &&
        other.pendingForCm == pendingForCm &&
        other.recentlyApproved == recentlyApproved &&
        other.statusDistribution == statusDistribution;
  }

  @override
  int get hashCode =>
      kpis.hashCode ^
      departmentStats.hashCode ^
      topOriginating.hashCode ^
      pendingForCm.hashCode ^
      recentlyApproved.hashCode ^
      statusDistribution.hashCode;
}

class CMDashboardSchema {
  static const String kpis = 'kpis';
  static const String departmentStats = 'department_stats';
  static const String topOriginating = 'top_originating';
  static const String pendingForCm = 'pending_for_cm';
  static const String recentlyApproved = 'recently_approved';
  static const String statusDistribution = 'status_distribution';
}

// ---------------------------------------------------------------------------

class CMDashboardKpisModel {
  final int? totalSummaries;
  final int? pendingMyApproval;
  final int? inProgress;
  final int? closedDisposed;
  final int? signedByMe;

  CMDashboardKpisModel({
    this.totalSummaries,
    this.pendingMyApproval,
    this.inProgress,
    this.closedDisposed,
    this.signedByMe,
  });

  CMDashboardKpisModel copyWith({
    int? totalSummaries,
    int? pendingMyApproval,
    int? inProgress,
    int? closedDisposed,
    int? signedByMe,
  }) {
    return CMDashboardKpisModel(
      totalSummaries: totalSummaries ?? this.totalSummaries,
      pendingMyApproval: pendingMyApproval ?? this.pendingMyApproval,
      inProgress: inProgress ?? this.inProgress,
      closedDisposed: closedDisposed ?? this.closedDisposed,
      signedByMe: signedByMe ?? this.signedByMe,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      CMDashboardKpisSchema.totalSummaries: totalSummaries,
      CMDashboardKpisSchema.pendingMyApproval: pendingMyApproval,
      CMDashboardKpisSchema.inProgress: inProgress,
      CMDashboardKpisSchema.closedDisposed: closedDisposed,
      CMDashboardKpisSchema.signedByMe: signedByMe,
    };
  }

  factory CMDashboardKpisModel.fromJson(Map<String, dynamic> map) {
    return CMDashboardKpisModel(
      totalSummaries: map[CMDashboardKpisSchema.totalSummaries]?.toInt(),
      pendingMyApproval: map[CMDashboardKpisSchema.pendingMyApproval]?.toInt(),
      inProgress: map[CMDashboardKpisSchema.inProgress]?.toInt(),
      closedDisposed: map[CMDashboardKpisSchema.closedDisposed]?.toInt(),
      signedByMe: map[CMDashboardKpisSchema.signedByMe]?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CMDashboardKpisModel &&
        other.totalSummaries == totalSummaries &&
        other.pendingMyApproval == pendingMyApproval &&
        other.inProgress == inProgress &&
        other.closedDisposed == closedDisposed &&
        other.signedByMe == signedByMe;
  }

  @override
  int get hashCode =>
      totalSummaries.hashCode ^
      pendingMyApproval.hashCode ^
      inProgress.hashCode ^
      closedDisposed.hashCode ^
      signedByMe.hashCode;
}

class CMDashboardKpisSchema {
  static const String totalSummaries = 'total_summaries';
  static const String pendingMyApproval = 'pending_my_approval';
  static const String inProgress = 'in_progress';
  static const String closedDisposed = 'closed_disposed';
  static const String signedByMe = 'signed_by_me';
}

// ---------------------------------------------------------------------------

class CMDepartmentStatModel {
  final int? id;
  final String? title;
  final int? total;
  final int? inProgress;
  final int? closed;

  CMDepartmentStatModel({
    this.id,
    this.title,
    this.total,
    this.inProgress,
    this.closed,
  });

  CMDepartmentStatModel copyWith({
    int? id,
    String? title,
    int? total,
    int? inProgress,
    int? closed,
  }) {
    return CMDepartmentStatModel(
      id: id ?? this.id,
      title: title ?? this.title,
      total: total ?? this.total,
      inProgress: inProgress ?? this.inProgress,
      closed: closed ?? this.closed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      CMDepartmentStatSchema.id: id,
      CMDepartmentStatSchema.title: title,
      CMDepartmentStatSchema.total: total,
      CMDepartmentStatSchema.inProgress: inProgress,
      CMDepartmentStatSchema.closed: closed,
    };
  }

  factory CMDepartmentStatModel.fromJson(Map<String, dynamic> map) {
    return CMDepartmentStatModel(
      id: map[CMDepartmentStatSchema.id]?.toInt(),
      title: map[CMDepartmentStatSchema.title],
      total: map[CMDepartmentStatSchema.total]?.toInt(),
      inProgress: int.tryParse(
        map[CMDepartmentStatSchema.inProgress]?.toString() ?? '',
      ),
      closed: int.tryParse(
        map[CMDepartmentStatSchema.closed]?.toString() ?? '',
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CMDepartmentStatModel &&
        other.id == id &&
        other.title == title &&
        other.total == total &&
        other.inProgress == inProgress &&
        other.closed == closed;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      total.hashCode ^
      inProgress.hashCode ^
      closed.hashCode;
}

class CMDepartmentStatSchema {
  static const String id = 'id';
  static const String title = 'title';
  static const String total = 'total';
  static const String inProgress = 'in_progress';
  static const String closed = 'closed';
}

// ---------------------------------------------------------------------------

class CMOriginatingDeptModel {
  final int? id;
  final String? title;
  final int? total;

  CMOriginatingDeptModel({this.id, this.title, this.total});

  CMOriginatingDeptModel copyWith({int? id, String? title, int? total}) {
    return CMOriginatingDeptModel(
      id: id ?? this.id,
      title: title ?? this.title,
      total: total ?? this.total,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      CMOriginatingDeptSchema.id: id,
      CMOriginatingDeptSchema.title: title,
      CMOriginatingDeptSchema.total: total,
    };
  }

  factory CMOriginatingDeptModel.fromJson(Map<String, dynamic> map) {
    return CMOriginatingDeptModel(
      id: map[CMOriginatingDeptSchema.id]?.toInt(),
      title: map[CMOriginatingDeptSchema.title],
      total: map[CMOriginatingDeptSchema.total]?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CMOriginatingDeptModel &&
        other.id == id &&
        other.title == title &&
        other.total == total;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ total.hashCode;
}

class CMOriginatingDeptSchema {
  static const String id = 'id';
  static const String title = 'title';
  static const String total = 'total';
}

// ---------------------------------------------------------------------------

class CMPendingForCmModel {
  final int? id;
  final String? summaryNo;
  final String? subject;
  final String? summaryDate;
  final int? currentHolderUserDesgId;
  final String? originDept;

  CMPendingForCmModel({
    this.id,
    this.summaryNo,
    this.subject,
    this.summaryDate,
    this.currentHolderUserDesgId,
    this.originDept,
  });

  CMPendingForCmModel copyWith({
    int? id,
    String? summaryNo,
    String? subject,
    String? summaryDate,
    int? currentHolderUserDesgId,
    String? originDept,
  }) {
    return CMPendingForCmModel(
      id: id ?? this.id,
      summaryNo: summaryNo ?? this.summaryNo,
      subject: subject ?? this.subject,
      summaryDate: summaryDate ?? this.summaryDate,
      currentHolderUserDesgId:
          currentHolderUserDesgId ?? this.currentHolderUserDesgId,
      originDept: originDept ?? this.originDept,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      CMPendingForCmSchema.id: id,
      CMPendingForCmSchema.summaryNo: summaryNo,
      CMPendingForCmSchema.subject: subject,
      CMPendingForCmSchema.summaryDate: summaryDate,
      CMPendingForCmSchema.currentHolderUserDesgId: currentHolderUserDesgId,
      CMPendingForCmSchema.originDept: originDept,
    };
  }

  factory CMPendingForCmModel.fromJson(Map<String, dynamic> map) {
    return CMPendingForCmModel(
      id: map[CMPendingForCmSchema.id]?.toInt(),
      summaryNo: map[CMPendingForCmSchema.summaryNo],
      subject: map[CMPendingForCmSchema.subject],
      summaryDate: map[CMPendingForCmSchema.summaryDate],
      currentHolderUserDesgId:
          map[CMPendingForCmSchema.currentHolderUserDesgId]?.toInt(),
      originDept: map[CMPendingForCmSchema.originDept],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CMPendingForCmModel &&
        other.id == id &&
        other.summaryNo == summaryNo &&
        other.subject == subject &&
        other.summaryDate == summaryDate &&
        other.currentHolderUserDesgId == currentHolderUserDesgId &&
        other.originDept == originDept;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      summaryNo.hashCode ^
      subject.hashCode ^
      summaryDate.hashCode ^
      currentHolderUserDesgId.hashCode ^
      originDept.hashCode;
}

class CMPendingForCmSchema {
  static const String id = 'id';
  static const String summaryNo = 'summary_no';
  static const String subject = 'subject';
  static const String summaryDate = 'summary_date';
  static const String currentHolderUserDesgId = 'current_holder_user_desg_id';
  static const String originDept = 'origin_dept';
}

// ---------------------------------------------------------------------------

class CMRecentlyApprovedModel {
  final int? id;
  final String? summaryNo;
  final String? subject;
  final String? actedAt;
  final String? originDept;

  CMRecentlyApprovedModel({
    this.id,
    this.summaryNo,
    this.subject,
    this.actedAt,
    this.originDept,
  });

  CMRecentlyApprovedModel copyWith({
    int? id,
    String? summaryNo,
    String? subject,
    String? actedAt,
    String? originDept,
  }) {
    return CMRecentlyApprovedModel(
      id: id ?? this.id,
      summaryNo: summaryNo ?? this.summaryNo,
      subject: subject ?? this.subject,
      actedAt: actedAt ?? this.actedAt,
      originDept: originDept ?? this.originDept,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      CMRecentlyApprovedSchema.id: id,
      CMRecentlyApprovedSchema.summaryNo: summaryNo,
      CMRecentlyApprovedSchema.subject: subject,
      CMRecentlyApprovedSchema.actedAt: actedAt,
      CMRecentlyApprovedSchema.originDept: originDept,
    };
  }

  factory CMRecentlyApprovedModel.fromJson(Map<String, dynamic> map) {
    return CMRecentlyApprovedModel(
      id: map[CMRecentlyApprovedSchema.id]?.toInt(),
      summaryNo: map[CMRecentlyApprovedSchema.summaryNo],
      subject: map[CMRecentlyApprovedSchema.subject],
      actedAt: map[CMRecentlyApprovedSchema.actedAt],
      originDept: map[CMRecentlyApprovedSchema.originDept],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CMRecentlyApprovedModel &&
        other.id == id &&
        other.summaryNo == summaryNo &&
        other.subject == subject &&
        other.actedAt == actedAt &&
        other.originDept == originDept;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      summaryNo.hashCode ^
      subject.hashCode ^
      actedAt.hashCode ^
      originDept.hashCode;
}

class CMRecentlyApprovedSchema {
  static const String id = 'id';
  static const String summaryNo = 'summary_no';
  static const String subject = 'subject';
  static const String actedAt = 'acted_at';
  static const String originDept = 'origin_dept';
}

// ---------------------------------------------------------------------------

class CMStatusDistributionModel {
  final int? statusCode;
  final String? statusLabel;
  final int? total;

  CMStatusDistributionModel({this.statusCode, this.statusLabel, this.total});

  CMStatusDistributionModel copyWith({
    int? statusCode,
    String? statusLabel,
    int? total,
  }) {
    return CMStatusDistributionModel(
      statusCode: statusCode ?? this.statusCode,
      statusLabel: statusLabel ?? this.statusLabel,
      total: total ?? this.total,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      CMStatusDistributionSchema.statusCode: statusCode,
      CMStatusDistributionSchema.statusLabel: statusLabel,
      CMStatusDistributionSchema.total: total,
    };
  }

  factory CMStatusDistributionModel.fromJson(Map<String, dynamic> map) {
    return CMStatusDistributionModel(
      statusCode: map[CMStatusDistributionSchema.statusCode]?.toInt(),
      statusLabel: map[CMStatusDistributionSchema.statusLabel],
      total: map[CMStatusDistributionSchema.total]?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CMStatusDistributionModel &&
        other.statusCode == statusCode &&
        other.statusLabel == statusLabel &&
        other.total == total;
  }

  @override
  int get hashCode =>
      statusCode.hashCode ^ statusLabel.hashCode ^ total.hashCode;
}

class CMStatusDistributionSchema {
  static const String statusCode = 'status_code';
  static const String statusLabel = 'status_label';
  static const String total = 'total';
}
