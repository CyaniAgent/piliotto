import 'package:appscheme/appscheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:universal_platform/universal_platform.dart';

import 'id_utils.dart';
import 'url_utils.dart';
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

  static void _routePush(value) async {
    final String scheme = value.scheme;
    final String host = value.host;
    final String path = value.path;
    if (scheme == 'bilibili') {
      switch (host) {
        case 'root':
          Navigator.popUntil(
              Get.context!, (Route<dynamic> route) => route.isFirst);
          break;
        case 'space':
          final String mid = path.split('/').last;
          Get.toNamed<dynamic>(
            '/member?mid=$mid',
            arguments: <String, dynamic>{'face': null},
          );
          break;
        case 'video':
          String pathQuery = path.split('/').last;
          final numericRegex = RegExp(r'^[0-9]+$');
          if (numericRegex.hasMatch(pathQuery)) {
            pathQuery = 'AV$pathQuery';
          }
          Map map = IdUtils.matchAvorBv(input: pathQuery);
          if (map.containsKey('AV')) {
            _videoPush(map['AV'], null);
          } else if (map.containsKey('BV')) {
            _videoPush(null, map['BV']);
          } else {
            SmartDialog.showToast('投稿匹配失败');
          }
          break;

        case 'bangumi':
          SmartDialog.showToast('暂不支持番剧观看');
          break;
        case 'opus':
          SmartDialog.showToast('暂不支持专栏查看');
          break;
        case 'search':
          Get.toNamed('/search');
          break;
        case 'article':
          SmartDialog.showToast('暂不支持专栏查看');
          break;
        case 'pgc':
          SmartDialog.showToast('暂不支持番剧观看');
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

  static Future<void> _videoPush(int? aidVal, String? bvidVal) async {
    SmartDialog.showLoading<dynamic>(msg: '获取中...');
    try {
      int? aid = aidVal;
      String? bvid = bvidVal;
      if (aidVal == null) {
        aid = IdUtils.bv2av(bvidVal!);
      }
      if (bvidVal == null) {
        bvid = IdUtils.av2bv(aidVal!);
      }
      final String heroTag = Utils.makeHeroTag(aid);
      SmartDialog.dismiss<dynamic>().then(
        (e) => Get.toNamed<dynamic>('/video?bvid=$bvid&cid=0',
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
    RegExp regExp = RegExp(r'^((www\.)|(m\.))?bilibili\.com$');
    if (regExp.hasMatch(host)) {
      if (path!.startsWith('/video')) {
        Map matchRes = IdUtils.matchAvorBv(input: path);
        if (matchRes.containsKey('AV')) {
          _videoPush(matchRes['AV']! as int, null);
        } else if (matchRes.containsKey('BV')) {
          _videoPush(null, matchRes['BV'] as String);
        } else {
          SmartDialog.showToast('投稿匹配失败');
        }
      }
      if (path.startsWith('/bangumi')) {
        SmartDialog.showToast('暂不支持番剧观看');
      } else if (path.startsWith('/BV')) {
        final String bvid = path.split('?').first.split('/').last;
        _videoPush(null, bvid);
      } else if (path.startsWith('/av')) {
        _videoPush(Utils.matchNum(path.split('?').first).first, null);
      }
    } else if (host.contains('space')) {
      var mid = path!.split('/').last;
      Get.toNamed('/member?mid=$mid', arguments: {'face': ''});
      return;
    } else if (host == 'b23.tv') {
      final String fullPath = 'https://$host$path';
      final String redirectUrl = await UrlUtils.parseRedirectUrl(fullPath);
      final String pathSegment = Uri.parse(redirectUrl).path;
      final String lastPathSegment = pathSegment.split('/').last;
      final RegExp avRegex = RegExp(r'^[aA][vV]\d+', caseSensitive: false);
      if (avRegex.hasMatch(lastPathSegment)) {
        final Map<String, dynamic> map =
            IdUtils.matchAvorBv(input: lastPathSegment);
        if (map.containsKey('AV')) {
          _videoPush(map['AV']! as int, null);
        } else if (map.containsKey('BV')) {
          _videoPush(null, map['BV'] as String);
        } else {
          SmartDialog.showToast('投稿匹配失败');
        }
      } else if (lastPathSegment.startsWith('ep') ||
          lastPathSegment.startsWith('ss')) {
        SmartDialog.showToast('暂不支持番剧观看');
      } else if (lastPathSegment.startsWith('BV')) {
        UrlUtils.matchUrlPush(
          lastPathSegment,
          '',
          redirectUrl,
        );
      } else {
        Get.toNamed(
          '/webview',
          parameters: {'url': redirectUrl, 'type': 'url', 'pageTitle': ''},
        );
      }
    } else if (path != null) {
      final String area = path.split('/').last;
      switch (area) {
        case 'bangumi':
          SmartDialog.showToast('暂不支持番剧观看');
          break;
        case 'video':
          final Map<String, dynamic> map = IdUtils.matchAvorBv(input: path);
          if (map.containsKey('AV')) {
            _videoPush(map['AV']! as int, null);
          } else if (map.containsKey('BV')) {
            _videoPush(null, map['BV'] as String);
          } else {
            SmartDialog.showToast('投稿匹配失败');
          }
          break;
        case 'read':
          SmartDialog.showToast('暂不支持专栏查看');
          break;
        case 'space':
          Get.toNamed('/member?mid=$area', arguments: {'face': ''});
          break;
        default:
          final Map<String, dynamic> map =
              IdUtils.matchAvorBv(input: area.split('?').first);
          if (map.containsKey('AV')) {
            _videoPush(map['AV']! as int, null);
          } else if (map.containsKey('BV')) {
            _videoPush(null, map['BV'] as String);
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
          break;
      }
    }
  }
}
