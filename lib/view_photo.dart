import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

void viewPhoto(BuildContext context, ImageProvider imageProvider) {
  assert(context != null);
  assert(imageProvider != null);

  Navigator.of(context).push(_ViewPhoteRoute(
    builder: (context) {
      return _ViewPhotePage(
        image: imageProvider,
      );
    },
  ));
}

class _ViewPhoteRoute<T> extends PageRoute<T> {
  _ViewPhoteRoute({this.builder}) : super();

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    );
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }
}

class _ViewPhotePage extends StatelessWidget {
  _ViewPhotePage({@required this.image}) : assert(image != null);

  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timeline'),
      ),
      backgroundColor: Colors.black.withAlpha(150),
      body: Container(
        alignment: Alignment.center,
        child: PhotoView(
          imageProvider: image,
          backgroundDecoration: BoxDecoration(
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
