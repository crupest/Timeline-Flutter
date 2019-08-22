import 'dart:convert';

import 'package:http/http.dart';

final String apiBaseUrl = 'https://api.crupest.xyz';

checkError(Response response, {int successCode = 200}) {
  if (response.statusCode == successCode) return;
  var rawBody = jsonDecode(response.body) as Map<String, dynamic>;
  StringBuffer messageBuilder = StringBuffer();
  if (rawBody.containsKey('code')) {
    messageBuilder.writeln('Error code is ${rawBody["code"]}.');
  }
  if (rawBody.containsKey('message')) {
    messageBuilder.writeln('Error message is ${rawBody["message"]}.');
  }
  if (messageBuilder.isEmpty) {
    throw Exception(
        'Unknown error. Response status code is ${response.statusCode}.');
  } else {
    throw Exception(messageBuilder.toString());
  }
}
