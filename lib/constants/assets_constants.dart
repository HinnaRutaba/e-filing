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
}
