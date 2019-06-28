import 'package:rxdart/subjects.dart';

class User {
  User(this.username, {this.isAdmin = false});

  String username;
  bool isAdmin;
}

class UserManager {
  static UserManager _instance;

  BehaviorSubject<User> _user = BehaviorSubject<User>();

  UserManager._create() {
    _user.add(User('mock-user', isAdmin: true));
  }

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

  Stream<User> get user {
    return _user;
  }

  dispose() {
    _user.close();
  }
}
