import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:efiling_balochistan/config/network/session_expired_handler.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class DioClient {
  final Dio _dio;
  static var logger = Logger();

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
          log("REQUEST_______${response.requestOptions.data}");
          log("RESPONSE________${response.data}_____${response.statusCode}");
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

          handler.next(response);
        },
        onError: (error, handler) async {
          logger.d("-------URL---------");
          logger.d(error.requestOptions.uri.toString());
          logger.d("-------ERROR CODE---------");
          logger.d(error.response?.statusCode?.toString());
          logger.d("-------ERROR RESP---------");
          logger.d(error.response?.data);
          logger.d("-------ERROR---------");
          logger.d(error);
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
        final HttpClient client =
            HttpClient(context: SecurityContext(withTrustedRoots: false));
        client.badCertificateCallback =
            ((X509Certificate cert, String host, int port) => true);
        return client;
      },
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
        logger.d("-------URL---------");
        logger.d(url);
        logger.d("-------HEADER---------");
        logger.d("${options.headers}");
        logger.d("-------QUERY PARAMS---------");
        logger.d("$queryParameters");
      }
      Response response;
      response = await _dio.get(
        url,
        queryParameters: queryParameters ?? {},
        options: options,
      );
      if (isShowLog) {
        debugPrint("-------Response---------");
        debugPrint(response.toString());
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
        logger.d("-------URL---------");
        logger.d(url);
        logger.d("-------HEADER---------");
        logger.d("${options?.headers}");
        logger.d("-------Request---------");
        logger.d(data.toString());
      }
      final Response response = await _dio.patch(
        url,
        data: data,
        options: options,
      );
      if (isShowLog) {
        logger.d("-------Response---------");
        logger.d(response.toString());
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
        logger.d("-------URL---------");
        logger.d(url);
        logger.d("-------HEADER---------");
        logger.d("${options.headers}");
        logger.d("-------Request---------");
        logger.d(data.toString());
      }
      final Response response = await _dio.post(
        url,
        data: data ?? formData,
        options: options,
        onSendProgress: onSendProgress,
      );
      if (isShowLog) {
        logger.d("-------Response---------");
        logger.d(response.toString());
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
        logger.d("-------URL---------");
        logger.d(url);
        logger.d("-------HEADER---------");
        logger.d("${options.headers}");
        logger.d("-------Request---------");
        logger.d(data.toString());
      }
      final Response response = await _dio.put(
        url,
        data: data,
        options: options,
      );
      if (isShowLog) {
        logger.d("-------Response---------");
        logger.d(response.toString());
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
        logger.d("-------URL---------");
        logger.d(url);
        logger.d("-------HEADER---------");
        logger.d("${options.headers}");
        logger.d("-------Request---------");
        logger.d(data.toString());
      }
      final Response response = await _dio.delete(
        url,
        data: data,
        options: options,
      );
      if (isShowLog) {
        logger.d("-------Response---------");
        logger.d(response.toString());
      }
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
