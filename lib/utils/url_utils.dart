import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

class UrlUtils {
  static Future<String> parseRedirectUrl(String url) async {
    late String redirectUrl;
    final dio = Dio();
    dio.options.followRedirects = false;
    dio.options.validateStatus = (status) {
      return status == 200 || status == 301 || status == 302;
    };
    try {
      final response = await dio.get(url);
      if (response.statusCode == 302 || response.statusCode == 301) {
        redirectUrl = response.headers['location']?.first as String;
        if (redirectUrl.endsWith('/')) {
          redirectUrl = redirectUrl.substring(0, redirectUrl.length - 1);
        }
      } else {
        if (url.endsWith('/')) {
          url = url.substring(0, url.length - 1);
        }
        return url;
      }
      return redirectUrl;
    } catch (err) {
      return url;
    }
  }

  static Future<void> matchUrlPush(
    BuildContext context,
    String pathSegment,
    String title,
    String redirectUrl,
  ) async {
    final vid = int.tryParse(pathSegment);
    if (vid != null) {
      context.go(
        '/video',
        extra: <String, dynamic>{
          'vid': vid,
          'pic': '',
          'heroTag': 'video_$vid',
        },
      );
    } else {
      SmartDialog.showToast('无法解析视频ID');
      context.go(
        '/webview',
        extra: {
          'url': redirectUrl,
          'type': 'url',
          'pageTitle': title,
        },
      );
    }
  }
}
