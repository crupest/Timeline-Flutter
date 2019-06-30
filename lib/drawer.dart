import 'package:flutter/material.dart';
import 'package:timeline/network.dart';

import 'user.dart';

enum DrawerItem { home, administration, login }

class MyDrawer extends StatelessWidget {
  MyDrawer({@required this.selectedItem, Key key}) : super(key: key);

  final DrawerItem selectedItem;

  @override
  Widget build(BuildContext context) {
    var tiles = <Widget>[];

    Widget createItem(DrawerItem item, String title, String route) {
      var selected = selectedItem == item;
      return ListTile(
        title: Text(title),
        selected: selected,
        dense: true,
        onTap: selected
            ? null
            : () {
                Navigator.popUntil(
                    context, (route) => route.settings.name == '/');
                if (route != '/') Navigator.pushNamed(context, route);
              },
      );
    }

    tiles.add(createItem(DrawerItem.home, 'Home', '/'));
    tiles.add(Divider());

    var user = UserManager.getInstance().currentUser;

    if (user != null && user.isAdmin) {
      tiles.add(createItem(
          DrawerItem.administration, 'Administration', '/administration'));
    }

    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            margin: EdgeInsets.zero,
            child: user != null
                ? Column(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(
                            '$apiBaseUrl/user/${user.username}/avatar?token=${UserManager.getInstance().token}'),
                        radius: 50,
                      ),
                      Center(child: Text(user.username)),
                    ],
                  )
                : Center(
                    child: selectedItem == DrawerItem.login
                        ? Text('logining now')
                        : FlatButton(
                            child: Text('no login, tap to login'),
                            onPressed: () {
                              Navigator.popAndPushNamed(context, '/login');
                            },
                          ),
                  ),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: tiles,
            ),
          ),
        ],
      ),
    );
  }
}
