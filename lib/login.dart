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
  Future<User> _loginFuture;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(children: <Widget>[
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
        FutureBuilder(
          future: _loginFuture,
          builder: (context, snapshot) {
            Widget createButton() {
              return RaisedButton(
                  child: Text('login'),
                  onPressed: () {
                    setState(() {
                      _loginFuture = UserManager.getInstance().login(
                          _usernameController.text, _passwordController.text);
                      _loginFuture.then((_) {
                        Navigator.pop(context);
                      });
                    });
                  });
            }

            if (snapshot.connectionState == ConnectionState.none) {
              return createButton();
            } else if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasError) {
              return Column(
                children: <Widget>[
                  Text('Login failed.'),
                  createButton(),
                ],
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        )
      ]),
    );
  }
}
