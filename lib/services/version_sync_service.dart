import 'dart:developer';
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
      "https://apps.apple.com/pk/app/balochistan-e-filing-system/id6758300893";
  static final String _playStoreUrl =
      "https://play.google.com/store/apps/details?id=com.lrm.efiling_balochistan&pcampaignid=web_share";

  static final VersionSyncService _instance = VersionSyncService._internal();

  factory VersionSyncService() {
    return _instance;
  }

  VersionSyncService._internal();

  VersionSyncModel? _versionSyncModel;

  VersionSyncModel? get versionSyncModel => _versionSyncModel;

  set versionSyncModel(VersionSyncModel? model) {
    _versionSyncModel = model;
  }

  VersionSyncRepo _versionSyncRepo = VersionSyncRepo();

  Future<void> fetchVersionSync() async {
    try {
      versionSyncModel = await _versionSyncRepo.getSyncVersion();
    } catch (e) {
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

  /// Compares two semantic version strings
  /// Returns: -1 if version1 < version2, 0 if equal, 1 if version1 > version2
  int _compareVersions(String version1, String version2) {
    final parts1 = version1
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    final parts2 = version2
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    // Pad with zeros to match length
    final maxLength = (parts1.length > parts2.length)
        ? parts1.length
        : parts2.length;
    while (parts1.length < maxLength) parts1.add(0);
    while (parts2.length < maxLength) parts2.add(0);

    // Compare each part
    for (int i = 0; i < maxLength; i++) {
      if (parts1[i] < parts2[i]) return -1;
      if (parts1[i] > parts2[i]) return 1;
    }
    return 0;
  }

  Future<bool> isAppVersionOutdated() async {
    if (versionSyncModel == null) {
      await fetchVersionSync();
    }
    if (versionSyncModel != null && versionSyncModel!.latestVersion != null) {
      final currentVersion = await getAppVersionString();
      return _compareVersions(
            currentVersion,
            _versionSyncModel!.latestVersion!,
          ) <
          0;
    }
    return false;
  }

  Future<bool> showUpdateDialog() async {
    final BuildContext? context = AppRouter.navigatorKey.currentContext;
    if (context == null) return false;

    final bool isOutdated = await isAppVersionOutdated();

    if (!isOutdated) return true;

    final title = versionSyncModel?.title ?? "Update Available";
    final message =
        versionSyncModel?.message ??
        "A new version of the app is available. Please update to continue.";

    if (!context.mounted) return true;

    return await showDialog(
      context: context,
      barrierDismissible: false,
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
                AppText.bodyMedium(message, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                AppSolidButton(
                  onPressed: () async {
                    final String url = Platform.isIOS
                        ? _appStoreUrl
                        : _playStoreUrl;

                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  text: "Update Now",
                  width: double.infinity,
                ),
                if (!(versionSyncModel?.forceUpdate ?? false)) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      RouteHelper.pop(true);
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
  }
}
