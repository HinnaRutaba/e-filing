class SummaryLocalLinkModel {
  final int? id;
  final String? linkType;
  final String? linkedBy;
  final SummaryLocalLinkFile? file;

  SummaryLocalLinkModel({
    this.id,
    this.linkType,
    this.linkedBy,
    this.file,
  });

  SummaryLocalLinkModel copyWith({
    int? id,
    String? linkType,
    String? linkedBy,
    SummaryLocalLinkFile? file,
  }) {
    return SummaryLocalLinkModel(
      id: id ?? this.id,
      linkType: linkType ?? this.linkType,
      linkedBy: linkedBy ?? this.linkedBy,
      file: file ?? this.file,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SummaryLocalLinkSchema.id: id,
      SummaryLocalLinkSchema.linkType: linkType,
      SummaryLocalLinkSchema.linkedBy: linkedBy,
      SummaryLocalLinkSchema.file: file?.toJson(),
    };
  }

  factory SummaryLocalLinkModel.fromJson(Map<String, dynamic> map) {
    return SummaryLocalLinkModel(
      id: map[SummaryLocalLinkSchema.id]?.toInt(),
      linkType: map[SummaryLocalLinkSchema.linkType],
      linkedBy: map[SummaryLocalLinkSchema.linkedBy],
      file: map[SummaryLocalLinkSchema.file] != null
          ? SummaryLocalLinkFile.fromJson(
              Map<String, dynamic>.from(map[SummaryLocalLinkSchema.file]),
            )
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SummaryLocalLinkModel &&
        other.id == id &&
        other.linkType == linkType &&
        other.linkedBy == linkedBy &&
        other.file == file;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        linkType.hashCode ^
        linkedBy.hashCode ^
        file.hashCode;
  }
}

class SummaryLocalLinkFile {
  final int? id;
  final String? referenceNo;
  final String? subject;

  SummaryLocalLinkFile({
    this.id,
    this.referenceNo,
    this.subject,
  });

  SummaryLocalLinkFile copyWith({
    int? id,
    String? referenceNo,
    String? subject,
  }) {
    return SummaryLocalLinkFile(
      id: id ?? this.id,
      referenceNo: referenceNo ?? this.referenceNo,
      subject: subject ?? this.subject,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SummaryLocalLinkFileSchema.id: id,
      SummaryLocalLinkFileSchema.referenceNo: referenceNo,
      SummaryLocalLinkFileSchema.subject: subject,
    };
  }

  factory SummaryLocalLinkFile.fromJson(Map<String, dynamic> map) {
    return SummaryLocalLinkFile(
      id: map[SummaryLocalLinkFileSchema.id]?.toInt(),
      referenceNo: map[SummaryLocalLinkFileSchema.referenceNo],
      subject: map[SummaryLocalLinkFileSchema.subject],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SummaryLocalLinkFile &&
        other.id == id &&
        other.referenceNo == referenceNo &&
        other.subject == subject;
  }

  @override
  int get hashCode => id.hashCode ^ referenceNo.hashCode ^ subject.hashCode;
}

class SummaryLocalLinkSchema {
  static const String id = 'id';
  static const String linkType = 'link_type';
  static const String linkedBy = 'linked_by';
  static const String file = 'file';
}

class SummaryLocalLinkFileSchema {
  static const String id = 'id';
  static const String referenceNo = 'reference_no';
  static const String subject = 'subject';
}
