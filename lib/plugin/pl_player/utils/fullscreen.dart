import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:auto_orientation_v2/auto_orientation_v2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

//横屏
Future<void> landScape() async {
  dynamic document;
  try {
    if (kIsWeb) {
      await document.documentElement?.requestFullscreen();
    } else if (Platform.isAndroid || Platform.isIOS) {
      await AutoOrientation.landscapeAutoMode(forceSensor: true);
    }
    // 桌面平台不调用原生全屏，由 UI 层控制播放器区域全屏
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
  }
}

//竖屏
Future<void> verticalScreen() async {
  try {
    if (Platform.isAndroid || Platform.isIOS) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
    // 桌面平台不需要切换方向
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
  }
}

Future<void> enterFullScreen() async {
  try {
    if (Platform.isAndroid || Platform.isIOS) {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      );
    }
    // 桌面平台不调用系统全屏，由 UI 层控制
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
  }
}

//退出全屏显示
Future<void> exitFullScreen() async {
  dynamic document;
  late SystemUiMode mode = SystemUiMode.edgeToEdge;
  try {
    if (kIsWeb) {
      document.exitFullscreen();
    } else if (Platform.isAndroid || Platform.isIOS) {
      if (Platform.isAndroid &&
          (await DeviceInfoPlugin().androidInfo).version.sdkInt < 29) {
        mode = SystemUiMode.manual;
      }
      await SystemChrome.setEnabledSystemUIMode(
        mode,
        overlays: SystemUiOverlay.values,
      );
      await SystemChrome.setPreferredOrientations([]);
    }
    // 桌面平台不调用原生退出全屏，由 UI 层控制
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
  }
}
