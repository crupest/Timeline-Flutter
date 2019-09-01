import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'user_service.dart';
import 'dialog.dart';
import 'http.dart';

//TODO: translation

class _UserAdminService {
  static const String _key_password = User.key_password;
  static const String _key_administrator = User.key_administrator;

  Dio _dio;

  _UserAdminService() {
    _dio = createDioWithToken();
  }

  String _generateUrl(String username) => '$apiBaseUrl/users/$username';

  Future<List<User>> fetchUserList() async {
    var res = await _dio.get('$apiBaseUrl/users');
    var rawList = res.data as List<dynamic>;
    return rawList.map((raw) => User.fromJson(raw)).toList();
  }

  Future createUser(
      String username, String password, bool administrator) async {
    await _dio.put(
      _generateUrl(username),
      data: {
        _key_password: password,
        _key_administrator: administrator,
      },
    );
  }

  Future changeUsername(String oldUsername, String newUsername) async {
    await _dio.post(
      '$apiBaseUrl/userop/changeusername',
      data: {
        'oldUsername': oldUsername,
        'newUsername': newUsername,
      },
    );
  }

  Future changePassword(String username, String newPassword) async {
    await _dio.patch(
      _generateUrl(username),
      data: {
        _key_password: newPassword,
      },
    );
  }

  Future removeUser(String username) async {
    await _dio.delete(_generateUrl(username));
  }

  Future changePermission(String username, bool administrator) async {
    await _dio.patch(
      _generateUrl(username),
      data: {
        _key_administrator: administrator,
      },
    );
  }
}

class UserAdminPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserAdminPageState();
  }
}

enum _UserAction {
  changeUsername,
  changePassword,
  changePermission,
  remove,
}

class _UserAdminPageState extends State<UserAdminPage> {
  _UserAdminService _service;

  List<User> _users;

  RefreshController _refreshController;

  Future _onRefresh() async {
    var list = await _service.fetchUserList();
    setState(() {
      _users = list;
    });
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    _service = _UserAdminService();
    _refreshController = RefreshController(initialRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SmartRefresher(
          enablePullDown: true,
          controller: _refreshController,
          header: WaterDropMaterialHeader(
            backgroundColor: Theme.of(context).primaryColor,
          ),
          onRefresh: _onRefresh,
          child: ListView.builder(
            itemCount: _users?.length ?? 0,
            itemBuilder: (context, index) {
              final user = _users[index];
              return Card(
                child: ListTile(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed('users/${user.username}/details');
                  },
                  title: Text(user.username),
                  subtitle: Text(user.administrator ? 'administrator' : 'user'),
                  trailing: PopupMenuButton<_UserAction>(
                    icon: Icon(Icons.more_vert),
                    itemBuilder: (context) {
                      return <PopupMenuEntry<_UserAction>>[
                        PopupMenuItem<_UserAction>(
                          value: _UserAction.changeUsername,
                          child: Text('change username'),
                        ),
                        PopupMenuItem<_UserAction>(
                          value: _UserAction.changePassword,
                          child: Text('change password'),
                        ),
                        PopupMenuItem<_UserAction>(
                          value: _UserAction.changePermission,
                          child: Text('change permission'),
                        ),
                        PopupMenuItem<_UserAction>(
                          value: _UserAction.remove,
                          child: Text('remove user'),
                        ),
                      ];
                    },
                    onSelected: (_UserAction action) {
                      switch (action) {
                        case _UserAction.changeUsername:
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => _ChangeUsernameDialog(
                              username: user.username,
                              changeUsernameFunction:
                                  (oldUsername, newUsername) async {
                                await _service.changeUsername(
                                    oldUsername, newUsername);
                                setState(() {
                                  user.username = newUsername;
                                });
                              },
                            ),
                          );
                          return;
                        case _UserAction.changePassword:
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => _ChangePasswordDialog(
                              username: user.username,
                              changePasswordFunction: (username, password) =>
                                  _service.changePassword(username, password),
                            ),
                          );
                          return;
                        case _UserAction.changePermission:
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => _ChangePermissionDialog(
                                username: user.username,
                                isAdmin: !user.administrator,
                                changePermissionFunction:
                                    (username, isAdmin) async {
                                  await _service.changePermission(
                                      username, isAdmin);
                                  setState(() {
                                    user.administrator = isAdmin;
                                  });
                                }),
                          );
                          return;
                        case _UserAction.remove:
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => _DeleteDialog(
                              username: user.username,
                              deleteUserFunction: () async {
                                await _service.removeUser(user.username);
                                setState(() {
                                  _users.removeAt(index);
                                });
                              },
                            ),
                          );
                          return;
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          alignment: Alignment.bottomRight,
          margin: EdgeInsets.all(18),
          child: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => _CreateUserDialog(
                        createUserFunction:
                            (username, password, isAdmin) async {
                          await this
                              ._service
                              .createUser(username, password, isAdmin);
                          setState(() {
                            _users.add(User(username, administrator: isAdmin));
                          });
                        },
                      ));
            },
          ),
        ),
      ],
    );
  }
}

typedef Future _CreateUserFunction(
    String username, String password, bool isAdmin);

class _CreateUserDialog extends StatefulWidget {
  _CreateUserDialog({
    this.createUserFunction,
    Key key,
  }) : super(key: key);

  final _CreateUserFunction createUserFunction;

  @override
  _CreateUserDialogState createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<_CreateUserDialog> {
  TextEditingController _usernameController;
  TextEditingController _passwordController;
  bool _isAdmin;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _isAdmin = false;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OperationDialog(
      title: Text('Create!'),
      subtitle: Text('You are creating a user.'),
      operationFunction: () => widget.createUserFunction(
          _usernameController.text, _passwordController.text, _isAdmin),
      inputContent: Column(
        children: <Widget>[
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
                border: UnderlineInputBorder(), labelText: 'username'),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
                border: UnderlineInputBorder(), labelText: 'password'),
          ),
          Row(children: <Widget>[
            Checkbox(
              onChanged: (value) {
                setState(() {
                  _isAdmin = value;
                });
              },
              value: _isAdmin,
            ),
            Text('administrator'),
          ]),
        ],
      ),
    );
  }
}

typedef Future ChangeUsernameFunction(String oldUsername, String newUsername);

class _ChangeUsernameDialog extends StatefulWidget {
  _ChangeUsernameDialog({
    @required this.username,
    @required this.changeUsernameFunction,
    Key key,
  });

  final ChangeUsernameFunction changeUsernameFunction;
  final String username;

  @override
  State<StatefulWidget> createState() {
    return _ChangeUsernameDialogState();
  }
}

class _ChangeUsernameDialogState extends State<_ChangeUsernameDialog> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OperationDialog.dangerous(
      subtitle: Text('You are changing username for ${widget.username}.'),
      inputContent: TextField(
        decoration: InputDecoration(
            border: UnderlineInputBorder(), labelText: 'new username'),
        controller: _controller,
      ),
      operationFunction: () {
        return widget.changeUsernameFunction(widget.username, _controller.text);
      },
    );
  }
}

typedef Future ChangePasswordFunction(String username, String password);

class _ChangePasswordDialog extends StatefulWidget {
  _ChangePasswordDialog({
    @required this.username,
    @required this.changePasswordFunction,
    Key key,
  });

  final ChangePasswordFunction changePasswordFunction;
  final String username;

  @override
  State<StatefulWidget> createState() {
    return _ChangePasswordDialogState();
  }
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OperationDialog(
      title: Text('Dangerous!'),
      subtitle: Text('You are changing password for ${widget.username}.'),
      inputContent: TextField(
        decoration: InputDecoration(
            border: UnderlineInputBorder(), labelText: 'new password'),
        controller: _controller,
      ),
      operationFunction: () {
        return widget.changePasswordFunction(widget.username, _controller.text);
      },
    );
  }
}

typedef Future _ChangePermissionFunction(String username, bool isAdmin);

class _ChangePermissionDialog extends StatelessWidget {
  _ChangePermissionDialog({
    @required this.username,
    @required this.isAdmin,
    @required this.changePermissionFunction,
    Key key,
  }) : super(key: key);

  final String username;
  final bool isAdmin;
  final _ChangePermissionFunction changePermissionFunction;

  @override
  Widget build(BuildContext context) {
    return OperationDialog(
      title: Text('Dangerous!'),
      subtitle: Text(
          'You are changing $username to ${isAdmin ? "administrator" : "user"} !'),
      operationFunction: () => changePermissionFunction(username, isAdmin),
    );
  }
}

class _DeleteDialog extends StatelessWidget {
  _DeleteDialog({
    @required this.username,
    @required this.deleteUserFunction,
    Key key,
  }) : super(key: key);

  final String username;
  final OperationFunction deleteUserFunction;

  @override
  Widget build(BuildContext context) {
    return OperationDialog(
      title: Text('Dangerous!'),
      subtitle: Text('You are deleting $username !'),
      operationFunction: deleteUserFunction,
    );
  }
}
