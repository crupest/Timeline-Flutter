import 'package:flutter/material.dart';

enum OperationStep { input, progress, done }
typedef Future OperationFunction();

typedef void OperationSuccessCallback();

class OperationDialog extends StatefulWidget {
  final Widget title;
  final Widget subtitle;

  final List<Widget> inputContent;

  final OperationFunction operationFunction;

  final OperationSuccessCallback onOk;

  OperationDialog({
    @required this.title,
    @required this.subtitle,
    this.inputContent = const [],
    @required this.operationFunction,
    this.onOk,
    Key key,
  })  : assert(operationFunction != null),
        super(key: key);

  @override
  OperationDialogState createState() => OperationDialogState();
}

class OperationDialogState extends State<OperationDialog> {
  OperationStep _step;
  dynamic _error;

  @override
  void initState() {
    super.initState();
    _step = OperationStep.input;
  }

  @override
  Widget build(BuildContext context) {
    var subtitle = widget.subtitle;

    List<Widget> content;

    switch (_step) {
      case OperationStep.input:
        content = [
          subtitle,
          ...widget.inputContent,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              FlatButton(
                onPressed: () {
                  setState(() {
                    _step = OperationStep.progress;
                  });
                  widget.operationFunction().then((_) {
                    setState(() {
                      _step = OperationStep.done;
                    });
                  }, onError: (error) {
                    setState(() {
                      _step = OperationStep.done;
                      _error = error;
                    });
                  });
                },
                child: Text('Confirm'),
              ),
            ],
          )
        ];
        break;
      case OperationStep.progress:
        content = [
          subtitle,
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          ),
        ];
        break;
      case OperationStep.done:
        var buttonBar = Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context, true);
                if (widget.onOk != null) widget.onOk();
              },
              child: Text(
                'Ok',
              ),
            )
          ],
        );
        if (_error == null) {
          content = [
            subtitle,
            Center(
              child: Text(
                'Success!',
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: Colors.green),
              ),
            ),
            buttonBar
          ];
        } else {
          content = [
            subtitle,
            Center(
              child: Text(
                'Error!\n$_error',
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: Colors.red),
              ),
            ),
            buttonBar
          ];
        }
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
