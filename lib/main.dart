import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timeline/i18n.dart';

import 'administration.dart';
import 'home.dart';
import 'login.dart';
import 'user_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    UserManager.disposeInstance();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timeline',
      localizationsDelegates: [
        TimelineLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      ],
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => StartPage(),
        '/home': (context) => HomePage(title: 'Timeline'),
        '/administration': (context) => AdministrationPage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}

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
