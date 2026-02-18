extension AssetPathExtension on String {
  String rootBundleAssetForWeb() {
    const assetsPrefix = 'assets/';
    if (startsWith(assetsPrefix)) {
      return substring(assetsPrefix.length);
    }
    return this;
  }
}

class AssetsConstants {
  AssetsConstants._();

  static const String logo = 'assets/logo.png';
  static const String icon = 'assets/icon.png';
  static const String cmduLogo = 'assets/CMDU.png';
  static const String govtLogo = 'assets/govt1.png';
  static const String fingerprint = 'assets/fingerprint.png';
    static const String chatBG = 'assets/chat_bg.png';
}
