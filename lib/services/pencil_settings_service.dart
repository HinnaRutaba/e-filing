import 'package:flutter/services.dart';

class PencilSettingsService {
  static const _channel = MethodChannel('com.efiling.pencil_settings');

  /// Returns true only on iPad when the system "Only Draw with Apple Pencil"
  /// setting is enabled (iOS 14+). Always returns false on iPhone or older OS.
  static Future<bool> isPencilOnlyDrawingEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'isPencilOnlyDrawingEnabled',
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
