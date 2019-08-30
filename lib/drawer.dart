import 'package:flutter/material.dart';

import 'avatar.dart';
import 'i18n.dart';
import 'user_service.dart';

enum DrawerSelectedItem { none, home, administration, settings }

class MyDrawer extends StatelessWidget {
  MyDrawer({this.selectedItem = DrawerSelectedItem.none, Key key})
      : super(key: key);

  final DrawerSelectedItem selectedItem;

  @override
  Widget build(BuildContext context) {
    final translation = TimelineLocalizations.of(context).drawer;

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

    tiles.add(createItem(DrawerSelectedItem.home, translation.home, '/home'));
    tiles.add(Divider());

    var user = UserManager().user;

    if (user.administrator) {
      tiles.add(createItem(DrawerSelectedItem.administration,
          translation.administration, '/admin'));
      tiles.add(Divider());
    }

    tiles.add(createItem(
        DrawerSelectedItem.settings, translation.settings, '/settings'));

    Widget headerContent;

    headerContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Avatar(user.username),
        ),
        Text(user.username),
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
