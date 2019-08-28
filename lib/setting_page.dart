import 'package:flutter/material.dart';

import 'i18n.dart';
import 'operation_dialog.dart';
import 'user_service.dart';

@immutable
class SettingsPageTranslation {
  SettingsPageTranslation({
    @required this.headerAccount,
    @required this.itemLogout,
    @required this.itemChangePassword,
    @required this.messageConfirmLogout,
  });

  final String headerAccount;

  final String itemLogout;
  final String itemChangePassword;

  final String messageConfirmLogout;
}

class _SettingHeader extends StatelessWidget {
  _SettingHeader({@required this.title}) : assert(title != null);

  final Widget title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 5, 0, 5),
      alignment: AlignmentDirectional.centerStart,
      child: DefaultTextStyle(
        style: Theme.of(context)
            .primaryTextTheme
            .title
            .copyWith(color: Colors.blue),
        child: title,
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  _SettingItem({
    @required this.title,
    @required this.onTap,
    this.isDangerous = false,
  })  : assert(title != null),
        assert(isDangerous != null);

  final Widget title;

  final bool isDangerous;

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Material(
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(10),
            alignment: AlignmentDirectional.centerStart,
            child: DefaultTextStyle(
              style: Theme.of(context).primaryTextTheme.body1.copyWith(
                    color: isDangerous ? Colors.red : Colors.black,
                  ),
              child: title,
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final translation = TimelineLocalizations.of(context).settingsPage;

    return Scaffold(
      appBar: AppBar(
        title: Text('Timeline'),
      ),
      body: ListView(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _SettingHeader(
                title: Text(translation.headerAccount),
              ),
              Divider(
                height: 1,
              ),
              _SettingItem(
                title: Text(translation.itemChangePassword),
                onTap: () {},
              ),
              Divider(
                height: 1,
              ),
              _SettingItem(
                title: Text(translation.itemLogout),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return OperationDialog.confirm(
                        context,
                        subtitle: Text(TimelineLocalizations.of(context)
                            .settingsPage
                            .messageConfirmLogout),
                        operationFunction: () async {
                          await UserManager().logout();
                          Navigator.of(context)
                              .pushNamedAndRemoveUntil('/login', (_) => false);
                        },
                      );
                    },
                    barrierDismissible: false,
                  );
                },
                isDangerous: true,
              ),
              Divider(
                height: 1,
              ),
            ],
          )
        ],
      ),
    );
  }
}
