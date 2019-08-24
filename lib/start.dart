import 'package:flutter/material.dart';

import 'user_service.dart';

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserManager.getInstance().checkLastLogin().then((user) {
      var navigator = Navigator.of(context);
      if (user != null)
        navigator.pushNamedAndRemoveUntil('/home', (_) => false);
      else
        navigator.pushNamedAndRemoveUntil('/login', (_) => false);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Timeline'),
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
