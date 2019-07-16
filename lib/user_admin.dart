import 'package:flutter/material.dart';

import 'user.dart';

class _UserAdminService {
  Future<List<User>> fetchUserList() async {
    return [
      User('user1', isAdmin: true),
      User('user2', isAdmin: false),
    ];
  }

  Future changePassword(String username, String newPassword) {
    return Future.delayed(const Duration(seconds: 2), () {
      throw Exception('Hahaha mock error.');
    });
  }

  Future removeUser(String username) {
    return Future.delayed(const Duration(seconds: 2), () {});
  }

  Future changePermission(String username, bool isAdmin) {
    return Future.delayed(const Duration(seconds: 2), () {});
  }
}

class UserAdminPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserAdminPageState();
  }
}

enum _UserAction {
  changePassword,
  changePermission,
  remove,
}

class _UserAdminPageState extends State<UserAdminPage> {
  _UserAdminService _service;

  List<User> _users;

  @override
  void initState() {
    super.initState();
    _service = _UserAdminService();
    _service.fetchUserList().then((users) {
      setState(() {
        _users = users;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_users == null) return LinearProgressIndicator();
    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          child: ListTile(
            title: Text(user.username),
            subtitle: Text(user.isAdmin ? 'administrator' : 'user'),
            trailing: PopupMenuButton<_UserAction>(
              icon: Icon(Icons.more_vert),
              itemBuilder: (context) {
                return <PopupMenuEntry<_UserAction>>[
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
                          isAdmin: !user.isAdmin,
                          changePermissionFunction: (username, isAdmin) async {
                            await _service.changePermission(username, isAdmin);
                            setState(() {
                              user.isAdmin = isAdmin;
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
                'Error! $_error',
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
          'You are change $username to ${isAdmin ? "administrator" : "user"} !'),
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
