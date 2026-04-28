import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/utils/utils.dart';
import 'package:piliotto/models/common/dynamic_badge_mode.dart';
import 'package:piliotto/models/common/nav_bar_config.dart';

class MainController extends GetxController {
  List<Widget> pages = <Widget>[];
  List<int> pagesIds = <int>[];
  RxList navigationBars = [].obs;
  late List defaultNavTabs;
  late List<int> navBarSort;
  final StreamController<bool> bottomBarStream =
      StreamController<bool>.broadcast();
  Box setting = GStrorage.setting;
  DateTime? _lastPressedAt;
  late bool hideTabBar;
  late PageController pageController;
  int selectedIndex = 0;
  Box userInfoCache = GStrorage.userInfo;
  RxBool userLogin = false.obs;
  late Rx<DynamicBadgeMode> dynamicBadgeType = DynamicBadgeMode.number.obs;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late bool enableGradientBg;
  late bool useDrawerForUser;
  bool imgPreviewStatus = false;

  @override
  void onInit() {
    super.onInit();
    if (setting.get(SettingBoxKey.autoUpdate, defaultValue: false)) {
      Utils.checkUpdata();
    }
    hideTabBar = setting.get(SettingBoxKey.hideTabBar, defaultValue: false);
    useDrawerForUser =
        setting.get(SettingBoxKey.useDrawerForUser, defaultValue: true);

    var userInfo = userInfoCache.get('userInfoCache');
    userLogin.value = userInfo != null;
    dynamicBadgeType.value = DynamicBadgeMode.values[setting.get(
        SettingBoxKey.dynamicBadgeMode,
        defaultValue: DynamicBadgeMode.number.code)];
    setNavBarConfig();
    enableGradientBg =
        setting.get(SettingBoxKey.enableGradientBg, defaultValue: true);
  }

  void onBackPressed(BuildContext context) {
    if (_lastPressedAt == null ||
        DateTime.now().difference(_lastPressedAt!) >
            const Duration(seconds: 2)) {
      _lastPressedAt = DateTime.now();
      if (selectedIndex != 0) {
        pageController.jumpTo(0);
      }
      SmartDialog.showToast("再按一次退出PiliOtto");
      return;
    }
    SystemNavigator.pop();
  }

  void setNavBarConfig() async {
    defaultNavTabs = [...defaultNavigationBars];
    navBarSort = setting.get(SettingBoxKey.navBarSort, defaultValue: [0, 1, 3]);

    // 自动添加新页面到导航栏
    for (var item in defaultNavigationBars) {
      if (!navBarSort.contains(item['id'])) {
        navBarSort.add(item['id']);
      }
    }

    // 移除不存在的页面ID
    navBarSort.removeWhere(
        (id) => !defaultNavigationBars.any((item) => item['id'] == id));

    // 只有窄屏且启用侧边栏时，才移除"我的"页面（id: 3）从底栏
    // 宽屏始终显示"我的"
    final isNarrowScreen = WidgetsBinding
                .instance.platformDispatcher.implicitView?.physicalSize.width !=
            null &&
        (WidgetsBinding.instance.platformDispatcher.implicitView!.physicalSize
                    .width /
                WidgetsBinding.instance.platformDispatcher.implicitView!
                    .devicePixelRatio) <
            600;
    if (isNarrowScreen && useDrawerForUser) {
      navBarSort.remove(3);
    }

    defaultNavTabs.retainWhere((item) => navBarSort.contains(item['id']));
    defaultNavTabs.sort((a, b) =>
        navBarSort.indexOf(a['id']).compareTo(navBarSort.indexOf(b['id'])));
    navigationBars.value = defaultNavTabs;
    int defaultHomePage =
        setting.get(SettingBoxKey.defaultHomePage, defaultValue: 0) as int;
    int defaultIndex =
        navigationBars.indexWhere((item) => item['id'] == defaultHomePage);
    selectedIndex = defaultIndex != -1 ? defaultIndex : 0;
    pages = navigationBars.map<Widget>((e) => e['page']).toList();
    pagesIds = navigationBars.map<int>((e) => e['id']).toList();
  }

  @override
  void onClose() {
    bottomBarStream.close();
    super.onClose();
  }
}
