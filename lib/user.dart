import 'dart:convert';

import 'package:rxdart/subjects.dart';
import 'package:http/http.dart' as http;
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

class AlreadyLoginException implements Exception {
  final String message = 'A user has already login.';
}

class UserManager {
  static UserManager _instance;
  static const tokenPreferenceKey = 'last_token';

  BehaviorSubject<User> _user = BehaviorSubject<User>();

  String _token;

  UserManager._create();

  factory UserManager.getInstance() {
    if (_instance == null) {
      _instance = UserManager._create();
    }
    return _instance;
  }

  static disposeInstance() {
    if (_instance != null) {
      _instance.dispose();
    }
  }

  User get currentUser {
    return _user.value;
  }

  Stream<User> get user {
    return _user;
  }

  String get token {
    return _token;
  }

  Future<User> checkLastLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey(tokenPreferenceKey)) {
      var savedToken = sharedPreferences.getString(tokenPreferenceKey);
      var res = await http.post(
        '$apiBaseUrl/token/verify',
        body: jsonEncode({
          'token': savedToken,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (res.statusCode == 200) {
        var body = jsonDecode(res.body) as Map<String, dynamic>;
        var user = User.fromJson(body['user']);
        _token = savedToken;
        _user.add(user);
        return user;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<User> login(String username, String password) async {
    if (currentUser != null) throw AlreadyLoginException();
    var res = await http.post(
      '$apiBaseUrl/token/create',
      body: jsonEncode(
          {User.key_username: username, User.key_password: password}),
      headers: {'Content-Type': 'application/json'},
    );
    checkError(res);
    var body = jsonDecode(res.body) as Map<String, dynamic>;
    var user = User.fromJson(body['user']);
    _token = body['token'] as String;
    _user.add(user);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(tokenPreferenceKey, _token);
    return user;
  }

  dispose() {
    _user.close();
  }
}
