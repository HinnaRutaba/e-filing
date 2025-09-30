import 'package:dio/dio.dart';
import 'package:efiling_balochistan/models/file_details_model.dart';
import 'package:efiling_balochistan/models/file_model.dart';
import 'package:efiling_balochistan/models/flag_model.dart';
import 'package:efiling_balochistan/models/forward_to.dart';
import 'package:efiling_balochistan/models/new_file_data_model.dart';
import 'package:efiling_balochistan/models/section_schema.dart';
import 'package:efiling_balochistan/repository/files/files_interface.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/add_file_flag_and_attachmention.dart';
import 'package:tuple/tuple.dart';

class FileRepo extends FilesInterface {
  @override
  Future<List<FileModel>> fetchPendingFiles(int? desId) async {
    if (desId == null) {
      throw "Designation id is required";
    }
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: pendingFilesUrl(desId),
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
  Future<FileDetailsModel?> viewPendingFileDetails(
      int fileId, int? desId) async {
    if (desId == null) {
      throw "Designation id is required";
    }
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: viewPendingFileUrl(fileId, desId),
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
  Future<String?> generateFileMovNumber(int? desId) async {
    try {
      if (desId == null) {
        throw "Designation id is required";
      }
      Map<String, dynamic> data = await dioClient.get(
        url: generateFileMovNumUrl(desId),
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
  Future<List<SectionModel>> getSections(int? desId) async {
    try {
      if (desId == null) {
        throw "Designation id is required";
      }
      Map<String, dynamic> data = await dioClient.get(
        url: forwardSectionUrl(desId),
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
  Future<List<ForwardToModel>> getForwardList(
      int? sectionId, int? desId) async {
    if (sectionId == null) {
      throw "Section id is required";
    }
    if (desId == null) {
      throw "Designation id is required";
    }
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: getForwardToUrl(sectionId, desId),
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
  Future<List<FlagModel>> getFlags(int? desId) async {
    if (desId == null) {
      throw "Designation id is required";
    }
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: getFlagsUrl(desId),
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
      required int designationId,
      required List<FlagAndAttachmentModel>? flags}) async {
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
        designationId: designationId,
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
  }

  @override
  Future<List<FileModel>> fetchMyFiles(int? desId) async {
    if (desId == null) {
      throw "Designation id is required";
    }
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: myFilesUrl(desId),
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
  Future<FileDetailsModel?> viewMyFileDetails(int fileId, int? desId) async {
    if (desId == null) {
      throw "Designation id is required";
    }
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: viewMyFileUrl(fileId, desId),
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
  Future<List<FileModel>> fetchActionReqFiles(int? desId) async {
    if (desId == null) {
      throw "Designation id is required";
    }
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: actionFilesUrl(desId),
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
  Future<FileDetailsModel?> viewActionReqFileDetails(
      int fileId, int? desId) async {
    if (desId == null) {
      throw "Designation id is required";
    }
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: viewActionFileUrl(fileId, desId),
        options: await options(),
      );
      if (data.isNotEmpty) {
        return FileDetailsModel.fromJsonActionReq(data['data']);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> submitAction(
      {required int fileId,
      required int userId,
      required String content,
      required int? forwardTo,
      required int choice,
      required int designationId,
      required List<FlagAndAttachmentModel>? flags}) async {
    try {
      try {
        Tuple2<Map<String, dynamic>, List<MapEntry<String, MultipartFile>>>
            jsonData = await FileContentModel.toSubmitJson(
          fileId: fileId,
          userId: userId,
          content: content,
          forwardTo: forwardTo,
          choice: choice,
          flags: flags,
          designationId: designationId,
        );
        FormData formData = FormData.fromMap(jsonData.item1);
        formData.files.addAll(jsonData.item2);
        Map<String, dynamic> data = await dioClient.post(
          url: submitActionUrl,
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
  Future<List<FileModel>> fetchForwardedFiles(int? desId) async {
    if (desId == null) {
      throw "Designation id is required";
    }
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: forwardedFilesUrl(desId),
        options: await options(),
      );
      if (data.isNotEmpty) {
        return data['forwarded_files'] != null &&
                data['forwarded_files'] is List
            ? (data['forwarded_files'] as List)
                .map((file) =>
                    FileModel.fromJson(file, status: FileStatus.reForwarded))
                .toList()
            : [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<FileDetailsModel?> viewForwardedFileDetails(
      int fileId, int? desId) async {
    if (desId == null) {
      throw "Designation id is required";
    }
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: viewForwardedFileUrl(fileId, desId),
        options: await options(),
      );
      if (data.isNotEmpty) {
        return FileDetailsModel.fromJsonForwardedFiles(data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<FileModel>> fetchArchivedFiles(int? desId) async {
    if (desId == null) {
      throw "Designation id is required";
    }
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: archivedFilesUrl(desId),
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
  Future<FileDetailsModel?> viewArchivedFileDetails(
      int fileId, int? desId) async {
    if (desId == null) {
      throw "Designation id is required";
    }
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: viewForwardedFileUrl(fileId, desId),
        options: await options(),
      );
      if (data.isNotEmpty) {
        return FileDetailsModel.fromJsonForwardedFiles(data['data']);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> reopenFile(
      {required int fileId,
      required int sectionId,
      required String content,
      required int forwardTo,
      required int designationId,
      required List<FlagAndAttachmentModel>? flags}) async {
    try {
      Tuple2<Map<String, dynamic>, List<MapEntry<String, MultipartFile>>>
          jsonData = await FileContentModel.toReopenJson(
        fileId: fileId,
        sectionId: sectionId,
        content: content,
        forwardTo: forwardTo,
        flags: flags,
        designationId: designationId,
      );
      FormData formData = FormData.fromMap(jsonData.item1);
      formData.files.addAll(jsonData.item2);
      Map<String, dynamic> data = await dioClient.post(
        url: reopenFileUrl,
        options: await options(),
        formData: formData,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<NewFileDataModel?> fetchCreateFileData(int? desId) async {
    if (desId == null) {
      throw "Designation id is required";
    }
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: newFileDataUrl(desId),
        options: await options(),
      );
      if (data.isNotEmpty) {
        return NewFileDataModel.fromJson(data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> createNewFile(
      {required String subject,
      required int fileType,
      required String content,
      required int forwardTo,
      required String fileMovNumber,
      required String refNumber,
      required String partFileNumber,
      required int tagId,
      required int designationId,
      required List<FlagAndAttachmentModel>? flags}) async {
    try {
      Tuple2<Map<String, dynamic>, List<MapEntry<String, MultipartFile>>>
          jsonData = await FileContentModel.toCreateFileJson(
        subject: subject,
        fileType: fileType,
        content: content,
        forwardTo: forwardTo,
        fileMovNumber: fileMovNumber,
        refNumber: refNumber,
        partFileNumber: partFileNumber,
        tagId: tagId,
        flags: flags,
        designationId: designationId,
      );
      FormData formData = FormData.fromMap(jsonData.item1);
      formData.files.addAll(jsonData.item2);
      Map<String, dynamic> data = await dioClient.post(
        url: createFileUrl,
        options: await options(),
        formData: formData,
      );
    } catch (e) {
      rethrow;
    }
  }
}
