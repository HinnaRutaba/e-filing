import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:efiling_balochistan/models/daak_meta_model.dart';
import 'package:efiling_balochistan/models/daak_model.dart';
import 'package:efiling_balochistan/repository/daak/daak_interface.dart';
import 'package:image_picker/image_picker.dart';

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

      log("INBOX____${daakInboxUrl(desId: desId, status: status, query: query)}");

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

      log("FWD HISTORY____${daakForwardedHistoryUrl(desId: desId, status: status, query: query)}");

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
          .map((e) => DaakModel.fromFwdJson(e))
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

      log("MY NFA____${daakMyNfaUrl(desId: desId, status: status, query: query)}");

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

  @override
  Future<DaakModel?> fetchDaakFwdShow(
      {required int? daakId, required int? desId}) async {
    try {
      if (desId == null) {
        throw Exception("Designation ID is required to fetch user details");
      }
      if (daakId == null) {
        throw Exception("Daak ID is required to fetch daak details");
      }

      Map<String, dynamic> data = await dioClient.get(
        url: daakFwdShowUrl(daakId!, desId),
        options: await options(authRequired: true),
      );
      return DaakModel.fromDetails(data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DaakModel?> fetchDaakInboxShow(
      {required int? daakId, required int? desId}) async {
    try {
      if (desId == null) {
        throw Exception("Designation ID is required to fetch user details");
      }

      if (daakId == null) {
        throw Exception("Daak ID is required to fetch daak details");
      }

      Map<String, dynamic> data = await dioClient.get(
        url: daakInboxShowUrl(daakId, desId),
        options: await options(authRequired: true),
      );
      return DaakModel.fromDetails(data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> forwardDaak(
      {required int? daakId,
      required int? fwdToDesId,
      required int? desId,
      String? remarks,
      XFile? supportingAttachment}) async {
    try {
      if (desId == null) {
        throw Exception("Designation ID is required to fetch user details");
      }
      if (daakId == null) {
        throw Exception("Daak ID is required to fetch daak details");
      }
      if (fwdToDesId == null) {
        throw Exception(
            "Forward To Designation ID is required to fetch daak details");
      }
      final Map<String, dynamic> json = {
        'userDesgID': desId,
        'forward_to_user_desg_id': fwdToDesId,
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
      };

      final FormData formData = FormData.fromMap(json);

      if (supportingAttachment != null) {
        formData.files.add(
          MapEntry(
            'supporting_attachments',
            await MultipartFile.fromFile(
              supportingAttachment.path,
              filename: supportingAttachment.name,
            ),
          ),
        );
      }

      await dioClient.post(
        url: daakFwdUrl(daakId),
        options: await options(authRequired: true),
        formData: formData,
      );
    } catch (e) {
      rethrow;
    }
  }
}
