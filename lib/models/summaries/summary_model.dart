class SummaryModel {
  final int? id;
  final String? summaryNo;
  final String? subject;
  final String? summaryDate;
  final String? summaryType;
  final String? body;
  final int? statusCode;
  final String? statusLabel;
  final String? statusBadge;
  final String? originatingDepartment;
  final String? currentDepartment;
  final String? originatingUser;
  final String? originatingDesignation;
  final String? currentHolder;
  final String? currentHolderDesignation;
  final String? draftTargetDepartment;
  final String? createdAt;
  final String? updatedAt;

  SummaryModel({
    this.id,
    this.summaryNo,
    this.subject,
    this.summaryDate,
    this.summaryType,
    this.body,
    this.statusCode,
    this.statusLabel,
    this.statusBadge,
    this.originatingDepartment,
    this.currentDepartment,
    this.originatingUser,
    this.originatingDesignation,
    this.currentHolder,
    this.currentHolderDesignation,
    this.draftTargetDepartment,
    this.createdAt,
    this.updatedAt,
  });

  SummaryModel copyWith({
    int? id,
    String? summaryNo,
    String? subject,
    String? summaryDate,
    String? summaryType,
    String? body,
    int? statusCode,
    String? statusLabel,
    String? statusBadge,
    String? originatingDepartment,
    String? currentDepartment,
    String? originatingUser,
    String? originatingDesignation,
    String? currentHolder,
    String? currentHolderDesignation,
    String? draftTargetDepartment,
    String? createdAt,
    String? updatedAt,
  }) {
    return SummaryModel(
      id: id ?? this.id,
      summaryNo: summaryNo ?? this.summaryNo,
      subject: subject ?? this.subject,
      summaryDate: summaryDate ?? this.summaryDate,
      summaryType: summaryType ?? this.summaryType,
      body: body ?? this.body,
      statusCode: statusCode ?? this.statusCode,
      statusLabel: statusLabel ?? this.statusLabel,
      statusBadge: statusBadge ?? this.statusBadge,
      originatingDepartment:
          originatingDepartment ?? this.originatingDepartment,
      currentDepartment: currentDepartment ?? this.currentDepartment,
      originatingUser: originatingUser ?? this.originatingUser,
      originatingDesignation:
          originatingDesignation ?? this.originatingDesignation,
      currentHolder: currentHolder ?? this.currentHolder,
      currentHolderDesignation:
          currentHolderDesignation ?? this.currentHolderDesignation,
      draftTargetDepartment:
          draftTargetDepartment ?? this.draftTargetDepartment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SummarySchema.id: id,
      SummarySchema.summaryNo: summaryNo,
      SummarySchema.subject: subject,
      SummarySchema.summaryDate: summaryDate,
      SummarySchema.summaryType: summaryType,
      SummarySchema.body: body,
      SummarySchema.statusCode: statusCode,
      SummarySchema.statusLabel: statusLabel,
      SummarySchema.statusBadge: statusBadge,
      SummarySchema.originatingDepartment: originatingDepartment,
      SummarySchema.currentDepartment: currentDepartment,
      SummarySchema.originatingUser: originatingUser,
      SummarySchema.originatingDesignation: originatingDesignation,
      SummarySchema.currentHolder: currentHolder,
      SummarySchema.currentHolderDesignation: currentHolderDesignation,
      SummarySchema.draftTargetDepartment: draftTargetDepartment,
      SummarySchema.createdAt: createdAt,
      SummarySchema.updatedAt: updatedAt,
    };
  }

  factory SummaryModel.fromJson(Map<String, dynamic> map) {
    return SummaryModel(
      id: map[SummarySchema.id]?.toInt(),
      summaryNo: map[SummarySchema.summaryNo],
      subject: map[SummarySchema.subject],
      summaryDate: map[SummarySchema.summaryDate],
      summaryType: map[SummarySchema.summaryType],
      body: map[SummarySchema.body],
      statusCode: map[SummarySchema.statusCode]?.toInt(),
      statusLabel: map[SummarySchema.statusLabel],
      statusBadge: map[SummarySchema.statusBadge],
      originatingDepartment: map[SummarySchema.originatingDepartment],
      currentDepartment: map[SummarySchema.currentDepartment],
      originatingUser: map[SummarySchema.originatingUser],
      originatingDesignation: map[SummarySchema.originatingDesignation],
      currentHolder: map[SummarySchema.currentHolder],
      currentHolderDesignation: map[SummarySchema.currentHolderDesignation],
      draftTargetDepartment: map[SummarySchema.draftTargetDepartment],
      createdAt: map[SummarySchema.createdAt],
      updatedAt: map[SummarySchema.updatedAt],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SummaryModel &&
        other.id == id &&
        other.summaryNo == summaryNo &&
        other.subject == subject &&
        other.summaryDate == summaryDate &&
        other.summaryType == summaryType &&
        other.body == body &&
        other.statusCode == statusCode &&
        other.statusLabel == statusLabel &&
        other.statusBadge == statusBadge &&
        other.originatingDepartment == originatingDepartment &&
        other.currentDepartment == currentDepartment &&
        other.originatingUser == originatingUser &&
        other.originatingDesignation == originatingDesignation &&
        other.currentHolder == currentHolder &&
        other.currentHolderDesignation == currentHolderDesignation &&
        other.draftTargetDepartment == draftTargetDepartment &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        summaryNo.hashCode ^
        subject.hashCode ^
        summaryDate.hashCode ^
        summaryType.hashCode ^
        body.hashCode ^
        statusCode.hashCode ^
        statusLabel.hashCode ^
        statusBadge.hashCode ^
        originatingDepartment.hashCode ^
        currentDepartment.hashCode ^
        originatingUser.hashCode ^
        originatingDesignation.hashCode ^
        currentHolder.hashCode ^
        currentHolderDesignation.hashCode ^
        draftTargetDepartment.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}

class SummarySchema {
  static const String id = 'id';
  static const String summaryNo = 'summary_no';
  static const String subject = 'subject';
  static const String summaryDate = 'summary_date';
  static const String summaryType = 'summary_type';
  static const String body = 'body';
  static const String statusCode = 'status_code';
  static const String statusLabel = 'status_label';
  static const String statusBadge = 'status_badge';
  static const String originatingDepartment = 'originating_department';
  static const String currentDepartment = 'current_department';
  static const String originatingUser = 'originating_user';
  static const String originatingDesignation = 'originating_designation';
  static const String currentHolder = 'current_holder';
  static const String currentHolderDesignation = 'current_holder_designation';
  static const String draftTargetDepartment = 'draft_target_department';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}
