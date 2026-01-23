import 'package:dio/dio.dart';
import 'package:efiling_balochistan/config/network/network_base.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/add_file_flag_and_attachmention.dart';
import 'package:tuple/tuple.dart';

class FileContentModel {
  final int? fileId;
  final String? fileType;
  final String? subject;
  final String? signature;
  final String? content;
  final String? fileMovNo;
  final String? barcode;
  final String? referenceNo;
  final DateTime? dateIn;
  final DateTime? dateCreated;
  final String? sender;
  final String? receiver;
  final String? designation;
  final DateTime? sendingDate;
  final int? trackId;
  final String? tag;
  final String? tagColor;
  final String? fileContentNumber;

  FileContentModel({
    this.fileId,
    this.fileType,
    this.subject,
    this.signature,
    this.content,
    this.fileMovNo,
    this.barcode,
    this.referenceNo,
    this.dateIn,
    this.sender,
    this.receiver,
    this.designation,
    this.sendingDate,
    this.trackId,
    this.tag,
    this.tagColor,
    this.dateCreated,
    this.fileContentNumber,
  });

  String get signatureUrl => "${NetworkBase.base}/$signature";

  factory FileContentModel.fromJson(Map<String, dynamic> json) {
    try {
      return FileContentModel(
        fileId: json[FileContentSchema.fileId] as int?,
        fileType: json[FileContentSchema.fileType] as String?,
        subject: json[FileContentSchema.subject] as String?,
        signature: json[FileContentSchema.signature] as String?,
        content: (json[FileContentSchema.content]) as String?,
        fileMovNo: json[FileContentSchema.fileMovNo] as String?,
        barcode: json[FileContentSchema.barcode] as String?,
        referenceNo: json[FileContentSchema.referenceNo] as String?,
        dateIn: json[FileContentSchema.dateIn] != null
            ? DateTime.tryParse(json[FileContentSchema.dateIn])
            : null,
        dateCreated: json[FileContentSchema.dateCreated] != null
            ? DateTime.tryParse(json[FileContentSchema.dateCreated])
            : null,
        sender: json[FileContentSchema.sender] as String?,
        receiver: json[FileContentSchema.receiver] as String?,
        designation: json[FileContentSchema.designation] ??
            json[FileContentSchema.senderDesignation],
        sendingDate: json[FileContentSchema.sendingDate] != null
            ? DateTime.tryParse(json[FileContentSchema.sendingDate])
            : null,
        trackId: json[FileContentSchema.trackId] as int?,
        tag: json[FileContentSchema.tag] as String?,
        tagColor: json[FileContentSchema.tagColor] as String?,
        fileContentNumber: json[FileContentSchema.partFileNo] as String?,
      );
    } catch (e, s) {
      print("ERROR FILEEEEEE_____${e}______$s");
      return FileContentModel();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      FileContentSchema.fileId: fileId,
      FileContentSchema.fileType: fileType,
      FileContentSchema.subject: subject,
      FileContentSchema.signature: signature,
      FileContentSchema.content: content,
      FileContentSchema.fileMovNo: fileMovNo,
      FileContentSchema.barcode: barcode,
      FileContentSchema.referenceNo: referenceNo,
      FileContentSchema.dateIn: dateIn?.toIso8601String(),
      FileContentSchema.sender: sender,
      FileContentSchema.receiver: receiver,
      FileContentSchema.designation: designation,
      FileContentSchema.sendingDate: sendingDate?.toIso8601String(),
      FileContentSchema.trackId: trackId,
      FileContentSchema.tag: tag,
      FileContentSchema.tagColor: tagColor,
    };
  }

  static Future<
          Tuple2<Map<String, dynamic>, List<MapEntry<String, MultipartFile>>>>
      toAddRemarksJson({
    required int fileId,
    required int userId,
    required String content,
    required int forwardTo,
    required String fileMovNo,
    required int lastTrackId,
    required List<FlagAndAttachmentModel>? flags,
    required int designationId,
  }) async {
    Map<String, dynamic> payload = {
      'fileID': fileId,
      'userid1': userId,
      'file_content1': content,
      'forward_to1': forwardTo,
      'file_mov_no': fileMovNo,
      'lastTrackID': lastTrackId,
      'userDesgID': designationId,
    };
    final files = <MapEntry<String, MultipartFile>>[];

    if (flags != null && flags.isNotEmpty) {
      for (var i = 0; i < flags!.length; i++) {
        payload['flag_name[$i]'] = flags![i].flagType?.id;
        if (flags[i].attachment != null) {
          files.add(
            MapEntry(
              'flag_attach[$i]',
              await MultipartFile.fromFile(flags[i].attachment!.path),
            ),
          );
        }
      }
    }
    return Tuple2(payload, files);
  }

  static Future<
          Tuple2<Map<String, dynamic>, List<MapEntry<String, MultipartFile>>>>
      toSubmitJson({
    required int fileId,
    required int userId,
    required String content,
    required int? forwardTo,
    required int choice,
    required int designationId,
    required List<FlagAndAttachmentModel>? flags,
  }) async {
    Map<String, dynamic> payload = {
      'fileID1': fileId,
      'userid2': userId,
      'file_content2': content,
      'Choice': choice,
      'userDesgID': designationId,
      if (forwardTo != null) 'forward_to2': forwardTo,
    };
    final files = <MapEntry<String, MultipartFile>>[];

    if (flags != null && flags.isNotEmpty) {
      for (var i = 0; i < flags.length; i++) {
        payload['flag_name[$i]'] = flags[i].flagType?.id;
        if (flags[i].attachment != null) {
          files.add(
            MapEntry(
              'flag_attach[$i]',
              await MultipartFile.fromFile(flags[i].attachment!.path),
            ),
          );
        }
      }
    }
    return Tuple2(payload, files);
  }

  static Future<
          Tuple2<Map<String, dynamic>, List<MapEntry<String, MultipartFile>>>>
      toReopenJson({
    required int fileId,
    required int sectionId,
    required String content,
    required int forwardTo,
    required int designationId,
    required List<FlagAndAttachmentModel>? flags,
  }) async {
    Map<String, dynamic> payload = {
      'file_id': fileId,
      'section': sectionId,
      'file_content1': content,
      'forward_to': forwardTo,
      'userDesgID': designationId,
    };
    final files = <MapEntry<String, MultipartFile>>[];

    if (flags != null && flags.isNotEmpty) {
      for (var i = 0; i < flags!.length; i++) {
        payload['flag_name[$i]'] = flags![i].flagType?.id;
        if (flags[i].attachment != null) {
          files.add(
            MapEntry(
              'flag_attach[$i]',
              await MultipartFile.fromFile(flags[i].attachment!.path),
            ),
          );
        }
      }
    }
    return Tuple2(payload, files);
  }

  static Future<
          Tuple2<Map<String, dynamic>, List<MapEntry<String, MultipartFile>>>>
      toCreateFileJson({
    required String subject,
    required int fileType,
    required String content,
    required int forwardTo,
    required String fileMovNumber,
    required String refNumber,
    required String partFileNumber,
    required int tagId,
    required int designationId,
    required List<FlagAndAttachmentModel>? flags,
  }) async {
    Map<String, dynamic> payload = {
      'file_subject': subject,
      'file_type': fileType,
      'file_content': content,
      'forward_to': forwardTo,
      'file_mov_no': fileMovNumber,
      'reference_no': refNumber,
      'part_file_no': partFileNumber,
      'tag_id': tagId,
      'userDesgID': designationId,
    };
    final files = <MapEntry<String, MultipartFile>>[];

    if (flags != null && flags.isNotEmpty) {
      for (var i = 0; i < flags!.length; i++) {
        payload['flag_name[$i]'] = flags![i].flagType?.id;
        if (flags[i].attachment != null) {
          files.add(
            MapEntry(
              'flag_attach[$i]',
              await MultipartFile.fromFile(flags[i].attachment!.path),
            ),
          );
        }
      }
    }
    return Tuple2(payload, files);
  }

  Map<String, dynamic> toContentJson() {
    return {
      FileContentSchema.fileType: fileType,
      FileContentSchema.subject: subject,
      FileContentSchema.content: content,
      FileContentSchema.referenceNo: referenceNo,
      FileContentSchema.dateIn: dateIn?.toIso8601String(),
      FileContentSchema.sender: sender,
      FileContentSchema.designation: designation,
      FileContentSchema.sendingDate: sendingDate?.toIso8601String(),
      FileContentSchema.tag: tag,
      FileContentSchema.receiver: receiver,
      //FileContentSchema.fileMovNo: fileMovNo,
      //FileContentSchema.barcode: barcode,
      //FileContentSchema.trackId: trackId,
      //FileContentSchema.tagColor: tagColor,
      //FileContentSchema.signature: signature,
      //FileContentSchema.fileId: fileId,
    };
  }
}

class FileAttachmentModel {
  final String? flagAttach;
  final String? flagTitle;

  FileAttachmentModel({
    this.flagAttach,
    this.flagTitle,
  });

  String? get attachmentFlag =>
      flagAttach == null ? null : "${NetworkBase.base}/$flagAttach";

  factory FileAttachmentModel.fromJson(Map<String, dynamic> json) {
    return FileAttachmentModel(
      flagAttach: json[FileAttachmentSchema.flagAttach] as String?,
      flagTitle: json[FileAttachmentSchema.flagTitle] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FileAttachmentSchema.flagAttach: flagAttach,
      FileAttachmentSchema.flagTitle: flagTitle,
    };
  }

  Map<String, dynamic> toContentJson() {
    return {
      FileAttachmentSchema.flagAttach: attachmentFlag,
      FileAttachmentSchema.flagTitle: flagTitle,
    };
  }

  FileAttachmentModel copyWith({
    String? flagAttach,
    String? flagTitle,
  }) {
    return FileAttachmentModel(
      flagAttach: flagAttach ?? this.flagAttach,
      flagTitle: flagTitle ?? this.flagTitle,
    );
  }
}

class FileDetailsModel {
  final List<FileContentModel> content;
  final List<FileAttachmentModel> attachments;

  FileDetailsModel({this.content = const [], this.attachments = const []});

  factory FileDetailsModel.fromJsonPending(Map<String, dynamic> json) {
    return FileDetailsModel(
      content: (json[FileDetailsSchema.fileContent] as List?)
              ?.map((item) => FileContentModel.fromJson(item))
              .toList() ??
          [],
      attachments: (json[FileDetailsSchema.attachments] as List?)
              ?.map((item) => FileAttachmentModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  factory FileDetailsModel.fromJsonMy(Map<String, dynamic> json) {
    return FileDetailsModel(
      content: (json[FileDetailsSchema.details] as List?)
              ?.map((item) => FileContentModel.fromJson(item))
              .toList() ??
          [],
      attachments: (json[FileDetailsSchema.flags] as List?)
              ?.map((item) => FileAttachmentModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  factory FileDetailsModel.fromJsonActionReq(Map<String, dynamic> json) {
    return FileDetailsModel(
      content: (json[FileDetailsSchema.file] as List?)
              ?.map((item) => FileContentModel.fromJson(item))
              .toList() ??
          [],
      attachments: (json[FileDetailsSchema.attachments] as List?)
              ?.map((item) => FileAttachmentModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  factory FileDetailsModel.fromJsonForwardedFiles(Map<String, dynamic> json) {
    return FileDetailsModel(
      content: (json[FileDetailsSchema.fileDetails] as List?)
              ?.map((item) => FileContentModel.fromJson(item))
              .toList() ??
          [],
      attachments: (json[FileDetailsSchema.attachments] as List?)
              ?.map((item) => FileAttachmentModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FileDetailsSchema.fileContent: content.map((e) => e.toJson()).toList(),
      FileDetailsSchema.attachments:
          attachments.map((e) => e.toJson()).toList(),
    };
  }

  Map<String, dynamic> toContentJson() {
    return {
      FileDetailsSchema.fileContent:
          content.map((e) => e.toContentJson()).toList(),
      FileDetailsSchema.attachments:
          attachments.map((e) => e.toContentJson()).toList(),
    };
  }
}

class FileContentSchema {
  static const String fileId = "file_id";
  static const String fileType = "file_type";
  static const String subject = "subject";
  static const String signature = "signature";
  static const String content = "content";

  static const String fileMovNo = "file_mov_no";
  static const String barcode = "barcode";
  static const String referenceNo = "reference_no";
  static const String dateIn = "date_in";
  static const String dateCreated = "date_created";
  static const String sender = "sender";
  static const String receiver = "receiver";
  static const String designation = "designation";
  static const String senderDesignation = "sender_designation";
  static const String sendingDate = "sending_date";
  static const String trackId = "track_id";
  static const String tag = "tag";
  static const String tagColor = "tag_color";
  static const String partFileNo = "part_file_no";
}

class FileAttachmentSchema {
  static const String flagAttach = "flag_attach";
  static const String flagTitle = "flag_title";
}

class FileDetailsSchema {
  static const String fileContent = 'file_content';
  static const String attachments = 'attachments';

  static const String details = 'details';
  static const String flags = 'flags';

  static const String file = 'file';
  static const String fileDetails = 'file_details';
}
