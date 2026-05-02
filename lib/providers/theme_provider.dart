import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:piliotto/utils/storage.dart';

part 'theme_provider.g.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  AppThemeMode build() {
    return _loadThemeFromStorage();
  }

  AppThemeMode _loadThemeFromStorage() {
    try {
      final themeModeIndex = GStrorage.setting.get(
        SettingBoxKey.themeMode,
        defaultValue: 0,
      ) as int;
      return AppThemeMode.values[themeModeIndex];
    } catch (e) {
      return AppThemeMode.system;
    }
  }

  void setThemeMode(AppThemeMode mode) {
    state = mode;
    GStrorage.setting.put(SettingBoxKey.themeMode, mode.index);
  }

  ThemeMode get materialThemeMode {
    switch (state) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

@riverpod
class DynamicColorNotifier extends _$DynamicColorNotifier {
  @override
  bool build() {
    return _loadDynamicColorFromStorage();
  }

  bool _loadDynamicColorFromStorage() {
    try {
      return GStrorage.setting.get(
        SettingBoxKey.dynamicColor,
        defaultValue: true,
      ) as bool;
    } catch (e) {
      return true;
    }
  }

  void setDynamicColor(bool enabled) {
    state = enabled;
    GStrorage.setting.put(SettingBoxKey.dynamicColor, enabled);
  }
}

@riverpod
class CustomColorNotifier extends _$CustomColorNotifier {
  @override
  Color? build() {
    return _loadCustomColorFromStorage();
  }

  Color? _loadCustomColorFromStorage() {
    try {
      final colorValue =
          GStrorage.setting.get(SettingBoxKey.customColor) as int?;
      if (colorValue != null) {
        return Color(colorValue);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  void setCustomColor(Color? color) {
    state = color;
    if (color != null) {
      GStrorage.setting.put(SettingBoxKey.customColor, color.toARGB32());
    } else {
      GStrorage.setting.delete(SettingBoxKey.customColor);
    }
  }
}

@riverpod
ThemeMode currentThemeMode(Ref ref) {
  final themeNotifier = ref.watch(themeProvider.notifier);
  return themeNotifier.materialThemeMode;
}

@riverpod
bool isDarkMode(Ref ref) {
  final themeMode = ref.watch(themeProvider);
  if (themeMode == AppThemeMode.system) {
    return PlatformDispatcher.instance.platformBrightness == Brightness.dark;
  }
  return themeMode == AppThemeMode.dark;
}
