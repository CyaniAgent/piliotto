import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:piliotto/pages/dynamics/provider.dart';
import 'package:piliotto/pages/home/provider.dart';
import 'package:piliotto/pages/media/provider.dart';
import 'package:piliotto/pages/mine/provider.dart';
import 'package:piliotto/router/app_router.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginUtils {
  static Future refreshLoginStatus(bool status, dynamic ref) async {
    try {
      if (ref != null) {
        final mineNotifier = ref.read(mineProvider.notifier);
        if (status) {
          final userInfo = await GStrorage.userInfo.get('userInfoCache');
          mineNotifier.state = mineNotifier.state.copyWith(
            userLogin: true,
            userInfo: userInfo,
          );
        } else {
          mineNotifier.state = mineNotifier.state.copyWith(
            userLogin: false,
          );
        }

        final homeNotifier = ref.read(homeProvider.notifier);
        homeNotifier.updateLoginStatus(status);

        final dynamicsNotifier = ref.read(dynamicsProvider.notifier);
        dynamicsNotifier.state = dynamicsNotifier.state.copyWith(
          userLogin: status,
        );

        final mediaNotifier = ref.read(mediaProvider.notifier);
        mediaNotifier.state = mediaNotifier.state.copyWith(
          userLogin: status,
        );
      }
    } catch (err) {
      SmartDialog.showToast('刷新状态失败: ${err.toString()}');
    }
  }

  static Future confirmLogin(String? url, WebViewController? controller) async {
    SmartDialog.showToast('Ottohub 请使用应用内登录功能');
    final BuildContext? context = rootNavigatorKey.currentContext;
    if (controller != null && context != null) {
      Navigator.of(context).pop();
    }
    if (context != null) {
      context.push('/loginPage');
    }
  }
}
