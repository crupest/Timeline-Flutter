import 'dart:convert';

import 'package:http/http.dart';

final String apiBaseUrl = 'https://api.crupest.xyz';

class HttpException implements Exception {
  HttpException(this.statusCode, {this.message}) : assert(statusCode != null);

  String message;

  int statusCode;

  @override
  String toString() {
    final buffer = StringBuffer('HttpException: Status code is $statusCode.');
    if (message != null) {
      buffer.write(message);
    }
    return buffer.toString();
  }
}

class HttpCodeException extends HttpException {
  HttpCodeException(this.errorCode, int responseCode, {String message})
      : assert(errorCode != null),
        super(responseCode, message: message);

  int errorCode;

  @override
  String toString() {
    final buffer = StringBuffer(
        'HttpException: Status code is $statusCode. Error code is $errorCode.');
    if (message != null) {
      buffer.write(message);
    }
    return buffer.toString();
  }
}

checkError(Response response, {int successCode = 200}) {
  if (response.statusCode == successCode) return;

  var rawBody = jsonDecode(response.body) as Map<String, dynamic>;
  int code = rawBody["code"];
  String message = rawBody["message"];
  if (code != null) {
    throw HttpCodeException(response.statusCode, code, message: message);
  } else {
    throw HttpException(response.statusCode, message: message);
  }
}
