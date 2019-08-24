import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

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
  final res = await get('$apiBaseUrl/users/$username/details');
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
      _doneFetch = true;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_doneFetch == false) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      if (_error != null) {
        return Center(
          child: Text(
            _error.toString(),
          ),
        );
      } else {
        return Column(
          children: <Widget>[
            //TODO
          ],
        );
      }
    }
  }
}
