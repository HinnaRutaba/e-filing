import 'package:efiling_balochistan/config/network/network_base.dart';
import 'package:efiling_balochistan/controllers/summaries_controller.dart';
import 'package:efiling_balochistan/models/department/department_secretaries_model.dart';
import 'package:efiling_balochistan/models/summaries/create_summary_model.dart';
import 'package:efiling_balochistan/models/summaries/summaries_meta_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_details_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_model.dart';

abstract class SummariesInterface extends NetworkBase {
  //========================URLS=============================

  String summaryMetaUrl(int desId) =>
      '${baseUrl}summaries/meta?userDesgID=$desId';

  String fetchSummariesListUrl({
    required int desId,
    required SummarySubTab subTab,
    String? query,
  }) {
    final String url =
        '${baseUrl}summaries/inbox?userDesgID=$desId&tab=${subTab.filterName}';
    if (query != null && query.isNotEmpty) {
      return '$url&q=$query';
    }
    return url;
  }

  String summaryDetailsUrl({required int summaryId, required int desId}) =>
      '${baseUrl}summaries/$summaryId?userDesgID=$desId';

  String departmentSecretaryUrl({required int deptId, required int desId}) =>
      '${baseUrl}summaries/department-secretaries/$deptId?userDesgID=$desId';

  String get deoDraftSummaryUrl => '${baseUrl}summaries/store-draft';

  String deoUpdateDraftSummaryUrl(int summaryId) =>
      '${baseUrl}summaries/$summaryId/update-draft';

  String get secretaryStoreSummaryUrl => '${baseUrl}summaries/store';

  String deleteAttachmentUrl(int attachmentId, int desId) =>
      '${baseUrl}summaries/attachment/$attachmentId?userDesgID=$desId';

  //========================Functions=============================

  Future<SummariesMetaModel> fetchSummariesMeta({required int desId});

  Future<List<SummaryModel>> fetchSummariesList({
    required int desId,
    required SummarySubTab subTab,
    String? query,
  });

  Future<SummaryDetailsModel> fetchSummaryDetails({
    required int summaryId,
    required int desId,
  });

  Future<List<DepartmentSecretariesModel>> fetchDepartmentSecretaries({
    required int deptId,
    required int desId,
  });

  Future<void> deoStoreDraftSummary({
    required CreateSummaryModel createSummaryModel,
    required int desId,
  });

  Future<void> deoUpdateDraftSummary({
    required int summaryId,
    required CreateSummaryModel createSummaryModel,
    required int desId,
  });

  Future<void> secretaryStoreSummary({
    required CreateSummaryModel createSummaryModel,
    required int desId,
    required bool isDraft,
  });

  Future<void> deleteAttachment({
    required int attachmentId,
    required int desId,
  });
}
