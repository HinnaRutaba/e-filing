import 'package:dio/dio.dart';
import 'package:efiling_balochistan/controllers/summaries_controller.dart';
import 'package:efiling_balochistan/models/department/department_secretaries_model.dart';
import 'package:efiling_balochistan/models/summaries/create_summary_model.dart';
import 'package:efiling_balochistan/models/summaries/summaries_meta_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_details_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_model.dart';
import 'package:efiling_balochistan/repository/summaries/summaries_interface.dart';
import 'package:tuple/tuple.dart';

class SummariesRepo extends SummariesInterface {
  @override
  Future<List<SummaryModel>> fetchSummariesList({
    required int? desId,
    required SummarySubTab subTab,
    String? query,
  }) async {
    try {
      if (desId == null) {
        throw Exception("Designation ID is required to fetch user details");
      }

      Map<String, dynamic> data = await dioClient.get(
        url: fetchSummariesListUrl(desId: desId, subTab: subTab, query: query),
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
  }) async{
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
}
