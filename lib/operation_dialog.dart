import 'package:flutter/material.dart';

import 'i18n.dart';

enum OperationStep { input, progress, success, error }
typedef Future OperationFunction();

/// If operation succeeds and user click the ok button, then the dialog is popped with true.
/// If operation fails and user click the ok button, then the dialog is popped with false.
/// If dialog is dismissed any other way, then the dialog is popped with null.
///
/// You have 3 choices:
/// 1. If you want to do something after the dialog is dismissed then subscribe to the future
/// returned by showDailog.
/// 2. If you want to do something right after the operation succeeded, wrap actions in operationFunction.
/// 3. If you want to do something after the dialog is dismissed only and if operation succeeded, define
/// a bool value as false, change it to true in operationFunction, and subscribe the future returned
/// by showDialog, check the bool value in subscription function and do anything you like. 
class OperationDialog extends StatefulWidget {
  final Widget title;

  // a title that will show all the time.
  final Widget subtitle;

  final OperationFunction operationFunction;

  final Widget inputContent;

  /// If null a default one will be used. But this function can't return null if set.
  /// Default one is show a success message with green color.
  final Widget Function(BuildContext, dynamic) successContentBuilder;

  // if null a default one will be used. But this function can't return null.
  /// Default one is show error.toString() with red color.
  final Widget Function(BuildContext, dynamic) errorContentBuilder;

  OperationDialog({
    @required this.title,
    @required this.operationFunction,
    this.subtitle,
    this.inputContent,
    this.successContentBuilder,
    this.errorContentBuilder,
    Key key,
  })  : assert(title != null),
        assert(operationFunction != null),
        super(key: key);

  factory OperationDialog.confirm(
    BuildContext context, {
    @required OperationFunction operationFunction,
    Widget subtitle,
    Widget inputContent,
    Widget Function(BuildContext, dynamic) successContentBuilder,
    Widget Function(BuildContext, dynamic) errorContentBuilder,
    Key key,
  }) {
    return OperationDialog(
      title: Text(
        TimelineLocalizations.of(context).confirmTitle,
        style: Theme.of(context).primaryTextTheme.title.copyWith(
              color: Colors.blue,
            ),
      ),
      subtitle: subtitle,
      operationFunction: operationFunction,
      inputContent: inputContent,
      successContentBuilder: successContentBuilder,
      errorContentBuilder: errorContentBuilder,
      key: key,
    );
  }

  factory OperationDialog.create(
    BuildContext context, {
    @required OperationFunction operationFunction,
    Widget subtitle,
    Widget inputContent,
    Widget Function(BuildContext, dynamic) successContentBuilder,
    Widget Function(BuildContext, dynamic) errorContentBuilder,
    Key key,
  }) {
    return OperationDialog(
      title: Text(
        TimelineLocalizations.of(context).createTitle,
        style: Theme.of(context).primaryTextTheme.title.copyWith(
              color: Colors.green,
            ),
      ),
      subtitle: subtitle,
      operationFunction: operationFunction,
      inputContent: inputContent,
      successContentBuilder: successContentBuilder,
      errorContentBuilder: errorContentBuilder,
      key: key,
    );
  }

  factory OperationDialog.dangerous(
    BuildContext context, {
    @required OperationFunction operationFunction,
    Widget subtitle,
    Widget inputContent,
    Widget Function(BuildContext, dynamic) successContentBuilder,
    Widget Function(BuildContext, dynamic) errorContentBuilder,
    Key key,
  }) {
    return OperationDialog(
      title: Text(
        TimelineLocalizations.of(context).dangerousTitle,
        style: Theme.of(context).primaryTextTheme.title.copyWith(
              color: Colors.red,
            ),
      ),
      subtitle: subtitle,
      operationFunction: operationFunction,
      inputContent: inputContent,
      successContentBuilder: successContentBuilder,
      errorContentBuilder: errorContentBuilder,
      key: key,
    );
  }

  @override
  OperationDialogState createState() => OperationDialogState();
}

class OperationDialogState extends State<OperationDialog> {
  OperationStep _step;
  dynamic _resultObject; // result or error

  @override
  void initState() {
    super.initState();
    _step = OperationStep.input;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = TimelineLocalizations.of(context);

    List<Widget> content = [];
    final subtitle = widget.subtitle;
    if (subtitle != null)
      content.add(
        DefaultTextStyle(
          style: Theme.of(context)
              .primaryTextTheme
              .subtitle
              .copyWith(color: Colors.black),
          child: subtitle,
        ),
      );

    Widget createOkButton(bool success) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FlatButton(
            onPressed: () => Navigator.pop(context, success),
            child: Text(
              localizations.ok,
            ),
          )
        ],
      );
    }

    switch (_step) {
      case OperationStep.input:
        final inputContent = widget.inputContent;
        if (inputContent != null) content.add(inputContent);
        content.add(Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.cancel),
            ),
            FlatButton(
              onPressed: () {
                setState(() {
                  _step = OperationStep.progress;
                });
                widget.operationFunction().then((value) {
                  _resultObject = value;
                  setState(() {
                    _step = OperationStep.success;
                  });
                }, onError: (error) {
                  _resultObject = error;
                  setState(() {
                    _step = OperationStep.error;
                  });
                });
              },
              child: Text(localizations.confirm),
            ),
          ],
        ));
        break;
      case OperationStep.progress:
        content.add(
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          ),
        );
        break;
      case OperationStep.success:
        Widget c;
        if (widget.successContentBuilder != null) {
          c = widget.successContentBuilder(context, _resultObject);
          assert(c != null);
        } else {
          c = Center(
            child: Text(
              localizations.operationSucceeded,
              style: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.green),
            ),
          );
        }

        content.add(c);
        content.add(createOkButton(true));
        break;
      case OperationStep.error:
        Widget c;
        if (widget.errorContentBuilder != null) {
          c = widget.errorContentBuilder(context, _resultObject);
          assert(c != null);
        } else {
          c = Center(
            child: Text(
              _resultObject.toString(),
              style: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.red),
            ),
          );
        }

        content.add(c);
        content.add(createOkButton(false));
        break;
    }

    return AlertDialog(
      title: widget.title,
      content: IntrinsicHeight(
        child: Column(
          children: content,
        ),
      ),
    );
  }
}
