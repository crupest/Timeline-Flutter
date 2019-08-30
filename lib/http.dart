import 'dart:io';

import 'package:dio/dio.dart';

import 'user_service.dart';

final String apiBaseUrl = 'https://api.crupest.xyz';

BaseOptions dioOptions = BaseOptions(
  baseUrl: apiBaseUrl,
  connectTimeout: 5000,
  receiveTimeout: 5000,
);

Dio createDio() {
  final dio = Dio(dioOptions);
  dio.interceptors.add(InterceptorsWrapper(onError: (error) {
    if (error.type == DioErrorType.RESPONSE) {
      final data = error.response.data;
      int code;
      String message;
      if (data != null && data is Map<String, dynamic>) {
        dynamic c = data['code'];
        if (c is int) code = c;

        dynamic m = data['message'];
        if (m is String) message = m;
      }
      if (code != null || message != null) {
        return dio.reject(HttpCommonErrorData(code: code, message: message));
      }
    }
    return error;
  }));
  return dio;
}

Dio createDioWithToken() {
  final dio = createDio();
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options) {
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer ${UserManager().token}';
      return options;
    },
  ));
  return dio;
}

// Corresponds to CommonResponse in server.
class HttpCommonErrorData {
  HttpCommonErrorData({this.code, this.message});

  int code;
  String message;

  @override
  String toString() {
    final buffer = StringBuffer();
    if (code != null) {
      buffer.write('Error code is $code.');
    }
    if (message != null) {
      if (code != null) buffer.write(' ');
      buffer.write(message);
    }
    return buffer.toString();
  }
}

bool isNetworkError(DioError e) {
  return !isNotNetworkError(e);
}

bool isNotNetworkError(DioError e) {
  return e.type == DioErrorType.DEFAULT || e.type == DioErrorType.RESPONSE;
}

int getCommonErrorCode(DioError e) {
  if (e.type == DioErrorType.DEFAULT) {
    final errorData = e.error;
    if (errorData is HttpCommonErrorData) return errorData.code;
  }
  return null;
}
