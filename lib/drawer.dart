import 'dart:async';
import 'package:flutter/material.dart';

import 'user.dart';

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() {
    return _MyDrawerState();
  }
}

class _MyDrawerState extends State<MyDrawer> {
  User _user;
  StreamSubscription<User> _userSubscription;

  @override
  void initState() {
    super.initState();

    _userSubscription = UserManager.getInstance().user.listen((User u) {
      setState(() {
        _user = u;
      });
    });
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var tiles = <Widget>[];

    if (_user != null && _user.isAdmin) {
      tiles.add(ListTile(
        title: Text('Administration'),
        onTap: () {
          
        },
      ));
    }

    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: Text(_user?.username ?? 'Not login.'),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          ...tiles
        ],
      ),
    );
  }
}
