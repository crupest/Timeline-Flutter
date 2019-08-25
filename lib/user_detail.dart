import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'avatar.dart';
import 'user_service.dart';
import 'drawer.dart';
import 'i18n.dart';
import 'http.dart';

class UserDetails {
  UserDetails({
    this.nickname,
    this.qq,
    this.email,
    this.phoneNumber,
    this.description,
  });

  String nickname;
  String qq;
  String email;
  String phoneNumber;
  String description;
}

const _nicknameKey = 'nickname';
const _qqKey = 'qq';
const _emailKey = 'email';
const _phoneNumberKey = 'phoneNumber';
const _descriptionKey = 'description';

Future<UserDetails> fetchUserDetail(String username) async {
  assert(username != null);
  assert(username.isNotEmpty);
  final res = await get(
      '$apiBaseUrl/users/$username/details?token=${UserManager.getInstance().token}');
  checkError(res);
  Map<String, dynamic> body = jsonDecode(res.body);
  return UserDetails(
    nickname: body[_nicknameKey],
    qq: body[_qqKey],
    email: body[_emailKey],
    phoneNumber: body[_phoneNumberKey],
    description: body[_descriptionKey],
  );
}

class UserDetailPage extends StatefulWidget {
  UserDetailPage({@required this.username, Key key})
      : assert(username != null),
        super(key: key);

  final String username;

  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  bool _doneFetch = false;
  dynamic _error;

  UserDetails _details;

  get username => widget.username;

  @override
  void initState() {
    super.initState();
    fetchUserDetail(widget.username).then((value) {
      setState(() {
        _doneFetch = true;
        _details = value;
        _error = null;
      });
    }, onError: (error) {
      setState(() {
        _doneFetch = true;
        _error = error;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = TimelineLocalizations.of(context);

    Widget content;

    if (_doneFetch == false) {
      content = Center(
        child: CircularProgressIndicator(),
      );
    } else {
      if (_error != null) {
        content = Center(
          child: Text(
            _error.toString(),
          ),
        );
      } else {
        Widget createItem(String name, String value, String placeHoler) {
          return Container(
            padding: EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: Theme.of(context).primaryTextTheme.body1.copyWith(
                        color: Colors.blue,
                      ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: value != null
                        ? Text(
                            value,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .title
                                .copyWith(color: Colors.black),
                          )
                        : Text(
                            placeHoler,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .title
                                .copyWith(color: Colors.grey),
                          )),
              ],
            ),
          );
        }

        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Avatar(username),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        createItem(localizations.username, username, null),
                        createItem(localizations.nickname, _details.nickname,
                            localizations.notSet),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            createItem(localizations.qq, _details.qq, localizations.notSet),
            createItem(
                localizations.email, _details.email, localizations.notSet),
            createItem(localizations.phoneNumber, _details.phoneNumber,
                localizations.notSet),
            createItem(localizations.userDescription, _details.description,
                localizations.noUserDescriptionPlaceholder),
          ],
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Timeline'),
      ),
      body: content,
      drawer: MyDrawer(
        selectedItem: DrawerSelectedItem.none,
      ),
    );
  }
}
