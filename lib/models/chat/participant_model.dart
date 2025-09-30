class ParticipantModel {
  final int? userDesignationId;
  final int? userId;
  final String? userTitle;
  final String? designation;
  final DateTime? joinedAt;
  final bool removed;
  final DateTime? removedAt;

  ParticipantModel({
    this.userDesignationId,
    this.userId,
    this.userTitle,
    this.designation,
    this.joinedAt,
    this.removed = false,
    this.removedAt,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      userDesignationId: json['user_designation_id'] ?? 0,
      userId: json['user_id'] ?? '',
      userTitle: json['user_title'] ?? '',
      designation: json['designation'] ?? '',
      joinedAt:
          json['joined_at'] != null ? DateTime.parse(json['joined_at']) : null,
      removed: json['removed'] ?? false,
      removedAt: json['removed_at'] != null
          ? DateTime.parse(json['removed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_designation_id': userDesignationId,
      'user_id': userId,
      'user_title': userTitle,
      'designation': designation,
      'removed': removed ?? false,
      if (joinedAt != null) 'joined_at': joinedAt!.toIso8601String(),
      if (removedAt != null) 'removed_at': removedAt!.toIso8601String(),
    };
  }

  ParticipantModel copyWith({
    int? userDesignationId,
    int? userId,
    String? userTitle,
    String? designation,
    DateTime? joinedAt,
    bool? removed,
    DateTime? removedAt,
  }) {
    return ParticipantModel(
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
