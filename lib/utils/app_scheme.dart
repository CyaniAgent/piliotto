import 'package:appscheme/appscheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:universal_platform/universal_platform.dart';

import '../http/search.dart';
import 'id_utils.dart';
import 'url_utils.dart';
import 'utils.dart';

class PiliSchame {
  static AppScheme appScheme = AppSchemeImpl.getInstance()!;
  static Future<void> init() async {
    // 只在移动平台上使用appscheme
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      try {
        ///
        final SchemeEntity? value = await appScheme.getInitScheme();
        if (value != null) {
          _routePush(value);
        }

        /// 完整链接进入 b23.无效
        appScheme.getLatestScheme().then((SchemeEntity? value) {
          if (value != null) {
            _routePush(value);
          }
        });

        /// 注册从外部打开的Scheme监听信息 #
        appScheme.registerSchemeListener().listen((SchemeEntity? event) {
          if (event != null) {
            _routePush(event);
          }
        });
      } catch (e) {
        // 捕获异常，避免初始化失败
        // AppScheme 初始化错误: $e
      }
    }
  }

  /// 路由跳转
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
          if (path.startsWith('/detail')) {
            var opusId = path.split('/').last;
            Get.toNamed('/opus', parameters: {
              'title': '',
              'id': opusId,
              'articleType': 'opus',
            });
          }
          break;
        case 'search':
          Get.toNamed('/searchResult', parameters: {'keyword': ''});
          break;
        case 'article':
          final String id = path.split('/').last.split('?').first;
          Get.toNamed(
            '/read',
            parameters: {
              'title': 'cv$id',
              'id': id,
              'dynamicType': 'read',
            },
          );
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

  // 投稿跳转
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
      final int cid = await SearchHttp.ab2c(bvid: bvidVal, aid: aidVal);
      final String heroTag = Utils.makeHeroTag(aid);
      SmartDialog.dismiss<dynamic>().then(
        // ignore: always_specify_types
        (e) => Get.toNamed<dynamic>('/video?bvid=$bvid&cid=$cid',
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
    // https://m.bilibili.com/bangumi/play/ss39708
    // https | m.bilibili.com | /bangumi/play/ss39708
    // final String scheme = value.scheme!;
    final String host = value.host!;
    final String? path = value.path;
    Map<String, String>? query = value.query;
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
          // 番剧
          SmartDialog.showToast('暂不支持番剧观看');
          break;
        case 'video':
          // 投稿
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
          // 专栏
          String id = Utils.matchNum(query!['id']!).first.toString();
          Get.toNamed('/read', parameters: {
            'url': value.dataString!,
            'title': '',
            'id': id,
            'articleType': 'read'
          });
          break;
        case 'space':
          // 个人空间
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
