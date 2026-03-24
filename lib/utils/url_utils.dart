import 'package:dio/dio.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

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

  static matchUrlPush(
    String pathSegment,
    String title,
    String redirectUrl,
  ) async {
    final vid = int.tryParse(pathSegment);
    if (vid != null) {
      await Get.toNamed(
        '/video?vid=$vid',
        arguments: <String, String?>{
          'pic': '',
          'heroTag': 'video_$vid',
        },
      );
    } else {
      SmartDialog.showToast('无法解析视频ID');
      await Get.toNamed(
        '/webview',
        parameters: {
          'url': redirectUrl,
          'type': 'url',
          'pageTitle': title,
        },
      );
    }
  }
}
