import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'dialog.dart';
import 'setting_page.dart';
import 'user_detail.dart';

@immutable
class DrawerTranslation {
  DrawerTranslation({
    @required this.home,
    @required this.administration,
    @required this.settings,
  });

  final String home;
  final String administration;
  final String settings;
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
class Translation {
  Translation({
    @required this.dialog,
    @required this.operationDialog,
    @required this.drawer,
    @required this.loginPage,
    @required this.userDetail,
    @required this.settingsPage,
  });

  final DialogTranslation dialog;
  final OperationDialogTranslation operationDialog;
  final DrawerTranslation drawer;
  final LoginPageTranslation loginPage;
  final UserDetailTranslation userDetail;
  final SettingsPageTranslation settingsPage;
}

Translation _createEnglishTranslation() {
  const username = 'username';

  return Translation(
    dialog: DialogTranslation(
      errorTitle: 'Error',
      errorOk: 'Ok',
    ),
    operationDialog: OperationDialogTranslation(
      confirmTitle: 'Confirm',
      createTitle: 'Create',
      dangerousTitle: 'Dangerous',
      cancel: 'cancel',
      confirm: 'confirm',
      ok: 'OK',
      operationSucceeded: 'Operation succeeded!',
    ),
    drawer: DrawerTranslation(
      home: 'Home',
      administration: 'Administration',
      settings: 'Settings',
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
      itemStateNotChange: 'This item is not changed.',
      itemStateWillSet: 'This item has been modified.',
      itemStateWillClear: 'This item will be cleared.',
      saveChange: 'Are you sure to save the changes?',
      guessFormatFailure: 'Failed to guess the format of the picture.',
      uploadAvatar: 'Are you sure to upload the new avatar?',
    ),
    settingsPage: SettingsPageTranslation(
      headerAccount: 'Account',
      itemLogout: 'Logout current account.',
      itemChangePassword: 'Change password.',
      messageConfirmLogout: 'Are you sure to logout current account?',
    ),
  );
}

Translation _createChineseTranslation() {
  const username = '用户名';

  return Translation(
    dialog: DialogTranslation(
      errorTitle: '错误',
      errorOk: '知道了',
    ),
    operationDialog: OperationDialogTranslation(
      confirmTitle: '确认',
      createTitle: '创建',
      dangerousTitle: '危险',
      cancel: '取消',
      confirm: '确认',
      ok: '好的',
      operationSucceeded: '操作成功啦！',
    ),
    drawer: DrawerTranslation(
      home: '主页',
      administration: '管理',
      settings: '设置',
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
      itemStateNotChange: '这一项未修改。',
      itemStateWillSet: '这一项已修改。',
      itemStateWillClear: '这一项将被清除。',
      saveChange: '你确定要保存修改吗？',
      guessFormatFailure: '判断图片的格式失败。',
      uploadAvatar: '确定要上传新的头像吗？',
    ),
    settingsPage: SettingsPageTranslation(
      headerAccount: '账号',
      itemLogout: '退出当前账号。',
      itemChangePassword: '修改密码。',
      messageConfirmLogout: '您确定要退出当前账号吗？',
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
