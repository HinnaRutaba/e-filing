class SummaryMovementModel {
  final int? id;
  final String? actionType;
  final String? remarks;
  final String? briefNote;
  final String? fromDepartment;
  final String? toDepartment;
  final String? fromUser;
  final String? toUser;
  final String? toUserDesignation;
  final String? actor;
  final String? actorDesignation;
  final String? signatureUrl;
  final String? handwrittenPngUrl;
  final double? handwrittenWidth;
  final double? handwrittenHeight;
  final String? handwrittenPenColor;
  final DateTime? actedAt;

  SummaryMovementModel({
    this.id,
    this.actionType,
    this.remarks,
    this.briefNote,
    this.fromDepartment,
    this.toDepartment,
    this.fromUser,
    this.toUser,
    this.toUserDesignation,
    this.actor,
    this.actorDesignation,
    this.signatureUrl,
    this.handwrittenPngUrl,
    this.handwrittenWidth,
    this.handwrittenHeight,
    this.handwrittenPenColor,
    this.actedAt,
  });

  SummaryMovementModel copyWith({
    int? id,
    String? actionType,
    String? remarks,
    String? briefNote,
    String? fromDepartment,
    String? toDepartment,
    String? fromUser,
    String? toUser,
    String? toUserDesignation,
    String? actor,
    String? actorDesignation,
    String? signatureUrl,
    String? handwrittenPngUrl,
    double? handwrittenWidth,
    double? handwrittenHeight,
    String? handwrittenPenColor,
    DateTime? actedAt,
  }) {
    return SummaryMovementModel(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      remarks: remarks ?? this.remarks,
      briefNote: briefNote ?? this.briefNote,
      fromDepartment: fromDepartment ?? this.fromDepartment,
      toDepartment: toDepartment ?? this.toDepartment,
      fromUser: fromUser ?? this.fromUser,
      toUser: toUser ?? this.toUser,
      toUserDesignation: toUserDesignation ?? this.toUserDesignation,
      actor: actor ?? this.actor,
      actorDesignation: actorDesignation ?? this.actorDesignation,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      handwrittenPngUrl: handwrittenPngUrl ?? this.handwrittenPngUrl,
      handwrittenWidth: handwrittenWidth ?? this.handwrittenWidth,
      handwrittenHeight: handwrittenHeight ?? this.handwrittenHeight,
      handwrittenPenColor: handwrittenPenColor ?? this.handwrittenPenColor,
      actedAt: actedAt ?? this.actedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SummaryMovementSchema.id: id,
      SummaryMovementSchema.actionType: actionType,
      SummaryMovementSchema.remarks: remarks,
      SummaryMovementSchema.briefNote: briefNote,
      SummaryMovementSchema.fromDepartment: fromDepartment,
      SummaryMovementSchema.toDepartment: toDepartment,
      SummaryMovementSchema.fromUser: fromUser,
      SummaryMovementSchema.toUser: toUser,
      SummaryMovementSchema.toUserDesignation: toUserDesignation,
      SummaryMovementSchema.actor: actor,
      SummaryMovementSchema.actorDesignation: actorDesignation,
      SummaryMovementSchema.signatureUrl: signatureUrl,
      SummaryMovementSchema.handwrittenPngUrl: handwrittenPngUrl,
      SummaryMovementSchema.handwrittenWidth: handwrittenWidth,
      SummaryMovementSchema.handwrittenHeight: handwrittenHeight,
      SummaryMovementSchema.handwrittenPenColor: handwrittenPenColor,
      SummaryMovementSchema.actedAt: actedAt?.toIso8601String(),
    };
  }

  factory SummaryMovementModel.fromJson(Map<String, dynamic> map) {
    return SummaryMovementModel(
      id: map[SummaryMovementSchema.id]?.toInt(),
      actionType: map[SummaryMovementSchema.actionType],
      remarks: map[SummaryMovementSchema.remarks],
      briefNote: map[SummaryMovementSchema.briefNote],
      fromDepartment: map[SummaryMovementSchema.fromDepartment],
      toDepartment: map[SummaryMovementSchema.toDepartment],
      fromUser: map[SummaryMovementSchema.fromUser],
      toUser: map[SummaryMovementSchema.toUser],
      toUserDesignation: map[SummaryMovementSchema.toUserDesignation],
      actor: map[SummaryMovementSchema.actor],
      actorDesignation: map[SummaryMovementSchema.actorDesignation],
      signatureUrl: map[SummaryMovementSchema.signatureUrl],
      handwrittenPngUrl: map[SummaryMovementSchema.handwrittenPngUrl],
      handwrittenWidth: map[SummaryMovementSchema.handwrittenWidth]?.toDouble(),
      handwrittenHeight:
          map[SummaryMovementSchema.handwrittenHeight]?.toDouble(),
      handwrittenPenColor: map[SummaryMovementSchema.handwrittenPenColor],
      actedAt: map[SummaryMovementSchema.actedAt] != null
          ? DateTime.tryParse(map[SummaryMovementSchema.actedAt])
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SummaryMovementModel &&
        other.id == id &&
        other.actionType == actionType &&
        other.remarks == remarks &&
        other.briefNote == briefNote &&
        other.fromDepartment == fromDepartment &&
        other.toDepartment == toDepartment &&
        other.fromUser == fromUser &&
        other.toUser == toUser &&
        other.toUserDesignation == toUserDesignation &&
        other.actor == actor &&
        other.actorDesignation == actorDesignation &&
        other.signatureUrl == signatureUrl &&
        other.handwrittenPngUrl == handwrittenPngUrl &&
        other.handwrittenWidth == handwrittenWidth &&
        other.handwrittenHeight == handwrittenHeight &&
        other.handwrittenPenColor == handwrittenPenColor &&
        other.actedAt == actedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        actionType.hashCode ^
        remarks.hashCode ^
        briefNote.hashCode ^
        fromDepartment.hashCode ^
        toDepartment.hashCode ^
        fromUser.hashCode ^
        toUser.hashCode ^
        toUserDesignation.hashCode ^
        actor.hashCode ^
        actorDesignation.hashCode ^
        signatureUrl.hashCode ^
        handwrittenPngUrl.hashCode ^
        handwrittenWidth.hashCode ^
        handwrittenHeight.hashCode ^
        handwrittenPenColor.hashCode ^
        actedAt.hashCode;
  }
}

class SummaryMovementSchema {
  static const String id = 'id';
  static const String actionType = 'action_type';
  static const String remarks = 'remarks';
  static const String briefNote = 'brief_note';
  static const String fromDepartment = 'from_department';
  static const String toDepartment = 'to_department';
  static const String fromUser = 'from_user';
  static const String toUser = 'to_user';
  static const String toUserDesignation = 'to_user_designation';
  static const String actor = 'actor';
  static const String actorDesignation = 'actor_designation';
  static const String signatureUrl = 'signature_url';
  static const String handwrittenPngUrl = 'handwritten_png_url';
  static const String handwrittenWidth = 'handwritten_width';
  static const String handwrittenHeight = 'handwritten_height';
  static const String handwrittenPenColor = 'handwritten_pen_color';
  static const String actedAt = 'acted_at';
}
