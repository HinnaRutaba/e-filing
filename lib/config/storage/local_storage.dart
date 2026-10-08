import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure key-value storage. Values are JSON-encoded so that the original
/// type (String, bool, int, double, List<String>) is preserved on read.
class LocalStorage {
  LocalStorage._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> save(String key, Object value) async {
    if (value is! String &&
        value is! bool &&
        value is! int &&
        value is! double &&
        value is! List<String>) {
      throw Exception('Type not supported');
    }
    await _storage.write(key: key, value: jsonEncode(value));
  }

  static Future<Object?> get(String key) async {
    final raw = await _storage.read(key: key);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is List) return decoded.cast<String>();
    return decoded;
  }

  static Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
