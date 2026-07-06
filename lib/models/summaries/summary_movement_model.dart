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
  final bool? hasHandwritten;
  final String? handwrittenPngUrl;
  final String? handwrittenPngApiUrl;
  final String? handwrittenStrokesUrl;
  final HandwrittenStrokes? handwrittenStrokes;
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
    this.hasHandwritten,
    this.handwrittenPngUrl,
    this.handwrittenPngApiUrl,
    this.handwrittenStrokesUrl,
    this.handwrittenStrokes,
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
    bool? hasHandwritten,
    String? handwrittenPngUrl,
    String? handwrittenPngApiUrl,
    String? handwrittenStrokesUrl,
    HandwrittenStrokes? handwrittenStrokes,
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
      SummaryMovementSchema.hasHandwritten: hasHandwritten,
      SummaryMovementSchema.handwrittenPngUrl: handwrittenPngUrl,
      SummaryMovementSchema.handwrittenPngApiUrl: handwrittenPngApiUrl,
      SummaryMovementSchema.handwrittenStrokesUrl: handwrittenStrokesUrl,
      SummaryMovementSchema.handwrittenStrokes: handwrittenStrokes?.toJson(),
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
      hasHandwritten: map[SummaryMovementSchema.hasHandwritten],
      handwrittenPngUrl: map[SummaryMovementSchema.handwrittenPngUrl],
      handwrittenPngApiUrl: map[SummaryMovementSchema.handwrittenPngApiUrl],
      handwrittenStrokesUrl: map[SummaryMovementSchema.handwrittenStrokesUrl],
      handwrittenStrokes: map[SummaryMovementSchema.handwrittenStrokes] != null
          ? HandwrittenStrokes.fromJson(
              Map<String, dynamic>.from(
                map[SummaryMovementSchema.handwrittenStrokes],
              ),
            )
          : null,
      handwrittenWidth: map[SummaryMovementSchema.handwrittenWidth]?.toDouble(),
      handwrittenHeight: map[SummaryMovementSchema.handwrittenHeight]
          ?.toDouble(),
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
        other.hasHandwritten == hasHandwritten &&
        other.handwrittenPngUrl == handwrittenPngUrl &&
        other.handwrittenPngApiUrl == handwrittenPngApiUrl &&
        other.handwrittenStrokesUrl == handwrittenStrokesUrl &&
        other.handwrittenStrokes == handwrittenStrokes &&
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
        hasHandwritten.hashCode ^
        handwrittenPngUrl.hashCode ^
        handwrittenPngApiUrl.hashCode ^
        handwrittenStrokesUrl.hashCode ^
        handwrittenStrokes.hashCode ^
        handwrittenWidth.hashCode ^
        handwrittenHeight.hashCode ^
        handwrittenPenColor.hashCode ^
        actedAt.hashCode;
  }
}

class HandwrittenStrokes {
  final double? w;
  final double? h;
  final List<HandwrittenStroke> strokes;

  HandwrittenStrokes({this.w, this.h, this.strokes = const []});

  HandwrittenStrokes copyWith({
    double? w,
    double? h,
    List<HandwrittenStroke>? strokes,
  }) {
    return HandwrittenStrokes(
      w: w ?? this.w,
      h: h ?? this.h,
      strokes: strokes ?? this.strokes,
    );
  }

  String toSvg({String? fallbackColor}) {
    final viewW = w ?? 1200;
    final viewH = h ?? 200;
    final buffer = StringBuffer()
      ..write(
        '<svg xmlns="http://www.w3.org/2000/svg" '
        'viewBox="0 0 $viewW $viewH" '
        'preserveAspectRatio="xMidYMid meet">',
      );
    for (final stroke in strokes) {
      final path = stroke.toSvgPath();
      if (path.isEmpty) continue;
      final color = stroke.color ?? fallbackColor ?? '#000000';
      final width = stroke.averageWidth ?? 2.5;
      buffer.write(
        '<path d="$path" fill="none" '
        'stroke="$color" stroke-width="$width" '
        'stroke-linecap="round" stroke-linejoin="round" />',
      );
    }
    buffer.write('</svg>');
    return buffer.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      HandwrittenStrokesSchema.w: w,
      HandwrittenStrokesSchema.h: h,
      HandwrittenStrokesSchema.strokes: strokes.map((e) => e.toJson()).toList(),
    };
  }

  factory HandwrittenStrokes.fromJson(Map<String, dynamic> map) {
    return HandwrittenStrokes(
      w: (map[HandwrittenStrokesSchema.w] as num?)?.toDouble(),
      h: (map[HandwrittenStrokesSchema.h] as num?)?.toDouble(),
      strokes: map[HandwrittenStrokesSchema.strokes] != null
          ? (map[HandwrittenStrokesSchema.strokes] as List)
                .map(
                  (e) =>
                      HandwrittenStroke.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
    );
  }
}

class HandwrittenStroke {
  final String? color;
  final List<double> widthRange;
  final List<StrokePoint> points;

  HandwrittenStroke({
    this.color,
    this.widthRange = const [],
    this.points = const [],
  });

  HandwrittenStroke copyWith({
    String? color,
    List<double>? widthRange,
    List<StrokePoint>? points,
  }) {
    return HandwrittenStroke(
      color: color ?? this.color,
      widthRange: widthRange ?? this.widthRange,
      points: points ?? this.points,
    );
  }

  double? get averageWidth {
    if (widthRange.isEmpty) return null;
    final sum = widthRange.fold<double>(0, (a, b) => a + b);
    return sum / widthRange.length;
  }

  String toSvgPath() {
    if (points.isEmpty) return '';
    final buffer = StringBuffer();
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      final x = p.x ?? 0;
      final y = p.y ?? 0;
      final prefix = i == 0 ? 'M' : 'L';
      buffer.write('$prefix${_fmt(x)} ${_fmt(y)} ');
    }
    return buffer.toString().trimRight();
  }

  static String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }

  Map<String, dynamic> toJson() {
    return {
      HandwrittenStrokeSchema.color: color,
      HandwrittenStrokeSchema.widthRange: widthRange,
      HandwrittenStrokeSchema.points: points.map((e) => e.toJson()).toList(),
    };
  }

  factory HandwrittenStroke.fromJson(Map<String, dynamic> map) {
    return HandwrittenStroke(
      color: map[HandwrittenStrokeSchema.color],
      widthRange: map[HandwrittenStrokeSchema.widthRange] != null
          ? (map[HandwrittenStrokeSchema.widthRange] as List)
                .map((e) => (e as num).toDouble())
                .toList()
          : const [],
      points: map[HandwrittenStrokeSchema.points] != null
          ? (map[HandwrittenStrokeSchema.points] as List)
                .map((e) => StrokePoint.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
    );
  }
}

class StrokePoint {
  final double? x;
  final double? y;
  final double? p;
  final int? t;

  StrokePoint({this.x, this.y, this.p, this.t});

  StrokePoint copyWith({double? x, double? y, double? p, int? t}) {
    return StrokePoint(
      x: x ?? this.x,
      y: y ?? this.y,
      p: p ?? this.p,
      t: t ?? this.t,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      StrokePointSchema.x: x,
      StrokePointSchema.y: y,
      StrokePointSchema.p: p,
      StrokePointSchema.t: t,
    };
  }

  factory StrokePoint.fromJson(Map<String, dynamic> map) {
    return StrokePoint(
      x: (map[StrokePointSchema.x] as num?)?.toDouble(),
      y: (map[StrokePointSchema.y] as num?)?.toDouble(),
      p: (map[StrokePointSchema.p] as num?)?.toDouble(),
      t: (map[StrokePointSchema.t] as num?)?.toInt(),
    );
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
  static const String hasHandwritten = 'has_handwritten';
  static const String handwrittenPngUrl = 'handwritten_png_url';
  static const String handwrittenPngApiUrl = 'handwritten_png_api_url';
  static const String handwrittenStrokesUrl = 'handwritten_strokes_url';
  static const String handwrittenStrokes = 'handwritten_strokes';
  static const String handwrittenWidth = 'handwritten_width';
  static const String handwrittenHeight = 'handwritten_height';
  static const String handwrittenPenColor = 'handwritten_pen_color';
  static const String actedAt = 'acted_at';
}

class HandwrittenStrokesSchema {
  static const String w = 'w';
  static const String h = 'h';
  static const String strokes = 'strokes';
}

class HandwrittenStrokeSchema {
  static const String color = 'color';
  static const String widthRange = 'widthRange';
  static const String points = 'points';
}

class StrokePointSchema {
  static const String x = 'x';
  static const String y = 'y';
  static const String p = 'p';
  static const String t = 't';
}
