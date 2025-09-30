import 'package:flutter/material.dart';

/// File Statuses (files table)
enum FileStatus {
  pending(0, "Pending"),
  approvedDisposed(1, "Approved & Disposed Off"),
  unapprovedDisposed(2, "Unapproved & Disposed Off"),
  reForwarded(3, "Re-Forwarded by you");

  final int value;
  final String label;
  const FileStatus(this.value, this.label);

  static FileStatus fromValue(int value) {
    return FileStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FileStatus.pending,
    );
  }
}

/// Track Statuses (tracks table)
enum TrackStatus {
  inactive(0, "Inactive Track"),
  active(1, "Currently Active Track");

  final int value;
  final String label;
  const TrackStatus(this.value, this.label);

  static TrackStatus fromValue(int value) {
    return TrackStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TrackStatus.inactive,
    );
  }
}

class FileModel {
  final int? trackId;
  final int? fileId;
  final String? fileContent;
  final String? subject;
  final String? referenceNo;
  final String? partFileNo;
  final String? fileMovNo;
  final String? barcode;
  final FileStatus? status;
  final DateTime? receivedAt;
  final TagModel? tag;
  final String? sender;
  final String? receiver;
  final String? fileType;
  final DateTime? createdAt;
  final DateTime? latestDate;
  final int? forwardedCount;

  FileModel({
    this.trackId,
    this.fileId,
    this.fileContent,
    this.subject,
    this.referenceNo,
    this.partFileNo,
    this.fileMovNo,
    this.barcode,
    this.status,
    this.receivedAt,
    this.tag,
    this.sender,
    this.receiver,
    this.fileType,
    this.createdAt,
    this.latestDate,
    this.forwardedCount,
  });

  factory FileModel.fromJson(Map<String, dynamic> json, {FileStatus? status}) {
    return FileModel(
      trackId: json[FileSchema.trackId],
      fileId: json[FileSchema.fileId],
      fileContent: json[FileSchema.fileContent],
      subject: json[FileSchema.subject],
      referenceNo: json[FileSchema.referenceNo],
      partFileNo: json[FileSchema.partFileNo],
      fileMovNo: json[FileSchema.fileMovNo],
      barcode: json[FileSchema.barcode],
      status: json[FileSchema.status] is int
          ? FileStatus.fromValue(
              json[FileSchema.status] ?? json[FileSchema.fileStatus])
          : status,
      receivedAt: json[FileSchema.receivedAt] != null
          ? DateTime.tryParse(json[FileSchema.receivedAt])
          : null,
      createdAt: json[FileSchema.createdAt] != null
          ? DateTime.tryParse(json[FileSchema.createdAt])
          : null,
      tag: json[FileSchema.tag] != null
          ? json[FileSchema.tag] is String
              ? TagModel(
                  id: null,
                  title: json[FileSchema.tag],
                  color: getTagColor(json[FileSchema.tagColor] ?? 'primary'))
              : TagModel.fromJson(json[FileSchema.tag])
          : null,
      sender: json[FileSchema.sender] as String?,
      receiver: json[FileSchema.receiver] as String?,
      fileType: json[FileSchema.fileType] as String?,
      latestDate: json[FileSchema.latestDate] != null
          ? DateTime.tryParse(json[FileSchema.latestDate])
          : null,
      forwardedCount: json[FileSchema.forwardedCount] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FileSchema.trackId: trackId,
      FileSchema.fileId: fileId,
      FileSchema.fileContent: fileContent,
      FileSchema.subject: subject,
      FileSchema.referenceNo: referenceNo,
      FileSchema.partFileNo: partFileNo,
      FileSchema.fileMovNo: fileMovNo,
      FileSchema.barcode: barcode,
      FileSchema.status: status,
      FileSchema.receivedAt: receivedAt?.toIso8601String(),
      FileSchema.tag: tag?.toJson(),
    };
  }
}

class TagModel {
  final int? id;
  final String? title;
  final Color? color;

  TagModel({
    this.id,
    this.title,
    this.color,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json[TagSchema.id] as int?,
      title: json[TagSchema.title] as String?,
      color: getTagColor(json[TagSchema.color]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      TagSchema.id: id,
      TagSchema.title: title,
      TagSchema.color: color,
    };
  }
}

class FileSchema {
  static const String trackId = "track_id";
  static const String fileId = "file_id";
  static const String fileContent = "file_content";
  static const String subject = "subject";
  static const String referenceNo = "reference_no";
  static const String partFileNo = "part_file_no";
  static const String fileMovNo = "file_mov_no";
  static const String barcode = "barcode";
  static const String status = "status";
  static const String fileStatus = "file_status";
  static const String receivedAt = "receiving_date";
  static const String tag = "tag";
  static const String tagColor = "tag_color";
  static const String sender = "sender";
  static const String receiver = "receiver";
  static const String fileType = "file_type";
  static const String createdAt = "created_at";
  static const String latestDate = "latest_date";
  static const String forwardedCount = "forwarded_count";
}

class TagSchema {
  static const String id = "id";
  static const String title = "title";
  static const String color = "color";
}

Color getTagColor(String colorName) {
  Color tagColor = Colors.blue;
  if (colorName == 'danger') {
    tagColor = Colors.red[700]!;
  } else if (colorName == 'warning') {
    tagColor = Colors.amber[700]!;
  } else if (colorName == 'success') {
    tagColor = Colors.green[700]!;
  } else if (colorName == 'info') {
    tagColor = Colors.blue[700]!;
  } else if (colorName == 'primary') {
    tagColor = Colors.blue[700]!;
  } else if (colorName == 'secondary') {
    tagColor = Colors.grey[700]!;
  }
  return tagColor;
}
