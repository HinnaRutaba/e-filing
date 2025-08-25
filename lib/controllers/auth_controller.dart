import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/token_model.dart';
import 'package:efiling_balochistan/repository/auth/auth_repo.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AuthController extends BaseController {
  AuthController(super.ref);

  AuthRepo get repo => ref.read(authRepo);

  Future<bool> login(
      {required String username, required String password}) async {
    bool success = false;
    EasyLoading.show();
    try {
      TokenModel? model = await repo.login(username, password);
      if (model != null) {
        localStorage.setToken(model);
        // ref.read(userController.notifier).setUser(model.item2);
      }
      RouteHelper.navigateTo(Routes.dashboard);
      success = true;
    } catch (e) {
      Toast.error(message: handleException(e));
    }
    EasyLoading.dismiss();
    return success;
  }

  Future<TokenModel?> fetchToken() async {
    try {
      TokenModel? model = await localStorage.getToken();
      return model;
    } catch (e) {
      Toast.error(message: handleException(e));
      return null;
    }
  }

  Future<int?> fetchLoggedInUserId() async {
    try {
      return await repo.fetchLoggedInUserId();
    } catch (e) {
      Toast.error(message: handleException(e));
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      return await repo.isLoggedIn() ?? false;
    } catch (e) {
      Toast.error(message: handleException(e));
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await repo.logout();
      RouteHelper.navigateTo(Routes.login);
    } catch (e) {
      Toast.error(message: handleException(e));
    }
  }
}
