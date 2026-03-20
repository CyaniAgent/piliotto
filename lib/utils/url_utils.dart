import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:piliotto/utils/id_utils.dart';

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
    final Map matchRes = IdUtils.matchAvorBv(input: pathSegment);
    if (matchRes.containsKey('BV')) {
      final String bv = matchRes['BV'];
      // TODO: Ottohub API 使用 vid 而不是 bvid，需要转换
      // 暂时跳转到 webview
      await Get.toNamed(
        '/webview',
        parameters: {
          'url': 'https://www.bilibili.com/video/$bv',
          'type': 'url',
          'pageTitle': title,
        },
      );
    } else {
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
