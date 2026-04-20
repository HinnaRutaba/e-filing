class SummaryBriefModel {
  final int? id;
  final String? briefNote;
  final String? actor;
  final DateTime? actedAt;

  SummaryBriefModel({
    this.id,
    this.briefNote,
    this.actor,
    this.actedAt,
  });

  SummaryBriefModel copyWith({
    int? id,
    String? briefNote,
    String? actor,
    DateTime? actedAt,
  }) {
    return SummaryBriefModel(
      id: id ?? this.id,
      briefNote: briefNote ?? this.briefNote,
      actor: actor ?? this.actor,
      actedAt: actedAt ?? this.actedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SummaryBriefSchema.id: id,
      SummaryBriefSchema.briefNote: briefNote,
      SummaryBriefSchema.actor: actor,
      SummaryBriefSchema.actedAt: actedAt?.toIso8601String(),
    };
  }

  factory SummaryBriefModel.fromJson(Map<String, dynamic> map) {
    return SummaryBriefModel(
      id: map[SummaryBriefSchema.id]?.toInt(),
      briefNote: map[SummaryBriefSchema.briefNote],
      actor: map[SummaryBriefSchema.actor],
      actedAt: map[SummaryBriefSchema.actedAt] != null
          ? DateTime.tryParse(map[SummaryBriefSchema.actedAt])
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SummaryBriefModel &&
        other.id == id &&
        other.briefNote == briefNote &&
        other.actor == actor &&
        other.actedAt == actedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        briefNote.hashCode ^
        actor.hashCode ^
        actedAt.hashCode;
  }
}

class SummaryBriefSchema {
  static const String id = 'id';
  static const String briefNote = 'brief_note';
  static const String actor = 'actor';
  static const String actedAt = 'acted_at';
}
