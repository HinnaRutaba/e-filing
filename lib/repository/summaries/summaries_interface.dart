import 'package:efiling_balochistan/config/network/network_base.dart';
import 'package:efiling_balochistan/models/department/department_secretaries_model.dart';
import 'package:efiling_balochistan/models/summaries/create_summary_model.dart';
import 'package:efiling_balochistan/models/summaries/summaries_meta_model.dart';
import 'package:efiling_balochistan/models/summaries/sign_forward_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_daak_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_details_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_file_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_model.dart';

abstract class SummariesInterface extends NetworkBase {
  //========================URLS=============================

  String summaryMetaUrl(int desId) =>
      '${baseUrl}summaries/meta?userDesgID=$desId';

  String fetchSummariesListUrl({
    required int desId,
    required String filterName,
    String? query,
  }) {
    final String url =
        '${baseUrl}summaries/inbox?userDesgID=$desId&tab=$filterName';
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

  String updateDraftContentUrl(int summaryId) =>
      '${baseUrl}summaries/$summaryId/update-draft-content';

  String returnToSectionUrl(int summaryId) =>
      '${baseUrl}summaries/$summaryId/return-to-section';

  String shareInternallyUrl(int summaryId) =>
      '${baseUrl}summaries/$summaryId/share-internally';

  String searchDaaksUrl({required int desId, String? query}) {
    final String url = '${baseUrl}summaries/search-daak?userDesgID=$desId';
    if (query != null && query.isNotEmpty) {
      return '$url&q=$query';
    }
    return url;
  }

  String searchFilesUrl({required int desId, String? query}) {
    final String url = '${baseUrl}summaries/search-files?userDesgID=$desId';
    if (query != null && query.isNotEmpty) {
      return '$url&q=$query';
    }
    return url;
  }

  String saveSignForFwdUrl(int summaryId) =>
      '${baseUrl}summaries/$summaryId/sign';

  String forwardToDepartmentUrl(int summaryId) =>
      '${baseUrl}summaries/$summaryId/forward';

  String submitRemarksUrl(int summaryId) =>
      '${baseUrl}summaries/$summaryId/submit-internal-action';    

  //========================Functions=============================

  Future<SummariesMetaModel> fetchSummariesMeta({required int desId});

  Future<List<SummaryModel>> fetchSummariesList({
    required int desId,
    required String filterName,
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

  Future<void> updateDraftContent({
    required int summaryId,
    required String body,
    required int desId,
  });

  Future<void> returnToSection({
    required int summaryId,
    required String remark,
    required int desId,
  });

  Future<void> shareInternally({
    required int summaryId,
    required String instruction,
    required int desId,
    required List<int> recipientDesIds,
  });

  Future<List<SummaryDaakModel>> searchDaaks({
    required int desId,
    String? query,
  });

  Future<List<SummaryFileModel>> searchFiles({
    required int desId,
    String? query,
  });

  Future<String?> saveSignForFwd({
    required int summaryId,
    required int desId,
    required String signatureBase64,
  });

  Future<void> signAndForward({
    required int summaryId,
    required int desId,
    required SignForwardModel payload,
  });

    Future<void> submitInternalRemarks({
    required CreateSummaryModel createSummaryModel,
    required int desId,
    required int summaryId,
  });
}
