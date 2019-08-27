import 'package:fluro/fluro.dart';
import 'package:timeline/setting_page.dart';

import 'administration.dart';
import 'home.dart';
import 'user_detail.dart';
import 'login.dart';
import 'start.dart';

final router = Router();

final _rootHandler = Handler(
  handlerFunc: (context, params) => StartPage(),
);

final _homeHandler = Handler(
  handlerFunc: (context, params) => HomePage(title: 'Timeline'),
);

final _loginHandler = Handler(
  handlerFunc: (context, params) => LoginPage(),
);

final _administrationHandler = Handler(
  handlerFunc: (context, params) => AdministrationPage(),
);

final _userDetailHandler = Handler(
  handlerFunc: (context, params) => UserDetailPage(
    username: params['username'].first,
  ),
);

final _settingsHandler = Handler(
  handlerFunc: (context, params) => SettingsPage(),
);

void configureRoutes(Router router) {
  router.define('/', handler: _rootHandler);
  router.define('/home', handler: _homeHandler);
  router.define('/login', handler: _loginHandler);
  router.define('/admin', handler: _administrationHandler);
  router.define('/users/:username/details', handler: _userDetailHandler);
  router.define('/settings', handler: _settingsHandler);
}
