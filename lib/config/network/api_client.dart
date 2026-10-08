import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:efiling_balochistan/config/network/session_expired_handler.dart';
import 'package:efiling_balochistan/utils/app_logger.dart';

class DioClient {
  final Dio _dio;

  DioClient(this._dio) {
    _enable();
  }

  void _enable() {
    _dio.interceptors.clear();
    final BaseOptions options = BaseOptions(
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
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

    _dio.options
      ..connectTimeout = options.connectTimeout
      ..receiveTimeout = options.receiveTimeout;

    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (requestOption, handler) async {
          handler.next(requestOption);
        },
        onResponse: (response, handler) {
          if (response.statusCode == 401) {
            SessionExpiredHandler.handleExpiration();
          }
          if (response.data is Map && response.data.containsKey("success")) {
            bool success = response.data["success"];
            if (!success) {
              handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  response: response,
                  error: response.data["message"] ?? "Something went wrong",
                  message: response.data["message"] ?? "Something went wrong",
                ),
              );
              return;
            }
          }

          if (response.statusCode! >= 300 &&
              response.data is Map &&
              response.data.containsKey("message")) {
            handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                error: response.data["message"] ?? "Something went wrong",
                message: response.data["message"] ?? "Something went wrong",
              ),
            );
            return;
          }

          handler.next(response);
        },
        onError: (error, handler) async {
          AppLogger.error(
            error,
            error.stackTrace,
            'ERROR ${error.requestOptions.method} ${error.requestOptions.uri}\n'
            'code: ${error.response?.statusCode ?? error.type.name}\n'
            'response: ${error.response?.data ?? "No response data"}\n'
            'message: ${error.message ?? "Unknown error"}',
          );
          if (error.response?.statusCode == 401) {
            SessionExpiredHandler.handleExpiration();
          }
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: error.response?.data is Map
                  ? error.response?.data['error'] ??
                        error.response?.data['message'] ??
                        "Something went wrong"
                  : error.response?.data,
              message: error.response?.data is Map
                  ? error.response?.data['error'] ??
                        error.response?.data['message'] ??
                        "Something went wrong"
                  : error.response?.data,
            ),
          );
        },
      ),
    );

    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        // Don't trust any certificate just because their root cert is trusted.
        final HttpClient client = HttpClient(
          context: SecurityContext(withTrustedRoots: false),
        );
        client.badCertificateCallback =
            ((X509Certificate cert, String host, int port) => true);
        return client;
      },
    );
  }

  void _logRequest(
    String method,
    String url,
    Map<String, dynamic>? headers, {
    Map<String, dynamic>? query,
    Object? body,
  }) {
    AppLogger.api(
      'REQUEST $method $url\n'
      'headers: $headers\n'
      '${query != null ? 'query: $query\n' : ''}'
      '${body != null ? 'body: $body' : ''}',
    );
  }

  void _logResponse(Response response) {
    AppLogger.api(
      'RESPONSE ${response.requestOptions.method} ${response.requestOptions.uri}\n'
      'status: ${response.statusCode}\n'
      'data: ${response.data}',
    );
  }

  Future<dynamic> get({
    required String url,
    Map<String, dynamic>? queryParameters,
    required Options options,
    bool isShowLog = true,
  }) async {
    try {
      if (isShowLog) {
        _logRequest('GET', url, options.headers, query: queryParameters);
      }
      Response response;
      response = await _dio.get(
        url,
        queryParameters: queryParameters ?? {},
        options: options,
      );
      if (isShowLog) {
        _logResponse(response);
      }
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> patch({
    required String url,
    required Map<String, dynamic> data,
    Options? options,
    bool isShowLog = false,
  }) async {
    try {
      if (isShowLog) {
        _logRequest('PATCH', url, options?.headers, body: data);
      }
      final Response response = await _dio.patch(
        url,
        data: data,
        options: options,
      );
      if (isShowLog) {
        _logResponse(response);
      }
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post({
    required String url,
    required Options options,
    Map<String, dynamic>? data,
    FormData? formData,
    bool isShowLog = true,
    Function(int sent, int total)? onSendProgress,
  }) async {
    if (formData == null && data == null) {
      throw Exception("Either 'formData' or 'data; is required");
    }
    try {
      if (isShowLog) {
        _logRequest(
          'POST',
          url,
          options.headers,
          body: data ?? formData?.fields,
        );
      }
      final Response response = await _dio.post(
        url,
        data: data ?? formData,
        options: options,
        onSendProgress: onSendProgress,
      );
      if (isShowLog) {
        _logResponse(response);
      }
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> put({
    required String url,
    required Map<String, dynamic> data,
    required Options options,
    bool isShowLog = false,
  }) async {
    try {
      if (isShowLog) {
        _logRequest('PUT', url, options.headers, body: data);
      }
      final Response response = await _dio.put(
        url,
        data: data,
        options: options,
      );
      if (isShowLog) {
        _logResponse(response);
      }
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> delete({
    required String url,
    Map<String, dynamic>? data,
    required Options options,
    bool isShowLog = false,
  }) async {
    try {
      if (isShowLog) {
        _logRequest('DELETE', url, options.headers, body: data);
      }
      final Response response = await _dio.delete(
        url,
        data: data,
        options: options,
      );
      if (isShowLog) {
        _logResponse(response);
      }
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
