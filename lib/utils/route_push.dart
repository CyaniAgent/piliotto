import 'package:get/get.dart';

class RoutePush {
  // 登录跳转
  static Future<void> loginPush() async {
    await Get.toNamed(
      '/webview',
      parameters: {
        'url': 'https://passport.bilibili.com/h5-app/passport/login',
        'type': 'login',
        'pageTitle': '登录bilibili',
      },
    );
  }

  // 登录跳转
  static Future<void> loginRedirectPush() async {
    await Get.offAndToNamed(
      '/webview',
      parameters: {
        'url': 'https://passport.bilibili.com/h5-app/passport/login',
        'type': 'login',
        'pageTitle': '登录bilibili',
      },
    );
  }
}
