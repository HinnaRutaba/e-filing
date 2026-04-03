import 'package:efiling_balochistan/config/network/network_base.dart';
import 'package:efiling_balochistan/models/daak_meta_model.dart';
import 'package:efiling_balochistan/models/daak_model.dart';
import 'package:image_picker/image_picker.dart';

abstract class DaakInterface extends NetworkBase {
  String metaUrl(int desId) => '${baseUrl}daak/meta?userDesgID=$desId';

  String daakInboxUrl({required int desId, DaakStatus? status, String? query}) {
    String url = '${baseUrl}daak/inbox?userDesgID=$desId';
    if (status != null) {
      url += '&status=${status.value}';
    }
    if (query != null && query.isNotEmpty) {
      url += '&q=$query';
    }
    return url;
  }

  String daakMyNfaUrl({required int desId, DaakStatus? status, String? query}) {
    String url = '${baseUrl}daak/my-nfa?userDesgID=$desId';
    if (status != null) {
      url += '&status=${status.value}';
    }
    if (query != null && query.isNotEmpty) {
      url += '&q=$query';
    }
    return url;
  }

  String daakForwardedHistoryUrl(
      {required int desId, DaakStatus? status, String? query}) {
    String url = '${baseUrl}daak/forwarded-history?userDesgID=$desId';
    if (status != null) {
      url += '&status=${status.value}';
    }
    if (query != null && query.isNotEmpty) {
      url += '&q=$query';
    }
    return url;
  }

  String daakInboxShowUrl(int daakId, int desId) =>
      '${baseUrl}daak/inbox/$daakId?userDesgID=$desId';

  String daakFwdShowUrl(int daakId, int desId) =>
      '${baseUrl}daak/forwarded-history/$daakId?userDesgID=$desId';

  String daakFwdUrl(int daakId) => '${baseUrl}daak/$daakId/forward';

    String daakFwdSecretaryUrl(int daakId) => '${baseUrl}daak/$daakId/secretary-return';

  Future<DaakMeta> fetchDaakMeta(int? desId);

  Future<List<DaakModel>> fetchDaakInbox(
      {required int? desId, DaakStatus? status, String? query});

  Future<List<DaakModel>> fetchDaakMyNfa(
      {required int? desId, DaakStatus? status, String? query});

  Future<List<DaakModel>> fetchDaakForwardedHistory(
      {required int? desId, DaakStatus? status, String? query});

  Future<DaakModel?> fetchDaakInboxShow(
      {required int daakId, required int desId});

  Future<DaakModel?> fetchDaakFwdShow(
      {required int daakId, required int desId});

  Future<void> forwardDaak({
    required int daakId,
    required int fwdToDesId,
    required int desId,
    String? remarks,
    XFile? supportingAttachment,
  });

  Future<void> forwardDaakSecretary({
    required int daakId,
    required int returnToDesId,
    required int desId,
    String? remarks,
    XFile? supportingAttachment,
  });
}
