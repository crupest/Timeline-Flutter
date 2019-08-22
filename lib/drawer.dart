import 'package:flutter/material.dart';

import 'user.dart';

enum DrawerSelectedItem { none, home, administration }

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

    tiles.add(createItem(DrawerSelectedItem.home, 'Home', '/home'));
    tiles.add(Divider());

    var user = UserManager.getInstance().currentUser;

    if (user.administrator) {
      tiles.add(createItem(DrawerSelectedItem.administration, 'Administration',
          '/administration'));
    }

    Widget headerContent;

    headerContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(user.username),
        Text('welcome!'),
      ],
    );

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
