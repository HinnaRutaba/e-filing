import 'package:dio/dio.dart';
import 'package:efiling_balochistan/models/file_details_model.dart';
import 'package:efiling_balochistan/models/file_model.dart';
import 'package:efiling_balochistan/models/flag_model.dart';
import 'package:efiling_balochistan/models/forward_to.dart';
import 'package:efiling_balochistan/models/section_schema.dart';
import 'package:efiling_balochistan/repository/files/files_interface.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/add_file_flag_and_attachmention.dart';
import 'package:tuple/tuple.dart';

class FileRepo extends FilesInterface {
  @override
  Future<List<FileModel>> fetchPendingFiles() async {
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: pendingFilesUrl,
        options: await options(),
      );
      if (data.isNotEmpty) {
        return data['data'] != null && data['data'] is List
            ? (data['data'] as List)
                .map((file) => FileModel.fromJson(file))
                .toList()
            : [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<FileDetailsModel?> viewPendingFileDetails(int fileId) async {
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: viewPendingFileUrl(fileId),
        options: await options(),
      );
      if (data.isNotEmpty) {
        return FileDetailsModel.fromJsonPending(data['data']);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String?> generateFileMovNumber() async {
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: generateFileMovNumUrl,
        options: await options(),
      );
      if (data.isNotEmpty && data['data'] != null) {
        return data['data']['file_mov_no'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SectionModel>> getSections() async {
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: forwardSectionUrl,
        options: await options(),
      );
      if (data.isNotEmpty && data['data'] != null) {
        return (data['data'] as List)
            .map((e) => SectionModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ForwardToModel>> getForwardList(int? sectionId) async {
    if (sectionId == null) {
      throw "Section id is required";
    }
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: getForwardToUrl(sectionId),
        options: await options(),
      );
      if (data.isNotEmpty && data['data'] != null) {
        return (data['data'] as List)
            .map((e) => ForwardToModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<FlagModel>> getFlags() async {
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: getFlagsUrl,
        options: await options(),
      );
      if (data.isNotEmpty && data['data'] != null) {
        return (data['data'] as List)
            .map((e) => FlagModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendPendingFileRemarks(
      {required int fileId,
      required int userId,
      required String content,
      required int forwardTo,
      required String fileMovNo,
      required int lastTrackId,
      required List<FlagAndAttachmentModel>? flags}) async {
    try {
      try {
        Tuple2<Map<String, dynamic>, List<MapEntry<String, MultipartFile>>>
            jsonData = await FileContentModel.toAddRemarksJson(
          fileId: fileId,
          userId: userId,
          content: content,
          forwardTo: forwardTo,
          fileMovNo: fileMovNo,
          lastTrackId: lastTrackId,
          flags: flags,
        );
        FormData formData = FormData.fromMap(jsonData.item1);
        formData.files.addAll(jsonData.item2);
        Map<String, dynamic> data = await dioClient.post(
          url: pendingFileSendUrl,
          options: await options(),
          formData: formData,
        );
      } catch (e) {
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<FileModel>> fetchMyFiles() async {
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: myFilesUrl,
        options: await options(),
      );
      if (data.isNotEmpty) {
        return data['data'] != null && data['data'] is List
            ? (data['data'] as List)
                .map((file) => FileModel.fromJson(file))
                .toList()
            : [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<FileDetailsModel?> viewMyFileDetails(int fileId) async {
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: viewMyFileUrl(fileId),
        options: await options(),
      );
      if (data.isNotEmpty) {
        return FileDetailsModel.fromJsonMy(data['data']);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<FileModel>> fetchActionReqFiles() async {
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: actionFilesUrl,
        options: await options(),
      );
      if (data.isNotEmpty) {
        return data['data'] != null && data['data'] is List
            ? (data['data'] as List)
                .map((file) => FileModel.fromJson(file))
                .toList()
            : [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<FileDetailsModel?> viewActionReqFileDetails(int fileId) async {
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: viewActionFileUrl(fileId),
        options: await options(),
      );
      if (data.isNotEmpty) {
        return FileDetailsModel.fromJsonMy(data['data']);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
