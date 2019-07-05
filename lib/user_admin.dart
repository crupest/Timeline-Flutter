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
    return Future.delayed(const Duration(seconds: 2), () {});
  }

  Future removeUser(String username) async {}
}

class UserAdminPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserAdminPageState();
  }
}

enum _UserAction {
  changePassword,
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
                  case _UserAction.remove:
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

enum _ChangePasswordDialogStep { input, progress, done, error }

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  _ChangePasswordDialogStep _step;

  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _step = _ChangePasswordDialogStep.input;
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children;

    switch (_step) {
      case _ChangePasswordDialogStep.input:
        children = [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'new password',
            ),
          ),
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
                    _step = _ChangePasswordDialogStep.progress;
                  });
                  widget
                      .changePasswordFunction(widget.username, _controller.text)
                      .then((_) {
                    setState(() {
                      _step = _ChangePasswordDialogStep.done;
                    });
                  }, onError: (_) {
                    setState(() {
                      _step = _ChangePasswordDialogStep.error;
                    });
                  });
                },
                child: Text('Ok'),
              ),
            ],
          )
        ];
        break;
      case _ChangePasswordDialogStep.progress:
        children = [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          )
        ];
        break;
      case _ChangePasswordDialogStep.done:
        children = [
          Center(
            child: Text(
              'Success!',
              style: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.green),
            ),
          ),
          Row(
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
          ),
        ];
        break;
      case _ChangePasswordDialogStep.error:
        children = [
          Text('Error!'),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Ok'),
              )
            ],
          ),
        ];
        break;
    }

    return SimpleDialog(
      title: Text('You are changing password for ${widget.username} !'),
      children: children,
    );
  }
}
