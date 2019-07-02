import 'dart:convert';

import 'package:rxdart/subjects.dart';
import 'package:http/http.dart' as http;

import 'network.dart';

class AlreadyLoginException implements Exception {
  final String message = 'A user has already login.';
}

class User {
  User(this.username, {this.isAdmin = false});

  String username;
  bool isAdmin;

  User.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        isAdmin = json['isAdmin'];
}

class UserManager {
  static UserManager _instance;

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

  Future<User> login(String username, String password) async {
    if (currentUser != null) throw AlreadyLoginException();
    var res = await http.post(
      '$apiBaseUrl/token/create',
      body: jsonEncode({'username': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );
    var body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] as bool) {
      var user = User.fromJson(body['userInfo']);
      _token = body['token'] as String;
      _user.add(user);
      return user;
    } else {
      throw Exception();
    }
  }

  String generateUserAvatarUrl(String username) {
    assert(token != null);
    return '$apiBaseUrl/user/$username/avatar?token=$token';
  }

  Future<User> fetchUserInfo(String username) async {
    var res = await http.get('$apiBaseUrl/user/$username?token=$token');
    var user = User.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    return user;
  }

  dispose() {
    _user.close();
  }
}
