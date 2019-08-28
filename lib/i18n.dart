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
    "nickname": "nickname",
    "qq": "QQ",
    "email": "email",
    "phoneNumber": "phone number",
    "userDescription": "description",
    "notSet": "not set",
    "noUserDescriptionPlaceholder": "This person has not set a description.",
    "confirmTitle": "Confirm",
    "createTitle": "Create",
    "dangerousTitle": "Dangerous",
    "cancel": "cancel",
    "confirm": "confirm",
    "ok": 'OK',
    "operationSucceeded": "Operation succeeded!",
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
    "badCredential": "用户名或密码错误。",
    "nickname": "昵称",
    "qq": "QQ",
    "email": "电子邮箱",
    "phoneNumber": "电话号码",
    "userDescription": "个人说明",
    "notSet": "未设置",
    "noUserDescriptionPlaceholder": "这个人懒到没有设置个人说明。",
    "confirmTitle": "确认",
    "createTitle": "创建",
    "dangerousTitle": "危险",
    "cancel": "取消",
    "confirm": "确认",
    "ok": "好的",
    "operationSucceeded": "操作成功啦！",
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

  String get nickname {
    return _map['nickname'];
  }

  String get qq {
    return _map['qq'];
  }

  String get email {
    return _map['email'];
  }

  String get phoneNumber => _map['phoneNumber'];

  String get userDescription => _map['userDescription'];

  String get notSet => _map['notSet'];

  String get noUserDescriptionPlaceholder =>
      _map['noUserDescriptionPlaceholder'];

  String get confirmTitle => _map['confirmTitle'];

  String get createTitle => _map['createTitle'];

  String get dangerousTitle => _map['dangerousTitle'];

  String get cancel => _map['cancel'];

  String get confirm => _map['confirm'];

  String get ok => _map['ok'];

  String get operationSucceeded => _map['operationSucceeded'];
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
