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
        onTap: selected
            ? null
            : () {
                Navigator.popAndPushNamed(context, route);
              },
      );
    }

    tiles.add(createItem(DrawerItem.home, 'Home', '/'));

    var user = UserManager.getInstance().currentUser;

    if (user != null && user.isAdmin) {
      tiles.add(createItem(
          DrawerItem.administration, 'Administration', '/administration'));
    }

    var avatarUrl = apiBaseUrl +
        '/user/' +
        user.username +
        '/avatar' +
        '?token=' +
        UserManager.getInstance().token;

    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: user != null
                ? Column(
                    children: <Widget>[
                      Image.network(
                        avatarUrl,
                        width: 100,
                        height: 100,
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
          ...tiles
        ],
      ),
    );
  }
}
