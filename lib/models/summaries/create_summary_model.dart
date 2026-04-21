import 'package:dio/dio.dart';
import 'package:efiling_balochistan/models/daak/daak_model.dart';
import 'package:efiling_balochistan/models/department/department_model.dart';
import 'package:efiling_balochistan/models/file/file_model.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/add_file_flag_and_attachmention.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tuple/tuple.dart';

class CreateSummaryModel {
  String subject;
  DateTime summaryDate;
  DepartmentModel? department;
  XFile? mainPdf;
  String summaryHtml;
  List<FlagAndAttachmentModel> attachments;
  List<DaakModel> linkedDaak;
  List<FileModel> linkedFiles;

  /// Base64-encoded PNG of the creator's signature.
  /// Captured via the signature pad widget and must be prefixed with
  /// `data:image/png;base64,` before assignment.
  String? creatorSignatureData;

  CreateSummaryModel({
    this.subject = '',
    DateTime? summaryDate,
    this.department,
    this.mainPdf,
    this.summaryHtml = '',
    List<FlagAndAttachmentModel>? attachments,
    List<DaakModel>? linkedDaak,
    List<FileModel>? linkedFiles,
    this.creatorSignatureData,
  }) : summaryDate = summaryDate ?? DateTime.now(),
       attachments = attachments ?? [FlagAndAttachmentModel()],
       linkedDaak = linkedDaak ?? [],
       linkedFiles = linkedFiles ?? [];

  int get addedFlagsCount =>
      attachments.where((e) => e.flagType != null).length;

  int get correspondenceCount => linkedDaak.length + linkedFiles.length;

  bool get allAttachmentsValid => attachments.every((e) => e.isValid);

  bool get hasAnyInput =>
      subject.trim().isNotEmpty ||
      department != null ||
      mainPdf != null ||
      summaryHtml.trim().isNotEmpty ||
      attachments.any((e) => e.flagType != null || e.attachment != null) ||
      linkedDaak.isNotEmpty ||
      linkedFiles.isNotEmpty;

  bool get isSummaryDetailsComplete =>
      subject.trim().isNotEmpty &&
      department != null &&
      mainPdf != null &&
      summaryHtml.trim().isNotEmpty;

  bool get isFlagsStepComplete => addedFlagsCount > 0 && allAttachmentsValid;

  bool get isCorrespondenceStepComplete => correspondenceCount > 0;

  Future<Tuple2<Map<String, dynamic>, List<MapEntry<String, MultipartFile>>>>
  toJson({required int? userDesgId, bool saveAsDraft = false}) async {
    final Map<String, dynamic> payload = {
      CreateSummarySchema.userDesgId: userDesgId,
      CreateSummarySchema.subject: subject,
      CreateSummarySchema.summaryDate: DateTimeHelper.apiFormat(summaryDate),
      CreateSummarySchema.body: summaryHtml,
      CreateSummarySchema.targetDepartmentId: department?.id,
      CreateSummarySchema.saveAsDraft: saveAsDraft ? 1 : 0,
      CreateSummarySchema.creatorSignatureData: creatorSignatureData,
    };
    final files = <MapEntry<String, MultipartFile>>[];

    if (mainPdf != null) {
      files.add(
        MapEntry(
          CreateSummarySchema.mainSummaryPdf,
          await MultipartFile.fromFile(mainPdf!.path),
        ),
      );
    }

    for (var i = 0; i < attachments.length; i++) {
      payload['${CreateSummarySchema.flagName}[$i]'] =
          attachments[i].flagType?.id;
      if (attachments[i].attachment != null) {
        files.add(
          MapEntry(
            '${CreateSummarySchema.supportingAttachments}[$i]',
            await MultipartFile.fromFile(attachments[i].attachment!.path),
          ),
        );
      }
    }

    for (var i = 0; i < linkedDaak.length; i++) {
      payload['${CreateSummarySchema.linkedDaakIds}[$i]'] = linkedDaak[i].id;
    }

    for (var i = 0; i < linkedFiles.length; i++) {
      payload['${CreateSummarySchema.linkedFileIds}[$i]'] =
          linkedFiles[i].fileId;
    }

    return Tuple2(payload, files);
  }
}

class CreateSummarySchema {
  static const String userDesgId = 'userDesgID';
  static const String subject = 'subject';
  static const String summaryDate = 'summary_date';
  static const String body = 'body';
  static const String targetDepartmentId = 'target_department_id';
  static const String saveAsDraft = 'save_as_draft';
  static const String creatorSignatureData = 'creator_signature_data';
  static const String mainSummaryPdf = 'main_summary_pdf';
  static const String supportingAttachments = 'supporting_attachments';
  static const String flagName = 'flag_name';
  static const String linkedDaakIds = 'linked_daak_ids';
  static const String linkedFileIds = 'linked_file_ids';
}
