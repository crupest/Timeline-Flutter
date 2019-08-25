import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeline/user_service.dart';

import 'http.dart';

class Avatar extends StatelessWidget {
  Avatar(this.username)
      : assert(username != null),
        assert(username.isNotEmpty);

  final String username;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        color: Colors.white,
        child: CachedNetworkImage(
          imageUrl:
              "$apiBaseUrl/users/$username/avatar?token=${UserManager.getInstance().token}",
        ),
      ),
    );
  }
}
