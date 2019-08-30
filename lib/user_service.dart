import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'http.dart';

class User {
  static const String key_username = 'username';
  static const String key_password = 'password';
  static const String key_administrator = 'administrator';

  User(this.username, {this.administrator = false});

  String username;
  bool administrator;

  User.fromJson(Map<String, dynamic> json)
      : username = json[key_username],
        administrator = json[key_administrator];
}

enum LastLoginResult { nologin, expired, ok }

class UserManager {
  static UserManager _instance;
  static const tokenPreferenceKey = 'last_token';

  User _user;
  String _token;

  Dio _dio;

  UserManager._() {
    _dio = createDio();
  }

  factory UserManager() {
    if (_instance == null) {
      _instance = UserManager._();
    }
    return _instance;
  }

  User get user {
    return _user;
  }

  String get token {
    return _token;
  }

  Future<LastLoginResult> checkLastLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (!sharedPreferences.containsKey(tokenPreferenceKey))
      return LastLoginResult.nologin;

    try {
      var savedToken = sharedPreferences.getString(tokenPreferenceKey);
      var res = await _dio.post(
        '$apiBaseUrl/token/verify',
        data: {
          'token': savedToken,
        },
      );
      var body = res.data;
      var user = User.fromJson(body['user']);
      _token = savedToken;
      _user = user;
      return LastLoginResult.ok;
    } on DioError catch (e) {
      if (isNotNetworkError(e)) {
        if (e.error is HttpCommonErrorData) {
          sharedPreferences.remove(tokenPreferenceKey);
          return LastLoginResult.expired;
        } else {
          debugPrint(
              "Server responses to token validation, it failed but return no error data.");
          throw e;
        }
      } else
        throw e;
    }
  }

  Future<User> login(String username, String password) async {
    if (_user != null) throw Exception('You can\'t login twice.');
    var res = await _dio.post(
      '$apiBaseUrl/token/create',
      data: {
        User.key_username: username,
        User.key_password: password,
      },
    );
    var body = res.data;
    var user = User.fromJson(body['user']);
    _token = body['token'] as String;
    _user = user;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(tokenPreferenceKey, _token);
    return user;
  }

  Future logout() async {
    if (_user == null)
      throw Exception("You can't logout because you haven't login.");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(tokenPreferenceKey);
    _token = null;
    _user = null;
  }
}
