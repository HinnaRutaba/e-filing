import 'package:efiling_balochistan/config/storage/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.light) {
    _load();
  }

  static const _key = 'theme_mode';

  Future<void> _load() async {
    final raw = await LocalStorage.get(_key);
    if (raw is String) {
      state = ThemeMode.values.firstWhere(
        (m) => m.name == raw,
        orElse: () => ThemeMode.light,
      );
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await LocalStorage.save(_key, mode.name);
  }

  Future<void> toggle() {
    return setMode(
      state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}
