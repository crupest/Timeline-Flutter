import 'package:fluro/fluro.dart';

import 'home.dart';
import 'login.dart';
import 'start.dart';

final router = Router();

final _rootHandler = Handler(handlerFunc: (context, params) => StartPage());

final _homeHandler =
    Handler(handlerFunc: (context, params) => HomePage(title: 'Timeline'));

final _loginHandler = Handler(handlerFunc: (context, params) => LoginPage());

final _administrationHandler =
    Handler(handlerFunc: (context, params) => LoginPage());

void configureRoutes(Router router) {
  router.define('/', handler: _rootHandler);
  router.define('/home', handler: _homeHandler);
  router.define('/login', handler: _loginHandler);
  router.define('/admin', handler: _administrationHandler);
}
