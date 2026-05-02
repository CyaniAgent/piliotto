import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:piliotto/models/common/color_type.dart';
import 'package:piliotto/models/common/theme_type.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/login.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/models/common/dynamic_badge_mode.dart';
import 'package:piliotto/models/common/nav_bar_config.dart';
import 'package:piliotto/pages/setting/widgets/select_dialog.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

class SettingState {
  final bool userLogin;
  final bool feedBackEnable;
  final double toastOpacity;
  final int picQuality;
  final ThemeType themeType;
  final dynamic userInfo;
  final DynamicBadgeMode dynamicBadgeType;
  final int defaultHomePage;

  const SettingState({
    this.userLogin = false,
    this.feedBackEnable = false,
    this.toastOpacity = 1.0,
    this.picQuality = 10,
    this.themeType = ThemeType.system,
    this.userInfo,
    this.dynamicBadgeType = DynamicBadgeMode.number,
    this.defaultHomePage = 0,
  });

  SettingState copyWith({
    bool? userLogin,
    bool? feedBackEnable,
    double? toastOpacity,
    int? picQuality,
    ThemeType? themeType,
    dynamic userInfo,
    DynamicBadgeMode? dynamicBadgeType,
    int? defaultHomePage,
  }) {
    return SettingState(
      userLogin: userLogin ?? this.userLogin,
      feedBackEnable: feedBackEnable ?? this.feedBackEnable,
      toastOpacity: toastOpacity ?? this.toastOpacity,
      picQuality: picQuality ?? this.picQuality,
      themeType: themeType ?? this.themeType,
      userInfo: userInfo ?? this.userInfo,
      dynamicBadgeType: dynamicBadgeType ?? this.dynamicBadgeType,
      defaultHomePage: defaultHomePage ?? this.defaultHomePage,
    );
  }
}

@riverpod
class SettingNotifier extends _$SettingNotifier {
  @override
  SettingState build() {
    return _loadSettingFromStorage();
  }

  SettingState _loadSettingFromStorage() {
    try {
      final userInfo = GStrorage.userInfo.get('userInfoCache');
      final userLogin = userInfo != null;
      final feedBackEnable = GStrorage.setting
          .get(SettingBoxKey.feedBackEnable, defaultValue: false);
      final toastOpacity = GStrorage.setting
          .get(SettingBoxKey.defaultToastOp, defaultValue: 1.0);
      final picQuality =
          GStrorage.setting.get(SettingBoxKey.defaultPicQa, defaultValue: 10);
      final themeType = ThemeType.values[GStrorage.setting
          .get(SettingBoxKey.themeMode, defaultValue: ThemeType.system.code)];
      final dynamicBadgeType = DynamicBadgeMode.values[GStrorage.setting.get(
          SettingBoxKey.dynamicBadgeMode,
          defaultValue: DynamicBadgeMode.number.code)];
      final defaultHomePage =
          GStrorage.setting.get(SettingBoxKey.defaultHomePage, defaultValue: 0);

      return SettingState(
        userLogin: userLogin,
        feedBackEnable: feedBackEnable as bool,
        toastOpacity: toastOpacity as double,
        picQuality: picQuality as int,
        themeType: themeType,
        userInfo: userInfo,
        dynamicBadgeType: dynamicBadgeType,
        defaultHomePage: defaultHomePage as int,
      );
    } catch (_) {
      return const SettingState();
    }
  }

  Future<void> loginOut(BuildContext context) async {
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('提示'),
          content: const Text('确认要退出登录吗'),
          actions: [
            TextButton(
              onPressed: () => SmartDialog.dismiss(),
              child: const Text('点错了'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  GStrorage.userInfo.put('userInfoCache', null);
                  GStrorage.localCache
                      .put(LocalCacheKey.accessKey, {'mid': -1, 'value': ''});
                } catch (_) {}

                await LoginUtils.refreshLoginStatus(false, ref);
                state = state.copyWith(userLogin: false, userInfo: null);
                SmartDialog.dismiss().then((value) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                });
              },
              child: const Text('确认'),
            )
          ],
        );
      },
    );
  }

  void onOpenFeedBack() {
    feedBack();
    final newValue = !state.feedBackEnable;
    state = state.copyWith(feedBackEnable: newValue);
    try {
      GStrorage.setting.put(SettingBoxKey.feedBackEnable, newValue);
    } catch (_) {}
  }

  Future<void> setDynamicBadgeMode(BuildContext context) async {
    DynamicBadgeMode? result = await showDialog(
      context: context,
      builder: (dialogContext) {
        return SelectDialog<DynamicBadgeMode>(
          title: '动态未读标记',
          value: state.dynamicBadgeType,
          values: DynamicBadgeMode.values.map((e) {
            return {'title': e.description, 'value': e};
          }).toList(),
        );
      },
    );
    if (result != null) {
      state = state.copyWith(dynamicBadgeType: result);
      try {
        GStrorage.setting.put(SettingBoxKey.dynamicBadgeMode, result.code);
      } catch (_) {}
      SmartDialog.showToast('设置成功');
    }
  }

  Future<void> setDefaultHomePage(BuildContext context) async {
    int? result = await showDialog(
      context: context,
      builder: (dialogContext) {
        return SelectDialog<int>(
          title: '首页启动页',
          value: state.defaultHomePage,
          values: defaultNavigationBars.map((e) {
            return {'title': e['label'], 'value': e['id']};
          }).toList(),
        );
      },
    );
    if (result != null) {
      state = state.copyWith(defaultHomePage: result);
      try {
        GStrorage.setting.put(SettingBoxKey.defaultHomePage, result);
      } catch (_) {}
      SmartDialog.showToast('设置成功，重启生效');
    }
  }

  void setPicQuality(int quality) {
    state = state.copyWith(picQuality: quality);
  }

  void setToastOpacity(double opacity) {
    state = state.copyWith(toastOpacity: opacity);
  }

  void setThemeType(ThemeType type) {
    state = state.copyWith(themeType: type);
  }
}

class ColorSelectState {
  final bool dynamicColor;
  final int type;
  final int currentColor;
  final List<Map<String, dynamic>> colorThemes;

  const ColorSelectState({
    this.dynamicColor = true,
    this.type = 0,
    this.currentColor = 0,
    this.colorThemes = const [],
  });

  ColorSelectState copyWith({
    bool? dynamicColor,
    int? type,
    int? currentColor,
    List<Map<String, dynamic>>? colorThemes,
  }) {
    return ColorSelectState(
      dynamicColor: dynamicColor ?? this.dynamicColor,
      type: type ?? this.type,
      currentColor: currentColor ?? this.currentColor,
      colorThemes: colorThemes ?? this.colorThemes,
    );
  }
}

@riverpod
class ColorSelectNotifier extends _$ColorSelectNotifier {
  @override
  ColorSelectState build() {
    bool dynamicColor = true;
    int currentColor = 0;
    try {
      dynamicColor =
          GStrorage.setting.get(SettingBoxKey.dynamicColor, defaultValue: true);
      currentColor =
          GStrorage.setting.get(SettingBoxKey.customColor, defaultValue: 0);
    } catch (_) {
      dynamicColor = true;
      currentColor = 0;
    }
    return ColorSelectState(
      dynamicColor: dynamicColor,
      type: dynamicColor ? 0 : 1,
      currentColor: currentColor,
      colorThemes: colorThemeTypes,
    );
  }

  void setType(int value) {
    state = state.copyWith(type: value);
    try {
      GStrorage.setting.put(SettingBoxKey.dynamicColor, value == 0);
    } catch (_) {}
  }

  void setCurrentColor(int index) {
    state = state.copyWith(currentColor: index);
    try {
      GStrorage.setting.put(SettingBoxKey.customColor, index);
    } catch (_) {}
  }
}
