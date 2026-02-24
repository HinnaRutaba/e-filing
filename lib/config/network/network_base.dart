import 'package:dio/dio.dart';
import 'package:efiling_balochistan/config/network/api_client.dart';
import 'package:efiling_balochistan/controllers/local_storage_controller.dart';
import 'package:efiling_balochistan/models/token_model.dart';

enum RequestType {
  create('create'),
  update('update');

  final String value;
  const RequestType(this.value);
}

abstract class NetworkBase {
  final DioClient dioClient = DioClient(Dio());
  static const String base = 'https://efiling.balochistan.gob.pk';
  //'https://test-efiling.balochistan.gob.pk';
  final String baseUrl = '$base/api/';

  Map<String, dynamic> get headers => {
        "Accept": "application/json",
      };

  Map<String, dynamic> get multipartHeader => {
        "Content-Type": "multipart/form-data",
        "Accept": "application/x-www-form-urlencoded",
      };

  isSuccess(Map<String, dynamic> data) {
    return data.isNotEmpty && data['status'] == true;
  }

  Future<Options> options(
      {bool authRequired = true, bool isMultipartContentType = false}) async {
    final options = Options(
      headers: isMultipartContentType ? multipartHeader : headers,
      followRedirects: false,
      contentType: isMultipartContentType
          ? Headers.multipartFormDataContentType
          : Headers.formUrlEncodedContentType,
      validateStatus: (statusCode) {
        if (statusCode == null) {
          return false;
        }
        if (statusCode == 401 || statusCode == 422 || statusCode == 302) {
          // your http status code
          return true;
        } else {
          return statusCode >= 200 && statusCode < 300;
        }
      },
    );
    if (authRequired) {
      TokenModel? token = await LocalStorageController().getToken();
      if (token != null) {
        options.headers!["Authorization"] = "Bearer ${token.token}";
      }
    }
    return options;
  }
}
