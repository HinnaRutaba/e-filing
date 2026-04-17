import 'package:efiling_balochistan/config/network/network_base.dart';
import 'package:efiling_balochistan/controllers/summaries_controller.dart';
import 'package:efiling_balochistan/models/summaries/summary_model.dart';

abstract class SummariesInterface extends NetworkBase {
  String fetchSummariesListUrl({
    required int desId,
    required SummarySubTab subTab,
    String? query,
  }) {
    final String url =  '${baseUrl}summaries/inbox?userDesgID=$desId&tab=${subTab.filterName}';
    if(query != null && query.isNotEmpty) {
      return '$url&q=$query';
    }
    return url;
  }


  Future<List<SummaryModel>> fetchSummariesList({
    required int desId,
    required SummarySubTab subTab,
    String? query,
  });
}
