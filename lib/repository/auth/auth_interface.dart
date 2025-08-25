import 'package:efiling_balochistan/config/network/network_base.dart';
import 'package:efiling_balochistan/models/token_model.dart';
import 'package:efiling_balochistan/models/user_model.dart';

abstract class AuthInterface extends NetworkBase {
  String get loginUrl => '${baseUrl}login';
  //String get meUrl => '${baseUrl}me';

  Future<TokenModel?> login(
    String username,
    String password,
  );

  Future<UserModel?> fetchCurrentUserDetails();

  Future<int?> fetchLoggedInUserId();

  Future<bool?> isLoggedIn();

  Future<void> logout();
}
