import 'package:efiling_balochistan/config/network/network_base.dart';
import 'package:efiling_balochistan/models/file_details_model.dart';
import 'package:efiling_balochistan/models/file_model.dart';
import 'package:efiling_balochistan/models/flag_model.dart';
import 'package:efiling_balochistan/models/forward_to.dart';
import 'package:efiling_balochistan/models/new_file_data_model.dart';
import 'package:efiling_balochistan/models/section_schema.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/add_file_flag_and_attachmention.dart';

abstract class FilesInterface extends NetworkBase {
  String pendingFilesUrl(int desId) =>
      '${baseUrl}pending-files?userDesgID=$desId';
  String viewPendingFileUrl(int fileId, int desId) =>
      '${baseUrl}pending-files/$fileId/view?userDesgID=$desId';
  String generateFileMovNumUrl(int desId) =>
      '${baseUrl}forward/suggest-file-mov-no?userDesgID=$desId';
  String forwardSectionUrl(int desId) =>
      '${baseUrl}forward/sections?userDesgID=$desId';
  String getForwardToUrl(int sectionId, int desId) =>
      '${baseUrl}forward/users?section_id=$sectionId&userDesgID=$desId';
  String getFlagsUrl(int desId) => '${baseUrl}forward/flags';
  String get pendingFileSendUrl => '${baseUrl}pending-file/send';

  String myFilesUrl(int desId) => '${baseUrl}myfiles?userDesgID=$desId';
  String viewMyFileUrl(int fileId, int desId) =>
      '${baseUrl}myfiles/$fileId?userDesgID=$desId';

  String actionFilesUrl(int desId) =>
      '${baseUrl}files/action-required?userDesgID=$desId';
  String viewActionFileUrl(int fileId, int desId) =>
      '${baseUrl}files/action-required/$fileId?userDesgID=$desId';

  String get submitActionUrl => '${baseUrl}file/submit-action';

  String forwardedFilesUrl(int desId) =>
      '${baseUrl}files/forwarded?userDesgID=$desId';
  String viewForwardedFileUrl(int fileId, int desId) =>
      '${baseUrl}files/forwarded/$fileId?userDesgID=$desId';

  String archivedFilesUrl(int desId) =>
      '${baseUrl}disposed-off-files?userDesgID=$desId';

  String viewArchivedFileUrl(int fileId, int desId) =>
      '${baseUrl}disposed-off-file/$fileId?userDesgID=$desId';

  String get reopenFileUrl => '${baseUrl}reopen-file';

  String newFileDataUrl(int desId) =>
      '${baseUrl}create-file-meta?userDesgID=$desId';

  String get createFileUrl => '${baseUrl}create-file';

  Future<List<FileModel>> fetchPendingFiles(int desId);

  Future<FileDetailsModel?> viewPendingFileDetails(int fileId, int desId);

  Future<String?> generateFileMovNumber(int desId);

  Future<List<SectionModel>> getSections(int desId);

  Future<List<ForwardToModel>> getForwardList(int? sectionId, int? desId);

  Future<List<FlagModel>> getFlags(int desId);

  Future<void> sendPendingFileRemarks({
    required int fileId,
    required int userId,
    required String content,
    required int forwardTo,
    required String fileMovNo,
    required int lastTrackId,
    required int designationId,
    required List<FlagAndAttachmentModel>? flags,
  });

  Future<List<FileModel>> fetchMyFiles(int desId);

  Future<FileDetailsModel?> viewMyFileDetails(int fileId, int desId);

  Future<List<FileModel>> fetchActionReqFiles(int desId);

  Future<FileDetailsModel?> viewActionReqFileDetails(int fileId, int desId);

  Future<void> submitAction({
    required int fileId,
    required int userId,
    required String content,
    required int forwardTo,
    required int choice,
    required int designationId,
    required List<FlagAndAttachmentModel>? flags,
  });

  Future<List<FileModel>> fetchForwardedFiles(int desId);

  Future<FileDetailsModel?> viewForwardedFileDetails(int fileId, int desId);

  Future<List<FileModel>> fetchArchivedFiles(int desId);

  Future<FileDetailsModel?> viewArchivedFileDetails(int fileId, int desId);

  Future<void> reopenFile({
    required int fileId,
    required int sectionId,
    required String content,
    required int forwardTo,
    required int designationId,
    required List<FlagAndAttachmentModel>? flags,
  });

  Future<NewFileDataModel?> fetchCreateFileData(int desId);

  Future<void> createNewFile({
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
  });
}
