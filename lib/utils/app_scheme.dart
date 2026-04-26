import 'package:appscheme/appscheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:universal_platform/universal_platform.dart';

import 'utils.dart';

class PiliSchame {
  static AppScheme appScheme = AppSchemeImpl.getInstance()!;
  static Future<void> init() async {
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      try {
        final SchemeEntity? value = await appScheme.getInitScheme();
        if (value != null) {
          _routePush(value);
        }

        appScheme.getLatestScheme().then((SchemeEntity? value) {
          if (value != null) {
            _routePush(value);
          }
        });

        appScheme.registerSchemeListener().listen((SchemeEntity? event) {
          if (event != null) {
            _routePush(event);
          }
        });
      } catch (e) {
        // ignore: scheme initialization failed
      }
    }
  }

  static void _routePush(SchemeEntity value) async {
    final String scheme = value.scheme ?? '';
    final String host = value.host ?? '';
    final String path = value.path ?? '';
    if (scheme == 'ottohub') {
      switch (host) {
        case 'root':
          Navigator.popUntil(
              Get.context!, (Route<dynamic> route) => route.isFirst);
          break;
        case 'u':
        case 'user':
          final String uid = path.split('/').last;
          Get.toNamed<dynamic>(
            '/member?mid=$uid',
            arguments: <String, dynamic>{'face': null},
          );
          break;
        case 'v':
        case 'video':
          final String vid = path.split('/').last;
          if (vid.isNotEmpty) {
            _videoPush(int.tryParse(vid) ?? 0);
          } else {
            SmartDialog.showToast('视频ID无效');
          }
          break;
        case 'b':
        case 'blog':
          SmartDialog.showToast('暂不支持动态查看');
          break;
        case 'search':
          Get.toNamed('/search');
          break;
        default:
          SmartDialog.showToast('未匹配地址，请联系开发者');
          Clipboard.setData(ClipboardData(text: value.toJson().toString()));
          break;
      }
    }
    if (scheme == 'https') {
      fullPathPush(value);
    }
  }

  static Future<void> _videoPush(int vid) async {
    SmartDialog.showLoading<dynamic>(msg: '获取中...');
    try {
      final String heroTag = Utils.makeHeroTag(vid);
      SmartDialog.dismiss<dynamic>().then(
        (e) => Get.toNamed<dynamic>('/video?vid=$vid',
            arguments: <String, String?>{
              'pic': '',
              'heroTag': heroTag,
            }),
      );
    } catch (e) {
      SmartDialog.showToast('video获取失败: $e');
    }
  }

  static Future<void> fullPathPush(SchemeEntity value) async {
    final String host = value.host!;
    final String? path = value.path;
    RegExp regExp = RegExp(r'^((www\.)?(m\.)?)?ottohub\.cn$');
    if (regExp.hasMatch(host)) {
      if (path!.startsWith('/v/')) {
        final String vid = path.split('/').last;
        final vidNum = int.tryParse(vid);
        if (vidNum != null) {
          _videoPush(vidNum);
        } else {
          SmartDialog.showToast('视频ID无效');
        }
      } else if (path.startsWith('/b/')) {
        SmartDialog.showToast('暂不支持动态查看');
      } else if (path.startsWith('/u/')) {
        final String uid = path.split('/').last;
        Get.toNamed('/member?mid=$uid', arguments: {'face': ''});
      }
    } else {
      Get.toNamed(
        '/webview',
        parameters: {
          'url': value.dataString ?? "",
          'type': 'url',
          'pageTitle': ''
        },
      );
    }
  }
}
