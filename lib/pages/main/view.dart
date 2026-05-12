import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/common/widgets/user_drawer.dart';
import 'package:piliotto/models/common/dynamic_badge_mode.dart';
import 'package:piliotto/pages/dynamics/index.dart';
import 'package:piliotto/pages/home/index.dart';
import 'package:piliotto/pages/media/index.dart';
import 'package:piliotto/utils/event_bus.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/responsive_util.dart';
import 'package:piliotto/utils/storage.dart';
import './controller.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  final MainController _mainController = Get.put(MainController());
  late HomeController _homeController;
  DynamicsController? _dynamicController;
  MediaController? _mediaController;

  int? _lastSelectTime;
  Box setting = GStrorage.setting;
  late bool enableMYBar;

  @override
  void initState() {
    super.initState();
    _lastSelectTime = DateTime.now().millisecondsSinceEpoch;
    _mainController.pageController =
        PageController(initialPage: _mainController.selectedIndex);
    enableMYBar = setting.get(SettingBoxKey.enableMYBar, defaultValue: true);
    controllerInit();
  }

  void setIndex(int value) async {
    feedBack();
    _mainController.pageController.jumpToPage(value);
    var currentPage = _mainController.pages[value];
    if (currentPage is HomePage) {
      if (_homeController.flag) {
        if (DateTime.now().millisecondsSinceEpoch - _lastSelectTime! < 500) {
          _homeController.onRefresh();
        } else {
          _homeController.animateToTop();
        }
        _lastSelectTime = DateTime.now().millisecondsSinceEpoch;
      }
      _homeController.flag = true;
    } else {
      _homeController.flag = false;
    }

    if (currentPage is DynamicsPage) {
      if (_dynamicController!.flag) {
        if (DateTime.now().millisecondsSinceEpoch - _lastSelectTime! < 500) {
          _dynamicController!.onRefresh();
        } else {
          _dynamicController!.scrollToTop();
        }
        _lastSelectTime = DateTime.now().millisecondsSinceEpoch;
      }
      _dynamicController!.flag = true;
    } else {
      _dynamicController?.flag = false;
    }

    if (currentPage is MediaPage) {
      _mediaController!.queryFavFolder();
    }
  }

  void controllerInit() {
    _homeController = Get.put(HomeController());
    if (_mainController.pagesIds.contains(1)) {
      _dynamicController = Get.put(DynamicsController());
    }
    if (_mainController.pagesIds.contains(2)) {
      _mediaController = Get.put(MediaController());
    }
  }

  @override
  void dispose() {
    GStrorage.close();
    EventBus().off(EventName.loginEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Box localCache = GStrorage.localCache;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double sheetHeight = MediaQuery.sizeOf(context).height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).size.width * 9 / 16;
    localCache.put('sheetHeight', sheetHeight);
    localCache.put('statusBarHeight', statusBarHeight);
    bool isWideScreen = ResponsiveUtil.isLg || ResponsiveUtil.isXl;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        _mainController.onBackPressed(context);
      },
      child: isWideScreen
          ? _buildWideScreenLayout(context)
          : _buildNarrowScreenLayout(context),
    );
  }

  Widget _buildNarrowScreenLayout(BuildContext context) {
    final useDrawer = _mainController.useDrawerForUser;
    return Scaffold(
      key: _mainController.scaffoldKey,
      drawer: useDrawer ? const UserDrawer() : null,
      extendBody: true,
      body: Stack(
        children: [
          PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _mainController.pageController,
            onPageChanged: (index) {
              _mainController.selectedIndex = index;
              setState(() {});
            },
            children: _mainController.pages,
          ),
        ],
      ),
      bottomNavigationBar: _mainController.navigationBars.length > 1
          ? StreamBuilder(
              stream: _mainController.hideTabBar
                  ? _mainController.bottomBarStream.stream.distinct()
                  : StreamController<bool>.broadcast().stream,
              initialData: true,
              builder: (context, AsyncSnapshot snapshot) {
                return AnimatedSlide(
                  curve: Curves.easeInOutCubicEmphasized,
                  duration: const Duration(milliseconds: 500),
                  offset: Offset(0, snapshot.data ? 0 : 1),
                  child: enableMYBar
                      ? Obx(
                          () => NavigationBar(
                            onDestinationSelected: (value) => setIndex(value),
                            selectedIndex: _mainController.selectedIndex,
                            destinations: <Widget>[
                              ..._mainController.navigationBars.map((e) {
                                return NavigationDestination(
                                  icon: Badge(
                                    label: _mainController
                                                .dynamicBadgeType.value ==
                                            DynamicBadgeMode.number
                                        ? Text(e['count'].toString())
                                        : null,
                                    padding:
                                        const EdgeInsets.fromLTRB(6, 0, 6, 0),
                                    isLabelVisible: _mainController
                                                .dynamicBadgeType.value !=
                                            DynamicBadgeMode.hidden &&
                                        e['count'] > 0,
                                    child: e['icon'],
                                  ),
                                  selectedIcon: e['selectIcon'],
                                  label: e['label'],
                                );
                              }),
                            ],
                          ),
                        )
                      : Obx(
                          () => BottomNavigationBar(
                            currentIndex: _mainController.selectedIndex,
                            type: BottomNavigationBarType.fixed,
                            onTap: (value) => setIndex(value),
                            iconSize: 16,
                            selectedFontSize: 12,
                            unselectedFontSize: 12,
                            items: [
                              ..._mainController.navigationBars.map((e) {
                                return BottomNavigationBarItem(
                                  icon: Badge(
                                    label: _mainController
                                                .dynamicBadgeType.value ==
                                            DynamicBadgeMode.number
                                        ? Text(e['count'].toString())
                                        : null,
                                    padding:
                                        const EdgeInsets.fromLTRB(6, 0, 6, 0),
                                    isLabelVisible: _mainController
                                                .dynamicBadgeType.value !=
                                            DynamicBadgeMode.hidden &&
                                        e['count'] > 0,
                                    child: e['icon'],
                                  ),
                                  activeIcon: e['selectIcon'],
                                  label: e['label'],
                                );
                              }),
                            ],
                          ),
                        ),
                );
              },
            )
          : null,
    );
  }

  Widget _buildWideScreenLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _mainController.selectedIndex,
            onDestinationSelected: (value) => setIndex(value),
            labelType: NavigationRailLabelType.all,
            destinations: _mainController.navigationBars.map((e) {
              return NavigationRailDestination(
                icon: Badge(
                  label: _mainController.dynamicBadgeType.value ==
                          DynamicBadgeMode.number
                      ? Text(e['count'].toString())
                      : null,
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                  isLabelVisible: _mainController.dynamicBadgeType.value !=
                          DynamicBadgeMode.hidden &&
                      e['count'] > 0,
                  child: e['icon'],
                ),
                selectedIcon: e['selectIcon'],
                label: Text(e['label']),
              );
            }).toList(),
          ),
          Expanded(
            child: Stack(
              children: [
                PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _mainController.pageController,
                  onPageChanged: (index) {
                    _mainController.selectedIndex = index;
                    setState(() {});
                  },
                  children: _mainController.pages,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
