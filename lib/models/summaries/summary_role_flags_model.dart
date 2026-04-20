class SummaryRoleFlagsModel {
  final bool? isDeo;
  final bool? isSecretary;
  final bool? isPstocm;
  final bool? isCm;
  final bool? isPsForSomeone;

  SummaryRoleFlagsModel({
    this.isDeo,
    this.isSecretary,
    this.isPstocm,
    this.isCm,
    this.isPsForSomeone,
  });

  SummaryRoleFlagsModel copyWith({
    bool? isDeo,
    bool? isSecretary,
    bool? isPstocm,
    bool? isCm,
    bool? isPsForSomeone,
  }) {
    return SummaryRoleFlagsModel(
      isDeo: isDeo ?? this.isDeo,
      isSecretary: isSecretary ?? this.isSecretary,
      isPstocm: isPstocm ?? this.isPstocm,
      isCm: isCm ?? this.isCm,
      isPsForSomeone: isPsForSomeone ?? this.isPsForSomeone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SummaryRoleFlagsSchema.isDeo: isDeo,
      SummaryRoleFlagsSchema.isSecretary: isSecretary,
      SummaryRoleFlagsSchema.isPstocm: isPstocm,
      SummaryRoleFlagsSchema.isCm: isCm,
      SummaryRoleFlagsSchema.isPsForSomeone: isPsForSomeone,
    };
  }

  factory SummaryRoleFlagsModel.fromJson(Map<String, dynamic> map) {
    return SummaryRoleFlagsModel(
      isDeo: map[SummaryRoleFlagsSchema.isDeo],
      isSecretary: map[SummaryRoleFlagsSchema.isSecretary],
      isPstocm: map[SummaryRoleFlagsSchema.isPstocm],
      isCm: map[SummaryRoleFlagsSchema.isCm],
      isPsForSomeone: map[SummaryRoleFlagsSchema.isPsForSomeone],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SummaryRoleFlagsModel &&
        other.isDeo == isDeo &&
        other.isSecretary == isSecretary &&
        other.isPstocm == isPstocm &&
        other.isCm == isCm &&
        other.isPsForSomeone == isPsForSomeone;
  }

  @override
  int get hashCode {
    return isDeo.hashCode ^
        isSecretary.hashCode ^
        isPstocm.hashCode ^
        isCm.hashCode ^
        isPsForSomeone.hashCode;
  }
}

class SummaryRoleFlagsSchema {
  static const String isDeo = 'is_deo';
  static const String isSecretary = 'is_secretary';
  static const String isPstocm = 'is_pstocm';
  static const String isCm = 'is_cm';
  static const String isPsForSomeone = 'is_ps_for_someone';
}
