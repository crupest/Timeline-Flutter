import 'package:flutter/material.dart';
import 'package:timeline/network.dart';

import 'user.dart';
import 'user_info.dart';

enum DrawerSelectedItem { none, selfUserInfo, home, administration }

class MyDrawer extends StatelessWidget {
  MyDrawer({this.selectedItem = DrawerSelectedItem.none, Key key})
      : super(key: key);

  final DrawerSelectedItem selectedItem;

  @override
  Widget build(BuildContext context) {
    var tiles = <Widget>[];

    Widget createItem(DrawerSelectedItem item, String title, String route) {
      var selected = selectedItem == item;
      return ListTile(
        title: Text(title),
        selected: selected,
        dense: true,
        onTap:
            selected ? null : () => Navigator.popAndPushNamed(context, route),
      );
    }

    tiles.add(createItem(DrawerSelectedItem.home, 'Home', '/'));
    tiles.add(Divider());

    var user = UserManager.getInstance().currentUser;

    if (user != null && user.isAdmin) {
      tiles.add(createItem(DrawerSelectedItem.administration, 'Administration',
          '/administration'));
    }

    Widget headerContent;

    if (user != null) {
      Widget avatar = CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(
            '$apiBaseUrl/user/${user.username}/avatar?token=${UserManager.getInstance().token}'),
        radius: 50,
      );

      if (selectedItem != DrawerSelectedItem.selfUserInfo) {
        avatar = GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: avatar,
          onTap: () {
            Navigator.popAndPushNamed(context, '/user-info',
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
        child: FlatButton(
          child: Text('no login, tap to login'),
          onPressed: () {
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
