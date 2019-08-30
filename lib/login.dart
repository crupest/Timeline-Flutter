import 'package:flutter/material.dart';

import 'http.dart';
import 'i18n.dart';
import 'user_service.dart';
import 'validatable_text_field.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<ValidatableTextFieldState> _usernameKey;
  GlobalKey<ValidatableTextFieldState> _passwordKey;
  bool _isProcessing;
  String _error;

  static const int _usernameError_empty = 1;
  static const int _passwordError_empty = 1;

  @override
  void initState() {
    super.initState();
    _usernameKey = GlobalKey();
    _passwordKey = GlobalKey();
    _isProcessing = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translation = TimelineLocalizations.of(context).loginPage;

    List<Widget> children = [];

    List<Widget> formChildren = [];

    formChildren.addAll([
      ValidatableTextField(
        key: _usernameKey,
        validator: (value) {
          if (value.isEmpty) return _usernameError_empty;
          return null;
        },
        errorMessageGenerator: (context, errorCode) {
          if (errorCode == _usernameError_empty)
            return TimelineLocalizations.of(context)
                .loginPage
                .errorEnterUsername;
          throw Exception('Unknown error code.'); // not reachable
        },
        decorationBuilder: ValidatableTextField.createDecorationGenerator(
            labelText: translation.username),
      ),
      ValidatableTextField(
        key: _passwordKey,
        validator: (value) {
          if (value.isEmpty) return _passwordError_empty;
          return null;
        },
        errorMessageGenerator: (context, errorCode) {
          if (errorCode == _passwordError_empty)
            return TimelineLocalizations.of(context)
                .loginPage
                .errorEnterPassword;
          throw Exception('Unknown error code.'); // not reachable
        },
        decorationBuilder: ValidatableTextField.createDecorationGenerator(
            labelText: translation.password),
        obscureText: true,
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
                child: Text(translation.login),
                onPressed: () {
                  final usernameState = _usernameKey.currentState;
                  final passwordState = _passwordKey.currentState;

                  if (!usernameState.validateNow() ||
                      !passwordState.validateNow()) {
                    setState(() {
                      _error = translation.errorFixErrorAbove;
                    });
                    return;
                  }

                  setState(() {
                    _isProcessing = true;
                  });
                  UserManager()
                      .login(usernameState.text, passwordState.text)
                      .then((_) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }, onError: (error) {
                    String message;
                    int code = getCommonErrorCode(error);
                    if (code == -1001 || code == -1002) {
                      message = translation.errorBadCredential;
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
          translation.welcome,
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
