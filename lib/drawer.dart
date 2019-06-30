import 'package:flutter/material.dart';
import 'package:timeline/network.dart';

import 'user.dart';
import 'user_info.dart';

enum DrawerItem { none, currentUserInfo, home, administration, login }

class MyDrawer extends StatelessWidget {
  MyDrawer({@required this.selectedItem, Key key}) : super(key: key);

  final DrawerItem selectedItem;

  static popToRoot(BuildContext context) {
    Navigator.pop(context);
    Navigator.popUntil(context, (route) => route.settings.name == '/');
  }

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
                popToRoot(context);
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

    Widget headerContent;

    if (user != null) {
      Widget avatar = CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(
            '$apiBaseUrl/user/${user.username}/avatar?token=${UserManager.getInstance().token}'),
        radius: 50,
      );

      if (selectedItem != DrawerItem.currentUserInfo) {
        avatar = GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: avatar,
          onTap: () {
            popToRoot(context);
            Navigator.pushNamed(context, '/user-info',
                arguments: UserInfoRouteParams(user.username));
          },
        );
      }

      headerContent = Column(
        children: <Widget>[
          avatar,
          Center(child: Text(user.username)),
        ],
      );
    } else {
      headerContent = Center(
        child: selectedItem == DrawerItem.login
            ? Text('logining now')
            : FlatButton(
                child: Text('no login, tap to login'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.popAndPushNamed(context, '/login');
                },
              ),
      );
    }

    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            margin: EdgeInsets.zero,
            child: headerContent,
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
