import 'package:flutter/material.dart';

import 'user_service.dart';

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

  String _usernameError;
  String _passwordError;

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
                labelText: 'username', errorText: _usernameError),
            onChanged: (value) {
              if (value.isEmpty && _usernameError == null) {
                setState(() {
                  _usernameError = 'Please enter username.';
                });
              } else if (value.isNotEmpty && _usernameError != null) {
                setState(() {
                  _usernameError = null;
                });
              }
            },
          ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
                labelText: 'password', errorText: _passwordError),
            enabled: !_isProcessing,
            onChanged: (value) {
              if (value.isEmpty && _passwordError == null) {
                setState(() {
                  _passwordError = 'Please enter password.';
                });
              } else if (value.isNotEmpty && _passwordError != null) {
                setState(() {
                  _passwordError = null;
                });
              }
            },
          ),
        ],
      ),
    ));

    if (!_isProcessing && _error != null) {
      children.add(
        Text(
          _error,
          style: Theme.of(context)
              .primaryTextTheme
              .title
              .copyWith(color: Colors.red),
        ),
      );
    }

    children.add(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.centerRight,
        child: _isProcessing
            ? CircularProgressIndicator()
            : FlatButton(
                child: Text('login'),
                onPressed: () {
                  if (_usernameError != null || _passwordError != null) {
                    setState(() {
                      _error = 'Please fix errors above!';
                    });
                    return;
                  }

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
      Image.asset(
        "assets/icon.png",
        color: Colors.deepOrange,
      ),
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
