import 'package:dio/dio.dart';
import 'package:efiling_balochistan/models/department/department_secretaries_model.dart';
import 'package:efiling_balochistan/models/summaries/create_summary_model.dart';
import 'package:efiling_balochistan/models/summaries/draft_remarks_model.dart';
import 'package:efiling_balochistan/models/summaries/summaries_meta_model.dart';
import 'package:efiling_balochistan/models/summaries/sign_forward_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_daak_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_details_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_file_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_model.dart';
import 'package:efiling_balochistan/repository/summaries/summaries_interface.dart';
import 'package:tuple/tuple.dart';

class SummariesRepo extends SummariesInterface {
  @override
  Future<List<SummaryModel>> fetchSummariesList({
    required int? desId,
    required String filterName,
    String? query,
  }) async {
    try {
      if (desId == null) {
        throw Exception("Designation ID is required to fetch user details");
      }

      Map<String, dynamic> data = await dioClient.get(
        url: fetchSummariesListUrl(
          desId: desId,
          filterName: filterName,
          query: query,
        ),
        options: await options(authRequired: true),
      );
      if (data['data'] == null || data['data']['items'] == null) {
        return [];
      }
      return (data['data']['items'] as List)
          .map((e) => SummaryModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SummaryDetailsModel> fetchSummaryDetails({
    required int? summaryId,
    required int? desId,
  }) async {
    try {
      if (desId == null) {
        throw Exception("Designation ID is required to fetch user details");
      }

      if (summaryId == null) {
        throw Exception("Summary ID is required to fetch summary details");
      }

      Map<String, dynamic> data = await dioClient.get(
        url: summaryDetailsUrl(summaryId: summaryId, desId: desId),
        options: await options(authRequired: true),
      );
      return SummaryDetailsModel.fromJson(data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SummariesMetaModel> fetchSummariesMeta({required int? desId}) async {
    try {
      if (desId == null) {
        throw Exception("Designation ID is required to fetch user details");
      }
      Map<String, dynamic> data = await dioClient.get(
        url: summaryMetaUrl(desId),
        options: await options(authRequired: true),
      );
      return SummariesMetaModel.fromJson(data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<DepartmentSecretariesModel>> fetchDepartmentSecretaries({
    required int? deptId,
    required int? desId,
  }) async {
    try {
      if (desId == null) {
        throw Exception("Designation ID is required to fetch user details");
      }

      if (deptId == null) {
        throw Exception(
          "Department ID is required to fetch department secretaries",
        );
      }

      Map<String, dynamic> data = await dioClient.get(
        url: departmentSecretaryUrl(deptId: deptId, desId: desId),
        options: await options(authRequired: true),
      );
      if (data['data'] == null) {
        return [];
      }
      return (data['data'] as List)
          .map((e) => DepartmentSecretariesModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deoStoreDraftSummary({
    required CreateSummaryModel createSummaryModel,
    required int? desId,
  }) async {
    try {
      if (desId == null) {
        throw Exception("Designation ID is required to fetch user details");
      }
      Tuple2<Map<String, dynamic>, List<MapEntry<String, MultipartFile>>>
      jsonData = await createSummaryModel.toJson(
        userDesgId: desId,
        saveAsDraft: true,
      );
      FormData formData = FormData.fromMap(jsonData.item1);
      formData.files.addAll(jsonData.item2);
      await dioClient.post(
        url: deoDraftSummaryUrl,
        options: await options(authRequired: true),
        formData: formData,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deoUpdateDraftSummary({
    required int? summaryId,
    required CreateSummaryModel createSummaryModel,
    required int? desId,
  }) async {
    try {
      if (desId == null) {
        throw Exception("Designation ID is required to fetch user details");
      }
      if (summaryId == null) {
        throw Exception("Summary ID is required to update draft summary");
      }
      Tuple2<Map<String, dynamic>, List<MapEntry<String, MultipartFile>>>
      jsonData = await createSummaryModel.toJson(
        userDesgId: desId,
        saveAsDraft: true,
      );
      FormData formData = FormData.fromMap(jsonData.item1);
      formData.files.addAll(jsonData.item2);
      await dioClient.post(
        url: deoUpdateDraftSummaryUrl(summaryId),
        options: await options(authRequired: true),
        formData: formData,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> secretaryStoreSummary({
    required CreateSummaryModel createSummaryModel,
    required int? desId,
    required bool isDraft,
  }) async {
    try {
      if (desId == null) {
        throw Exception("Designation ID is required to fetch user details");
      }
      Tuple2<Map<String, dynamic>, List<MapEntry<String, MultipartFile>>>
      jsonData = await createSummaryModel.toJson(
        userDesgId: desId,
        saveAsDraft: isDraft,
      );
      FormData formData = FormData.fromMap(jsonData.item1);
      formData.files.addAll(jsonData.item2);
      await dioClient.post(
        url: secretaryStoreSummaryUrl,
        options: await options(authRequired: true),
        formData: formData,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAttachment({
    required int? attachmentId,
    required int? desId,
  }) async {
    try {
      if (attachmentId == null) {
        throw Exception("Attachment ID is required to delete attachment");
      }
      if (desId == null) {
        throw Exception("Designation ID is required to delete attachment");
      }
      await dioClient.delete(
        url: deleteAttachmentUrl(attachmentId, desId),
        options: await options(authRequired: true),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> returnToSection({
    required int? summaryId,
    required String? remark,
    required int? desId,
  }) async {
    try {
      if (summaryId == null) {
        throw Exception("Summary ID is required to return summary to section");
      }
      if (desId == null) {
        throw Exception(
          "Designation ID is required to return summary to section",
        );
      }
      await dioClient.post(
        url: returnToSectionUrl(summaryId),
        options: await options(authRequired: true),
        data: {"return_remarks": remark, "userDesgID": desId},
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> submitDraftRemarks({required DraftRemarksModel model}) async {
    try {
      final jsonData = await model.toJson();
      final formData = FormData.fromMap(jsonData.item1);
      formData.files.addAll(jsonData.item2);
      await dioClient.post(
        url: submitRemarksUrl(model.summaryId),
        options: await options(authRequired: true),
        formData: formData,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> shareInternally({
    required int? summaryId,
    required String instruction,
    required int? desId,
    required List<int>? recipientDesIds,
  }) async {
    try {
      if (summaryId == null) {
        throw Exception("Summary ID is required to share summary internally");
      }
      if (desId == null) {
        throw Exception(
          "Designation ID is required to share summary internally",
        );
      }
      if (recipientDesIds == null || recipientDesIds.isEmpty) {
        throw Exception(
          "At least one recipient designation ID is required to share summary internally",
        );
      }
      final Map<String, dynamic> data = {
        "instruction": instruction,
        "userDesgID": desId,
        "user_desg_ids": recipientDesIds,
      };

      await dioClient.post(
        url: shareInternallyUrl(summaryId),
        options: (await options(authRequired: true))
          ..contentType = Headers.jsonContentType,
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateDraftContent({
    required int? summaryId,
    required String? body,
    required int? desId,
  }) async {
    try {
      if (summaryId == null) {
        throw Exception("Summary ID is required to update draft content");
      }
      if (desId == null) {
        throw Exception("Designation ID is required to update draft content");
      }
      await dioClient.post(
        url: updateDraftContentUrl(summaryId),
        options: await options(authRequired: true),
        data: {"body": body, "userDesgID": desId},
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SummaryDaakModel>> searchDaaks({
    required int? desId,
    String? query,
  }) async {
    try {
      if (desId == null) {
        throw Exception("Designation ID is required to search daaks");
      }
      Map<String, dynamic> data = await dioClient.get(
        url: searchDaaksUrl(desId: desId, query: query),
        options: await options(authRequired: true),
      );
      if (data['data'] == null) {
        return [];
      }
      return (data['data'] as List)
          .map((e) => SummaryDaakModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SummaryFileModel>> searchFiles({
    required int? desId,
    String? query,
  }) async {
    try {
      if (desId == null) {
        throw Exception("Designation ID is required to search files");
      }
      Map<String, dynamic> data = await dioClient.get(
        url: searchFilesUrl(desId: desId, query: query),
        options: await options(authRequired: true),
      );
      if (data['data'] == null) {
        return [];
      }
      return (data['data'] as List)
          .map((e) => SummaryFileModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String?> saveSignForFwd({
    required int? summaryId,
    required int? desId,
    required String signatureBase64,
  }) async {
    try {
      if (summaryId == null) {
        throw Exception('Summary ID is required to save signature');
      }
      if (desId == null) {
        throw Exception('Designation ID is required to save signature');
      }
      final Map<String, dynamic> data = await dioClient.post(
        url: saveSignForFwdUrl(summaryId),
        options: await options(authRequired: true),
        data: {'userDesgID': desId, 'signature': signatureBase64},
      );
      return data['path'] as String?;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signAndForward({
    required int? summaryId,
    required int? desId,
    required SignForwardModel payload,
  }) async {
    try {
      if (summaryId == null) {
        throw Exception('Summary ID is required to sign and forward');
      }
      if (desId == null) {
        throw Exception('Designation ID is required to sign and forward');
      }
      await dioClient.post(
        url: forwardToDepartmentUrl(summaryId),
        options: await options(authRequired: true),
        data: payload.toJson(desId),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> disposeOffSummary({
    required int? summaryId,
    required String instruction,
    required int? desId,
  }) async {
    try {
      if (summaryId == null) {
        throw Exception('Summary ID is required to dispose off');
      }
      if (desId == null) {
        throw Exception('Designation ID is required to dispose off');
      }
      await dioClient.post(
        url: disposeOffSummaryUrl(summaryId),
        options: await options(authRequired: true),
        data: {
          'userDesgID': desId,
          if (instruction.isNotEmpty) 'remarks': instruction,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> submitInternalRemarks({
    required CreateSummaryModel createSummaryModel,
    required int? desId,
    required int? summaryId,
  }) async {
    try {
      if (desId == null) {
        throw Exception("Designation ID is required to fetch user details");
      }
      if (summaryId == null) {
        throw Exception("Summary ID is required to fetch user details");
      }
      Tuple2<Map<String, dynamic>, List<MapEntry<String, MultipartFile>>>
      jsonData = await createSummaryModel.toJson(
        userDesgId: desId,
        saveAsDraft: true,
      );
      FormData formData = FormData.fromMap(jsonData.item1);
      formData.files.addAll(jsonData.item2);
      await dioClient.post(
        url: returnToSectionUrl(summaryId),
        options: await options(authRequired: true),
        formData: formData,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> forwardToCM({
    required int? summaryId,
    required int? desgId,
  }) async {
    try {
      if (summaryId == null) {
        throw Exception('Summary ID is required to forward to CM');
      }
      if (desgId == null) {
        throw Exception('Designation ID is required to forward to CM');
      }
      await dioClient.post(
        url: forwardToCMUrl(summaryId),
        options: await options(authRequired: true),
        data: {'userDesgID': desgId},
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> psToSectForward({
    required int summaryId,
    required int desgId,
  }) async {
    try {
      await dioClient.post(
        url: forwardPsToSectUrl(summaryId),
        options: await options(authRequired: true),
        data: {'userDesgID': desgId},
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signAndReturnCM({
    required int summaryId,
    required int desgId,
    required SignForwardModel payload,
  }) async {
    try {
      await dioClient.post(
        url: cmSignAndReturnUrl(summaryId),
        options: await options(authRequired: true),
        data: payload.toJson(desgId),
      );
    } catch (e) {
      rethrow;
    }
  }
}
