import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image;
import 'package:image_cropper/image_cropper.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:timeline/view_photo.dart';

import 'avatar.dart';
import 'dialog.dart';
import 'user_service.dart';
import 'drawer.dart';
import 'i18n.dart';
import 'http.dart';

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
    @required this.itemStateNotChange,
    @required this.itemStateWillClear,
    @required this.itemStateWillSet,
    @required this.saveChange,
    @required this.guessFormatFailure,
    @required this.uploadAvatar,
    @required this.requirementNickname,
    @required this.requirementQq,
    @required this.requirementEmail,
    @required this.requirementPhoneNumber,
    @required this.errorEditNotValid,
  });

  final String username;
  final String nickname;
  final String qq;
  final String email;
  final String phoneNumber;
  final String description;
  final String notSet;
  final String noDescriptionPlaceholder;

  final String itemStateNotChange;
  final String itemStateWillSet;
  final String itemStateWillClear;

  final String saveChange;

  final String guessFormatFailure;
  final String uploadAvatar;

  final String requirementNickname;
  final String requirementQq;
  final String requirementEmail;
  final String requirementPhoneNumber;
  final String errorEditNotValid;
}

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
  final res =
      await createDioWithToken().get('$apiBaseUrl/users/$username/details');
  Map<String, dynamic> body = res.data;
  return UserDetails(
    nickname: body[_nicknameKey],
    qq: body[_qqKey],
    email: body[_emailKey],
    phoneNumber: body[_phoneNumberKey],
    description: body[_descriptionKey],
  );
}

String _getImageMimeType(List<int> data) {
  final d = Uint8List.fromList(data);
  final decoder = image.findDecoderForData(d);

  if (decoder is image.PngDecoder) return 'image/png';
  if (decoder is image.JpegDecoder) return 'image/jpeg';
  if (decoder is image.GifDecoder) return 'image/gif';
  if (decoder is image.WebPDecoder) return 'image/webp';
  return null;
}

Future putUserAvatar(String username, String mimeType, List<int> data) async {
  assert(username != null);
  assert(username.isNotEmpty);
  assert(mimeType != null);
  assert(mimeType.isNotEmpty);

  await createDioWithToken().put(
    '$apiBaseUrl/users/$username/avatar',
    options: RequestOptions(
      headers: {
        HttpHeaders.contentTypeHeader: mimeType,
      },
    ),
    data: data,
  );
}

enum UserDetailItemEditState {
  notChange,
  willSet,
  notValid,
  willClear,
}

/// Feature:
/// 1. display grey message that item not changed (initText == value)
/// 2. display green message that item will be changed (initText != value && value.isNotEmpty)
/// 3. display red message that item is not valid (validate failed)
/// 4. display yellow message that item will be cleared (value.isEmpty && !initText.isNotEmpty)
class UserDetailEditItemController extends ChangeNotifier {
  UserDetailEditItemController({
    @required this.initText,
    @required this.validator,
    @required this.errorMessageGenerator,
  })  : assert(validator != null),
        assert(errorMessageGenerator != null) {
    _controller = TextEditingController(text: initText);
    _state = UserDetailItemEditState.notChange;
    _controller.addListener(() {
      _calculateState(_controller.text);
    });
  }

  final String initText;

  final int Function(String value) validator;

  final String Function(BuildContext context, int errorCode)
      errorMessageGenerator;

  TextEditingController _controller;

  UserDetailItemEditState _state;

  int _errorCode;

  TextEditingController get controller => _controller;

  UserDetailItemEditState get state => _state;

  int get errorCode => _errorCode;

  bool get isNoError => _state != UserDetailItemEditState.notValid;

  String get valueForResult {
    final text = _controller.text;
    return text.isEmpty ? null : text;
  }

  String get valueForRequest =>
      _state == UserDetailItemEditState.notChange ? null : _controller.text;

  void reset() {
    _controller.text = initText ?? '';
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  _calculateState(String value) {
    assert(value != null);

    final isInitEmpty = initText == null || initText.isEmpty;

    int validateValue() {
      return validator(value);
    }

    if (value.isEmpty) {
      if (isInitEmpty) {
        _state = UserDetailItemEditState.notChange;
        _errorCode = null;
      } else {
        _state = UserDetailItemEditState.willClear;
        _errorCode = null;
      }
      notifyListeners();
    } else {
      if (value == initText) {
        _state = UserDetailItemEditState.notChange;
        _errorCode = null;
        notifyListeners();
      } else {
        int errorCode = validateValue();
        if (errorCode != _errorCode ||
            _state == UserDetailItemEditState.notChange ||
            _state == UserDetailItemEditState.willClear) {
          _state = errorCode != null
              ? UserDetailItemEditState.notValid
              : UserDetailItemEditState.willSet;
          _errorCode = errorCode;
          notifyListeners();
        }
      }
    }
  }

  static const _colorMap = {
    UserDetailItemEditState.notChange: Colors.grey,
    UserDetailItemEditState.willSet: Colors.green,
    UserDetailItemEditState.notValid: Colors.red,
    UserDetailItemEditState.willClear: Colors.yellow,
  };

  Color get suggestedColor => _colorMap[_state];

  String getTranslatedMessage(BuildContext context) {
    final translation = TimelineLocalizations.of(context).userDetail;
    switch (state) {
      case UserDetailItemEditState.notChange:
        return translation.itemStateNotChange;
      case UserDetailItemEditState.willSet:
        return translation.itemStateWillSet;
      case UserDetailItemEditState.willClear:
        return translation.itemStateWillClear;
      case UserDetailItemEditState.notValid:
        return errorMessageGenerator(context, errorCode);
      default:
        return null;
    }
  }
}

class UserDetailEditItem extends StatefulWidget {
  UserDetailEditItem({
    @required this.label,
    @required this.controller,
    this.multiline = false,
    Key key,
  })  : assert(label != null),
        assert(controller != null),
        assert(multiline != null),
        super(key: key);

  final String label;

  final UserDetailEditItemController controller;

  final bool multiline;

  @override
  _UserDetailEditItemState createState() => _UserDetailEditItemState();
}

class _UserDetailEditItemState extends State<UserDetailEditItem> {
  UserDetailEditItemController get _controller => widget.controller;

  void Function() _listener;

  @override
  void initState() {
    super.initState();
    _listener = () {
      setState(() {});
    };
    _controller.addListener(_listener);
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final multiline = widget.multiline;

    final isError = _controller.state == UserDetailItemEditState.notValid;
    final message = _controller.getTranslatedMessage(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: TextField(
        controller: _controller.controller,
        decoration: InputDecoration(
          isDense: multiline ? false : true,
          labelText: widget.label,
          errorText: isError ? message : null,
          helperText: !isError ? message : null,
          helperStyle: TextStyle(color: _controller.suggestedColor),
          border: multiline ? OutlineInputBorder() : null,
        ),
        maxLines: multiline ? 10 : 1,
        textAlignVertical: multiline ? TextAlignVertical.top : null,
      ),
    );
  }
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
    final translation = TimelineLocalizations.of(context).userDetail;

    final user = UserManager().user;
    final editable = user.username == username || user.administrator;

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

        Widget avatarArea = Padding(
          padding: EdgeInsets.fromLTRB(5, 5, 30, 5),
          child: Avatar(
            username,
            onPressed: () {
              viewPhoto(context, avatarImageProvider(username));
            },
          ),
        );

        if (editable) {
          avatarArea = Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              avatarArea,
              Container(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    final image =
                        await MultiImagePicker.pickImages(maxImages: 1);
                    final path = await image.first.filePath;

                    final croppedImage = await ImageCropper.cropImage(
                      sourcePath: path,
                      ratioX: 1.0,
                      ratioY: 1.0,
                    );

                    final data = await croppedImage.readAsBytes();

                    final mimeType = _getImageMimeType(data);
                    if (mimeType == null) {
                      showErrorDialog(
                        context,
                        (context) => TimelineLocalizations.of(context)
                            .userDetail
                            .guessFormatFailure,
                      );
                      return;
                    }

                    showDialog(
                      context: context,
                      builder: (context) {
                        return OperationDialog.confirm(
                          inputContent: Text(TimelineLocalizations.of(context)
                              .userDetail
                              .uploadAvatar),
                          operationFunction: () async {
                            await putUserAvatar(username, mimeType, data);
                          },
                        );
                      },
                      barrierDismissible: false,
                    );
                  },
                ),
              ),
            ],
          );
        }

        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: avatarArea,
                ),
                Expanded(
                  flex: 5,
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        createItem(translation.username, username, null),
                        createItem(translation.nickname, _details.nickname,
                            translation.notSet),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            createItem(translation.qq, _details.qq, translation.notSet),
            createItem(translation.email, _details.email, translation.notSet),
            createItem(translation.phoneNumber, _details.phoneNumber,
                translation.notSet),
            createItem(translation.description, _details.description,
                translation.noDescriptionPlaceholder),
          ],
        );
      }
    }

    List<Widget> actions;
    if (editable) {
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
  await createDioWithToken()
      .patch('$apiBaseUrl/users/$username/details', data: {
    _nicknameKey: details.nickname,
    _qqKey: details.qq,
    _emailKey: details.email,
    _phoneNumberKey: details.phoneNumber,
    _descriptionKey: details.description,
  });
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

bool _isDigit(String value, int index) {
  return value[index] == "0" ||
      value[index] == "1" ||
      value[index] == "2" ||
      value[index] == "3" ||
      value[index] == "4" ||
      value[index] == "5" ||
      value[index] == "6" ||
      value[index] == "7" ||
      value[index] == "8" ||
      value[index] == "9";
}

final _emailReg = RegExp('^[-_.a-zA-Z0-9]+@([-a-zA-Z0-9]+\\.)+[a-z]{2,4}\$');

class _UserDetailEditPageState extends State<_UserDetailEditPage> {
  UserDetailEditItemController _nicknameController;
  UserDetailEditItemController _qqController;
  UserDetailEditItemController _emailController;
  UserDetailEditItemController _phoneNumberController;
  UserDetailEditItemController _descriptionController;

  List<UserDetailEditItemController> _controllers;

  @override
  void initState() {
    super.initState();

    final oldDetails = widget.oldDetails;

    _nicknameController = UserDetailEditItemController(
      initText: oldDetails.nickname,
      validator: (value) {
        if (value.length > 10) return 1;
        return null;
      },
      errorMessageGenerator: (context, _) =>
          TimelineLocalizations.of(context).userDetail.requirementNickname,
    );

    _qqController = UserDetailEditItemController(
      initText: oldDetails.qq,
      validator: (value) {
        if (value.length < 5) return 1;
        if (value.length > 11) return 2;
        for (int i = 0; i < value.length; i++) {
          if (!_isDigit(value, i)) return 3;
        }
        return null;
      },
      errorMessageGenerator: (context, _) =>
          TimelineLocalizations.of(context).userDetail.requirementQq,
    );

    _emailController = UserDetailEditItemController(
      initText: oldDetails.email,
      validator: (value) {
        if (value.length > 50) return 1;
        if (!_emailReg.hasMatch(value)) return 2;
        return null;
      },
      errorMessageGenerator: (context, _) =>
          TimelineLocalizations.of(context).userDetail.requirementEmail,
    );

    _phoneNumberController = UserDetailEditItemController(
      initText: oldDetails.phoneNumber,
      validator: (value) {
        if (value.length > 14) return 1;
        for (int i = 0; i < value.length; i++) {
          if (!_isDigit(value, i)) return 2;
        }
        return null;
      },
      errorMessageGenerator: (context, _) =>
          TimelineLocalizations.of(context).userDetail.requirementPhoneNumber,
    );

    _descriptionController = UserDetailEditItemController(
      initText: oldDetails.description,
      validator: (_) => null,
      errorMessageGenerator: (_, _a) => null,
    );

    _controllers = [
      _nicknameController,
      _qqController,
      _emailController,
      _phoneNumberController,
      _descriptionController,
    ];
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
    final translation = TimelineLocalizations.of(context).userDetail;

    Widget body = ListView(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(5),
          child: Row(
            children: <Widget>[
              Text(
                translation.username,
                style: TextStyle(color: Colors.blue),
              ),
              Padding(
                padding: EdgeInsets.only(left: 6),
                child: Text(
                  widget.username,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        UserDetailEditItem(
          controller: _nicknameController,
          label: translation.nickname,
        ),
        UserDetailEditItem(
          controller: _qqController,
          label: translation.qq,
        ),
        UserDetailEditItem(
          controller: _emailController,
          label: translation.email,
        ),
        UserDetailEditItem(
          controller: _phoneNumberController,
          label: translation.phoneNumber,
        ),
        Padding(
          padding: EdgeInsets.only(top: 18),
          child: UserDetailEditItem(
            controller: _descriptionController,
            label: translation.description,
            multiline: true,
          ),
        )
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Timeline'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              bool success = false;

              bool check() {
                for (final controller in _controllers)
                  if (!controller.isNoError) return false;
                return true;
              }

              if (!check()) {
                showErrorDialog(
                  context,
                  (context) => TimelineLocalizations.of(context)
                      .userDetail
                      .errorEditNotValid,
                );
                return;
              }

              showDialog(
                context: context,
                builder: (context) {
                  return OperationDialog.confirm(
                    inputContent: Text(TimelineLocalizations.of(context)
                        .userDetail
                        .saveChange),
                    operationFunction: () async {
                      await updateUserDetail(
                        widget.username,
                        UserDetails(
                          nickname: _nicknameController.valueForRequest,
                          qq: _qqController.valueForRequest,
                          email: _emailController.valueForRequest,
                          phoneNumber: _phoneNumberController.valueForRequest,
                          description: _descriptionController.valueForRequest,
                        ),
                      );
                      success = true;
                    },
                  );
                },
                barrierDismissible: false,
              ).then((_) {
                if (success == true) {
                  Navigator.of(context).pop(
                    UserDetails(
                      nickname: _nicknameController.valueForResult,
                      qq: _qqController.valueForResult,
                      email: _emailController.valueForResult,
                      phoneNumber: _phoneNumberController.valueForResult,
                      description: _descriptionController.valueForResult,
                    ),
                  );
                }
              });
            },
          )
        ],
      ),
      body: body,
    );
  }
}
