import 'dart:io';

import 'package:efiling_balochistan/config/network/network_base.dart';
import 'package:efiling_balochistan/models/version_sync_model.dart';

class VersionSyncRepo extends NetworkBase {
  String versionSyncUrl(String platform) =>
      '${baseUrl}app/version?platform=$platform';

  Future<VersionSyncModel> getSyncVersion() async {
    try {
      String platform = Platform.isIOS ? 'ios' : 'android';
      Map<String, dynamic> data = await dioClient.get(
        url: versionSyncUrl(platform),
        options: await options(authRequired: false),
      );
      return VersionSyncModel.fromJson(data['data']);
    } catch (e) {
      rethrow;
    }
  }
}
