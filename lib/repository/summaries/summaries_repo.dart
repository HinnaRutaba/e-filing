import 'package:efiling_balochistan/controllers/summaries_controller.dart';
import 'package:efiling_balochistan/models/summaries/summaries_meta_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_details_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_model.dart';
import 'package:efiling_balochistan/repository/summaries/summaries_interface.dart';

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
  Future<SummaryDetailsModel> fetchSummaryDetails({required int? summaryId, required int? desId}) async {
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
  Future<SummariesMetaModel> fetchSummariesMeta({required int desId}) async {
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: summaryMetaUrl(desId),
        options: await options(authRequired: true),
      );
      return SummariesMetaModel.fromJson(data['data']);
    } catch (e) {
      rethrow;
    }
  }
}
