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
  dynamic _error;

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
    List<Widget> children;

    if (_isProcessing) {
      children = [CircularProgressIndicator()];
    } else {
      children = [
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
        ),
      ];
      if (_error != null) {
        children.add(Text('Login failed. Error: $_error'));
      }
      children.add(RaisedButton(
        child: Text('login'),
        onPressed: () {
          setState(() {
            _isProcessing = true;
          });
          UserManager.getInstance()
              .login(_usernameController.text, _passwordController.text)
              .then((_) {
            Navigator.pop(context);
          }, onError: (error) {
            setState(() {
              _isProcessing = false;
              _error = error;
            });
          });
        },
      ));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Login'),
      ),
      body: Column(children: children),
    );
  }
}
