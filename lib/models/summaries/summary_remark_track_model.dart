import 'package:efiling_balochistan/models/summaries/summary_movement_model.dart';
import 'package:flutter/material.dart';

class SummaryRemarkTrackModel {
  final int? movementId;
  final String? actionType;
  final String? actionLabel;
  final int? actorUserDesgId;
  final String? actorName;
  final String? actorDesignation;
  final int? fromDepartmentId;
  final String? fromDepartment;
  final int? toDepartmentId;
  final String? toDepartment;
  final int? toUserDesgId;
  final String? toUserName;
  final String? toUserDesignation;
  final String? effectiveToUser;
  final String? effectiveToDesignation;
  final String? effectiveToDepartment;
  final String? remarks;
  final String? briefNote;
  final String? signatureUrl;
  final bool? hasHandwritten;
  final String? handwrittenPngUrl;
  final String? handwrittenPngApiUrl;
  final String? handwrittenStrokesUrl;
  final HandwrittenStrokes? handwrittenStrokes;
  final double? handwrittenWidth;
  final double? handwrittenHeight;
  final Color? handwrittenPenColor;
  final DateTime? actedAt;
  final String? actedAtDisplay;

  static Color? _parseHexColor(String? hex) {
    if (hex == null) return null;
    var value = hex.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('#')) value = value.substring(1);
    if (value.length == 6) value = 'FF$value';
    if (value.length != 8) return null;
    final parsed = int.tryParse(value, radix: 16);
    return parsed == null ? null : Color(parsed);
  }

  static String? _colorToHex(Color? color) {
    if (color == null) return null;
    final argb = color.toARGB32();
    return '#${argb.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  SummaryRemarkTrackModel({
    this.movementId,
    this.actionType,
    this.actionLabel,
    this.actorUserDesgId,
    this.actorName,
    this.actorDesignation,
    this.fromDepartmentId,
    this.fromDepartment,
    this.toDepartmentId,
    this.toDepartment,
    this.toUserDesgId,
    this.toUserName,
    this.toUserDesignation,
    this.effectiveToUser,
    this.effectiveToDesignation,
    this.effectiveToDepartment,
    this.remarks,
    this.briefNote,
    this.signatureUrl,
    this.hasHandwritten,
    this.handwrittenPngUrl,
    this.handwrittenPngApiUrl,
    this.handwrittenStrokesUrl,
    this.handwrittenStrokes,
    this.handwrittenWidth,
    this.handwrittenHeight,
    this.handwrittenPenColor,
    this.actedAt,
    this.actedAtDisplay,
  });

  SummaryRemarkTrackModel copyWith({
    int? movementId,
    String? actionType,
    String? actionLabel,
    int? actorUserDesgId,
    String? actorName,
    String? actorDesignation,
    int? fromDepartmentId,
    String? fromDepartment,
    int? toDepartmentId,
    String? toDepartment,
    int? toUserDesgId,
    String? toUserName,
    String? toUserDesignation,
    String? effectiveToUser,
    String? effectiveToDesignation,
    String? effectiveToDepartment,
    String? remarks,
    String? briefNote,
    String? signatureUrl,
    bool? hasHandwritten,
    String? handwrittenPngUrl,
    String? handwrittenPngApiUrl,
    String? handwrittenStrokesUrl,
    HandwrittenStrokes? handwrittenStrokes,
    double? handwrittenWidth,
    double? handwrittenHeight,
    Color? handwrittenPenColor,
    DateTime? actedAt,
    String? actedAtDisplay,
  }) {
    return SummaryRemarkTrackModel(
      movementId: movementId ?? this.movementId,
      actionType: actionType ?? this.actionType,
      actionLabel: actionLabel ?? this.actionLabel,
      actorUserDesgId: actorUserDesgId ?? this.actorUserDesgId,
      actorName: actorName ?? this.actorName,
      actorDesignation: actorDesignation ?? this.actorDesignation,
      fromDepartmentId: fromDepartmentId ?? this.fromDepartmentId,
      fromDepartment: fromDepartment ?? this.fromDepartment,
      toDepartmentId: toDepartmentId ?? this.toDepartmentId,
      toDepartment: toDepartment ?? this.toDepartment,
      toUserDesgId: toUserDesgId ?? this.toUserDesgId,
      toUserName: toUserName ?? this.toUserName,
      toUserDesignation: toUserDesignation ?? this.toUserDesignation,
      effectiveToUser: effectiveToUser ?? this.effectiveToUser,
      effectiveToDesignation:
          effectiveToDesignation ?? this.effectiveToDesignation,
      effectiveToDepartment:
          effectiveToDepartment ?? this.effectiveToDepartment,
      remarks: remarks ?? this.remarks,
      briefNote: briefNote ?? this.briefNote,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      hasHandwritten: hasHandwritten ?? this.hasHandwritten,
      handwrittenPngUrl: handwrittenPngUrl ?? this.handwrittenPngUrl,
      handwrittenPngApiUrl: handwrittenPngApiUrl ?? this.handwrittenPngApiUrl,
      handwrittenStrokesUrl:
          handwrittenStrokesUrl ?? this.handwrittenStrokesUrl,
      handwrittenStrokes: handwrittenStrokes ?? this.handwrittenStrokes,
      handwrittenWidth: handwrittenWidth ?? this.handwrittenWidth,
      handwrittenHeight: handwrittenHeight ?? this.handwrittenHeight,
      handwrittenPenColor: handwrittenPenColor ?? this.handwrittenPenColor,
      actedAt: actedAt ?? this.actedAt,
      actedAtDisplay: actedAtDisplay ?? this.actedAtDisplay,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SummaryRemarkTrackSchema.movementId: movementId,
      SummaryRemarkTrackSchema.actionType: actionType,
      SummaryRemarkTrackSchema.actionLabel: actionLabel,
      SummaryRemarkTrackSchema.actorUserDesgId: actorUserDesgId,
      SummaryRemarkTrackSchema.actorName: actorName,
      SummaryRemarkTrackSchema.actorDesignation: actorDesignation,
      SummaryRemarkTrackSchema.fromDepartmentId: fromDepartmentId,
      SummaryRemarkTrackSchema.fromDepartment: fromDepartment,
      SummaryRemarkTrackSchema.toDepartmentId: toDepartmentId,
      SummaryRemarkTrackSchema.toDepartment: toDepartment,
      SummaryRemarkTrackSchema.toUserDesgId: toUserDesgId,
      SummaryRemarkTrackSchema.toUserName: toUserName,
      SummaryRemarkTrackSchema.toUserDesignation: toUserDesignation,
      SummaryRemarkTrackSchema.effectiveToUser: effectiveToUser,
      SummaryRemarkTrackSchema.effectiveToDesignation: effectiveToDesignation,
      SummaryRemarkTrackSchema.effectiveToDepartment: effectiveToDepartment,
      SummaryRemarkTrackSchema.remarks: remarks,
      SummaryRemarkTrackSchema.briefNote: briefNote,
      SummaryRemarkTrackSchema.signatureUrl: signatureUrl,
      SummaryRemarkTrackSchema.hasHandwritten: hasHandwritten,
      SummaryRemarkTrackSchema.handwrittenPngUrl: handwrittenPngUrl,
      SummaryRemarkTrackSchema.handwrittenPngApiUrl: handwrittenPngApiUrl,
      SummaryRemarkTrackSchema.handwrittenStrokesUrl: handwrittenStrokesUrl,
      SummaryRemarkTrackSchema.handwrittenStrokes: handwrittenStrokes?.toJson(),
      SummaryRemarkTrackSchema.handwrittenWidth: handwrittenWidth,
      SummaryRemarkTrackSchema.handwrittenHeight: handwrittenHeight,
      SummaryRemarkTrackSchema.handwrittenPenColor: _colorToHex(
        handwrittenPenColor,
      ),
      SummaryRemarkTrackSchema.actedAt: actedAt?.toIso8601String(),
      SummaryRemarkTrackSchema.actedAtDisplay: actedAtDisplay,
    };
  }

  factory SummaryRemarkTrackModel.fromJson(Map<String, dynamic> map) {
    return SummaryRemarkTrackModel(
      movementId: map[SummaryRemarkTrackSchema.movementId]?.toInt(),
      actionType: map[SummaryRemarkTrackSchema.actionType],
      actionLabel: map[SummaryRemarkTrackSchema.actionLabel],
      actorUserDesgId: map[SummaryRemarkTrackSchema.actorUserDesgId]?.toInt(),
      actorName: map[SummaryRemarkTrackSchema.actorName],
      actorDesignation: map[SummaryRemarkTrackSchema.actorDesignation],
      fromDepartmentId: map[SummaryRemarkTrackSchema.fromDepartmentId]?.toInt(),
      fromDepartment: map[SummaryRemarkTrackSchema.fromDepartment],
      toDepartmentId: map[SummaryRemarkTrackSchema.toDepartmentId]?.toInt(),
      toDepartment: map[SummaryRemarkTrackSchema.toDepartment],
      toUserDesgId: map[SummaryRemarkTrackSchema.toUserDesgId]?.toInt(),
      toUserName: map[SummaryRemarkTrackSchema.toUserName],
      toUserDesignation: map[SummaryRemarkTrackSchema.toUserDesignation],
      effectiveToUser: map[SummaryRemarkTrackSchema.effectiveToUser],
      effectiveToDesignation:
          map[SummaryRemarkTrackSchema.effectiveToDesignation],
      effectiveToDepartment:
          map[SummaryRemarkTrackSchema.effectiveToDepartment],
      remarks: map[SummaryRemarkTrackSchema.remarks],
      briefNote: map[SummaryRemarkTrackSchema.briefNote],
      signatureUrl: map[SummaryRemarkTrackSchema.signatureUrl],
      hasHandwritten: map[SummaryRemarkTrackSchema.hasHandwritten],
      handwrittenPngUrl: map[SummaryRemarkTrackSchema.handwrittenPngUrl],
      handwrittenPngApiUrl: map[SummaryRemarkTrackSchema.handwrittenPngApiUrl],
      handwrittenStrokesUrl:
          map[SummaryRemarkTrackSchema.handwrittenStrokesUrl],
      handwrittenStrokes:
          map[SummaryRemarkTrackSchema.handwrittenStrokes] != null
          ? HandwrittenStrokes.fromJson(
              Map<String, dynamic>.from(
                map[SummaryRemarkTrackSchema.handwrittenStrokes],
              ),
            )
          : null,
      handwrittenWidth: (map[SummaryRemarkTrackSchema.handwrittenWidth] as num?)
          ?.toDouble(),
      handwrittenHeight:
          (map[SummaryRemarkTrackSchema.handwrittenHeight] as num?)?.toDouble(),
      handwrittenPenColor: _parseHexColor(
        map[SummaryRemarkTrackSchema.handwrittenPenColor],
      ),
      actedAt: map[SummaryRemarkTrackSchema.actedAt] != null
          ? DateTime.tryParse(map[SummaryRemarkTrackSchema.actedAt])
          : null,
      actedAtDisplay: map[SummaryRemarkTrackSchema.actedAtDisplay],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SummaryRemarkTrackModel &&
        other.movementId == movementId &&
        other.actionType == actionType &&
        other.actionLabel == actionLabel &&
        other.actorUserDesgId == actorUserDesgId &&
        other.actorName == actorName &&
        other.actorDesignation == actorDesignation &&
        other.fromDepartmentId == fromDepartmentId &&
        other.fromDepartment == fromDepartment &&
        other.toDepartmentId == toDepartmentId &&
        other.toDepartment == toDepartment &&
        other.toUserDesgId == toUserDesgId &&
        other.toUserName == toUserName &&
        other.toUserDesignation == toUserDesignation &&
        other.effectiveToUser == effectiveToUser &&
        other.effectiveToDesignation == effectiveToDesignation &&
        other.effectiveToDepartment == effectiveToDepartment &&
        other.remarks == remarks &&
        other.briefNote == briefNote &&
        other.signatureUrl == signatureUrl &&
        other.hasHandwritten == hasHandwritten &&
        other.handwrittenPngUrl == handwrittenPngUrl &&
        other.handwrittenPngApiUrl == handwrittenPngApiUrl &&
        other.handwrittenStrokesUrl == handwrittenStrokesUrl &&
        other.handwrittenStrokes == handwrittenStrokes &&
        other.handwrittenWidth == handwrittenWidth &&
        other.handwrittenHeight == handwrittenHeight &&
        other.handwrittenPenColor == handwrittenPenColor &&
        other.actedAt == actedAt &&
        other.actedAtDisplay == actedAtDisplay;
  }

  @override
  int get hashCode {
    return movementId.hashCode ^
        actionType.hashCode ^
        actionLabel.hashCode ^
        actorUserDesgId.hashCode ^
        actorName.hashCode ^
        actorDesignation.hashCode ^
        fromDepartmentId.hashCode ^
        fromDepartment.hashCode ^
        toDepartmentId.hashCode ^
        toDepartment.hashCode ^
        toUserDesgId.hashCode ^
        toUserName.hashCode ^
        toUserDesignation.hashCode ^
        effectiveToUser.hashCode ^
        effectiveToDesignation.hashCode ^
        effectiveToDepartment.hashCode ^
        remarks.hashCode ^
        briefNote.hashCode ^
        signatureUrl.hashCode ^
        hasHandwritten.hashCode ^
        handwrittenPngUrl.hashCode ^
        handwrittenPngApiUrl.hashCode ^
        handwrittenStrokesUrl.hashCode ^
        handwrittenStrokes.hashCode ^
        handwrittenWidth.hashCode ^
        handwrittenHeight.hashCode ^
        handwrittenPenColor.hashCode ^
        actedAt.hashCode ^
        actedAtDisplay.hashCode;
  }
}

class SummaryRemarkTrackSchema {
  static const String movementId = 'movement_id';
  static const String actionType = 'action_type';
  static const String actionLabel = 'action_label';
  static const String actorUserDesgId = 'actor_user_desg_id';
  static const String actorName = 'actor_name';
  static const String actorDesignation = 'actor_designation';
  static const String fromDepartmentId = 'from_department_id';
  static const String fromDepartment = 'from_department';
  static const String toDepartmentId = 'to_department_id';
  static const String toDepartment = 'to_department';
  static const String toUserDesgId = 'to_user_desg_id';
  static const String toUserName = 'to_user_name';
  static const String toUserDesignation = 'to_user_designation';
  static const String effectiveToUser = 'effective_to_user';
  static const String effectiveToDesignation = 'effective_to_designation';
  static const String effectiveToDepartment = 'effective_to_department';
  static const String remarks = 'remarks';
  static const String briefNote = 'brief_note';
  static const String signatureUrl = 'signature_url';
  static const String hasHandwritten = 'has_handwritten';
  static const String handwrittenPngUrl = 'handwritten_png_url';
  static const String handwrittenPngApiUrl = 'handwritten_png_api_url';
  static const String handwrittenStrokesUrl = 'handwritten_strokes_url';
  static const String handwrittenStrokes = 'handwritten_strokes';
  static const String handwrittenWidth = 'handwritten_width';
  static const String handwrittenHeight = 'handwritten_height';
  static const String handwrittenPenColor = 'handwritten_pen_color';
  static const String actedAt = 'acted_at';
  static const String actedAtDisplay = 'acted_at_display';
}
