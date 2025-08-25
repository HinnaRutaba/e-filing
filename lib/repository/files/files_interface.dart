import 'package:efiling_balochistan/config/network/network_base.dart';
import 'package:efiling_balochistan/models/file_details_model.dart';
import 'package:efiling_balochistan/models/file_model.dart';
import 'package:efiling_balochistan/models/flag_model.dart';
import 'package:efiling_balochistan/models/forward_to.dart';
import 'package:efiling_balochistan/models/section_schema.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/add_file_flag_and_attachmention.dart';

abstract class FilesInterface extends NetworkBase {
  String get pendingFilesUrl => '${baseUrl}pending-files';
  String viewPendingFileUrl(int fileId) =>
      '${baseUrl}pending-files/$fileId/view';
  String get generateFileMovNumUrl => '${baseUrl}forward/suggest-file-mov-no';
  String get forwardSectionUrl => '${baseUrl}forward/sections';
  String getForwardToUrl(int sectionId) =>
      '${baseUrl}forward/users?section_id=$sectionId';
  String get getFlagsUrl => '${baseUrl}forward/flags';
  String get pendingFileSendUrl => '${baseUrl}pending-file/send';

  String get myFilesUrl => '${baseUrl}myfiles';
  String viewMyFileUrl(int fileId) => '${baseUrl}myfiles/$fileId';

  String get actionFilesUrl => '${baseUrl}files/action-required';
  String viewActionFileUrl(int fileId) =>
      '${baseUrl}files/action-required/$fileId';

  Future<List<FileModel>> fetchPendingFiles();

  Future<FileDetailsModel?> viewPendingFileDetails(int fileId);

  Future<String?> generateFileMovNumber();

  Future<List<SectionModel>> getSections();

  Future<List<ForwardToModel>> getForwardList(int? sectionId);

  Future<List<FlagModel>> getFlags();

  Future<void> sendPendingFileRemarks({
    required int fileId,
    required int userId,
    required String content,
    required int forwardTo,
    required String fileMovNo,
    required int lastTrackId,
    required List<FlagAndAttachmentModel>? flags,
  });

  Future<List<FileModel>> fetchMyFiles();

  Future<FileDetailsModel?> viewMyFileDetails(int fileId);

  Future<List<FileModel>> fetchActionReqFiles();

  Future<FileDetailsModel?> viewActionReqFileDetails(int fileId);
}
