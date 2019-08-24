import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef Map<String, String> TranslationInitializer();

Map<String, String> _createEn() {
  return {
    "welcome": "Welcome to Timeline!",
    "username": "username",
    "enterUsername": "Please enter username.",
    "password": "password",
    "enterPassword": "Please enter password.",
    "login": "login",
    "fixErrorAbove": "Please fix errors above!",
    "badCredential": "Username or password is wrong.",
  };
}

Map<String, String> _createZh() {
  return {
    "welcome": "欢迎来到时间线！",
    "username": "用户名",
    "enterUsername": "请输入用户名。",
    "password": "密码",
    "enterPassword": "请输入密码。",
    "login": "登录",
    "fixErrorAbove": "请修复上面的错误！",
    "badCredential": "用户名或密码错误。"
  };
}

class TimelineLocalizations {
  TimelineLocalizations(this.locale) {
    _map = _initializerMap[locale.languageCode]();
  }

  Map<String, String> _map;

  final Locale locale;

  static TimelineLocalizations of(BuildContext context) {
    return Localizations.of<TimelineLocalizations>(
        context, TimelineLocalizations);
  }

  static Map<String, TranslationInitializer> _initializerMap = {
    'en': _createEn,
    'zh': _createZh,
  };

  String get welcome {
    return _map['welcome'];
  }

  String get username {
    return _map['username'];
  }

  String get enterUsername {
    return _map['enterUsername'];
  }

  String get password {
    return _map['password'];
  }

  String get enterPassword {
    return _map['enterPassword'];
  }

  String get login {
    return _map['login'];
  }

  String get fixErrorAbove {
    return _map['fixErrorAbove'];
  }

  String get badCredential {
    return _map['badCredential'];
  }
}

class TimelineLocalizationsDelegate
    extends LocalizationsDelegate<TimelineLocalizations> {
  const TimelineLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' ||
      (locale.languageCode == 'zh' && locale.scriptCode == 'Hans');

  @override
  Future<TimelineLocalizations> load(Locale locale) {
    return SynchronousFuture<TimelineLocalizations>(
        TimelineLocalizations(locale));
  }

  @override
  bool shouldReload(TimelineLocalizationsDelegate old) => false;
}
