import 'package:flutter/material.dart';

import 'user.dart';

class _UserAdminService {
  Future<List<User>> fetchUserList() async {
    return [
      User('user1', isAdmin: true),
      User('user2', isAdmin: false),
    ];
  }

  Future changePassword(String username, String newPassword) async {}

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
                      builder: (context) =>
                          _ChangePasswordDialog(username: user.username),
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

class _ChangePasswordDialog extends StatefulWidget {
  _ChangePasswordDialog({@required this.username, Key key});

  final String username;

  @override
  State<StatefulWidget> createState() {
    return _ChangePasswordDialogState();
  }
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(child: Text('Changing password for ${widget.username}.'));
  }
}
