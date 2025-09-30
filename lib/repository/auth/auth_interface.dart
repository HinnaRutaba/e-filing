import 'package:efiling_balochistan/config/network/network_base.dart';
import 'package:efiling_balochistan/models/token_model.dart';
import 'package:efiling_balochistan/models/user_model.dart';

abstract class AuthInterface extends NetworkBase {
  String get loginUrl => '${baseUrl}login';
  String meUrl(int desId) => '${baseUrl}me?userDesgID=$desId';
  String get changePasswordUrl => '${baseUrl}change-password';

  Future<TokenModel?> login(
    String username,
    String password,
  );

  Future<UserModel?> fetchCurrentUserDetails(int desId);

  Future<int?> fetchLoggedInUserId();

  Future<bool?> isLoggedIn();

  Future<void> logout();

  Future<void> changePassword(
      {required String currentPassword,
      required String newPassword,
      required String confirmPassword});
}
