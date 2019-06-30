import 'package:flutter/material.dart';

import 'drawer.dart';
import 'user.dart';

class UserInfoRouteParams {
  String username;

  UserInfoRouteParams(this.username);
}

class UserInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserInfoRouteParams params =
        ModalRoute.of(context).settings.arguments;
    final self =
        UserManager.getInstance().currentUser.username == params.username;

    return Scaffold(
      appBar: AppBar(
        title: Text('User'),
      ),
      body: Center(
        child: Text(params.username),
      ),
      drawer: MyDrawer(
        selectedItem: self ? DrawerItem.currentUserInfo : DrawerItem.none,
      ),
    );
  }
}
