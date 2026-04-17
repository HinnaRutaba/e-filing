import 'package:efiling_balochistan/controllers/summaries_controller.dart';
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
}
