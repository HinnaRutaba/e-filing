class VersionSyncModel {
  String? platform;
  String? latestVersion;
  String? minSupportedVersion;
  bool? forceUpdate;
  String? playStoreUrl;
  String? title;
  String? message;

  VersionSyncModel({
    this.platform,
    this.latestVersion,
    this.minSupportedVersion,
    this.forceUpdate,
    this.playStoreUrl,
    this.title,
    this.message,
  });

  factory VersionSyncModel.fromJson(Map<String, dynamic> json) {
    try {
      return VersionSyncModel(
        platform: json[VersionSyncSchema.platform],
        latestVersion: json[VersionSyncSchema.latestVersion]?.toString(),
        minSupportedVersion: json[VersionSyncSchema.minSupportedVersion]?.toString(),
        forceUpdate: json[VersionSyncSchema.forceUpdate],
        playStoreUrl: json[VersionSyncSchema.playStoreUrl],
        title: json[VersionSyncSchema.title],
        message: json[VersionSyncSchema.message],
      );
    } catch (e) {
    
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      VersionSyncSchema.platform: platform,
      VersionSyncSchema.latestVersion: latestVersion,
      VersionSyncSchema.minSupportedVersion: minSupportedVersion,
      VersionSyncSchema.forceUpdate: forceUpdate,
      VersionSyncSchema.playStoreUrl: playStoreUrl,
      VersionSyncSchema.title: title,
      VersionSyncSchema.message: message,
    };
  }
}

class VersionSyncSchema {
  static const String platform = 'platform';
  static const String latestVersion = 'latest_version';
  static const String minSupportedVersion = 'min_supported_version';
  static const String forceUpdate = 'force_update';
  static const String playStoreUrl = 'play_store_url';
  static const String title = 'title';
  static const String message = 'message';
}
