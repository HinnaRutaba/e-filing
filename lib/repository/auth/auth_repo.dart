import 'package:efiling_balochistan/controllers/local_storage_controller.dart';
import 'package:efiling_balochistan/models/token_model.dart';
import 'package:efiling_balochistan/models/user_model.dart';
import 'package:efiling_balochistan/repository/auth/auth_interface.dart';

class AuthRepo extends AuthInterface {
  final LocalStorageController localStorage = LocalStorageController();

  @override
  Future<int?> fetchLoggedInUserId() async {
    try {
      TokenModel? tokenModel = await localStorage.getToken();
      return tokenModel?.user?.id;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool?> isLoggedIn() async {
    try {
      int? id = await fetchLoggedInUserId();
      return id != null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel?> fetchCurrentUserDetails(int? desId) async {
    try {
      if (desId == null) {
        throw Exception("Designation ID is required to fetch user details");
      }
      // TokenModel? tokenModel = await localStorage.getToken();
      // return tokenModel?.user;
      // int? userId = await fetchLoggedInUserId();
      // if (userId == null) {
      //   throw Exception("User is not logged in");
      // }
      Map<String, dynamic> data = await dioClient.get(
        url: meUrl(desId),
        options: await options(authRequired: true),
      );
      return UserModel.fromJson(data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TokenModel?> login(String username, String password) async {
    try {
      Map<String, dynamic> data = await dioClient.post(
        url: loginUrl,
        options: await options(authRequired: false),
        data: {
          UserSchema.username: username,
          UserSchema.password: password,
        },
      );
      if (data.isNotEmpty) {
        return TokenModel.fromJson(data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await localStorage.removeAll();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> changePassword(
      {required String currentPassword,
      required String newPassword,
      required String confirmPassword}) async {
    try {
      Map<String, dynamic> data = await dioClient.post(
        url: changePasswordUrl,
        options: await options(authRequired: false),
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> getOpenAIKey() async {
    try {
      Map<String, dynamic> data = await dioClient.get(
        url: openAIKey,
        options: await options(authRequired: true),
      );
      return data['openai_key'] ?? '';
    } catch (e) {
      rethrow;
    }
  }
}
