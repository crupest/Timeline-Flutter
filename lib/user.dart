import 'dart:convert';

import 'package:rxdart/subjects.dart';
import 'package:http/http.dart' as http;

import 'network.dart';

class User {
  User(this.username, {this.administrator = false});

  String username;
  bool administrator;

  User.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        administrator = json['administrator'];
}

class AlreadyLoginException implements Exception {
  final String message = 'A user has already login.';
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
    if (res.statusCode != 200) {
      throw Exception('Login failed.'); // TODO: Add detailed error message.
    }
    var body = jsonDecode(res.body) as Map<String, dynamic>;
    var user = User.fromJson(body['user']);
    _token = body['token'] as String;
    _user.add(user);
    return user;
  }

  dispose() {
    _user.close();
  }
}
