import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:piliotto/models/common/theme_type.dart';
import 'package:piliotto/models/user/info.dart';
import 'package:piliotto/models/user/stat.dart';
import 'package:piliotto/providers/repository_provider.dart';
import 'package:piliotto/router/app_router.dart';
import 'package:piliotto/services/loggeer.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

final _logger = getLogger();

class MineState {
  final UserInfoData userInfo;
  final UserStat userStat;
  final bool userLogin;
  final ThemeType themeType;

  MineState({
    UserInfoData? userInfo,
    UserStat? userStat,
    this.userLogin = false,
    this.themeType = ThemeType.system,
  })  : userInfo = userInfo ?? UserInfoData(),
        userStat = userStat ?? UserStat();

  MineState copyWith({
    UserInfoData? userInfo,
    UserStat? userStat,
    bool? userLogin,
    ThemeType? themeType,
  }) {
    return MineState(
      userInfo: userInfo ?? this.userInfo,
      userStat: userStat ?? this.userStat,
      userLogin: userLogin ?? this.userLogin,
      themeType: themeType ?? this.themeType,
    );
  }
}

@riverpod
class MineNotifier extends _$MineNotifier {
  @override
  MineState build() {
    UserInfoData? userInfo;
    bool userLogin = false;
    ThemeType themeType = ThemeType.system;

    try {
      final cachedUserInfo = GStrorage.userInfo.get('userInfoCache');
      if (cachedUserInfo != null && cachedUserInfo is UserInfoData) {
        userInfo = cachedUserInfo;
        userLogin = true;
      }

      final themeIndex = GStrorage.setting
          .get(SettingBoxKey.themeMode, defaultValue: ThemeType.system.code);
      if (themeIndex >= 0 && themeIndex < ThemeType.values.length) {
        themeType = ThemeType.values[themeIndex];
      }

      if (userLogin) {
        _refreshUserInfo();
      }
    } catch (e) {
      SmartDialog.showToast('MineNotifier初始化错误: ${e.toString()}');
    }

    return MineState(
      userInfo: userInfo,
      userLogin: userLogin,
      themeType: themeType,
    );
  }

  Future _refreshUserInfo() async {
    try {
      final uid = state.userInfo.mid;
      if (uid == null) return;

      final userRepo = ref.read(userRepositoryProvider);
      final profileInfo = await userRepo.getUserProfileInfo(uid: uid);

      UserInfoData newUserInfo = state.userInfo;
      UserStat newUserStat = state.userStat;

      if (profileInfo.coverUrl != null && profileInfo.coverUrl!.isNotEmpty) {
        newUserInfo = newUserInfo.copyWith(cover: profileInfo.coverUrl);
      }
      newUserStat = newUserStat.copyWith(
        following: profileInfo.followingCount,
        follower: profileInfo.fansCount,
      );

      state = state.copyWith(userInfo: newUserInfo, userStat: newUserStat);
      GStrorage.userInfo.put('userInfoCache', newUserInfo);
    } catch (e) {
      _logger.e('刷新用户信息失败: $e');
    }
  }

  Future<void> onLogin() async {
    final BuildContext? context = rootNavigatorKey.currentContext;
    if (context == null) return;
    if (!state.userLogin) {
      context.push('/loginPage');
    } else {
      int mid = state.userInfo.mid!;
      String face = state.userInfo.face!;
      context.push(
        '/member?mid=$mid',
        extra: {'face': face},
      );
    }
  }

  Future queryUserInfo() async {
    return {'status': true, 'data': state.userInfo};
  }

  Future resetUserInfo() async {
    state = MineState(
      userLogin: false,
      themeType: state.themeType,
    );
    try {
      GStrorage.userInfo.delete('userInfoCache');
    } catch (_) {}
  }

  void onChangeTheme() {
    ThemeType nextTheme;
    switch (state.themeType) {
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
    try {
      GStrorage.setting.put(SettingBoxKey.themeMode, nextTheme.code);
    } catch (_) {}
    state = state.copyWith(themeType: nextTheme);
  }

  void pushFollow() {
    final BuildContext? context = rootNavigatorKey.currentContext;
    if (context == null) return;
    if (!state.userLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    context.go(
      '/follow?mid=${state.userInfo.mid}&name=${Uri.encodeComponent(state.userInfo.uname ?? '')}',
    );
  }

  void pushFans() {
    final BuildContext? context = rootNavigatorKey.currentContext;
    if (context == null) return;
    if (!state.userLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    context.go(
      '/fan?mid=${state.userInfo.mid}&name=${Uri.encodeComponent(state.userInfo.uname ?? '')}',
    );
  }

  void pushDynamic() {
    final BuildContext? context = rootNavigatorKey.currentContext;
    if (context == null) return;
    if (!state.userLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    context.push('/memberDynamics?mid=${state.userInfo.mid}');
  }
}
