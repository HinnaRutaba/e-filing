import 'package:dio/dio.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BaseControllerState<T> extends StateNotifier<T> {
  late final Ref ref;
  late final localStorage = ref.read(localStorageController);

  // UserModel get user {
  //   UserModel? u = ref.read(authRepo).fetchCurrentUser();
  //   if (u == null) {
  //     ref.read(authRepo).signOut();
  //   }
  //   return u!;
  // }

  String handleException(e) {
    if (e is DioException && e.response?.statusCode == 500) {
      return "Unable to process your request at this moment. Please try again later.";
    }
    String cleanedError = e.toString().replaceAll(RegExp(r':.*$'), '');
    return e?.toString().replaceAll(cleanedError, 'Error') ??
        "Something went wrong!";
  }

  BaseControllerState(super.state, this.ref);
}

class BaseController {
  late final Ref ref;
  late final localStorage = ref.read(localStorageController);

  // UserModel get user {
  //   UserModel? u = ref.read(authRepo).fetchCurrentUser();
  //   if (u == null) {
  //     ref.read(authRepo).signOut();
  //   }
  //   return u!;
  // }

  String handleException(e) {
    if (e is DioException && e.response?.statusCode == 500) {
      return "Unable to process your request at this moment. Please try again later.";
    }
    String cleanedError = e.toString().replaceAll(RegExp(r':.*$'), '');
    return e?.toString().replaceAll(cleanedError, 'Error') ??
        "Something went wrong!";
  }

  BaseController(this.ref);
}
