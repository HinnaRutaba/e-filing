import 'package:dio/dio.dart';
import 'package:efiling_balochistan/models/summaries/summary_daak_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_file_model.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/add_file_flag_and_attachmention.dart';
import 'package:tuple/tuple.dart';

class DraftRemarksModel {
  final int summaryId;
  final int userDesgId;
  final int? internalForwardId;
  final String body;
  final String briefNote;
  final List<FlagAndAttachmentModel> newFlags;
  final List<SummaryDaakModel> linkedDaak;
  final List<SummaryFileModel> linkedFiles;

  const DraftRemarksModel({
    required this.summaryId,
    required this.userDesgId,
    this.internalForwardId,
    required this.body,
    required this.briefNote,
    required this.newFlags,
    required this.linkedDaak,
    required this.linkedFiles,
  });

  Future<Tuple2<Map<String, dynamic>, List<MapEntry<String, MultipartFile>>>>
  toJson() async {
    final Map<String, dynamic> payload = {
      DraftRemarksSchema.userDesgId: userDesgId,
      DraftRemarksSchema.internalForwardId: internalForwardId,
      DraftRemarksSchema.actionType: DraftRemarksSchema.actionTypeValue,
      DraftRemarksSchema.body: body,
      DraftRemarksSchema.briefNote: briefNote,
    };

    final files = <MapEntry<String, MultipartFile>>[];

    final validFlags = newFlags.where((f) => f.flagType != null).toList();
    for (var i = 0; i < validFlags.length; i++) {
      payload['${DraftRemarksSchema.flagName}[$i]'] =
          validFlags[i].flagType?.id;
      if (validFlags[i].attachment != null) {
        files.add(
          MapEntry(
            '${DraftRemarksSchema.supportingAttachments}[$i]',
            await MultipartFile.fromFile(validFlags[i].attachment!.path),
          ),
        );
      }
    }

    for (var i = 0; i < linkedDaak.length; i++) {
      payload['${DraftRemarksSchema.linkedDaakIds}[$i]'] = linkedDaak[i].id;
    }

    for (var i = 0; i < linkedFiles.length; i++) {
      payload['${DraftRemarksSchema.linkedFileIds}[$i]'] = linkedFiles[i].id;
    }

    return Tuple2(payload, files);
  }
}

class DraftRemarksSchema {
  static const String userDesgId = 'userDesgID';
  static const String internalForwardId = 'internal_forward_id';
  static const String actionType = 'action_type';
  static const String actionTypeValue = 'return_to_secretary';
  static const String body = 'body';
  static const String briefNote = 'brief_note';
  static const String flagName = 'flag_name';
  static const String supportingAttachments = 'supporting_attachments';
  static const String linkedDaakIds = 'linked_daak_ids';
  static const String linkedFileIds = 'linked_file_ids';
}
