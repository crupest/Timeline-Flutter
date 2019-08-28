import 'package:flutter/material.dart';
import 'package:timeline/operation_dialog.dart';
import 'package:timeline/user_service.dart';

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
                title: Text('Account'),
              ),
              Divider(
                height: 1,
              ),
              _SettingItem(
                title: Text('Change password.'),
                onTap: () {},
              ),
              Divider(
                height: 1,
              ),
              _SettingItem(
                title: Text('Logout current account.'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return OperationDialog(
                        title: Text('Confirm'),
                        subtitle: Text('Are you sure you want to logout?'),
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
