import 'dart:io';

// import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:piliotto/common/widgets/custom_toast.dart';
import 'package:piliotto/models/common/color_type.dart';
import 'package:piliotto/models/common/theme_type.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:window_manager/window_manager.dart';

import 'package:piliotto/router/app_router.dart';
import 'package:piliotto/services/service_locator.dart';
import 'package:piliotto/utils/app_scheme.dart';
import 'package:piliotto/utils/data.dart';
import 'package:piliotto/utils/global_data_cache.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:media_kit/media_kit.dart';
import 'package:piliotto/ottohub/repositories/ottohub_video_repository.dart';
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/repositories/i_user_repository.dart';
import 'package:piliotto/ottohub/repositories/ottohub_user_repository.dart';
import 'package:piliotto/repositories/i_dynamics_repository.dart';
import 'package:piliotto/ottohub/repositories/ottohub_dynamics_repository.dart';
import 'package:piliotto/ottohub/repositories/ottohub_comment_repository.dart';
import 'package:piliotto/repositories/i_comment_repository.dart';
import 'package:piliotto/repositories/i_message_repository.dart';
import 'package:piliotto/ottohub/repositories/ottohub_message_repository.dart';
import 'package:piliotto/ottohub/repositories/ottohub_danmaku_repository.dart';
import 'package:piliotto/repositories/i_danmaku_repository.dart';
import 'package:piliotto/utils/recommend_filter.dart';
import 'package:catcher_2/catcher_2.dart';

import './services/loggeer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  // 桌面端窗口初始化
  if (UniversalPlatform.isDesktop) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      // size: Size(1280, 720),
      // minimumSize: Size(640, 480),
      center: true,
      // backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'PiliOtto',
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await GStrorage.init();
  clearLogs();

  Get.put<IVideoRepository>(OttohubVideoRepository());
  Get.put<IUserRepository>(OttohubUserRepository());
  Get.put<IDynamicsRepository>(OttohubDynamicsRepository());
  Get.put<ICommentRepository>(OttohubCommentRepository());
  Get.put<IMessageRepository>(OttohubMessageRepository());
  Get.put<IDanmakuRepository>(OttohubDanmakuRepository());

  // 异常捕获 logo记录
  final Catcher2Options releaseConfig = Catcher2Options(
    SilentReportMode(),
    [FileHandler(await getLogsPath())],
  );

  Catcher2(
    releaseConfig: releaseConfig,
    runAppFunction: () {
      runApp(const MyApp());
    },
  );

  // // 小白条、导航栏沉浸
  // if (Platform.isAndroid) {
  //   final androidInfo = await DeviceInfoPlugin().androidInfo;
  //   if (androidInfo.version.sdkInt >= 29) {
  //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  //   }
  //   SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //     systemNavigationBarColor: Colors.transparent,
  //     systemNavigationBarDividerColor: Colors.transparent,
  //     statusBarColor: Colors.transparent,
  //   ));
  // }

  PiliSchame.init();
  await GlobalDataCache().initialize();

  RecommendFilter();
  Data.init();
  setupServiceLocator();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 安全获取设置值
  T _getSetting<T>(Box setting, String key, T defaultValue) {
    try {
      if (setting.isOpen) {
        return setting.get(key, defaultValue: defaultValue) ?? defaultValue;
      }
    } catch (_) {}
    return defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    // 主题色
    Color defaultColor = colorThemeTypes[
        _getSetting(GStrorage.setting, SettingBoxKey.customColor, 0)]['color'];
    Color brandColor = defaultColor;
    // 主题模式
    ThemeType currentThemeValue = ThemeType.values[_getSetting(
        GStrorage.setting, SettingBoxKey.themeMode, ThemeType.system.code)];
    // 是否动态取色
    bool isDynamicColor =
        _getSetting(GStrorage.setting, SettingBoxKey.dynamicColor, true);
    // 字体缩放大小
    double textScale =
        _getSetting(GStrorage.setting, SettingBoxKey.defaultTextScale, 1.0);

    // 强制设置高帧率
    if (Platform.isAndroid) {
      try {
        late List modes;
        FlutterDisplayMode.supported.then((value) {
          modes = value;
          var storageDisplay =
              _getSetting(GStrorage.setting, SettingBoxKey.displayMode, null);
          DisplayMode f = DisplayMode.auto;
          if (storageDisplay != null) {
            f = modes.firstWhere((e) => e.toString() == storageDisplay);
          }
          DisplayMode preferred = modes.toList().firstWhere((el) => el == f);
          FlutterDisplayMode.setPreferredMode(preferred);
        });
      } catch (_) {}
    }

    if (Platform.isAndroid) {
      return AndroidApp(
        brandColor: brandColor,
        isDynamicColor: isDynamicColor,
        currentThemeValue: currentThemeValue,
        textScale: textScale,
      );
    } else {
      return OtherApp(
        brandColor: brandColor,
        currentThemeValue: currentThemeValue,
        textScale: textScale,
      );
    }
  }
}

class AndroidApp extends StatelessWidget {
  const AndroidApp({
    super.key,
    required this.brandColor,
    required this.isDynamicColor,
    required this.currentThemeValue,
    required this.textScale,
  });

  final Color brandColor;
  final bool isDynamicColor;
  final ThemeType currentThemeValue;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: ((ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme? lightColorScheme;
        ColorScheme? darkColorScheme;
        if (lightDynamic != null && darkDynamic != null && isDynamicColor) {
          // dynamic取色成功
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          // dynamic取色失败，采用品牌色
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: brandColor,
            brightness: Brightness.light,
          );
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: brandColor,
            brightness: Brightness.dark,
          );
        }
        return BuildMainApp(
          lightColorScheme: lightColorScheme,
          darkColorScheme: darkColorScheme,
          currentThemeValue: currentThemeValue,
          textScale: textScale,
        );
      }),
    );
  }
}

class OtherApp extends StatelessWidget {
  const OtherApp({
    super.key,
    required this.brandColor,
    required this.currentThemeValue,
    required this.textScale,
  });

  final Color brandColor;
  final ThemeType currentThemeValue;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    return BuildMainApp(
      lightColorScheme: ColorScheme.fromSeed(
        seedColor: brandColor,
        brightness: Brightness.light,
      ),
      darkColorScheme: ColorScheme.fromSeed(
        seedColor: brandColor,
        brightness: Brightness.dark,
      ),
      currentThemeValue: currentThemeValue,
      textScale: textScale,
    );
  }
}

class BuildMainApp extends StatelessWidget {
  const BuildMainApp({
    super.key,
    required this.lightColorScheme,
    required this.darkColorScheme,
    required this.currentThemeValue,
    required this.textScale,
  });

  final ColorScheme lightColorScheme;
  final ColorScheme darkColorScheme;
  final ThemeType currentThemeValue;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    final SnackBarThemeData lightSnackBarTheme = SnackBarThemeData(
      actionTextColor: lightColorScheme.primary,
      backgroundColor: lightColorScheme.secondaryContainer,
      closeIconColor: lightColorScheme.secondary,
      contentTextStyle: TextStyle(color: lightColorScheme.secondary),
      elevation: 20,
    );

    final SnackBarThemeData darkSnackBarTheme = SnackBarThemeData(
      actionTextColor: darkColorScheme.primary,
      backgroundColor: darkColorScheme.secondaryContainer,
      closeIconColor: darkColorScheme.secondary,
      contentTextStyle: TextStyle(color: darkColorScheme.secondary),
      elevation: 20,
    );

    ThemeMode appThemeMode;
    switch (currentThemeValue) {
      case ThemeType.light:
        appThemeMode = ThemeMode.light;
        break;
      case ThemeType.dark:
        appThemeMode = ThemeMode.dark;
        break;
      case ThemeType.system:
        appThemeMode = ThemeMode.system;
        break;
    }

    return ProviderScope(
      child: MaterialApp.router(
        title: 'PiliOtto',
        themeMode: appThemeMode,
        theme: ThemeData(
          colorScheme: lightColorScheme,
          snackBarTheme: lightSnackBarTheme,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: ZoomPageTransitionsBuilder(
                allowEnterRouteSnapshotting: false,
              ),
            },
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme,
          snackBarTheme: darkSnackBarTheme,
        ),
        localizationsDelegates: const [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        locale: const Locale("zh", "CN"),
        supportedLocales: const [Locale("zh", "CN"), Locale("en", "US")],
        routerConfig: appRouter,
        builder: (BuildContext context, Widget? child) {
          return FlutterSmartDialog(
            toastBuilder: (String msg) => CustomToast(msg: msg),
            child: MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
          );
        },
      ),
    );
  }
}
