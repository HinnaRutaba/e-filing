/// Period filter for the Daak report. [value] is what the API expects in the
/// `period` query param; [all] sends no period (all time).
enum DaakReportPeriod {
  all('', 'All time'),
  today('today', 'Today'),
  last7Days('7d', '7 days'),
  last30Days('30d', '30 days'),
  month('month', 'This month'),
  year('year', 'This year'),
  custom('custom', 'Custom');

  const DaakReportPeriod(this.value, this.label);

  final String value;
  final String label;

  static DaakReportPeriod fromValue(String? value) => DaakReportPeriod.values
      .firstWhere((e) => e.value == value, orElse: () => DaakReportPeriod.all);
}

/// Response `data` of `secretary/dashboard/daak`.
class DaakReportModel {
  final DaakReportPeriodInfo? period;
  final DaakReportSummary? summary;
  final List<DaakReportStatusCard> statusCards;
  final List<DaakReportMonthlyTrend> monthlyTrend;
  final List<DaakReportAgeing> ageing;
  final List<DaakReportPendingWith> pendingWith;
  final List<DaakReportDepartmentFlow> sentToDepartments;
  final List<DaakReportDepartmentFlow> receivedFromDepartments;
  final List<DaakReportSourceDepartment> sourceDepartmentStats;
  final String? generatedAt;

  DaakReportModel({
    this.period,
    this.summary,
    this.statusCards = const [],
    this.monthlyTrend = const [],
    this.ageing = const [],
    this.pendingWith = const [],
    this.sentToDepartments = const [],
    this.receivedFromDepartments = const [],
    this.sourceDepartmentStats = const [],
    this.generatedAt,
  });

  DaakReportModel copyWith({
    DaakReportPeriodInfo? period,
    DaakReportSummary? summary,
    List<DaakReportStatusCard>? statusCards,
    List<DaakReportMonthlyTrend>? monthlyTrend,
    List<DaakReportAgeing>? ageing,
    List<DaakReportPendingWith>? pendingWith,
    List<DaakReportDepartmentFlow>? sentToDepartments,
    List<DaakReportDepartmentFlow>? receivedFromDepartments,
    List<DaakReportSourceDepartment>? sourceDepartmentStats,
    String? generatedAt,
  }) {
    return DaakReportModel(
      period: period ?? this.period,
      summary: summary ?? this.summary,
      statusCards: statusCards ?? this.statusCards,
      monthlyTrend: monthlyTrend ?? this.monthlyTrend,
      ageing: ageing ?? this.ageing,
      pendingWith: pendingWith ?? this.pendingWith,
      sentToDepartments: sentToDepartments ?? this.sentToDepartments,
      receivedFromDepartments:
          receivedFromDepartments ?? this.receivedFromDepartments,
      sourceDepartmentStats:
          sourceDepartmentStats ?? this.sourceDepartmentStats,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DaakReportSchema.period: period?.toJson(),
      DaakReportSchema.summary: summary?.toJson(),
      DaakReportSchema.statusCards: statusCards.map((e) => e.toJson()).toList(),
      DaakReportSchema.monthlyTrend: monthlyTrend
          .map((e) => e.toJson())
          .toList(),
      DaakReportSchema.ageing: ageing.map((e) => e.toJson()).toList(),
      DaakReportSchema.pendingWith: pendingWith.map((e) => e.toJson()).toList(),
      DaakReportSchema.sentToDepartments: sentToDepartments
          .map((e) => e.toJson())
          .toList(),
      DaakReportSchema.receivedFromDepartments: receivedFromDepartments
          .map((e) => e.toJson())
          .toList(),
      DaakReportSchema.sourceDepartmentStats: sourceDepartmentStats
          .map((e) => e.toJson())
          .toList(),
      DaakReportSchema.generatedAt: generatedAt,
    };
  }

  /// Parses the response's `data` object.
  factory DaakReportModel.fromJson(Map<String, dynamic> map) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) parse) =>
        map[key] is List
        ? (map[key] as List)
              .map((e) => parse(Map<String, dynamic>.from(e)))
              .toList()
        : <T>[];

    return DaakReportModel(
      period: map[DaakReportSchema.period] != null
          ? DaakReportPeriodInfo.fromJson(
              Map<String, dynamic>.from(map[DaakReportSchema.period]),
            )
          : null,
      summary: map[DaakReportSchema.summary] != null
          ? DaakReportSummary.fromJson(
              Map<String, dynamic>.from(map[DaakReportSchema.summary]),
            )
          : null,
      statusCards: list(
        DaakReportSchema.statusCards,
        DaakReportStatusCard.fromJson,
      ),
      monthlyTrend: list(
        DaakReportSchema.monthlyTrend,
        DaakReportMonthlyTrend.fromJson,
      ),
      ageing: list(DaakReportSchema.ageing, DaakReportAgeing.fromJson),
      pendingWith: list(
        DaakReportSchema.pendingWith,
        DaakReportPendingWith.fromJson,
      ),
      sentToDepartments: list(
        DaakReportSchema.sentToDepartments,
        DaakReportDepartmentFlow.fromJson,
      ),
      receivedFromDepartments: list(
        DaakReportSchema.receivedFromDepartments,
        DaakReportDepartmentFlow.fromJson,
      ),
      sourceDepartmentStats: list(
        DaakReportSchema.sourceDepartmentStats,
        DaakReportSourceDepartment.fromJson,
      ),
      generatedAt: map[DaakReportSchema.generatedAt],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DaakReportModel &&
        other.period == period &&
        other.summary == summary &&
        other.statusCards == statusCards &&
        other.monthlyTrend == monthlyTrend &&
        other.ageing == ageing &&
        other.pendingWith == pendingWith &&
        other.sentToDepartments == sentToDepartments &&
        other.receivedFromDepartments == receivedFromDepartments &&
        other.sourceDepartmentStats == sourceDepartmentStats &&
        other.generatedAt == generatedAt;
  }

  @override
  int get hashCode =>
      period.hashCode ^
      summary.hashCode ^
      statusCards.hashCode ^
      monthlyTrend.hashCode ^
      ageing.hashCode ^
      pendingWith.hashCode ^
      sentToDepartments.hashCode ^
      receivedFromDepartments.hashCode ^
      sourceDepartmentStats.hashCode ^
      generatedAt.hashCode;
}

class DaakReportSchema {
  static const String period = 'period';
  static const String summary = 'summary';
  static const String statusCards = 'status_cards';
  static const String monthlyTrend = 'monthly_trend';
  static const String ageing = 'ageing';
  static const String pendingWith = 'pending_with';
  static const String sentToDepartments = 'sent_to_departments';
  static const String receivedFromDepartments = 'received_from_departments';
  static const String sourceDepartmentStats = 'source_department_stats';
  static const String generatedAt = 'generated_at';
}

// ---------------------------------------------------------------------------

/// The range the server actually applied. [from] / [to] are `yyyy-MM-dd`;
/// either can be null (e.g. an open-ended "last 30 days" has no [to]).
class DaakReportPeriodInfo {
  final String? key;
  final String? from;
  final String? to;

  DaakReportPeriodInfo({this.key, this.from, this.to});

  DaakReportPeriodInfo copyWith({String? key, String? from, String? to}) {
    return DaakReportPeriodInfo(
      key: key ?? this.key,
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DaakReportPeriodSchema.key: key,
      DaakReportPeriodSchema.from: from,
      DaakReportPeriodSchema.to: to,
    };
  }

  factory DaakReportPeriodInfo.fromJson(Map<String, dynamic> map) {
    return DaakReportPeriodInfo(
      key: map[DaakReportPeriodSchema.key],
      from: map[DaakReportPeriodSchema.from],
      to: map[DaakReportPeriodSchema.to],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DaakReportPeriodInfo &&
        other.key == key &&
        other.from == from &&
        other.to == to;
  }

  @override
  int get hashCode => key.hashCode ^ from.hashCode ^ to.hashCode;
}

class DaakReportPeriodSchema {
  static const String key = 'key';
  static const String from = 'from';
  static const String to = 'to';
}

// ---------------------------------------------------------------------------

class DaakReportSummary {
  final int? total;
  final int? inProgress;
  final int? returned;
  final int? filePutup;
  final int? nfa;
  final int? disposedOff;
  final int? closed;

  DaakReportSummary({
    this.total,
    this.inProgress,
    this.returned,
    this.filePutup,
    this.nfa,
    this.disposedOff,
    this.closed,
  });

  DaakReportSummary copyWith({
    int? total,
    int? inProgress,
    int? returned,
    int? filePutup,
    int? nfa,
    int? disposedOff,
    int? closed,
  }) {
    return DaakReportSummary(
      total: total ?? this.total,
      inProgress: inProgress ?? this.inProgress,
      returned: returned ?? this.returned,
      filePutup: filePutup ?? this.filePutup,
      nfa: nfa ?? this.nfa,
      disposedOff: disposedOff ?? this.disposedOff,
      closed: closed ?? this.closed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DaakReportSummarySchema.total: total,
      DaakReportSummarySchema.inProgress: inProgress,
      DaakReportSummarySchema.returned: returned,
      DaakReportSummarySchema.filePutup: filePutup,
      DaakReportSummarySchema.nfa: nfa,
      DaakReportSummarySchema.disposedOff: disposedOff,
      DaakReportSummarySchema.closed: closed,
    };
  }

  factory DaakReportSummary.fromJson(Map<String, dynamic> map) {
    return DaakReportSummary(
      total: map[DaakReportSummarySchema.total]?.toInt(),
      inProgress: map[DaakReportSummarySchema.inProgress]?.toInt(),
      returned: map[DaakReportSummarySchema.returned]?.toInt(),
      filePutup: map[DaakReportSummarySchema.filePutup]?.toInt(),
      nfa: map[DaakReportSummarySchema.nfa]?.toInt(),
      disposedOff: map[DaakReportSummarySchema.disposedOff]?.toInt(),
      closed: map[DaakReportSummarySchema.closed]?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DaakReportSummary &&
        other.total == total &&
        other.inProgress == inProgress &&
        other.returned == returned &&
        other.filePutup == filePutup &&
        other.nfa == nfa &&
        other.disposedOff == disposedOff &&
        other.closed == closed;
  }

  @override
  int get hashCode =>
      total.hashCode ^
      inProgress.hashCode ^
      returned.hashCode ^
      filePutup.hashCode ^
      nfa.hashCode ^
      disposedOff.hashCode ^
      closed.hashCode;
}

class DaakReportSummarySchema {
  static const String total = 'total';
  static const String inProgress = 'in_progress';
  static const String returned = 'returned';
  static const String filePutup = 'file_putup';
  static const String nfa = 'nfa';
  static const String disposedOff = 'disposed_off';
  static const String closed = 'closed';
}

// ---------------------------------------------------------------------------

class DaakReportStatusCard {
  final int? status;
  final String? label;
  final int? count;

  DaakReportStatusCard({this.status, this.label, this.count});

  DaakReportStatusCard copyWith({int? status, String? label, int? count}) {
    return DaakReportStatusCard(
      status: status ?? this.status,
      label: label ?? this.label,
      count: count ?? this.count,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DaakReportStatusCardSchema.status: status,
      DaakReportStatusCardSchema.label: label,
      DaakReportStatusCardSchema.count: count,
    };
  }

  factory DaakReportStatusCard.fromJson(Map<String, dynamic> map) {
    return DaakReportStatusCard(
      status: map[DaakReportStatusCardSchema.status]?.toInt(),
      label: map[DaakReportStatusCardSchema.label],
      count: map[DaakReportStatusCardSchema.count]?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DaakReportStatusCard &&
        other.status == status &&
        other.label == label &&
        other.count == count;
  }

  @override
  int get hashCode => status.hashCode ^ label.hashCode ^ count.hashCode;
}

class DaakReportStatusCardSchema {
  static const String status = 'status';
  static const String label = 'label';
  static const String count = 'count';
}

// ---------------------------------------------------------------------------

class DaakReportMonthlyTrend {
  /// `yyyy-MM`.
  final String? month;
  final String? label;
  final int? received;
  final int? open;

  DaakReportMonthlyTrend({this.month, this.label, this.received, this.open});

  DaakReportMonthlyTrend copyWith({
    String? month,
    String? label,
    int? received,
    int? open,
  }) {
    return DaakReportMonthlyTrend(
      month: month ?? this.month,
      label: label ?? this.label,
      received: received ?? this.received,
      open: open ?? this.open,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DaakReportMonthlyTrendSchema.month: month,
      DaakReportMonthlyTrendSchema.label: label,
      DaakReportMonthlyTrendSchema.received: received,
      DaakReportMonthlyTrendSchema.open: open,
    };
  }

  factory DaakReportMonthlyTrend.fromJson(Map<String, dynamic> map) {
    return DaakReportMonthlyTrend(
      month: map[DaakReportMonthlyTrendSchema.month],
      label: map[DaakReportMonthlyTrendSchema.label],
      received: map[DaakReportMonthlyTrendSchema.received]?.toInt(),
      open: map[DaakReportMonthlyTrendSchema.open]?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DaakReportMonthlyTrend &&
        other.month == month &&
        other.label == label &&
        other.received == received &&
        other.open == open;
  }

  @override
  int get hashCode =>
      month.hashCode ^ label.hashCode ^ received.hashCode ^ open.hashCode;
}

class DaakReportMonthlyTrendSchema {
  static const String month = 'month';
  static const String label = 'label';
  static const String received = 'received';
  static const String open = 'open';
}

// ---------------------------------------------------------------------------

class DaakReportAgeing {
  final String? label;
  final int? count;

  DaakReportAgeing({this.label, this.count});

  DaakReportAgeing copyWith({String? label, int? count}) {
    return DaakReportAgeing(
      label: label ?? this.label,
      count: count ?? this.count,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DaakReportAgeingSchema.label: label,
      DaakReportAgeingSchema.count: count,
    };
  }

  factory DaakReportAgeing.fromJson(Map<String, dynamic> map) {
    return DaakReportAgeing(
      label: map[DaakReportAgeingSchema.label],
      count: map[DaakReportAgeingSchema.count]?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DaakReportAgeing &&
        other.label == label &&
        other.count == count;
  }

  @override
  int get hashCode => label.hashCode ^ count.hashCode;
}

class DaakReportAgeingSchema {
  static const String label = 'label';
  static const String count = 'count';
}

// ---------------------------------------------------------------------------

class DaakReportPendingWith {
  final int? userDesgId;
  final String? name;
  final String? designation;
  final String? section;
  final String? department;
  final int? count;

  /// When the oldest pending daak reached this person.
  final DateTime? oldest;

  DaakReportPendingWith({
    this.userDesgId,
    this.name,
    this.designation,
    this.section,
    this.department,
    this.count,
    this.oldest,
  });

  DaakReportPendingWith copyWith({
    int? userDesgId,
    String? name,
    String? designation,
    String? section,
    String? department,
    int? count,
    DateTime? oldest,
  }) {
    return DaakReportPendingWith(
      userDesgId: userDesgId ?? this.userDesgId,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      section: section ?? this.section,
      department: department ?? this.department,
      count: count ?? this.count,
      oldest: oldest ?? this.oldest,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DaakReportPendingWithSchema.userDesgId: userDesgId,
      DaakReportPendingWithSchema.name: name,
      DaakReportPendingWithSchema.designation: designation,
      DaakReportPendingWithSchema.section: section,
      DaakReportPendingWithSchema.department: department,
      DaakReportPendingWithSchema.count: count,
      DaakReportPendingWithSchema.oldest: oldest?.toIso8601String(),
    };
  }

  factory DaakReportPendingWith.fromJson(Map<String, dynamic> map) {
    return DaakReportPendingWith(
      userDesgId: map[DaakReportPendingWithSchema.userDesgId]?.toInt(),
      name: map[DaakReportPendingWithSchema.name],
      designation: map[DaakReportPendingWithSchema.designation],
      section: map[DaakReportPendingWithSchema.section],
      department: map[DaakReportPendingWithSchema.department],
      count: map[DaakReportPendingWithSchema.count]?.toInt(),
      oldest: map[DaakReportPendingWithSchema.oldest] != null
          ? DateTime.tryParse(map[DaakReportPendingWithSchema.oldest])
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DaakReportPendingWith &&
        other.userDesgId == userDesgId &&
        other.name == name &&
        other.designation == designation &&
        other.section == section &&
        other.department == department &&
        other.count == count &&
        other.oldest == oldest;
  }

  @override
  int get hashCode =>
      userDesgId.hashCode ^
      name.hashCode ^
      designation.hashCode ^
      section.hashCode ^
      department.hashCode ^
      count.hashCode ^
      oldest.hashCode;
}

class DaakReportPendingWithSchema {
  static const String userDesgId = 'user_desg_id';
  static const String name = 'name';
  static const String designation = 'designation';
  static const String section = 'section';
  static const String department = 'department';
  static const String count = 'count';
  static const String oldest = 'oldest';
}

// ---------------------------------------------------------------------------

/// A department's total and still-open daak, used for both
/// `sent_to_departments` and `received_from_departments`.
class DaakReportDepartmentFlow {
  final String? department;
  final int? total;
  final int? open;

  DaakReportDepartmentFlow({this.department, this.total, this.open});

  DaakReportDepartmentFlow copyWith({
    String? department,
    int? total,
    int? open,
  }) {
    return DaakReportDepartmentFlow(
      department: department ?? this.department,
      total: total ?? this.total,
      open: open ?? this.open,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DaakReportDepartmentFlowSchema.department: department,
      DaakReportDepartmentFlowSchema.total: total,
      DaakReportDepartmentFlowSchema.open: open,
    };
  }

  factory DaakReportDepartmentFlow.fromJson(Map<String, dynamic> map) {
    return DaakReportDepartmentFlow(
      department: map[DaakReportDepartmentFlowSchema.department],
      total: map[DaakReportDepartmentFlowSchema.total]?.toInt(),
      open: map[DaakReportDepartmentFlowSchema.open]?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DaakReportDepartmentFlow &&
        other.department == department &&
        other.total == total &&
        other.open == open;
  }

  @override
  int get hashCode => department.hashCode ^ total.hashCode ^ open.hashCode;
}

class DaakReportDepartmentFlowSchema {
  static const String department = 'department';
  static const String total = 'total';
  static const String open = 'open';
}

// ---------------------------------------------------------------------------

class DaakReportSourceDepartment {
  /// Null for daak whose sender was typed in rather than picked from the
  /// department list.
  final int? sourceDepartmentId;
  final String? sourceDepartment;
  final int? total;
  final int? inProgress;
  final int? filePutup;
  final int? nfa;
  final int? disposedOff;

  DaakReportSourceDepartment({
    this.sourceDepartmentId,
    this.sourceDepartment,
    this.total,
    this.inProgress,
    this.filePutup,
    this.nfa,
    this.disposedOff,
  });

  DaakReportSourceDepartment copyWith({
    int? sourceDepartmentId,
    String? sourceDepartment,
    int? total,
    int? inProgress,
    int? filePutup,
    int? nfa,
    int? disposedOff,
  }) {
    return DaakReportSourceDepartment(
      sourceDepartmentId: sourceDepartmentId ?? this.sourceDepartmentId,
      sourceDepartment: sourceDepartment ?? this.sourceDepartment,
      total: total ?? this.total,
      inProgress: inProgress ?? this.inProgress,
      filePutup: filePutup ?? this.filePutup,
      nfa: nfa ?? this.nfa,
      disposedOff: disposedOff ?? this.disposedOff,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      DaakReportSourceDepartmentSchema.sourceDepartmentId: sourceDepartmentId,
      DaakReportSourceDepartmentSchema.sourceDepartment: sourceDepartment,
      DaakReportSourceDepartmentSchema.total: total,
      DaakReportSourceDepartmentSchema.inProgress: inProgress,
      DaakReportSourceDepartmentSchema.filePutup: filePutup,
      DaakReportSourceDepartmentSchema.nfa: nfa,
      DaakReportSourceDepartmentSchema.disposedOff: disposedOff,
    };
  }

  factory DaakReportSourceDepartment.fromJson(Map<String, dynamic> map) {
    return DaakReportSourceDepartment(
      sourceDepartmentId:
          map[DaakReportSourceDepartmentSchema.sourceDepartmentId]?.toInt(),
      sourceDepartment: map[DaakReportSourceDepartmentSchema.sourceDepartment],
      total: map[DaakReportSourceDepartmentSchema.total]?.toInt(),
      inProgress: map[DaakReportSourceDepartmentSchema.inProgress]?.toInt(),
      filePutup: map[DaakReportSourceDepartmentSchema.filePutup]?.toInt(),
      nfa: map[DaakReportSourceDepartmentSchema.nfa]?.toInt(),
      disposedOff: map[DaakReportSourceDepartmentSchema.disposedOff]?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DaakReportSourceDepartment &&
        other.sourceDepartmentId == sourceDepartmentId &&
        other.sourceDepartment == sourceDepartment &&
        other.total == total &&
        other.inProgress == inProgress &&
        other.filePutup == filePutup &&
        other.nfa == nfa &&
        other.disposedOff == disposedOff;
  }

  @override
  int get hashCode =>
      sourceDepartmentId.hashCode ^
      sourceDepartment.hashCode ^
      total.hashCode ^
      inProgress.hashCode ^
      filePutup.hashCode ^
      nfa.hashCode ^
      disposedOff.hashCode;
}

class DaakReportSourceDepartmentSchema {
  static const String sourceDepartmentId = 'source_department_id';
  static const String sourceDepartment = 'source_department';
  static const String total = 'total';
  static const String inProgress = 'in_progress';
  static const String filePutup = 'file_putup';
  static const String nfa = 'nfa';
  static const String disposedOff = 'disposed_off';
}
