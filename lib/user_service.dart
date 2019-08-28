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

class UserManager {
  static UserManager _instance;
  static const tokenPreferenceKey = 'last_token';

  BehaviorSubject<User> _user = BehaviorSubject<User>.seeded(null);

  String _token;

  UserManager._();

  factory UserManager() {
    if (_instance == null) {
      _instance = UserManager._();
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
      checkError(res);
      var body = jsonDecode(res.body) as Map<String, dynamic>;
      var user = User.fromJson(body['user']);
      _token = savedToken;
      _user.add(user);
      return user;
    }
    return null;
  }

  Future<User> login(String username, String password) async {
    if (currentUser != null) throw Exception('You can\'t login twice.');
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

  Future logout() async {
    if (currentUser == null)
      throw Exception("You can't logout because you haven't login.");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(tokenPreferenceKey);
    _token = null;
    _user.add(null);
  }

  dispose() {
    _user.close();
  }
}
