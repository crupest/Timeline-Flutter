import 'package:flutter/material.dart';

class ValidatableTextField extends StatefulWidget {
  static InputDecoration Function(BuildContext, String)
      createDecorationGenerator({String labelText, bool isDense}) {
    return (context, errorText) {
      return InputDecoration(
        labelText: labelText,
        errorText: errorText,
        isDense: isDense,
      );
    };
  }

  ValidatableTextField({
    @required this.validator,
    @required this.errorMessageGenerator,
    @required this.decorationBuilder,
    this.initValidate = false,
    this.obscureText = false,
    this.initText,
    Key key,
  })  : assert(validator != null),
        assert(errorMessageGenerator != null),
        assert(decorationBuilder != null),
        assert(initValidate != null),
        assert(obscureText != null),
        super(key: key);

  final int Function(String value) validator;

  final String Function(BuildContext context, int errorCode)
      errorMessageGenerator;

  final InputDecoration Function(BuildContext context, String errorMessage)
      decorationBuilder;

  final bool initValidate;

  final bool obscureText;

  final String initText;

  @override
  ValidatableTextFieldState createState() => ValidatableTextFieldState();
}

class ValidatableTextFieldState extends State<ValidatableTextField> {
  TextEditingController _controller;

  int _errorCode;

  int get errorCode => _errorCode;
  String get text => _controller.text;

  bool _validate(String value) {
    final errorCode = widget.validator(value);
    if (errorCode != _errorCode) {
      setState(() {
        _errorCode = errorCode;
      });
    }
    return errorCode == null;
  }

  bool validateNow() {
    return _validate(text);
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initText);
    if (widget.initValidate) {
      _errorCode = widget.validator(widget.initText);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (value) {
        _validate(value);
      },
      obscureText: widget.obscureText,
      decoration: widget.decorationBuilder(
          context,
          _errorCode != null
              ? widget.errorMessageGenerator(context, _errorCode)
              : null),
    );
  }
}
