import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/api/services/old_api_service.dart';
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

      // 如果已登录，刷新用户信息获取最新的封面URL
      if (userLogin.value) {
        _refreshUserInfo();
      }
    } catch (e) {
      SmartDialog.showToast('MineController初始化错误: ${e.toString()}');
    }
  }

  Future _refreshUserInfo() async {
    try {
      final uid = userInfo.value.mid;
      if (uid == null) return;

      final response = await OldApiService.getUserDetail(uid: uid);
      if (response['status'] == 'success') {
        // 旧版 API 直接返回数据，没有 data 包装
        final coverUrl = response['cover_url']?.toString();
        if (coverUrl != null && coverUrl.isNotEmpty) {
          userInfo.value.cover = coverUrl;
        }
        // 更新关注和粉丝数量
        userStat.value.following =
            int.tryParse(response['followings_count']?.toString() ?? '0') ?? 0;
        userStat.value.follower =
            int.tryParse(response['fans_count']?.toString() ?? '0') ?? 0;
        userInfo.refresh();
        userStat.refresh();
        // 同时更新缓存
        userInfoCache.put('userInfoCache', userInfo.value);
      }
    } catch (e) {
      // 静默失败，不影响用户体验
    }
  }

  Future<void> onLogin() async {
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

  void onChangeTheme() {
    ThemeType nextTheme;
    switch (themeType.value) {
      case ThemeType.light:
        nextTheme = ThemeType.dark;
        break;
      case ThemeType.dark:
        nextTheme = ThemeType.system;
        break;
      case ThemeType.system:
        nextTheme = ThemeType.light;
        break;
    }
    setting.put(SettingBoxKey.themeMode, nextTheme.code);
    themeType.value = nextTheme;
    Get.forceAppUpdate();
  }

  void pushFollow() {
    if (!userLogin.value) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    Get.toNamed(
      '/follow?mid=${userInfo.value.mid}&name=${Uri.encodeComponent(userInfo.value.uname ?? '')}',
      preventDuplicates: false,
    );
  }

  void pushFans() {
    if (!userLogin.value) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    Get.toNamed(
      '/fan?mid=${userInfo.value.mid}&name=${Uri.encodeComponent(userInfo.value.uname ?? '')}',
      preventDuplicates: false,
    );
  }

  void pushDynamic() {
    if (!userLogin.value) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    Get.toNamed('/memberDynamics?mid=${userInfo.value.mid}',
        preventDuplicates: false);
  }
}
