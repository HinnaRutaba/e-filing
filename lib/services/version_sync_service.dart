import 'dart:io';

import 'package:efiling_balochistan/config/router/app_router.dart';
import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/models/version_sync_model.dart';
import 'package:efiling_balochistan/repository/version_sync_repo.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionSyncService {
  static final String _appStoreUrl =
      "https://apps.apple.com/pk/app/balochistan-e-filing-system/id6758300893Balochistan E-Filing System";
  static final String _playStoreUrl =
      "https://play.google.com/store/apps/details?id=com.lrm.efiling_balochistan&pcampaignid=web_share";

  static final VersionSyncService _instance = VersionSyncService._internal();

  factory VersionSyncService() {
    return _instance;
  }

  VersionSyncService._internal();

  VersionSyncModel? _versionSyncModel;
  double? _currentAppVersion;

  VersionSyncModel? get versionSyncModel => _versionSyncModel;
  double? get currentAppVersion => _currentAppVersion;

  set versionSyncModel(VersionSyncModel? model) {
    _versionSyncModel = model;
  }

  set currentAppVersion(double? version) {
    _currentAppVersion = version;
  }

  VersionSyncRepo _versionSyncRepo = VersionSyncRepo();

  Future<void> fetchVersionSync() async {
    try {
      versionSyncModel = await _versionSyncRepo.getSyncVersion();
    } catch (e) {
      rethrow;
    }
  }

  Future<double?> getCurrentAppVersion() async {
    try {
      String versionStr = await getAppVersionString();
      currentAppVersion = _parseVersion(versionStr);
      return currentAppVersion;
    } catch (e, s) {
      rethrow;
    }
  }

  Future<String> getAppVersionString() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      rethrow;
    }
  }

  double _parseVersion(String versionStr) {
    final parts = versionStr.split('.');
    double version = 0;
    for (int i = 0; i < parts.length; i++) {
      final part = int.tryParse(parts[i]) ?? 0;
      version += part / (i == 0 ? 1 : (100.0 * i));
    }
    return version;
  }

  Future<bool> isAppVersionOutdated() async {
    if (versionSyncModel == null) {
      await fetchVersionSync();
    }
    if (currentAppVersion == null) {
      await getCurrentAppVersion();
    }
    if (versionSyncModel != null && versionSyncModel!.latestVersion != null) {
      return currentAppVersion! <
          _parseVersion(_versionSyncModel!.latestVersion!);
    }
    return false;
  }

  Future<bool> showUpdateDialog() async {
    final BuildContext? context = AppRouter.navigatorKey.currentContext;
    if (context == null) return false;

    final bool isOutdated = await isAppVersionOutdated();

    print(
        "IS OUTDATED______${isOutdated}_____${currentAppVersion}____${versionSyncModel?.latestVersion}");

    if (!isOutdated) return false;

    final title = versionSyncModel?.title ?? "Update Available";
    final message = versionSyncModel?.message ??
        "A new version of the app is available. Please update to continue.";

    showDialog(
      context: context,
      barrierDismissible: !(versionSyncModel?.forceUpdate ?? false),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: AppColors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.system_update,
                  size: 48,
                  color: AppColors.primaryDark,
                ),
                const SizedBox(height: 16),
                AppText.headlineSmall(title),
                const SizedBox(height: 8),
                AppText.bodyMedium(
                  message,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AppSolidButton(
                  onPressed: () async {
                    final String url = Platform.isIOS
                        ? versionSyncModel?.playStoreUrl ?? _appStoreUrl
                        : versionSyncModel?.playStoreUrl ?? _playStoreUrl;

                    await launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
                  },
                  text: "Update Now",
                  width: double.infinity,
                ),
                if (!(versionSyncModel?.forceUpdate ?? false)) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      RouteHelper.pop();
                    },
                    child: AppText.bodyMedium("Later"),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
    return true;
  }
}
