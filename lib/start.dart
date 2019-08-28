import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'route.dart';
import 'user_service.dart';

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserManager().checkLastLogin().then((user) {
      if (user != null)
        router.navigateTo(context, '/home',
            replace: true, transition: TransitionType.fadeIn);
      else
        router.navigateTo(context, '/login',
            replace: true, transition: TransitionType.fadeIn);
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
