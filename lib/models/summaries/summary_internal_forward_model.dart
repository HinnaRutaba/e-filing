import 'package:efiling_balochistan/models/summaries/summary_internal_forward_remark_model.dart';

enum RemarksStatus {
  pending(1, 'Pending'),
  submitted(2, 'Remarks Submitted');

  final int code;
  final String label;

  const RemarksStatus(this.code, this.label);

  static RemarksStatus? fromCode(int code) {
    return RemarksStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => RemarksStatus.pending,
    );
  }
}

class SummaryInternalForwardModel {
  final int? id;
  final int? forwardedByUserDesgId;
  final String? forwardedBy;
  final String? forwardedByDesignation;
  final int? forwardedToUserDesgId;
  final String? forwardedTo;
  final String? forwardedToDesignation;
  final String? instruction;
  final String? submittedRemarks;
  final int? status;
  final String? statusLabel;
  final DateTime? submittedAt;
  final DateTime? createdAt;
  final List<SummaryInternalForwardRemarkModel> remarks;
  final RemarksStatus? remarksStatus;

  SummaryInternalForwardModel({
    this.id,
    this.forwardedByUserDesgId,
    this.forwardedBy,
    this.forwardedByDesignation,
    this.forwardedToUserDesgId,
    this.forwardedTo,
    this.forwardedToDesignation,
    this.instruction,
    this.submittedRemarks,
    this.status,
    this.statusLabel,
    this.submittedAt,
    this.createdAt,
    this.remarks = const [],
    this.remarksStatus,
  });

  SummaryInternalForwardModel copyWith({
    int? id,
    int? forwardedByUserDesgId,
    String? forwardedBy,
    String? forwardedByDesignation,
    int? forwardedToUserDesgId,
    String? forwardedTo,
    String? forwardedToDesignation,
    String? instruction,
    String? submittedRemarks,
    int? status,
    String? statusLabel,
    DateTime? submittedAt,
    DateTime? createdAt,
    List<SummaryInternalForwardRemarkModel>? remarks,
    RemarksStatus? remarksStatus,
  }) {
    return SummaryInternalForwardModel(
      id: id ?? this.id,
      forwardedByUserDesgId:
          forwardedByUserDesgId ?? this.forwardedByUserDesgId,
      forwardedBy: forwardedBy ?? this.forwardedBy,
      forwardedByDesignation:
          forwardedByDesignation ?? this.forwardedByDesignation,
      forwardedToUserDesgId:
          forwardedToUserDesgId ?? this.forwardedToUserDesgId,
      forwardedTo: forwardedTo ?? this.forwardedTo,
      forwardedToDesignation:
          forwardedToDesignation ?? this.forwardedToDesignation,
      instruction: instruction ?? this.instruction,
      submittedRemarks: submittedRemarks ?? this.submittedRemarks,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      submittedAt: submittedAt ?? this.submittedAt,
      createdAt: createdAt ?? this.createdAt,
      remarks: remarks ?? this.remarks,
      remarksStatus: remarksStatus ?? this.remarksStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SummaryInternalForwardSchema.id: id,
      SummaryInternalForwardSchema.forwardedByUserDesgId: forwardedByUserDesgId,
      SummaryInternalForwardSchema.forwardedBy: forwardedBy,
      SummaryInternalForwardSchema.forwardedByDesignation:
          forwardedByDesignation,
      SummaryInternalForwardSchema.forwardedToUserDesgId: forwardedToUserDesgId,
      SummaryInternalForwardSchema.forwardedTo: forwardedTo,
      SummaryInternalForwardSchema.forwardedToDesignation:
          forwardedToDesignation,
      SummaryInternalForwardSchema.instruction: instruction,
      SummaryInternalForwardSchema.submittedRemarks: submittedRemarks,
      SummaryInternalForwardSchema.status: status,
      SummaryInternalForwardSchema.statusLabel: statusLabel,
      SummaryInternalForwardSchema.submittedAt: submittedAt?.toIso8601String(),
      SummaryInternalForwardSchema.createdAt: createdAt?.toIso8601String(),
      SummaryInternalForwardSchema.remarks: remarks,
    };
  }

  factory SummaryInternalForwardModel.fromJson(Map<String, dynamic> map) {
    return SummaryInternalForwardModel(
      id: map[SummaryInternalForwardSchema.id]?.toInt(),
      forwardedByUserDesgId:
          map[SummaryInternalForwardSchema.forwardedByUserDesgId]?.toInt(),
      forwardedBy: map[SummaryInternalForwardSchema.forwardedBy],
      forwardedByDesignation:
          map[SummaryInternalForwardSchema.forwardedByDesignation],
      forwardedToUserDesgId:
          map[SummaryInternalForwardSchema.forwardedToUserDesgId]?.toInt(),
      forwardedTo: map[SummaryInternalForwardSchema.forwardedTo],
      forwardedToDesignation:
          map[SummaryInternalForwardSchema.forwardedToDesignation],
      instruction: map[SummaryInternalForwardSchema.instruction],
      submittedRemarks: map[SummaryInternalForwardSchema.submittedRemarks],
      status: map[SummaryInternalForwardSchema.status]?.toInt(),
      statusLabel: map[SummaryInternalForwardSchema.statusLabel],
      submittedAt: map[SummaryInternalForwardSchema.submittedAt] != null
          ? DateTime.tryParse(map[SummaryInternalForwardSchema.submittedAt])
          : null,
      createdAt: map[SummaryInternalForwardSchema.createdAt] != null
          ? DateTime.tryParse(map[SummaryInternalForwardSchema.createdAt])
          : null,
      remarks: map[SummaryInternalForwardSchema.remarks] != null
          ? (map[SummaryInternalForwardSchema.remarks] as List)
                .map(
                  (e) => SummaryInternalForwardRemarkModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
      remarksStatus: map[SummaryInternalForwardSchema.status] != null
          ? RemarksStatus.fromCode(
              map[SummaryInternalForwardSchema.status]?.toInt(),
            )
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SummaryInternalForwardModel &&
        other.id == id &&
        other.forwardedByUserDesgId == forwardedByUserDesgId &&
        other.forwardedBy == forwardedBy &&
        other.forwardedByDesignation == forwardedByDesignation &&
        other.forwardedToUserDesgId == forwardedToUserDesgId &&
        other.forwardedTo == forwardedTo &&
        other.forwardedToDesignation == forwardedToDesignation &&
        other.instruction == instruction &&
        other.submittedRemarks == submittedRemarks &&
        other.status == status &&
        other.statusLabel == statusLabel &&
        other.submittedAt == submittedAt &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        forwardedByUserDesgId.hashCode ^
        forwardedBy.hashCode ^
        forwardedByDesignation.hashCode ^
        forwardedToUserDesgId.hashCode ^
        forwardedTo.hashCode ^
        forwardedToDesignation.hashCode ^
        instruction.hashCode ^
        submittedRemarks.hashCode ^
        status.hashCode ^
        statusLabel.hashCode ^
        submittedAt.hashCode ^
        createdAt.hashCode;
  }
}

class SummaryInternalForwardSchema {
  static const String id = 'id';
  static const String forwardedByUserDesgId = 'forwarded_by_user_desg_id';
  static const String forwardedBy = 'forwarded_by';
  static const String forwardedByDesignation = 'forwarded_by_designation';
  static const String forwardedToUserDesgId = 'forwarded_to_user_desg_id';
  static const String forwardedTo = 'forwarded_to';
  static const String forwardedToDesignation = 'forwarded_to_designation';
  static const String instruction = 'instruction';
  static const String submittedRemarks = 'submitted_remarks';
  static const String status = 'status';
  static const String statusLabel = 'status_label';
  static const String submittedAt = 'submitted_at';
  static const String createdAt = 'created_at';
  static const String remarks = 'remarks';
}
