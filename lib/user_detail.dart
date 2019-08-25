import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'avatar.dart';
import 'operation_dialog.dart';
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
                                .body1
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

    final user = UserManager.getInstance().currentUser;
    List<Widget> actions;
    if (user.username == username || user.administrator) {
      actions = [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return _UserDetailEditPage(
                  username: username, oldDetails: _details);
            })).then((value) {
              if (value != null)
                setState(() {
                  _details = value;
                });
            });
          },
        )
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Timeline'),
        actions: actions,
      ),
      body: content,
      drawer: MyDrawer(
        selectedItem: DrawerSelectedItem.none,
      ),
    );
  }
}

Future updateUserDetail(String username, UserDetails details) async {
  assert(username != null);
  assert(username.isNotEmpty);
  final res = await patch(
      '$apiBaseUrl/users/$username/details?token=${UserManager.getInstance().token}',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        _nicknameKey: details.nickname,
        _qqKey: details.qq,
        _emailKey: details.email,
        _phoneNumberKey: details.phoneNumber,
        _descriptionKey: details.description,
      }));
  checkError(res);
}

class _UserDetailEditPage extends StatefulWidget {
  _UserDetailEditPage({@required this.username, @required this.oldDetails})
      : assert(username != null),
        assert(username.isNotEmpty),
        assert(oldDetails != null);

  final String username;
  final UserDetails oldDetails;

  @override
  _UserDetailEditPageState createState() => _UserDetailEditPageState();
}

class _UserDetailEditPageState extends State<_UserDetailEditPage> {
  final _nicknameController = TextEditingController();
  final _qqController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final oldDetails = widget.oldDetails;

    String coerce(String raw) => raw == null ? '' : raw;
    _nicknameController.text = coerce(oldDetails.nickname);
    _qqController.text = coerce(oldDetails.qq);
    _emailController.text = coerce(oldDetails.email);
    _phoneNumberController.text = coerce(oldDetails.phoneNumber);
    _descriptionController.text = coerce(oldDetails.description);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _qqController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = TimelineLocalizations.of(context);

    Widget content = Container();

    Widget createField(
      String name,
      TextEditingController controller, {
      bool outlineBorder = false,
      bool expand = false,
    }) {
      return Container(
        padding: EdgeInsets.all(5),
        child: TextField(
          controller: controller,
          maxLines: expand ? null : 1,
          expands: expand,
          textAlignVertical: expand ? TextAlignVertical.top : null,
          decoration: InputDecoration(
            labelText: name,
            border: outlineBorder ? OutlineInputBorder() : null,
          ),
        ),
      );
    }

    content = Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(5),
          child: Row(
            children: <Widget>[
              Text(
                localizations.username,
                style: Theme.of(context).primaryTextTheme.body1.copyWith(
                      color: Colors.blue,
                    ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 6),
                child: Text(
                  widget.username,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .title
                      .copyWith(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        createField(localizations.nickname, _nicknameController),
        createField(localizations.qq, _qqController),
        createField(localizations.email, _emailController),
        createField(localizations.phoneNumber, _phoneNumberController),
        Expanded(
          child: createField(
              localizations.userDescription, _descriptionController,
              outlineBorder: true, expand: true),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Timeline'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  //TODO: error message
                  return OperationDialog(
                    title: Text('Confirm!'), //TODO: translation.
                    subtitle: Text('Are you sure to change your informantion?'),
                    operationFunction: () {
                      return updateUserDetail(
                        widget.username,
                        UserDetails(
                          nickname: _nicknameController.text,
                          qq: _qqController.text,
                          email: _emailController.text,
                          phoneNumber: _phoneNumberController.text,
                          description: _descriptionController.text,
                        ),
                      );
                    },
                    onOk: () {
                      String coerce(String raw) => raw.isEmpty ? null : raw;

                      Navigator.of(context).pop(
                        UserDetails(
                          nickname: coerce(_nicknameController.text),
                          qq: coerce(_qqController.text),
                          email: coerce(_emailController.text),
                          phoneNumber: coerce(_phoneNumberController.text),
                          description: coerce(_descriptionController.text),
                        ),
                      );
                    },
                  );
                },
                barrierDismissible: false,
              );
            },
          )
        ],
      ),
      body: content,
    );
  }
}
