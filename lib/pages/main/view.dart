import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:piliotto/common/widgets/user_drawer.dart';
import 'package:piliotto/models/common/dynamic_badge_mode.dart';
import 'package:piliotto/models/common/nav_bar_config.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/responsive_util.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'view.g.dart';

class MainAppState {
  final List<Widget> pages;
  final List<int> pagesIds;
  final List<Map<String, dynamic>> navigationBars;
  final int selectedIndex;
  final bool userLogin;
  final DynamicBadgeMode dynamicBadgeType;
  final bool hideTabBar;
  final bool useDrawerForUser;
  final bool enableGradientBg;
  final bool imgPreviewStatus;

  const MainAppState({
    this.pages = const [],
    this.pagesIds = const [],
    this.navigationBars = const [],
    this.selectedIndex = 0,
    this.userLogin = false,
    this.dynamicBadgeType = DynamicBadgeMode.number,
    this.hideTabBar = false,
    this.useDrawerForUser = true,
    this.enableGradientBg = true,
    this.imgPreviewStatus = false,
  });

  MainAppState copyWith({
    List<Widget>? pages,
    List<int>? pagesIds,
    List<Map<String, dynamic>>? navigationBars,
    int? selectedIndex,
    bool? userLogin,
    DynamicBadgeMode? dynamicBadgeType,
    bool? hideTabBar,
    bool? useDrawerForUser,
    bool? enableGradientBg,
    bool? imgPreviewStatus,
  }) {
    return MainAppState(
      pages: pages ?? this.pages,
      pagesIds: pagesIds ?? this.pagesIds,
      navigationBars: navigationBars ?? this.navigationBars,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      userLogin: userLogin ?? this.userLogin,
      dynamicBadgeType: dynamicBadgeType ?? this.dynamicBadgeType,
      hideTabBar: hideTabBar ?? this.hideTabBar,
      useDrawerForUser: useDrawerForUser ?? this.useDrawerForUser,
      enableGradientBg: enableGradientBg ?? this.enableGradientBg,
      imgPreviewStatus: imgPreviewStatus ?? this.imgPreviewStatus,
    );
  }
}

@riverpod
class MainAppNotifier extends _$MainAppNotifier {
  late PageController pageController;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final StreamController<bool> bottomBarStream = StreamController<bool>.broadcast();
  DateTime? _lastPressedAt;

  @override
  MainAppState build() {
    pageController = PageController(initialPage: 0);
    _initConfig();
    return state;
  }

  void _initConfig() {
    bool hideTabBar = false;
    bool useDrawerForUser = true;
    bool userLogin = false;
    DynamicBadgeMode dynamicBadgeType = DynamicBadgeMode.number;
    bool enableGradientBg = true;

    try {
      hideTabBar = GStrorage.setting.get(SettingBoxKey.hideTabBar, defaultValue: false);
      useDrawerForUser = GStrorage.setting.get(SettingBoxKey.useDrawerForUser, defaultValue: true);
      final userInfo = GStrorage.userInfo.get('userInfoCache');
      userLogin = userInfo != null;
      dynamicBadgeType = DynamicBadgeMode.values[GStrorage.setting.get(
          SettingBoxKey.dynamicBadgeMode, defaultValue: DynamicBadgeMode.number.code)];
      enableGradientBg = GStrorage.setting.get(SettingBoxKey.enableGradientBg, defaultValue: true);
    } catch (_) {}

    state = MainAppState(
      hideTabBar: hideTabBar,
      useDrawerForUser: useDrawerForUser,
      userLogin: userLogin,
      dynamicBadgeType: dynamicBadgeType,
      enableGradientBg: enableGradientBg,
    );

    _setNavBarConfig();
  }

  void _setNavBarConfig() {
    List<int> navBarSort;
    try {
      navBarSort = GStrorage.setting.get(SettingBoxKey.navBarSort, defaultValue: [0, 1, 3]);
    } catch (_) {
      navBarSort = [0, 1, 3];
    }

    for (var item in defaultNavigationBars) {
      if (!navBarSort.contains(item['id'])) {
        navBarSort.add(item['id']);
      }
    }

    navBarSort.removeWhere((id) => !defaultNavigationBars.any((item) => item['id'] == id));

    final isNarrowScreen = WidgetsBinding
                .instance.platformDispatcher.implicitView?.physicalSize.width != null &&
        (WidgetsBinding.instance.platformDispatcher.implicitView!.physicalSize.width /
                WidgetsBinding.instance.platformDispatcher.implicitView!.devicePixelRatio) <
            600;
    if (isNarrowScreen && state.useDrawerForUser) {
      navBarSort.remove(3);
    }

    List<Map<String, dynamic>> defaultNavTabs = [...defaultNavigationBars];
    defaultNavTabs.retainWhere((item) => navBarSort.contains(item['id']));
    defaultNavTabs.sort((a, b) => navBarSort.indexOf(a['id']).compareTo(navBarSort.indexOf(b['id'])));

    int defaultHomePage;
    try {
      defaultHomePage = GStrorage.setting.get(SettingBoxKey.defaultHomePage, defaultValue: 0) as int;
    } catch (_) {
      defaultHomePage = 0;
    }

    int defaultIndex = defaultNavTabs.indexWhere((item) => item['id'] == defaultHomePage);
    int selectedIndex = defaultIndex != -1 ? defaultIndex : 0;

    List<Widget> pages = defaultNavTabs.map<Widget>((e) => e['page'] as Widget).toList();
    List<int> pagesIds = defaultNavTabs.map<int>((e) => e['id'] as int).toList();

    state = state.copyWith(
      navigationBars: defaultNavTabs,
      selectedIndex: selectedIndex,
      pages: pages,
      pagesIds: pagesIds,
    );
    
    pageController = PageController(initialPage: selectedIndex);
  }

  void setSelectedIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }

  void onBackPressed(BuildContext context) {
    if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      _lastPressedAt = DateTime.now();
      if (state.selectedIndex != 0) {
        pageController.jumpTo(0);
      }
      SmartDialog.showToast("再按一次退出PiliOtto");
      return;
    }
    Navigator.of(context).pop();
  }
}

class MainApp extends ConsumerStatefulWidget {
  final Widget? child;

  const MainApp({super.key, this.child});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  late bool enableMYBar;

  @override
  void initState() {
    super.initState();
    try {
      enableMYBar = GStrorage.setting.get(SettingBoxKey.enableMYBar, defaultValue: true);
    } catch (_) {
      enableMYBar = true;
    }
  }

  void setIndex(int value, MainAppNotifier notifier) {
    feedBack();
    notifier.pageController.jumpToPage(value);
    notifier.setSelectedIndex(value);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mainAppProvider);
    final notifier = ref.read(mainAppProvider.notifier);

    double statusBarHeight = MediaQuery.of(context).padding.top;
    double sheetHeight = MediaQuery.sizeOf(context).height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).size.width * 9 / 16;
    try {
      GStrorage.localCache.put('sheetHeight', sheetHeight);
      GStrorage.localCache.put('statusBarHeight', statusBarHeight);
    } catch (_) {}
    bool isWideScreen = ResponsiveUtil.isLg || ResponsiveUtil.isXl;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        notifier.onBackPressed(context);
      },
      child: isWideScreen
          ? _buildWideScreenLayout(context, state, notifier)
          : _buildNarrowScreenLayout(context, state, notifier),
    );
  }

  Widget _buildNarrowScreenLayout(BuildContext context, MainAppState state, MainAppNotifier notifier) {
    final useDrawer = state.useDrawerForUser;
    return Scaffold(
      key: notifier.scaffoldKey,
      drawer: useDrawer ? const UserDrawer() : null,
      extendBody: true,
      body: Stack(
        children: [
          PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: notifier.pageController,
            onPageChanged: (index) {
              notifier.setSelectedIndex(index);
            },
            children: state.pages,
          ),
        ],
      ),
      bottomNavigationBar: state.navigationBars.length > 1
          ? StreamBuilder(
              stream: state.hideTabBar
                  ? notifier.bottomBarStream.stream.distinct()
                  : StreamController<bool>.broadcast().stream,
              initialData: true,
              builder: (context, AsyncSnapshot snapshot) {
                return AnimatedSlide(
                  curve: Curves.easeInOutCubicEmphasized,
                  duration: const Duration(milliseconds: 500),
                  offset: Offset(0, snapshot.data ? 0 : 1),
                  child: enableMYBar
                      ? NavigationBar(
                          onDestinationSelected: (value) => setIndex(value, notifier),
                          selectedIndex: state.selectedIndex,
                          destinations: <Widget>[
                            ...state.navigationBars.map((e) {
                              return NavigationDestination(
                                icon: Badge(
                                  label: state.dynamicBadgeType == DynamicBadgeMode.number
                                      ? Text(e['count'].toString())
                                      : null,
                                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                                  isLabelVisible: state.dynamicBadgeType != DynamicBadgeMode.hidden &&
                                      e['count'] > 0,
                                  child: e['icon'],
                                ),
                                selectedIcon: e['selectIcon'],
                                label: e['label'],
                              );
                            }),
                          ],
                        )
                      : BottomNavigationBar(
                          currentIndex: state.selectedIndex,
                          type: BottomNavigationBarType.fixed,
                          onTap: (value) => setIndex(value, notifier),
                          iconSize: 16,
                          selectedFontSize: 12,
                          unselectedFontSize: 12,
                          items: [
                            ...state.navigationBars.map((e) {
                              return BottomNavigationBarItem(
                                icon: Badge(
                                  label: state.dynamicBadgeType == DynamicBadgeMode.number
                                      ? Text(e['count'].toString())
                                      : null,
                                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                                  isLabelVisible: state.dynamicBadgeType != DynamicBadgeMode.hidden &&
                                      e['count'] > 0,
                                  child: e['icon'],
                                ),
                                activeIcon: e['selectIcon'],
                                label: e['label'],
                              );
                            }),
                          ],
                        ),
                );
              },
            )
          : null,
    );
  }

  Widget _buildWideScreenLayout(BuildContext context, MainAppState state, MainAppNotifier notifier) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: state.selectedIndex,
            onDestinationSelected: (value) => setIndex(value, notifier),
            labelType: NavigationRailLabelType.all,
            destinations: state.navigationBars.map((e) {
              return NavigationRailDestination(
                icon: Badge(
                  label: state.dynamicBadgeType == DynamicBadgeMode.number
                      ? Text(e['count'].toString())
                      : null,
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                  isLabelVisible: state.dynamicBadgeType != DynamicBadgeMode.hidden &&
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
                  controller: notifier.pageController,
                  onPageChanged: (index) {
                    notifier.setSelectedIndex(index);
                  },
                  children: state.pages,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
