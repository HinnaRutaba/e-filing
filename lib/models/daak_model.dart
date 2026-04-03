import 'package:efiling_balochistan/models/daak_meta_model.dart';
import 'package:flutter/material.dart';

class DaakModel {
  final int? id;
  final String? diaryNo;
  final String? letterNo;
  final DateTime? letterDate;
  final String? subject;
  final String? sourceDepartment;
  final DaakStatus? status;
  final int? statusCode;
  final String? statusLabel;
  final String? statusBadge;
  final String? currentHolder;
  final String? currentHolderDesignation;
  final String? currentHolderSection;
  final String? receivedBy;
  final DateTime? receivedAt;
  final String? incomingScanUrl;
  final int? convertedFileId;
  final LatestMovement? latestMovement;
  final DateTime? closedAt;
  final String? closureActionType;
  final String? closureRemarks;
  final List<dynamic>? issuedCorrespondence;
  final DaakForwardDetails? forwardDetails;
  final List<DaakAttachmentModel>? attachments;
  final List<DaakMovementModel>? movements;

  DaakModel({
    this.id,
    this.diaryNo,
    this.letterNo,
    this.letterDate,
    this.subject,
    this.sourceDepartment,
    this.status,
    this.statusCode,
    this.statusLabel,
    this.statusBadge,
    this.currentHolder,
    this.currentHolderDesignation,
    this.currentHolderSection,
    this.receivedBy,
    this.receivedAt,
    this.incomingScanUrl,
    this.convertedFileId,
    this.latestMovement,
    this.closedAt,
    this.closureActionType,
    this.closureRemarks,
    this.issuedCorrespondence,
    this.forwardDetails,
    this.attachments,
    this.movements,
  });

  factory DaakModel.fromJson(Map<String, dynamic> json) {
    return DaakModel(
      id: json['id'],
      diaryNo: json['diary_no'],
      letterNo: json['letter_no'],
      letterDate: json['letter_date'] != null
          ? DateTime.tryParse(json['letter_date'])
          : null,
      subject: json['subject'],
      sourceDepartment: json['source_department'],
      status: (json['status_code'] ?? json['current_status_code']) != null
          ? DaakStatus.fromValue(
              json['status_code'] ?? json['current_status_code'])
          : null,
      statusCode: json['status_code'] ?? json['current_status_code'],
      statusLabel: json['status_label'] ?? json['current_status_label'],
      statusBadge: json['status_badge'] ?? json['current_status_badge'],
      currentHolder: json['current_holder'],
      currentHolderDesignation: json['current_holder_designation'],
      currentHolderSection: json['current_holder_section'],
      receivedBy: json['received_by'],
      receivedAt: json['received_at'] != null
          ? DateTime.tryParse(json['received_at'])
          : null,
      incomingScanUrl: json['incoming_scan_url'],
      convertedFileId: json['converted_file_id'],
      latestMovement: json['latest_movement'] != null
          ? LatestMovement.fromJson(json['latest_movement'])
          : null,
      closedAt: json['closed_at'] != null && json['closed_at'] != ''
          ? DateTime.tryParse(json['closed_at'])
          : null,
      closureActionType: json['closure_action_type'],
      closureRemarks: json['closure_remarks'],
      issuedCorrespondence: json['issued_correspondence'],
    );
  }

  factory DaakModel.fromFwdJson(Map<String, dynamic> json) {
    DaakModel model = DaakModel.fromJson(json['letter']);
    model = model.copyWith(
      forwardDetails: DaakForwardDetails.fromJson(json),
    );
    return model;
  }

  factory DaakModel.fromDetails(Map<String, dynamic> json) {
    DaakModel model = DaakModel.fromJson(json['letter']);
    model = model.copyWith(
      attachments: (json['attachments'] as List?)
          ?.map((e) => DaakAttachmentModel.fromJson(e))
          .toList(),
      movements: (json['movements'] as List?)
          ?.map((e) => DaakMovementModel.fromJson(e))
          .toList(),
      forwardDetails: json['your_forward_record'] != null
          ? DaakForwardDetails(
              lastForward: DaakLastForward(
                movementId: json['your_forward_record']['movement_id'],
                forwardedAt: json['your_forward_record']['forwarded_at'] != null
                    ? DateTime.tryParse(
                        json['your_forward_record']['forwarded_at'])
                    : null,
                remarks: json['your_forward_record']['remarks'],
                forwardedTo: json['your_forward_record']['forwarded_to'],
              ),
            )
          : null,
    );
    return model;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'diary_no': diaryNo,
      'letter_no': letterNo,
      'letter_date': letterDate?.toIso8601String(),
      'subject': subject,
      'source_department': sourceDepartment,
      'status_code': statusCode,
      'status_label': statusLabel,
      'status_badge': statusBadge,
      'current_holder': currentHolder,
      'current_holder_designation': currentHolderDesignation,
      'current_holder_section': currentHolderSection,
      'received_by': receivedBy,
      'received_at': receivedAt?.toIso8601String(),
      'incoming_scan_url': incomingScanUrl,
      'converted_file_id': convertedFileId,
      'latest_movement': latestMovement?.toJson(),
      'closed_at': closedAt?.toIso8601String(),
      'closure_action_type': closureActionType,
      'closure_remarks': closureRemarks,
      'issued_correspondence': issuedCorrespondence,
    };
  }

  DaakModel copyWith({
    int? id,
    String? diaryNo,
    String? letterNo,
    DateTime? letterDate,
    String? subject,
    String? sourceDepartment,
    DaakStatus? status,
    int? statusCode,
    String? statusLabel,
    String? statusBadge,
    String? currentHolder,
    String? currentHolderDesignation,
    String? currentHolderSection,
    String? receivedBy,
    DateTime? receivedAt,
    String? incomingScanUrl,
    int? convertedFileId,
    LatestMovement? latestMovement,
    DateTime? closedAt,
    String? closureActionType,
    String? closureRemarks,
    List<dynamic>? issuedCorrespondence,
    DaakForwardDetails? forwardDetails,
    List<DaakAttachmentModel>? attachments,
    List<DaakMovementModel>? movements,
  }) {
    return DaakModel(
      id: id ?? this.id,
      diaryNo: diaryNo ?? this.diaryNo,
      letterNo: letterNo ?? this.letterNo,
      letterDate: letterDate ?? this.letterDate,
      subject: subject ?? this.subject,
      sourceDepartment: sourceDepartment ?? this.sourceDepartment,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      statusLabel: statusLabel ?? this.statusLabel,
      statusBadge: statusBadge ?? this.statusBadge,
      currentHolder: currentHolder ?? this.currentHolder,
      currentHolderDesignation:
          currentHolderDesignation ?? this.currentHolderDesignation,
      currentHolderSection: currentHolderSection ?? this.currentHolderSection,
      receivedBy: receivedBy ?? this.receivedBy,
      receivedAt: receivedAt ?? this.receivedAt,
      incomingScanUrl: incomingScanUrl ?? this.incomingScanUrl,
      convertedFileId: convertedFileId ?? this.convertedFileId,
      latestMovement: latestMovement ?? this.latestMovement,
      closedAt: closedAt ?? this.closedAt,
      closureActionType: closureActionType ?? this.closureActionType,
      closureRemarks: closureRemarks ?? this.closureRemarks,
      issuedCorrespondence: issuedCorrespondence ?? this.issuedCorrespondence,
      forwardDetails: forwardDetails ?? this.forwardDetails,
      attachments: attachments ?? this.attachments,
      movements: movements ?? this.movements,
    );
  }
}

class LatestMovement {
  final String? actionType;
  final String? remarks;
  final DateTime? actedAt;
  final String? actor;

  LatestMovement({
    this.actionType,
    this.remarks,
    this.actedAt,
    this.actor,
  });

  factory LatestMovement.fromJson(Map<String, dynamic> json) {
    return LatestMovement(
      actionType: json['action_type'],
      remarks: json['remarks'],
      actedAt:
          json['acted_at'] != null ? DateTime.tryParse(json['acted_at']) : null,
      actor: json['actor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action_type': actionType,
      'remarks': remarks,
      'acted_at': actedAt?.toIso8601String(),
      'actor': actor,
    };
  }
}

class DaakLastForward {
  final int? movementId;
  final DateTime? forwardedAt;
  final String? remarks;
  final String? forwardedTo;
  final String? forwardedToDesignation;

  DaakLastForward({
    this.movementId,
    this.forwardedAt,
    this.remarks,
    this.forwardedTo,
    this.forwardedToDesignation,
  });

  factory DaakLastForward.fromJson(Map<String, dynamic> json) {
    return DaakLastForward(
      movementId: json['movement_id'],
      forwardedAt: json['forwarded_at'] != null
          ? DateTime.tryParse(json['forwarded_at'])
          : null,
      remarks: json['remarks'] ?? json['your_remarks'],
      forwardedTo: json['forwarded_to'],
      forwardedToDesignation: json['forwarded_to_designation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movement_id': movementId,
      'forwarded_at': forwardedAt?.toIso8601String(),
      'remarks': remarks,
      'forwarded_to': forwardedTo,
      'forwarded_to_designation': forwardedToDesignation,
    };
  }
}

class DaakForwardDetails {
  final DateTime? latestForwardedAt;
  final int? yourForwardCount;
  final int? totalMovementCount;
  final DaakLastForward? lastForward;

  DaakForwardDetails({
    this.latestForwardedAt,
    this.yourForwardCount,
    this.totalMovementCount,
    this.lastForward,
  });

  factory DaakForwardDetails.fromJson(Map<String, dynamic> json) {
    return DaakForwardDetails(
      latestForwardedAt: json['latest_forwarded_at'] != null
          ? DateTime.tryParse(json['latest_forwarded_at'])
          : null,
      yourForwardCount: json['your_forward_count'],
      totalMovementCount: json['total_movement_count'],
      lastForward: json['last_forward'] != null
          ? DaakLastForward.fromJson(json['last_forward'])
          : null,
    );
  }

  factory DaakForwardDetails.fromDetailsJson(Map<String, dynamic> json) {
    return DaakForwardDetails(
      latestForwardedAt: json['latest_forwarded_at'] != null
          ? DateTime.tryParse(json['latest_forwarded_at'])
          : null,
      yourForwardCount: json['your_forward_count'],
      totalMovementCount: json['total_movement_count'],
      lastForward: json['last_forward'] != null
          ? DaakLastForward.fromJson(json['last_forward'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latest_forwarded_at': latestForwardedAt?.toIso8601String(),
      'your_forward_count': yourForwardCount,
      'total_movement_count': totalMovementCount,
      'last_forward': lastForward?.toJson(),
    };
  }
}

class DaakAttachmentModel {
  final int? id;
  final String? attachmentType;
  final String? originalName;
  final String? mimeType;
  final int? fileSize;
  final String? fileUrl;
  final DateTime? uploadedAt;

  DaakAttachmentModel({
    this.id,
    this.attachmentType,
    this.originalName,
    this.mimeType,
    this.fileSize,
    this.fileUrl,
    this.uploadedAt,
  });

  factory DaakAttachmentModel.fromJson(Map<String, dynamic> json) {
    return DaakAttachmentModel(
      id: json['id'],
      attachmentType: json['attachment_type'],
      originalName: json['original_name'],
      mimeType: json['mime_type'],
      fileSize: json['file_size'],
      fileUrl: json['file_url'],
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.tryParse(json['uploaded_at'])
          : null,
    );
  }

  String? get fileSizeText {
    if (fileSize == null) return null;
    const kb = 1024;
    const mb = kb * 1024;
    const gb = mb * 1024;
    if (fileSize! >= gb) {
      return '${(fileSize! / gb).toStringAsFixed(2)} GB';
    } else if (fileSize! >= mb) {
      return '${(fileSize! / mb).toStringAsFixed(2)} MB';
    } else if (fileSize! >= kb) {
      return '${(fileSize! / kb).toStringAsFixed(1)} KB';
    } else {
      return '$fileSize B';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attachment_type': attachmentType,
      'original_name': originalName,
      'mime_type': mimeType,
      'file_size': fileSize,
      'file_url': fileUrl,
      'uploaded_at': uploadedAt?.toIso8601String(),
    };
  }
}

enum MovementactionType {
  forwarded('forwarded', Colors.orange),
  returned('received', Colors.green);

  final String value;
  final Color color;

  const MovementactionType(this.value, this.color);

  static MovementactionType fromValue(String? value) {
    return MovementactionType.values.firstWhere((e) => e.value == value,
        orElse: () => MovementactionType.forwarded);
  }
}

class DaakMovementModel {
  final int? id;
  final MovementactionType? actionType;
  final String? remarks;
  final DaakStatus? statusAfter;
  final String? fromUser;
  final String? toUser;
  final String? actor;
  final DateTime? actedAt;

  DaakMovementModel({
    this.id,
    this.actionType,
    this.remarks,
    this.statusAfter,
    this.fromUser,
    this.toUser,
    this.actor,
    this.actedAt,
  });

  factory DaakMovementModel.fromJson(Map<String, dynamic> json) {
    return DaakMovementModel(
      id: json['id'],
      actionType: json['action_type'] != null
          ? MovementactionType.fromValue(json['action_type'])
          : null,
      remarks: json['remarks'],
      statusAfter: json['status_after'] != null
          ? DaakStatus.fromValue(json['status_after'])
          : null,
      fromUser: json['from_user'],
      toUser: json['to_user'],
      actor: json['actor'],
      actedAt:
          json['acted_at'] != null ? DateTime.tryParse(json['acted_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action_type': actionType?.value,
      'remarks': remarks,
      'status_after': statusAfter?.value,
      'from_user': fromUser,
      'to_user': toUser,
      'actor': actor,
      'acted_at': actedAt?.toIso8601String(),
    };
  }
}
