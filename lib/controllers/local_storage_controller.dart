import 'dart:convert';

import 'package:efiling_balochistan/config/storage/local_storage.dart';
import 'package:efiling_balochistan/models/token_model.dart';
import 'package:efiling_balochistan/models/user_model.dart';

class LocalStorageController {
  Future setRememberLogin(bool remember) async {
    await LocalStorage.save(LocalStorageKeys.rememberLogin, remember);
  }

  Future<bool?> getRememberLogin() async {
    return await LocalStorage.get(LocalStorageKeys.rememberLogin) as bool?;
  }

  // Future setUserId(int userId) async {
  //   await LocalStorage.save(LocalStorageKeys.userId, userId);
  // }
  //
  // Future<int?> getUserId() async {
  //   return await LocalStorage.get(LocalStorageKeys.userId) as int?;
  // }
  //
  // Future<void> removeUserId() async {
  //   return await LocalStorage.remove(LocalStorageKeys.userId);
  // }

  Future setToken(TokenModel token) async {
    await LocalStorage.save(LocalStorageKeys.token, jsonEncode(token.toJson()));
  }

  Future<TokenModel?> getToken() async {
    String? tokenStr =
        await LocalStorage.get(LocalStorageKeys.token) as String?;
    if (tokenStr == null) return null;
    return TokenModel.fromJson(jsonDecode(tokenStr));
  }

  Future<void> removeToken() async {
    return await LocalStorage.remove(LocalStorageKeys.token);
  }

  Future setDesignation(DesignationModel designation) async {
    await LocalStorage.save(
        LocalStorageKeys.designation, jsonEncode(designation.toJson()));
  }

  Future<DesignationModel?> getDesignation() async {
    String? desStr =
        await LocalStorage.get(LocalStorageKeys.designation) as String?;
    if (desStr == null) return null;
    return DesignationModel.fromJson(jsonDecode(desStr));
  }

  Future<void> removeAll() async {
    return await LocalStorage.clear();
  }
}

class LocalStorageKeys {
  static const String rememberLogin = 'rememberLogin';
  static const String userId = 'user_id';
  static const String token = 'token';
  static const String designation = 'designation';
}
