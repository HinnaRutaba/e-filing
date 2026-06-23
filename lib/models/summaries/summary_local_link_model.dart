import 'summary_daak_model.dart';
import 'summary_file_model.dart';

enum SummaryLinkType {
  file('file'),
  daak('daak');

  final String value;

  const SummaryLinkType(this.value);

  static SummaryLinkType? fromString(String? value) {
    if (value == null) return null;
    return SummaryLinkType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid SummaryLinkType: $value'),
    );
  }
}

sealed class SummaryLocalLinkAttachment {
  const SummaryLocalLinkAttachment();

  Map<String, dynamic> toJson();

  static SummaryLocalLinkAttachment? fromJson(
    SummaryLinkType? linkType,
    Map<String, dynamic> map,
  ) {
    if (linkType == null) return null;
    return switch (linkType) {
      SummaryLinkType.file when map[SummaryLocalLinkSchema.file] != null =>
        SummaryLocalLinkFileAttachment(
          SummaryFileModel.fromJson(
            Map<String, dynamic>.from(map[SummaryLocalLinkSchema.file]),
          ),
        ),
      SummaryLinkType.daak when map[SummaryLocalLinkSchema.daak] != null =>
        SummaryLocalLinkDaakAttachment(
          SummaryDaakModel.fromJson(
            Map<String, dynamic>.from(map[SummaryLocalLinkSchema.daak]),
          ),
        ),
      _ => null,
    };
  }
}

final class SummaryLocalLinkFileAttachment extends SummaryLocalLinkAttachment {
  final SummaryFileModel file;

  const SummaryLocalLinkFileAttachment(this.file);

  @override
  Map<String, dynamic> toJson() => file.toJson();
}

final class SummaryLocalLinkDaakAttachment extends SummaryLocalLinkAttachment {
  final SummaryDaakModel daak;

  const SummaryLocalLinkDaakAttachment(this.daak);

  @override
  Map<String, dynamic> toJson() => daak.toJson();
}

class SummaryLocalLinkModel {
  final int? id;
  final SummaryLinkType? linkType;
  final String? linkedBy;
  final SummaryLocalLinkAttachment? attachment;

  SummaryLocalLinkModel({
    this.id,
    this.linkType,
    this.linkedBy,
    this.attachment,
  });

  SummaryLocalLinkModel copyWith({
    int? id,
    SummaryLinkType? linkType,
    String? linkedBy,
    SummaryLocalLinkAttachment? attachment,
  }) {
    return SummaryLocalLinkModel(
      id: id ?? this.id,
      linkType: linkType ?? this.linkType,
      linkedBy: linkedBy ?? this.linkedBy,
      attachment: attachment ?? this.attachment,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      SummaryLocalLinkSchema.id: id,
      SummaryLocalLinkSchema.linkType: linkType?.value,
      SummaryLocalLinkSchema.linkedBy: linkedBy,
    };
    switch (attachment) {
      case SummaryLocalLinkFileAttachment():
        json[SummaryLocalLinkSchema.file] = attachment!.toJson();
      case SummaryLocalLinkDaakAttachment():
        json[SummaryLocalLinkSchema.daak] = attachment!.toJson();
      case null:
        break;
    }
    return json;
  }

  factory SummaryLocalLinkModel.fromJson(Map<String, dynamic> map) {
    SummaryLinkType? linkType = SummaryLinkType.fromString(
      map[SummaryLocalLinkSchema.linkType],
    );
    return SummaryLocalLinkModel(
      id: map[SummaryLocalLinkSchema.id]?.toInt(),
      linkType: linkType,
      linkedBy: map[SummaryLocalLinkSchema.linkedBy],
      attachment: SummaryLocalLinkAttachment.fromJson(linkType, map),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SummaryLocalLinkModel &&
        other.id == id &&
        other.linkType == linkType &&
        other.linkedBy == linkedBy &&
        other.attachment == attachment;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        linkType.hashCode ^
        linkedBy.hashCode ^
        attachment.hashCode;
  }
}

class SummaryLocalLinkSchema {
  static const String id = 'id';
  static const String linkType = 'link_type';
  static const String linkedBy = 'linked_by';
  static const String file = 'file';
  static const String daak = 'daak';
}
