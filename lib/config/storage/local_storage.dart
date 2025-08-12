import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage._();

  static Future<void> save(String key, Object value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is String) {
      prefs.setString(key, value);
    } else if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is int) {
      prefs.setInt(key, value);
    } else if (value is double) {
      prefs.setDouble(key, value);
    } else if (value is List<String>) {
      prefs.setStringList(key, value);
    } else {
      throw Exception('Type not supported');
    }
  }

  static Future<Object?> get(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  static Future<void> remove(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  static Future<void> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
