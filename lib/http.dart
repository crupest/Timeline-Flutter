import 'dart:convert';

import 'package:http/http.dart';

final String apiBaseUrl = 'https://api.crupest.xyz';

class HttpCodeException implements Exception {
  HttpCodeException(this.code, this.message);

  int code;
  String message;
}

checkError(Response response, {int successCode = 200}) {
  if (response.statusCode == successCode) return;
  var rawBody = jsonDecode(response.body) as Map<String, dynamic>;
  StringBuffer messageBuilder = StringBuffer();

  int code = rawBody["code"];
  if (code != null) {
    messageBuilder.writeln('Error code is $code.');
  }
  if (rawBody.containsKey('message')) {
    messageBuilder.writeln('Error message is ${rawBody["message"]}.');
  }
  if (messageBuilder.isEmpty) {
    messageBuilder.write(
      'Unknown error. Response status code is ${response.statusCode}.',
    );
  }

  if (code != null) {
    throw HttpCodeException(code, messageBuilder.toString());
  } else {
    throw Exception(messageBuilder.toString());
  }
}
