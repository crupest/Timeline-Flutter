import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class OperationDialogTranslation {
  OperationDialogTranslation({
    @required this.confirmTitle,
    @required this.createTitle,
    @required this.dangerousTitle,
    @required this.cancel,
    @required this.confirm,
    @required this.ok,
    @required this.operationSucceeded,
  });

  final String confirmTitle;
  final String createTitle;
  final String dangerousTitle;
  final String cancel;
  final String confirm;
  final String ok;
  final String operationSucceeded;
}

@immutable
class LoginPageTranslation {
  LoginPageTranslation({
    @required this.username,
    @required this.password,
    @required this.login,
    @required this.welcome,
    @required this.errorEnterUsername,
    @required this.errorEnterPassword,
    @required this.errorFixErrorAbove,
    @required this.errorBadCredential,
  });

  final String username;
  final String password;
  final String login;
  final String welcome;
  final String errorEnterUsername;
  final String errorEnterPassword;
  final String errorFixErrorAbove;
  final String errorBadCredential;
}

@immutable
class UserDetailTranslation {
  UserDetailTranslation({
    @required this.username,
    @required this.nickname,
    @required this.qq,
    @required this.email,
    @required this.phoneNumber,
    @required this.description,
    @required this.notSet,
    @required this.noDescriptionPlaceholder,
  });

  final String username;
  final String nickname;
  final String qq;
  final String email;
  final String phoneNumber;
  final String description;
  final String notSet;
  final String noDescriptionPlaceholder;
}

@immutable
class Translation {
  Translation({
    @required this.operationDialog,
    @required this.loginPage,
    @required this.userDetail,
  });

  final OperationDialogTranslation operationDialog;
  final LoginPageTranslation loginPage;
  final UserDetailTranslation userDetail;
}

Translation _createEnglishTranslation() {
  const username = 'username';

  return Translation(
    operationDialog: OperationDialogTranslation(
      confirmTitle: 'Confirm',
      createTitle: 'Create',
      dangerousTitle: 'Dangerous',
      cancel: 'cancel',
      confirm: 'confirm',
      ok: 'OK',
      operationSucceeded: 'Operation succeeded!',
    ),
    loginPage: LoginPageTranslation(
      username: username,
      password: 'password',
      login: 'login',
      welcome: 'Welcome to Timeline!',
      errorEnterUsername: 'Please enter username.',
      errorEnterPassword: 'Please enter password.',
      errorFixErrorAbove: 'Please fix errors above!',
      errorBadCredential: 'Username or password is wrong.',
    ),
    userDetail: UserDetailTranslation(
      username: username,
      nickname: 'nickname',
      qq: 'QQ',
      email: 'email',
      phoneNumber: 'phone number',
      description: 'description',
      notSet: 'not set',
      noDescriptionPlaceholder: 'This person has not set a description.',
    ),
  );
}

Translation _createChineseTranslation() {
  const username = '用户名';

  return Translation(
    operationDialog: OperationDialogTranslation(
      confirmTitle: '确认',
      createTitle: '创建',
      dangerousTitle: '危险',
      cancel: '取消',
      confirm: '确认',
      ok: '好的',
      operationSucceeded: '操作成功啦！',
    ),
    loginPage: LoginPageTranslation(
      username: username,
      password: '密码',
      login: '登录',
      welcome: '欢迎来到时间线！',
      errorEnterUsername: '请输入用户名。',
      errorEnterPassword: '请输入密码。',
      errorFixErrorAbove: '请修复上面的错误！',
      errorBadCredential: '用户名或密码错误。',
    ),
    userDetail: UserDetailTranslation(
      username: username,
      nickname: '昵称',
      qq: 'QQ',
      email: '电子邮箱',
      phoneNumber: '电话号码',
      description: '个人说明',
      notSet: '未设置',
      noDescriptionPlaceholder: '这个人懒到没有设置个人说明。',
    ),
  );
}

class TimelineLocalizations {
  TimelineLocalizations(this.locale) {
    _translation = _initializerMap[locale.languageCode]();
  }

  Translation _translation;

  Translation get translation => _translation;

  final Locale locale;

  static Translation of(BuildContext context) {
    return Localizations.of<TimelineLocalizations>(
            context, TimelineLocalizations)
        .translation;
  }

  static Map<String, Translation Function()> _initializerMap = {
    'en': _createEnglishTranslation,
    'zh': _createChineseTranslation,
  };
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
