import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/models/common/theme_type.dart';
import 'package:piliotto/models/user/info.dart';
import 'package:piliotto/models/user/stat.dart';
import 'package:piliotto/utils/storage.dart';

class MineController extends GetxController {
  Rx<UserInfoData> userInfo = UserInfoData().obs;
  Rx<UserStat> userStat = UserStat().obs;
  RxBool userLogin = false.obs;
  Box userInfoCache = GStrorage.userInfo;
  Box setting = GStrorage.setting;
  Rx<ThemeType> themeType = ThemeType.system.obs;

  @override
  onInit() {
    super.onInit();
    try {
      final cachedUserInfo = userInfoCache.get('userInfoCache');
      if (cachedUserInfo != null && cachedUserInfo is UserInfoData) {
        userInfo.value = cachedUserInfo;
        userLogin.value = true;
      }

      final themeIndex = setting.get(SettingBoxKey.themeMode,
          defaultValue: ThemeType.system.code);
      if (themeIndex >= 0 && themeIndex < ThemeType.values.length) {
        themeType.value = ThemeType.values[themeIndex];
      } else {
        themeType.value = ThemeType.system;
      }
    } catch (e) {
      SmartDialog.showToast('MineController初始化错误: ${e.toString()}');
    }
  }

  onLogin() async {
    if (!userLogin.value) {
      Get.toNamed('/loginPage', preventDuplicates: false);
    } else {
      int mid = userInfo.value.mid!;
      String face = userInfo.value.face!;
      Get.toNamed(
        '/member?mid=$mid',
        arguments: {'face': face},
      );
    }
  }

  Future queryUserInfo() async {
    return {'status': true, 'data': userInfo.value};
  }

  Future resetUserInfo() async {
    userInfo.value = UserInfoData();
    userStat.value = UserStat();
    userInfoCache.delete('userInfoCache');
    userLogin.value = false;
  }

  onChangeTheme() {
    Brightness currentBrightness =
        MediaQuery.of(Get.context!).platformBrightness;
    ThemeType currentTheme = themeType.value;
    switch (currentTheme) {
      case ThemeType.dark:
        setting.put(SettingBoxKey.themeMode, ThemeType.light.code);
        themeType.value = ThemeType.light;
        break;
      case ThemeType.light:
        setting.put(SettingBoxKey.themeMode, ThemeType.dark.code);
        themeType.value = ThemeType.dark;
        break;
      case ThemeType.system:
        if (currentBrightness == Brightness.light) {
          setting.put(SettingBoxKey.themeMode, ThemeType.dark.code);
          themeType.value = ThemeType.dark;
        } else {
          setting.put(SettingBoxKey.themeMode, ThemeType.light.code);
          themeType.value = ThemeType.light;
        }
        break;
    }
    Get.forceAppUpdate();
  }

  pushFollow() {
    if (!userLogin.value) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    Get.toNamed('/follow?mid=${userInfo.value.mid}', preventDuplicates: false);
  }

  pushFans() {
    if (!userLogin.value) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    Get.toNamed('/fan?mid=${userInfo.value.mid}', preventDuplicates: false);
  }

  pushDynamic() {
    if (!userLogin.value) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    Get.toNamed('/memberDynamics?mid=${userInfo.value.mid}',
        preventDuplicates: false);
  }
}
