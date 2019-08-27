import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui show instantiateImageCodec, Codec;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

import 'user_service.dart';
import 'http.dart';

class _AvatarImageProvider extends ImageProvider<_AvatarImageProvider> {
  _AvatarImageProvider(this.codec, {this.scale = 1.0});

  final Future<ui.Codec> codec;
  final double scale;

  @override
  Future<_AvatarImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture(this);
  }

  @override
  ImageStreamCompleter load(_AvatarImageProvider key) {
    return MultiFrameImageStreamCompleter(codec: codec, scale: scale);
  }
}

class _AvatarManager {
  static _AvatarManager _instance;

  factory _AvatarManager() {
    if (_instance == null) {
      _instance = _AvatarManager._();
    }
    return _instance;
  }

  String _cacheDir;
  File _etagMapFile;

  Map<String, String> _etagMap;

  _AvatarManager._();

  Future _checkAndInit() async {
    if (_cacheDir == null) {
      _cacheDir = (await getTemporaryDirectory()).path + '/avatars';
      _etagMapFile = File(_cacheDir + '/!etags');
      _etagMap = {};
      if (!(await _etagMapFile.exists())) {
        await _etagMapFile.create(recursive: true);
        await _etagMapFile.writeAsString('{}');
      } else {
        final content = await _etagMapFile.readAsString();
        final map = jsonDecode(content) as Map<String, dynamic>;
        map.forEach((k, v) => _etagMap[k] = (v as String));
      }
    }
  }

  String _getAvatarUrl(String username) {
    assert(username != null);
    assert(username.isNotEmpty);
    return "$apiBaseUrl/users/$username/avatar?token=${UserManager.getInstance().token}";
  }

  File _getAvatarCacheFile(String username) {
    return File('$_cacheDir/$username');
  }

  Future _updateCache(String username, List<int> data, String etag) async {
    await _getAvatarCacheFile(username).writeAsBytes(data);
    _etagMap[username] = etag;
    await _etagMapFile.writeAsString(jsonEncode(_etagMap));
  }

  Future<ui.Codec> _getCodec(String username) async {
    await _checkAndInit();
    var etag = _etagMap[username];
    Map<String, String> headers = {};
    if (etag != null) {
      headers['If-None-Match'] = etag;
    }
    var res = await get(_getAvatarUrl(username), headers: headers);
    if (res.statusCode == 200) {
      final newEtag = res.headers['etag'];
      final body = res.bodyBytes;
      if (newEtag != null) {
        _updateCache(username, body, newEtag);
      } else {
        debugPrint('Get avatar responsed 200 but with no etag. So not cache.');
      }
      return await ui.instantiateImageCodec(body);
    } else if (res.statusCode == 304) {
      debugPrint('Get avatar of $username responsed 304. So cache is used.');
      return await ui.instantiateImageCodec(
          await _getAvatarCacheFile(username).readAsBytes());
    } else {
      throw HttpException(res.statusCode);
    }
  }

  ImageProvider getImageProvider(String username, {double scale = 1.0}) {
    return _AvatarImageProvider(_getCodec(username), scale: scale);
  }
}

ImageProvider avatarImageProvider(String username) {
  assert(username != null);
  assert(username.isNotEmpty);
  return _AvatarManager().getImageProvider(username);
}

class Avatar extends StatelessWidget {
  Avatar(this.username, {this.onPressed})
      : assert(username != null),
        assert(username.isNotEmpty);

  final String username;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    Widget content = Image(
      image: avatarImageProvider(username),
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
