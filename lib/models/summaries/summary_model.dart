import 'package:efiling_balochistan/utils/helper_utils.dart';
import 'package:flutter/material.dart';

enum SummaryStatus {
  pendingWithSecretary(1, 'Pending with Secretary', 'warning'),
  sharedInternallyForFeedback(2, 'Shared Internally for Feedback', 'info'),
  collectingInternalRemarks(3, 'Collecting Internal Remarks', 'primary'),
  readyToForward(4, 'Ready to Forward', 'success'),
  forwardedToNextDepartment(5, 'Forwarded to Next Department', 'secondary'),
  closedFinal(6, 'Closed / Final', 'dark'),
  draftFromSection(7, 'Draft from Section', 'danger'),
  withChiefMinisterForApproval(
    8,
    'With Chief Minister for Approval',
    'primary',
  ),
  disposedOff(9, 'Disposed Off', 'dark'),
  pendingDisposalBySection(10, 'Pending Disposal by Section', 'warning'),
  withPersonalSecretaryForPreReview(
    11,
    'With Personal Secretary for Pre-Review',
    'info',
  );

  final int value;
  final String label;
  final String tag;

  const SummaryStatus(this.value, this.label, this.tag);

  static SummaryStatus? fromValue(int? statusCode) {
    if (statusCode == null) return null;
    try {
      return SummaryStatus.values.firstWhere(
        (status) => status.value == statusCode,
        orElse: () => SummaryStatus.draftFromSection,
      );
    } catch (_) {
      return null;
    }
  }

  Color getStatusColor() {
    return HelperUtils.getTagColor(tag);
  }
}

class SummaryModel {
  final int? id;
  final String? summaryNo;
  final String? subject;
  final DateTime? summaryDate;
  final String? summaryType;
  final String? body;
  final int? statusCode;
  final String? statusLabel;
  final Color? statusBadge;
  final int? originatingDepartmentId;
  final String? originatingDepartment;
  final int? currentDepartmentId;
  final String? currentDepartment;
  final int? originatingUserDesgId;
  final String? originatingUser;
  final String? originatingDesignation;
  final int? currentHolderUserDesgId;
  final String? currentHolder;
  final String? currentHolderDesignation;
  final int? draftTargetDepartmentId;
  final String? draftTargetDepartment;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SummaryStatus? summaryStatus;

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
    this.originatingDepartmentId,
    this.originatingDepartment,
    this.currentDepartmentId,
    this.currentDepartment,
    this.originatingUserDesgId,
    this.originatingUser,
    this.originatingDesignation,
    this.currentHolderUserDesgId,
    this.currentHolder,
    this.currentHolderDesignation,
    this.draftTargetDepartmentId,
    this.draftTargetDepartment,
    this.createdAt,
    this.updatedAt,
    this.summaryStatus,
  });

  SummaryModel copyWith({
    int? id,
    String? summaryNo,
    String? subject,
    DateTime? summaryDate,
    String? summaryType,
    String? body,
    int? statusCode,
    String? statusLabel,
    Color? statusBadge,
    int? originatingDepartmentId,
    String? originatingDepartment,
    int? currentDepartmentId,
    String? currentDepartment,
    int? originatingUserDesgId,
    String? originatingUser,
    String? originatingDesignation,
    int? currentHolderUserDesgId,
    String? currentHolder,
    String? currentHolderDesignation,
    int? draftTargetDepartmentId,
    String? draftTargetDepartment,
    DateTime? createdAt,
    DateTime? updatedAt,
    SummaryStatus? summaryStatus,
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
      originatingDepartmentId:
          originatingDepartmentId ?? this.originatingDepartmentId,
      originatingDepartment:
          originatingDepartment ?? this.originatingDepartment,
      currentDepartmentId: currentDepartmentId ?? this.currentDepartmentId,
      currentDepartment: currentDepartment ?? this.currentDepartment,
      originatingUserDesgId:
          originatingUserDesgId ?? this.originatingUserDesgId,
      originatingUser: originatingUser ?? this.originatingUser,
      originatingDesignation:
          originatingDesignation ?? this.originatingDesignation,
      currentHolderUserDesgId:
          currentHolderUserDesgId ?? this.currentHolderUserDesgId,
      currentHolder: currentHolder ?? this.currentHolder,
      currentHolderDesignation:
          currentHolderDesignation ?? this.currentHolderDesignation,
      draftTargetDepartmentId:
          draftTargetDepartmentId ?? this.draftTargetDepartmentId,
      draftTargetDepartment:
          draftTargetDepartment ?? this.draftTargetDepartment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      summaryStatus: summaryStatus ?? this.summaryStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SummarySchema.id: id,
      SummarySchema.summaryNo: summaryNo,
      SummarySchema.subject: subject,
      SummarySchema.summaryDate: summaryDate?.toIso8601String(),
      SummarySchema.summaryType: summaryType,
      SummarySchema.body: body,
      SummarySchema.statusCode: statusCode,
      SummarySchema.statusLabel: statusLabel,
      SummarySchema.statusBadge: statusBadge,
      SummarySchema.originatingDepartmentId: originatingDepartmentId,
      SummarySchema.originatingDepartment: originatingDepartment,
      SummarySchema.currentDepartmentId: currentDepartmentId,
      SummarySchema.currentDepartment: currentDepartment,
      SummarySchema.originatingUserDesgId: originatingUserDesgId,
      SummarySchema.originatingUser: originatingUser,
      SummarySchema.originatingDesignation: originatingDesignation,
      SummarySchema.currentHolderUserDesgId: currentHolderUserDesgId,
      SummarySchema.currentHolder: currentHolder,
      SummarySchema.currentHolderDesignation: currentHolderDesignation,
      SummarySchema.draftTargetDepartmentId: draftTargetDepartmentId,
      SummarySchema.draftTargetDepartment: draftTargetDepartment,
      SummarySchema.createdAt: createdAt?.toIso8601String(),
      SummarySchema.updatedAt: updatedAt?.toIso8601String(),
    };
  }

  factory SummaryModel.fromJson(Map<String, dynamic> map) {
    return SummaryModel(
      id: map[SummarySchema.id]?.toInt(),
      summaryNo: map[SummarySchema.summaryNo],
      subject: map[SummarySchema.subject],
      summaryDate: map[SummarySchema.summaryDate] != null
          ? DateTime.tryParse(map[SummarySchema.summaryDate])
          : null,
      summaryType: map[SummarySchema.summaryType],
      body: map[SummarySchema.body],
      statusCode: map[SummarySchema.statusCode]?.toInt(),
      statusLabel: map[SummarySchema.statusLabel],
      statusBadge: HelperUtils.getTagColor(map[SummarySchema.statusBadge]),
      originatingDepartmentId: map[SummarySchema.originatingDepartmentId]
          ?.toInt(),
      originatingDepartment: map[SummarySchema.originatingDepartment],
      currentDepartmentId: map[SummarySchema.currentDepartmentId]?.toInt(),
      currentDepartment: map[SummarySchema.currentDepartment],
      originatingUserDesgId: map[SummarySchema.originatingUserDesgId]?.toInt(),
      originatingUser: map[SummarySchema.originatingUser],
      originatingDesignation: map[SummarySchema.originatingDesignation],
      currentHolderUserDesgId: map[SummarySchema.currentHolderUserDesgId]
          ?.toInt(),
      currentHolder: map[SummarySchema.currentHolder],
      currentHolderDesignation: map[SummarySchema.currentHolderDesignation],
      draftTargetDepartmentId: map[SummarySchema.draftTargetDepartmentId]
          ?.toInt(),
      draftTargetDepartment: map[SummarySchema.draftTargetDepartment],
      createdAt: map[SummarySchema.createdAt] != null
          ? DateTime.tryParse(map[SummarySchema.createdAt])
          : null,
      updatedAt: map[SummarySchema.updatedAt] != null
          ? DateTime.tryParse(map[SummarySchema.updatedAt])
          : null,
      summaryStatus: map[SummarySchema.statusCode] != null
          ? SummaryStatus.fromValue(map[SummarySchema.statusCode]?.toInt())
          : null,
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
        other.originatingDepartmentId == originatingDepartmentId &&
        other.originatingDepartment == originatingDepartment &&
        other.currentDepartmentId == currentDepartmentId &&
        other.currentDepartment == currentDepartment &&
        other.originatingUserDesgId == originatingUserDesgId &&
        other.originatingUser == originatingUser &&
        other.originatingDesignation == originatingDesignation &&
        other.currentHolderUserDesgId == currentHolderUserDesgId &&
        other.currentHolder == currentHolder &&
        other.currentHolderDesignation == currentHolderDesignation &&
        other.draftTargetDepartmentId == draftTargetDepartmentId &&
        other.draftTargetDepartment == draftTargetDepartment &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.summaryStatus == summaryStatus;
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
        originatingDepartmentId.hashCode ^
        originatingDepartment.hashCode ^
        currentDepartmentId.hashCode ^
        currentDepartment.hashCode ^
        originatingUserDesgId.hashCode ^
        originatingUser.hashCode ^
        originatingDesignation.hashCode ^
        currentHolderUserDesgId.hashCode ^
        currentHolder.hashCode ^
        currentHolderDesignation.hashCode ^
        draftTargetDepartmentId.hashCode ^
        draftTargetDepartment.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        summaryStatus.hashCode;
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
  static const String originatingDepartmentId = 'originating_department_id';
  static const String originatingDepartment = 'originating_department';
  static const String currentDepartmentId = 'current_department_id';
  static const String currentDepartment = 'current_department';
  static const String originatingUserDesgId = 'originating_user_desg_id';
  static const String originatingUser = 'originating_user';
  static const String originatingDesignation = 'originating_designation';
  static const String currentHolderUserDesgId = 'current_holder_user_desg_id';
  static const String currentHolder = 'current_holder';
  static const String currentHolderDesignation = 'current_holder_designation';
  static const String draftTargetDepartmentId = 'draft_target_department_id';
  static const String draftTargetDepartment = 'draft_target_department';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}
