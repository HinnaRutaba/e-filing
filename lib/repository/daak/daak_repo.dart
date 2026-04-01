import 'dart:developer';

import 'package:efiling_balochistan/models/daak_meta_model.dart';
import 'package:efiling_balochistan/models/daak_model.dart';
import 'package:efiling_balochistan/repository/daak/daak_interface.dart';

class DaakRepo extends DaakInterface {
  @override
  Future<DaakMeta> fetchDaakMeta(int? desId) async {
    try {
      if (desId == null) {
        throw Exception("Designation ID is required to fetch user details");
      }

      Map<String, dynamic> data = await dioClient.get(
        url: metaUrl(desId),
        options: await options(authRequired: true),
      );
      log("META DETAILS_________${data}");
      return DaakMeta.fromJson(data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<DaakModel>> fetchDaakInbox(
      {required int? desId, DaakStatus? status, String? query}) async {
    try {
      if (desId == null) {
        throw Exception("Designation ID is required to fetch user details");
      }

      Map<String, dynamic> data = await dioClient.get(
        url: daakInboxUrl(desId: desId, status: status, query: query),
        options: await options(authRequired: true),
      );
      log("INBOX DAAK DETAILS_________${data}");
      if (data['data'] == null || data['data']['items'] == null) {
        return [];
      }
      return (data['data']['items'] as List)
          .map((e) => DaakModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<DaakModel>> fetchDaakForwardedHistory(
      {required int? desId, DaakStatus? status, String? query}) async {
    try {
      if (desId == null) {
        throw Exception("Designation ID is required to fetch user details");
      }

      Map<String, dynamic> data = await dioClient.get(
        url:
            daakForwardedHistoryUrl(desId: desId, status: status, query: query),
        options: await options(authRequired: true),
      );
      log("FWD DAAK DETAILS_________${data}");
      if (data['data'] == null || data['data']['items'] == null) {
        return [];
      }
      return (data['data']['items'] as List)
          .map((e) => DaakModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<DaakModel>> fetchDaakMyNfa(
      {required int? desId, DaakStatus? status, String? query}) async {
    try {
      if (desId == null) {
        throw Exception("Designation ID is required to fetch user details");
      }

      Map<String, dynamic> data = await dioClient.get(
        url: daakMyNfaUrl(desId: desId, status: status, query: query),
        options: await options(authRequired: true),
      );
      log("MY NFA DAAK DETAILS_________${data}");
      if (data['data'] == null || data['data']['items'] == null) {
        return [];
      }
      return (data['data']['items'] as List)
          .map((e) => DaakModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
