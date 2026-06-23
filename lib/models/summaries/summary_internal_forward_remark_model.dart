class SummaryInternalForwardRemarkModel {
  final int? id;
  final String? remarkType;
  final String? paraNumber;
  final String? heading;
  final String? content;
  final String? submittedBy;
  final String? submittedByDesignation;

  SummaryInternalForwardRemarkModel({
    this.id,
    this.remarkType,
    this.paraNumber,
    this.heading,
    this.content,
    this.submittedBy,
    this.submittedByDesignation,
  });

  SummaryInternalForwardRemarkModel copyWith({
    int? id,
    String? remarkType,
    String? paraNumber,
    String? heading,
    String? content,
    String? submittedBy,
    String? submittedByDesignation,
  }) {
    return SummaryInternalForwardRemarkModel(
      id: id ?? this.id,
      remarkType: remarkType ?? this.remarkType,
      paraNumber: paraNumber ?? this.paraNumber,
      heading: heading ?? this.heading,
      content: content ?? this.content,
      submittedBy: submittedBy ?? this.submittedBy,
      submittedByDesignation:
          submittedByDesignation ?? this.submittedByDesignation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SummaryInternalForwardRemarkSchema.id: id,
      SummaryInternalForwardRemarkSchema.remarkType: remarkType,
      SummaryInternalForwardRemarkSchema.paraNumber: paraNumber,
      SummaryInternalForwardRemarkSchema.heading: heading,
      SummaryInternalForwardRemarkSchema.content: content,
      SummaryInternalForwardRemarkSchema.submittedBy: submittedBy,
      SummaryInternalForwardRemarkSchema.submittedByDesignation:
          submittedByDesignation,
    };
  }

  factory SummaryInternalForwardRemarkModel.fromJson(Map<String, dynamic> map) {
    return SummaryInternalForwardRemarkModel(
      id: map[SummaryInternalForwardRemarkSchema.id]?.toInt(),
      remarkType: map[SummaryInternalForwardRemarkSchema.remarkType],
      paraNumber: map[SummaryInternalForwardRemarkSchema.paraNumber]
          ?.toString(),
      heading: map[SummaryInternalForwardRemarkSchema.heading],
      content: map[SummaryInternalForwardRemarkSchema.content],
      submittedBy: map[SummaryInternalForwardRemarkSchema.submittedBy],
      submittedByDesignation:
          map[SummaryInternalForwardRemarkSchema.submittedByDesignation],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SummaryInternalForwardRemarkModel &&
        other.id == id &&
        other.remarkType == remarkType &&
        other.paraNumber == paraNumber &&
        other.heading == heading &&
        other.content == content &&
        other.submittedBy == submittedBy &&
        other.submittedByDesignation == submittedByDesignation;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        remarkType.hashCode ^
        paraNumber.hashCode ^
        heading.hashCode ^
        content.hashCode ^
        submittedBy.hashCode ^
        submittedByDesignation.hashCode;
  }
}

class SummaryInternalForwardRemarkSchema {
  static const String id = 'id';
  static const String remarkType = 'remark_type';
  static const String paraNumber = 'para_number';
  static const String heading = 'heading';
  static const String content = 'content';
  static const String submittedBy = 'submitted_by';
  static const String submittedByDesignation = 'submitted_by_designation';
}
