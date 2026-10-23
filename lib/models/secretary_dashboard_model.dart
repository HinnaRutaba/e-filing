import 'package:efiling_balochistan/models/department/department_model.dart';

class SecretaryDashboardModel {
  final SecretaryContextModel? context;
  final SecretaryMyKpisModel? myKpis;
  final SecretaryDepartmentFilesModel? departmentFiles;
  final SecretaryDepartmentDaakModel? departmentDaak;
  final SecretaryChartsModel? charts;
  final List<SecretarySectionStatModel> sectionStats;
  final int? activeUsers;
  final String? generatedAt;

  SecretaryDashboardModel({
    this.context,
    this.myKpis,
    this.departmentFiles,
    this.departmentDaak,
    this.charts,
    this.sectionStats = const [],
    this.activeUsers,
    this.generatedAt,
  });

  SecretaryDashboardModel copyWith({
    SecretaryContextModel? context,
    SecretaryMyKpisModel? myKpis,
    SecretaryDepartmentFilesModel? departmentFiles,
    SecretaryDepartmentDaakModel? departmentDaak,
    SecretaryChartsModel? charts,
    List<SecretarySectionStatModel>? sectionStats,
    int? activeUsers,
    String? generatedAt,
  }) {
    return SecretaryDashboardModel(
      context: context ?? this.context,
      myKpis: myKpis ?? this.myKpis,
      departmentFiles: departmentFiles ?? this.departmentFiles,
      departmentDaak: departmentDaak ?? this.departmentDaak,
      charts: charts ?? this.charts,
      sectionStats: sectionStats ?? this.sectionStats,
      activeUsers: activeUsers ?? this.activeUsers,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SecretaryDashboardSchema.context: context?.toJson(),
      SecretaryDashboardSchema.myKpis: myKpis?.toJson(),
      SecretaryDashboardSchema.departmentFiles: departmentFiles?.toJson(),
      SecretaryDashboardSchema.departmentDaak: departmentDaak?.toJson(),
      SecretaryDashboardSchema.charts: charts?.toJson(),
      SecretaryDashboardSchema.sectionStats: sectionStats
          .map((e) => e.toJson())
          .toList(),
      SecretaryDashboardSchema.activeUsers: activeUsers,
      SecretaryDashboardSchema.generatedAt: generatedAt,
    };
  }

  factory SecretaryDashboardModel.fromJson(Map<String, dynamic> map) {
    return SecretaryDashboardModel(
      context: map[SecretaryDashboardSchema.context] != null
          ? SecretaryContextModel.fromJson(
              Map<String, dynamic>.from(map[SecretaryDashboardSchema.context]),
            )
          : null,
      myKpis: map[SecretaryDashboardSchema.myKpis] != null
          ? SecretaryMyKpisModel.fromJson(
              Map<String, dynamic>.from(map[SecretaryDashboardSchema.myKpis]),
            )
          : null,
      departmentFiles: map[SecretaryDashboardSchema.departmentFiles] != null
          ? SecretaryDepartmentFilesModel.fromJson(
              Map<String, dynamic>.from(
                map[SecretaryDashboardSchema.departmentFiles],
              ),
            )
          : null,
      departmentDaak: map[SecretaryDashboardSchema.departmentDaak] != null
          ? SecretaryDepartmentDaakModel.fromJson(
              Map<String, dynamic>.from(
                map[SecretaryDashboardSchema.departmentDaak],
              ),
            )
          : null,
      charts: map[SecretaryDashboardSchema.charts] != null
          ? SecretaryChartsModel.fromJson(
              Map<String, dynamic>.from(map[SecretaryDashboardSchema.charts]),
            )
          : null,
      sectionStats: map[SecretaryDashboardSchema.sectionStats] != null
          ? List<SecretarySectionStatModel>.from(
              (map[SecretaryDashboardSchema.sectionStats] as List).map(
                (e) => SecretarySectionStatModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              ),
            )
          : [],
      activeUsers: map[SecretaryDashboardSchema.activeUsers]?.toInt(),
      generatedAt: map[SecretaryDashboardSchema.generatedAt],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecretaryDashboardModel &&
        other.context == context &&
        other.myKpis == myKpis &&
        other.departmentFiles == departmentFiles &&
        other.departmentDaak == departmentDaak &&
        other.charts == charts &&
        other.sectionStats == sectionStats &&
        other.activeUsers == activeUsers &&
        other.generatedAt == generatedAt;
  }

  @override
  int get hashCode =>
      context.hashCode ^
      myKpis.hashCode ^
      departmentFiles.hashCode ^
      departmentDaak.hashCode ^
      charts.hashCode ^
      sectionStats.hashCode ^
      activeUsers.hashCode ^
      generatedAt.hashCode;
}

class SecretaryDashboardSchema {
  static const String context = 'context';
  static const String myKpis = 'my_kpis';
  static const String departmentFiles = 'department_files';
  static const String departmentDaak = 'department_daak';
  static const String charts = 'charts';
  static const String sectionStats = 'section_stats';
  static const String activeUsers = 'active_users';
  static const String generatedAt = 'generated_at';
}

// ---------------------------------------------------------------------------

class SecretaryContextModel {
  final int? userDesgId;
  final String? userTitle;
  final String? designation;
  final String? section;
  final DepartmentModel? department;

  SecretaryContextModel({
    this.userDesgId,
    this.userTitle,
    this.designation,
    this.section,
    this.department,
  });

  SecretaryContextModel copyWith({
    int? userDesgId,
    String? userTitle,
    String? designation,
    String? section,
    DepartmentModel? department,
  }) {
    return SecretaryContextModel(
      userDesgId: userDesgId ?? this.userDesgId,
      userTitle: userTitle ?? this.userTitle,
      designation: designation ?? this.designation,
      section: section ?? this.section,
      department: department ?? this.department,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SecretaryContextSchema.userDesgId: userDesgId,
      SecretaryContextSchema.userTitle: userTitle,
      SecretaryContextSchema.designation: designation,
      SecretaryContextSchema.section: section,
      SecretaryContextSchema.department: department?.toJson(),
    };
  }

  factory SecretaryContextModel.fromJson(Map<String, dynamic> map) {
    return SecretaryContextModel(
      userDesgId: map[SecretaryContextSchema.userDesgId]?.toInt(),
      userTitle: map[SecretaryContextSchema.userTitle],
      designation: map[SecretaryContextSchema.designation],
      section: map[SecretaryContextSchema.section],
      department: map[SecretaryContextSchema.department] != null
          ? DepartmentModel.fromJson(
              Map<String, dynamic>.from(map[SecretaryContextSchema.department]),
            )
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecretaryContextModel &&
        other.userDesgId == userDesgId &&
        other.userTitle == userTitle &&
        other.designation == designation &&
        other.section == section &&
        other.department == department;
  }

  @override
  int get hashCode =>
      userDesgId.hashCode ^
      userTitle.hashCode ^
      designation.hashCode ^
      section.hashCode ^
      department.hashCode;
}

class SecretaryContextSchema {
  static const String userDesgId = 'user_desg_id';
  static const String userTitle = 'user_title';
  static const String designation = 'designation';
  static const String section = 'section';
  static const String department = 'department';
}

// ---------------------------------------------------------------------------

class SecretaryMyKpisModel {
  final int? myFiles;
  final int? actionRequired;
  final int? pending;
  final int? archived;
  final int? filesSent;
  final int? filesReceived;
  final int? processed;
  final int? daakInbox;
  final int? daakReturned;

  SecretaryMyKpisModel({
    this.myFiles,
    this.actionRequired,
    this.pending,
    this.archived,
    this.filesSent,
    this.filesReceived,
    this.processed,
    this.daakInbox,
    this.daakReturned,
  });

  SecretaryMyKpisModel copyWith({
    int? myFiles,
    int? actionRequired,
    int? pending,
    int? archived,
    int? filesSent,
    int? filesReceived,
    int? processed,
    int? daakInbox,
    int? daakReturned,
  }) {
    return SecretaryMyKpisModel(
      myFiles: myFiles ?? this.myFiles,
      actionRequired: actionRequired ?? this.actionRequired,
      pending: pending ?? this.pending,
      archived: archived ?? this.archived,
      filesSent: filesSent ?? this.filesSent,
      filesReceived: filesReceived ?? this.filesReceived,
      processed: processed ?? this.processed,
      daakInbox: daakInbox ?? this.daakInbox,
      daakReturned: daakReturned ?? this.daakReturned,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SecretaryMyKpisSchema.myFiles: myFiles,
      SecretaryMyKpisSchema.actionRequired: actionRequired,
      SecretaryMyKpisSchema.pending: pending,
      SecretaryMyKpisSchema.archived: archived,
      SecretaryMyKpisSchema.filesSent: filesSent,
      SecretaryMyKpisSchema.filesReceived: filesReceived,
      SecretaryMyKpisSchema.processed: processed,
      SecretaryMyKpisSchema.daakInbox: daakInbox,
      SecretaryMyKpisSchema.daakReturned: daakReturned,
    };
  }

  factory SecretaryMyKpisModel.fromJson(Map<String, dynamic> map) {
    return SecretaryMyKpisModel(
      myFiles: map[SecretaryMyKpisSchema.myFiles]?.toInt(),
      actionRequired: map[SecretaryMyKpisSchema.actionRequired]?.toInt(),
      pending: map[SecretaryMyKpisSchema.pending]?.toInt(),
      archived: map[SecretaryMyKpisSchema.archived]?.toInt(),
      filesSent: map[SecretaryMyKpisSchema.filesSent]?.toInt(),
      filesReceived: map[SecretaryMyKpisSchema.filesReceived]?.toInt(),
      processed: map[SecretaryMyKpisSchema.processed]?.toInt(),
      daakInbox: map[SecretaryMyKpisSchema.daakInbox]?.toInt(),
      daakReturned: map[SecretaryMyKpisSchema.daakReturned]?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecretaryMyKpisModel &&
        other.myFiles == myFiles &&
        other.actionRequired == actionRequired &&
        other.pending == pending &&
        other.archived == archived &&
        other.filesSent == filesSent &&
        other.filesReceived == filesReceived &&
        other.processed == processed &&
        other.daakInbox == daakInbox &&
        other.daakReturned == daakReturned;
  }

  @override
  int get hashCode =>
      myFiles.hashCode ^
      actionRequired.hashCode ^
      pending.hashCode ^
      archived.hashCode ^
      filesSent.hashCode ^
      filesReceived.hashCode ^
      processed.hashCode ^
      daakInbox.hashCode ^
      daakReturned.hashCode;
}

class SecretaryMyKpisSchema {
  static const String myFiles = 'my_files';
  static const String actionRequired = 'action_required';
  static const String pending = 'pending';
  static const String archived = 'archived';
  static const String filesSent = 'files_sent';
  static const String filesReceived = 'files_received';
  static const String processed = 'processed';
  static const String daakInbox = 'daak_inbox';
  static const String daakReturned = 'daak_returned';
}

// ---------------------------------------------------------------------------

class SecretaryDepartmentFilesModel {
  final int? totalCreated;
  final int? totalPending;
  final int? totalDisposed;
  final int? totalForwarded;

  SecretaryDepartmentFilesModel({
    this.totalCreated,
    this.totalPending,
    this.totalDisposed,
    this.totalForwarded,
  });

  SecretaryDepartmentFilesModel copyWith({
    int? totalCreated,
    int? totalPending,
    int? totalDisposed,
    int? totalForwarded,
  }) {
    return SecretaryDepartmentFilesModel(
      totalCreated: totalCreated ?? this.totalCreated,
      totalPending: totalPending ?? this.totalPending,
      totalDisposed: totalDisposed ?? this.totalDisposed,
      totalForwarded: totalForwarded ?? this.totalForwarded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SecretaryDepartmentFilesSchema.totalCreated: totalCreated,
      SecretaryDepartmentFilesSchema.totalPending: totalPending,
      SecretaryDepartmentFilesSchema.totalDisposed: totalDisposed,
      SecretaryDepartmentFilesSchema.totalForwarded: totalForwarded,
    };
  }

  factory SecretaryDepartmentFilesModel.fromJson(Map<String, dynamic> map) {
    return SecretaryDepartmentFilesModel(
      totalCreated: map[SecretaryDepartmentFilesSchema.totalCreated]?.toInt(),
      totalPending: map[SecretaryDepartmentFilesSchema.totalPending]?.toInt(),
      totalDisposed: map[SecretaryDepartmentFilesSchema.totalDisposed]?.toInt(),
      totalForwarded: map[SecretaryDepartmentFilesSchema.totalForwarded]
          ?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecretaryDepartmentFilesModel &&
        other.totalCreated == totalCreated &&
        other.totalPending == totalPending &&
        other.totalDisposed == totalDisposed &&
        other.totalForwarded == totalForwarded;
  }

  @override
  int get hashCode =>
      totalCreated.hashCode ^
      totalPending.hashCode ^
      totalDisposed.hashCode ^
      totalForwarded.hashCode;
}

class SecretaryDepartmentFilesSchema {
  static const String totalCreated = 'total_created';
  static const String totalPending = 'total_pending';
  static const String totalDisposed = 'total_disposed';
  static const String totalForwarded = 'total_forwarded';
}

// ---------------------------------------------------------------------------

class SecretaryDepartmentDaakModel {
  final int? totalReceived;
  final int? totalPending;
  final int? totalForwarded;
  final int? totalConverted;
  final int? totalNfa;
  final int? totalDisposed;

  SecretaryDepartmentDaakModel({
    this.totalReceived,
    this.totalPending,
    this.totalForwarded,
    this.totalConverted,
    this.totalNfa,
    this.totalDisposed,
  });

  SecretaryDepartmentDaakModel copyWith({
    int? totalReceived,
    int? totalPending,
    int? totalForwarded,
    int? totalConverted,
    int? totalNfa,
    int? totalDisposed,
  }) {
    return SecretaryDepartmentDaakModel(
      totalReceived: totalReceived ?? this.totalReceived,
      totalPending: totalPending ?? this.totalPending,
      totalForwarded: totalForwarded ?? this.totalForwarded,
      totalConverted: totalConverted ?? this.totalConverted,
      totalNfa: totalNfa ?? this.totalNfa,
      totalDisposed: totalDisposed ?? this.totalDisposed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SecretaryDepartmentDaakSchema.totalReceived: totalReceived,
      SecretaryDepartmentDaakSchema.totalPending: totalPending,
      SecretaryDepartmentDaakSchema.totalForwarded: totalForwarded,
      SecretaryDepartmentDaakSchema.totalConverted: totalConverted,
      SecretaryDepartmentDaakSchema.totalNfa: totalNfa,
      SecretaryDepartmentDaakSchema.totalDisposed: totalDisposed,
    };
  }

  factory SecretaryDepartmentDaakModel.fromJson(Map<String, dynamic> map) {
    return SecretaryDepartmentDaakModel(
      totalReceived: map[SecretaryDepartmentDaakSchema.totalReceived]?.toInt(),
      totalPending: map[SecretaryDepartmentDaakSchema.totalPending]?.toInt(),
      totalForwarded: map[SecretaryDepartmentDaakSchema.totalForwarded]
          ?.toInt(),
      totalConverted: map[SecretaryDepartmentDaakSchema.totalConverted]
          ?.toInt(),
      totalNfa: map[SecretaryDepartmentDaakSchema.totalNfa]?.toInt(),
      totalDisposed: map[SecretaryDepartmentDaakSchema.totalDisposed]?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecretaryDepartmentDaakModel &&
        other.totalReceived == totalReceived &&
        other.totalPending == totalPending &&
        other.totalForwarded == totalForwarded &&
        other.totalConverted == totalConverted &&
        other.totalNfa == totalNfa &&
        other.totalDisposed == totalDisposed;
  }

  @override
  int get hashCode =>
      totalReceived.hashCode ^
      totalPending.hashCode ^
      totalForwarded.hashCode ^
      totalConverted.hashCode ^
      totalNfa.hashCode ^
      totalDisposed.hashCode;
}

class SecretaryDepartmentDaakSchema {
  static const String totalReceived = 'total_received';
  static const String totalPending = 'total_pending';
  static const String totalForwarded = 'total_forwarded';
  static const String totalConverted = 'total_converted';
  static const String totalNfa = 'total_nfa';
  static const String totalDisposed = 'total_disposed';
}

// ---------------------------------------------------------------------------

class SecretaryChartsModel {
  final List<SecretaryTopUserModel> topFilePutup;
  final List<SecretaryTopUserModel> topPending;
  final List<SecretaryTopUserModel> topForwarded;

  SecretaryChartsModel({
    this.topFilePutup = const [],
    this.topPending = const [],
    this.topForwarded = const [],
  });

  SecretaryChartsModel copyWith({
    List<SecretaryTopUserModel>? topFilePutup,
    List<SecretaryTopUserModel>? topPending,
    List<SecretaryTopUserModel>? topForwarded,
  }) {
    return SecretaryChartsModel(
      topFilePutup: topFilePutup ?? this.topFilePutup,
      topPending: topPending ?? this.topPending,
      topForwarded: topForwarded ?? this.topForwarded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SecretaryChartsSchema.topFilePutup: topFilePutup
          .map((e) => e.toJson())
          .toList(),
      SecretaryChartsSchema.topPending: topPending
          .map((e) => e.toJson())
          .toList(),
      SecretaryChartsSchema.topForwarded: topForwarded
          .map((e) => e.toJson())
          .toList(),
    };
  }

  factory SecretaryChartsModel.fromJson(Map<String, dynamic> map) {
    List<SecretaryTopUserModel> parseList(String key) {
      return map[key] != null
          ? List<SecretaryTopUserModel>.from(
              (map[key] as List).map(
                (e) => SecretaryTopUserModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              ),
            )
          : [];
    }

    return SecretaryChartsModel(
      topFilePutup: parseList(SecretaryChartsSchema.topFilePutup),
      topPending: parseList(SecretaryChartsSchema.topPending),
      topForwarded: parseList(SecretaryChartsSchema.topForwarded),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecretaryChartsModel &&
        other.topFilePutup == topFilePutup &&
        other.topPending == topPending &&
        other.topForwarded == topForwarded;
  }

  @override
  int get hashCode =>
      topFilePutup.hashCode ^ topPending.hashCode ^ topForwarded.hashCode;
}

class SecretaryChartsSchema {
  static const String topFilePutup = 'top_file_putup';
  static const String topPending = 'top_pending';
  static const String topForwarded = 'top_forwarded';
}

// ---------------------------------------------------------------------------

class SecretaryTopUserModel {
  final int? userDesgId;
  final String? userTitle;
  final String? designation;
  final String? section;
  final int? count;

  SecretaryTopUserModel({
    this.userDesgId,
    this.userTitle,
    this.designation,
    this.section,
    this.count,
  });

  SecretaryTopUserModel copyWith({
    int? userDesgId,
    String? userTitle,
    String? designation,
    String? section,
    int? count,
  }) {
    return SecretaryTopUserModel(
      userDesgId: userDesgId ?? this.userDesgId,
      userTitle: userTitle ?? this.userTitle,
      designation: designation ?? this.designation,
      section: section ?? this.section,
      count: count ?? this.count,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SecretaryTopUserSchema.userDesgId: userDesgId,
      SecretaryTopUserSchema.userTitle: userTitle,
      SecretaryTopUserSchema.designation: designation,
      SecretaryTopUserSchema.section: section,
      SecretaryTopUserSchema.count: count,
    };
  }

  factory SecretaryTopUserModel.fromJson(Map<String, dynamic> map) {
    return SecretaryTopUserModel(
      userDesgId: map[SecretaryTopUserSchema.userDesgId]?.toInt(),
      userTitle: map[SecretaryTopUserSchema.userTitle],
      designation: map[SecretaryTopUserSchema.designation],
      section: map[SecretaryTopUserSchema.section],
      count: map[SecretaryTopUserSchema.count]?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecretaryTopUserModel &&
        other.userDesgId == userDesgId &&
        other.userTitle == userTitle &&
        other.designation == designation &&
        other.section == section &&
        other.count == count;
  }

  @override
  int get hashCode =>
      userDesgId.hashCode ^
      userTitle.hashCode ^
      designation.hashCode ^
      section.hashCode ^
      count.hashCode;
}

class SecretaryTopUserSchema {
  static const String userDesgId = 'user_desg_id';
  static const String userTitle = 'user_title';
  static const String designation = 'designation';
  static const String section = 'section';
  static const String count = 'count';
}

// ---------------------------------------------------------------------------

class SecretarySectionStatModel {
  final int? sectionId;
  final String? section;
  final int? total;
  final int? archived;
  final int? pending;

  SecretarySectionStatModel({
    this.sectionId,
    this.section,
    this.total,
    this.archived,
    this.pending,
  });

  SecretarySectionStatModel copyWith({
    int? sectionId,
    String? section,
    int? total,
    int? archived,
    int? pending,
  }) {
    return SecretarySectionStatModel(
      sectionId: sectionId ?? this.sectionId,
      section: section ?? this.section,
      total: total ?? this.total,
      archived: archived ?? this.archived,
      pending: pending ?? this.pending,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SecretarySectionStatSchema.sectionId: sectionId,
      SecretarySectionStatSchema.section: section,
      SecretarySectionStatSchema.total: total,
      SecretarySectionStatSchema.archived: archived,
      SecretarySectionStatSchema.pending: pending,
    };
  }

  factory SecretarySectionStatModel.fromJson(Map<String, dynamic> map) {
    return SecretarySectionStatModel(
      sectionId: map[SecretarySectionStatSchema.sectionId]?.toInt(),
      section: map[SecretarySectionStatSchema.section],
      total: map[SecretarySectionStatSchema.total]?.toInt(),
      archived: map[SecretarySectionStatSchema.archived]?.toInt(),
      pending: map[SecretarySectionStatSchema.pending]?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecretarySectionStatModel &&
        other.sectionId == sectionId &&
        other.section == section &&
        other.total == total &&
        other.archived == archived &&
        other.pending == pending;
  }

  @override
  int get hashCode =>
      sectionId.hashCode ^
      section.hashCode ^
      total.hashCode ^
      archived.hashCode ^
      pending.hashCode;
}

class SecretarySectionStatSchema {
  static const String sectionId = 'section_id';
  static const String section = 'section';
  static const String total = 'total';
  static const String archived = 'archived';
  static const String pending = 'pending';
}
