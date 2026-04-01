import 'package:efiling_balochistan/models/daak_meta_model.dart';


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
  });

  factory DaakModel.fromJson(Map<String, dynamic> json) {
    return DaakModel(
      id: json['id'],
      diaryNo: json['diary_no'],
      letterNo: json['letter_no'],
      letterDate: json['letter_date'] != null ? DateTime.tryParse(json['letter_date']) : null,
      subject: json['subject'],
      sourceDepartment: json['source_department'],
      status: json['status_code'] != null ? DaakStatus.fromValue(json['status_code']) : null,
      statusCode: json['status_code'],
      statusLabel: json['status_label'],
      statusBadge: json['status_badge'],
      currentHolder: json['current_holder'],
      currentHolderDesignation: json['current_holder_designation'],
      currentHolderSection: json['current_holder_section'],
      receivedBy: json['received_by'],
      receivedAt: json['received_at'] != null ? DateTime.tryParse(json['received_at']) : null,
      incomingScanUrl: json['incoming_scan_url'],
      convertedFileId: json['converted_file_id'],
      latestMovement: json['latest_movement'] != null ? LatestMovement.fromJson(json['latest_movement']) : null,
      closedAt: json['closed_at'] != null && json['closed_at'] != '' ? DateTime.tryParse(json['closed_at']) : null,
      closureActionType: json['closure_action_type'],
      closureRemarks: json['closure_remarks'],
      issuedCorrespondence: json['issued_correspondence'],
    );
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
      actedAt: json['acted_at'] != null ? DateTime.tryParse(json['acted_at']) : null,
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
