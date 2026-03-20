import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:piliotto/models/user/info.dart';
import 'package:piliotto/models/user/stat.dart';
import 'package:piliotto/pages/dynamics/index.dart';
import 'package:piliotto/pages/home/index.dart';
import 'package:piliotto/pages/media/index.dart';
import 'package:piliotto/pages/mine/index.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginUtils {
  static Future refreshLoginStatus(bool status) async {
    try {
      final mineCtr = Get.find<MineController>();
      mineCtr.userLogin.value = status;
      if (status) {
        mineCtr.userInfo.value = await GStrorage.userInfo.get('userInfoCache');
      } else {
        mineCtr.userInfo.value = UserInfoData();
        mineCtr.userStat.value = UserStat();
      }

      HomeController homeCtr = Get.find<HomeController>();
      homeCtr.updateLoginStatus(status);

      DynamicsController dynamicsCtr = Get.find<DynamicsController>();
      dynamicsCtr.userLogin.value = status;

      MediaController mediaCtr = Get.find<MediaController>();
      mediaCtr.userLogin.value = status;
    } catch (err) {
      SmartDialog.showToast('刷新状态失败: ${err.toString()}');
    }
  }

  // 用于 WebView 登录确认（B站登录方式已废弃，Ottohub 使用自己的登录）
  static Future confirmLogin(String? url, WebViewController? controller) async {
    SmartDialog.showToast('Ottohub 请使用应用内登录功能');
    if (controller != null) {
      // 关闭 webview
      Get.back();
    }
    // 跳转到登录页面
    Get.toNamed('/loginPage');
  }
}
