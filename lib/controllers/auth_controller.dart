import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/token_model.dart';
import 'package:efiling_balochistan/models/user_model.dart';
import 'package:efiling_balochistan/repository/auth/auth_repo.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AuthController extends BaseControllerState<UserModel> {
  AuthController(super.state, super.ref);

  AuthRepo get repo => ref.read(authRepo);

  Future<bool> login(
      {required String username, required String password}) async {
    bool success = false;
    EasyLoading.show();
    try {
      TokenModel? model = await repo.login(username, password);
      if (model != null) {
        state = model.user!;
        localStorage.setToken(model);
        if (model.user?.designations.length == 1) {
          await setDesignation(model.user!.designations.first);
          RouteHelper.navigateTo(Routes.dashboard);
        } else {
          RouteHelper.navigateTo(
            Routes.selectDesignation,
            extra: model.user!.designations,
          );
        }
        success = true;
      }
    } catch (e) {
      Toast.error(message: handleException(e));
    }
    EasyLoading.dismiss();
    return success;
  }

  Future<TokenModel?> fetchToken() async {
    try {
      TokenModel? model = await localStorage.getToken();
      if (model?.user != null) {
        state = model!.user!;
      }
      return model;
    } catch (e) {
      Toast.error(message: handleException(e));
      return null;
    }
  }

  Future<UserModel?> fetchLoggedInUser() async {
    try {
      int desId = state.currentDesignation?.userDesgId ??
          (await localStorage.getDesignation())?.userDesgId ??
          0;
      UserModel? model = await repo.fetchCurrentUserDetails(desId);
      if (model != null) {
        state = state.copyWhole(model);
      }
      return model;
    } catch (e, s) {
      print("ME ERROR_______${e}______$s");
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

  Future<bool> changePassword(
      {required String currentPassword,
      required String newPassword,
      required String confirmPassword}) async {
    bool success = false;
    EasyLoading.show();
    try {
      await repo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      success = true;
    } catch (e) {
      Toast.error(message: handleException(e));
    }
    EasyLoading.dismiss();
    return success;
  }

  Future<DesignationModel?> fetchDesignation() async {
    try {
      DesignationModel? model = await localStorage.getDesignation();
      state = state.copyWith(currentDesignation: model);
      return model;
    } catch (e) {
      Toast.error(message: handleException(e));
      return null;
    }
  }

  Future<DesignationModel?> setDesignation(DesignationModel model) async {
    try {
      await localStorage.setDesignation(model);
      state = state.copyWith(currentDesignation: model);
      return model;
    } catch (e) {
      Toast.error(message: handleException(e));
      return null;
    }
  }
}
