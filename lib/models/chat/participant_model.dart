import 'package:cloud_firestore/cloud_firestore.dart';

class ChatParticipantModel {
  final int? userDesignationId;
  final int? userId;
  final String? userTitle;
  final String? designation;
  final DateTime? joinedAt;
  final bool removed;
  final DateTime? removedAt;

  ChatParticipantModel({
    this.userDesignationId,
    this.userId,
    this.userTitle,
    this.designation,
    this.joinedAt,
    this.removed = false,
    this.removedAt,
  });

  factory ChatParticipantModel.fromJson(Map<String, dynamic> json) {
    return ChatParticipantModel(
      userDesignationId: json['user_designation_id'] ?? 0,
      userId: json['user_id'] ?? '',
      userTitle: json['user_title'] ?? '',
      designation: json['designation'] ?? '',
      joinedAt: json['joined_at'] != null
          ? json['joined_at'] is Timestamp
              ? (json['joined_at'] as Timestamp).toDate()
              : DateTime.parse(json['joined_at'])
          : null,
      removed: json['removed'] ?? false,
      removedAt: json['removed_at'] != null
          ? json['removed_at'] is Timestamp
              ? (json['removed_at'] as Timestamp).toDate()
              : DateTime.parse(json['removed_at'])
          : null,
    );
  }

  factory ChatParticipantModel.fromParticipantEndpoint(
      Map<String, dynamic> json) {
    return ChatParticipantModel(
      userDesignationId: json['userDesgId'] ?? 0,
      userId: json['userId'] ?? '',
      userTitle: json['userTitle'] ?? json['userName'] ?? '',
      designation: json['userDesignationTitle'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_designation_id': userDesignationId,
      'user_id': userId,
      'user_title': userTitle,
      'designation': designation,
      'removed': removed ?? false,
      if (joinedAt != null) 'joined_at': Timestamp.fromDate(joinedAt!),
      if (removedAt != null) 'removed_at': Timestamp.fromDate(removedAt!),
    };
  }

  ChatParticipantModel copyWith({
    int? userDesignationId,
    int? userId,
    String? userTitle,
    String? designation,
    DateTime? joinedAt,
    bool? removed,
    DateTime? removedAt,
  }) {
    return ChatParticipantModel(
      userDesignationId: userDesignationId ?? this.userDesignationId,
      userId: userId ?? this.userId,
      userTitle: userTitle ?? this.userTitle,
      designation: designation ?? this.designation,
      joinedAt: joinedAt ?? this.joinedAt,
      removed: removed ?? this.removed,
      removedAt: removedAt ?? this.removedAt,
    );
  }
}
