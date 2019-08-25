import 'package:flutter/material.dart';
import 'package:timeline/http.dart';

import 'i18n.dart';
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
    final localizations = TimelineLocalizations.of(context);

    List<Widget> children = [];

    _validate(
        String value, dynamic error, void errorSetter(), void errorClearer()) {
      if (value.isEmpty && error == null) {
        setState(() {
          errorSetter();
        });
      } else if (value.isNotEmpty && error != null) {
        setState(() {
          errorClearer();
        });
      }
    }

    validateUsername(String value) {
      _validate(value, _usernameError, () {
        _usernameError = localizations.enterUsername;
      }, () {
        _usernameError = null;
      });
    }

    validatePassword(String value) {
      _validate(value, _passwordError, () {
        _passwordError = localizations.enterPassword;
      }, () {
        _passwordError = null;
      });
    }

    List<Widget> formChildren = [];

    formChildren.addAll([
      TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: localizations.username,
            errorText: _usernameError,
            isDense: true,
          ),
          onChanged: validateUsername),
      TextField(
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: localizations.password,
          errorText: _passwordError,
          isDense: true,
        ),
        enabled: !_isProcessing,
        onChanged: validatePassword,
      ),
      SizedBox(
        height: 10,
      ),
    ]);

    if (!_isProcessing && _error != null) {
      formChildren.add(
        Text(
          _error,
          style: Theme.of(context)
              .primaryTextTheme
              .title
              .copyWith(color: Colors.red),
        ),
      );
    }

    formChildren.add(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.centerRight,
        child: _isProcessing
            ? CircularProgressIndicator()
            : FlatButton(
                child: Text(localizations.login),
                onPressed: () {
                  validateUsername(_usernameController.text);
                  validatePassword(_passwordController.text);

                  if (_usernameError != null || _passwordError != null) {
                    setState(() {
                      _error = localizations.fixErrorAbove;
                    });
                    return;
                  }

                  setState(() {
                    _isProcessing = true;
                  });
                  UserManager.getInstance()
                      .login(_usernameController.text, _passwordController.text)
                      .then((_) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }, onError: (error) {
                    String message;
                    if (error is HttpCodeException &&
                        error.errorCode == -1001) {
                      message = localizations.badCredential;
                    } else {
                      message = error.message;
                    }
                    setState(() {
                      _isProcessing = false;
                      _error = message;
                    });
                  });
                },
              ),
      ),
    );

    children.add(Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: formChildren,
      ),
    ));

    children = [
      Center(
        child: Text(
          localizations.welcome,
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
