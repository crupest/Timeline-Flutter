import 'package:flutter/material.dart';

import 'user.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController;
  TextEditingController _passwordController;
  bool _isProcessing;
  String _error;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _isProcessing = false;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    children.add(Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'username',
            ),
          ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'password',
            ),
            enabled: !_isProcessing,
          ),
        ],
      ),
    ));

    if (!_isProcessing && _error != null) {
      children.add(
        Text(
          'Login failed.\n' + _error,
          style: Theme.of(context)
              .primaryTextTheme
              .body1
              .copyWith(color: Colors.redAccent),
        ),
      );
    }

    children.add(
      Container(
        padding: EdgeInsets.all(10),
        alignment: Alignment.centerRight,
        child: _isProcessing
            ? CircularProgressIndicator()
            : FlatButton(
                child: Text('login'),
                onPressed: () {
                  setState(() {
                    _isProcessing = true;
                  });
                  UserManager.getInstance()
                      .login(_usernameController.text, _passwordController.text)
                      .then((_) {
                    Navigator.popAndPushNamed(context, '/home');
                  }, onError: (error) {
                    setState(() {
                      _isProcessing = false;
                      _error = error.message;
                    });
                  });
                },
              ),
      ),
    );

    children = [
      Center(
        child: Text(
          'Welcome to Timeline!',
          style: Theme.of(context)
              .primaryTextTheme
              .display1
              .copyWith(color: Colors.blueAccent),
        ),
      ),
      Image.asset("assets/icon.png"),
      ...children,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Timeline'),
      ),
      body: ListView(children: children),
    );
  }
}
