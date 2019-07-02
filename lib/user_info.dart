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
    final username = params.username;
    final self = UserManager.getInstance().currentUser.username == username;
    final user = UserManager.getInstance().fetchUserInfo(username);

    return Scaffold(
      appBar: AppBar(
        title: Text('User'),
      ),
      body: FutureBuilder<User>(
        future: user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              alignment: Alignment.topCenter,
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      UserManager.getInstance().generateUserAvatarUrl(username),
                    ),
                    backgroundColor: Colors.white,
                    radius: 50,
                  ),
                  Text(username),
                  Text(snapshot.data.isAdmin ? 'administrator' : 'user'),
                ],
              ),
            );
          }
          return LinearProgressIndicator();
        },
      ),
      drawer: MyDrawer(
        selectedItem:
            self ? DrawerSelectedItem.selfUserInfo : DrawerSelectedItem.none,
      ),
    );
  }
}
