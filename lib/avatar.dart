import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeline/user_service.dart';

import 'http.dart';

String _getAvatarUrl(String username) {
  assert(username != null);
  assert(username.isNotEmpty);
  return "$apiBaseUrl/users/$username/avatar?token=${UserManager.getInstance().token}";
}

ImageProvider avatarImageProvider(String username) {
  assert(username != null);
  assert(username.isNotEmpty);
  return CachedNetworkImageProvider(_getAvatarUrl(username));
}

class Avatar extends StatelessWidget {
  Avatar(this.username, {this.onPressed})
      : assert(username != null),
        assert(username.isNotEmpty);

  final String username;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    Widget content = CachedNetworkImage(
      imageUrl: _getAvatarUrl(username),
    );

    if (onPressed == null) {
      content = ClipOval(
        child: Container(
          color: Colors.white,
          child: content,
        ),
      );
    } else {
      content = Material(
        color: Colors.white,
        shape: CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: content,
        ),
      );
    }

    return content;
  }
}
