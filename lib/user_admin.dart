import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'user.dart';
import 'network.dart';

class _UserAdminService {
  static const String _key_password = User.key_password;
  static const String _key_administrator = User.key_administrator;

  String _generateUrl(String username) =>
      '$apiBaseUrl/users/$username?token=${UserManager.getInstance().token}';

  _checkError(Response response, {int successCode = 200}) {
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
      throw Exception('Unknown error. Response status code is ${response.statusCode}.');
    } else {
      throw Exception(messageBuilder.toString());
    }
  }

  Future<List<User>> fetchUserList() async {
    var res =
        await get('$apiBaseUrl/users?token=${UserManager.getInstance().token}');
    _checkError(res);
    var rawList = jsonDecode(res.body) as List<dynamic>;
    return rawList.map((raw) => User.fromJson(raw)).toList();
  }

  Future createUser(
      String username, String password, bool administrator) async {
    var res = await put(_generateUrl(username),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {_key_password: password, _key_administrator: administrator}));
    _checkError(res, successCode: 201);
  }

  Future changeUsername(String oldUsername, String newUsername) async {
    var res = await post(
      '$apiBaseUrl/userop/changeusername?token=${UserManager.getInstance().token}',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'oldUsername': oldUsername,
        'newUsername': newUsername,
      }),
    );
    _checkError(res);
  }

  Future changePassword(String username, String newPassword) async {
    var res = await patch(_generateUrl(username),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          _key_password: newPassword,
        }));
    _checkError(res);
  }

  Future removeUser(String username) async {
    var res = await delete(_generateUrl(username));
    _checkError(res);
  }

  Future changePermission(String username, bool administrator) async {
    var res = await patch(_generateUrl(username),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          _key_administrator: administrator,
        }));
    _checkError(res);
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

enum _OperationStep { input, progress, done }
typedef Future _OperationFunction();

class _OperationDialog extends StatefulWidget {
  final Widget title;
  final Widget subtitle;

  final List<Widget> inputContent;

  final _OperationFunction operationFunction;

  _OperationDialog({
    @required this.title,
    @required this.subtitle,
    this.inputContent = const [],
    @required this.operationFunction,
    Key key,
  })  : assert(operationFunction != null),
        super(key: key);

  @override
  _OperationDialogState createState() => _OperationDialogState();
}

class _OperationDialogState extends State<_OperationDialog> {
  _OperationStep _step;
  dynamic _error;

  @override
  void initState() {
    super.initState();
    _step = _OperationStep.input;
  }

  @override
  Widget build(BuildContext context) {
    var subtitle = widget.subtitle;

    List<Widget> content;

    switch (_step) {
      case _OperationStep.input:
        content = [
          subtitle,
          ...widget.inputContent,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              FlatButton(
                onPressed: () {
                  setState(() {
                    _step = _OperationStep.progress;
                  });
                  widget.operationFunction().then((_) {
                    setState(() {
                      _step = _OperationStep.done;
                    });
                  }, onError: (error) {
                    setState(() {
                      _step = _OperationStep.done;
                      _error = error;
                    });
                  });
                },
                child: Text('Confirm'),
              ),
            ],
          )
        ];
        break;
      case _OperationStep.progress:
        content = [
          subtitle,
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          ),
        ];
        break;
      case _OperationStep.done:
        var buttonBar = Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Ok',
              ),
            )
          ],
        );
        if (_error == null) {
          content = [
            subtitle,
            Center(
              child: Text(
                'Success!',
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: Colors.green),
              ),
            ),
            buttonBar
          ];
        } else {
          content = [
            subtitle,
            Center(
              child: Text(
                'Error!\n$_error',
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: Colors.red),
              ),
            ),
            buttonBar
          ];
        }
        break;
    }

    return AlertDialog(
      title: widget.title,
      content: IntrinsicHeight(
        child: Column(
          children: content,
        ),
      ),
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
    return _OperationDialog(
      title: Text('Create!'),
      subtitle: Text('You are creating a user.'),
      operationFunction: () => widget.createUserFunction(
          _usernameController.text, _passwordController.text, _isAdmin),
      inputContent: <Widget>[
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
    return _OperationDialog(
      title: Text('Dangerous!'),
      subtitle: Text('You are changing username for ${widget.username}.'),
      inputContent: <Widget>[
        TextField(
          decoration: InputDecoration(
              border: UnderlineInputBorder(), labelText: 'new username'),
          controller: _controller,
        ),
      ],
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
    return _OperationDialog(
      title: Text('Dangerous!'),
      subtitle: Text('You are changing password for ${widget.username}.'),
      inputContent: <Widget>[
        TextField(
          decoration: InputDecoration(
              border: UnderlineInputBorder(), labelText: 'new password'),
          controller: _controller,
        ),
      ],
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
    return _OperationDialog(
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
  final _OperationFunction deleteUserFunction;

  @override
  Widget build(BuildContext context) {
    return _OperationDialog(
      title: Text('Dangerous!'),
      subtitle: Text('You are deleting $username !'),
      operationFunction: deleteUserFunction,
    );
  }
}
