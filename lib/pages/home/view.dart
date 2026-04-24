import 'dart:async';
import 'dart:io';

import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/pages/main/controller.dart';
import 'package:piliotto/pages/mine/index.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/storage.dart';
import './controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final HomeController _homeController = Get.put(HomeController());
  List videoList = [];
  late Stream<bool> stream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    stream = _homeController.searchBarStream.stream;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    EasyThrottle.throttle(
        'homePageDidChange', const Duration(milliseconds: 100), () {});
  }

  showUserBottomSheet() {
    feedBack();
    // 不使用侧边栏时，跳转到"我的"页面
    final mainController = Get.find<MainController>();
    if (mainController.useDrawerForUser) {
      // 使用侧边栏时，显示底页
      showModalBottomSheet(
        context: context,
        builder: (_) => const SizedBox(
          height: 450,
          child: MinePage(),
        ),
        clipBehavior: Clip.hardEdge,
        isScrollControlled: true,
      );
    } else {
      // 不使用侧边栏时，跳转到"我的"页面
      Get.toNamed('/mine');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isNarrowScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: Platform.isAndroid
            ? SystemUiOverlayStyle(
                statusBarIconBrightness:
                    Theme.of(context).brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark,
              )
            : Theme.of(context).brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
      ),
      body: Column(
        children: [
          CustomAppBar(
            stream: _homeController.hideSearchBar
                ? stream
                : StreamController<bool>.broadcast().stream,
            ctr: _homeController,
            callback: showUserBottomSheet,
            isNarrowScreen: isNarrowScreen,
          ),
          if (_homeController.tabs.length > 1) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: Align(
                alignment: Alignment.center,
                child: TabBar(
                  controller: _homeController.tabController,
                  tabs: [
                    for (var i in _homeController.tabs) Tab(text: i['label'])
                  ],
                  isScrollable: true,
                  dividerColor: Colors.transparent,
                  enableFeedback: true,
                  splashBorderRadius: BorderRadius.circular(10),
                  tabAlignment: TabAlignment.center,
                  onTap: (value) {
                    feedBack();
                    if (_homeController.initialIndex.value == value) {
                      _homeController.tabsCtrList[value]().animateToTop();
                    }
                    _homeController.initialIndex.value = value;
                  },
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 6),
          ],
          Expanded(
            child: TabBarView(
              controller: _homeController.tabController,
              children: _homeController.tabsPageList,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final Stream<bool>? stream;
  final HomeController? ctr;
  final Function? callback;
  final bool isNarrowScreen;

  const CustomAppBar({
    super.key,
    this.height = kToolbarHeight,
    this.stream,
    this.ctr,
    this.callback,
    this.isNarrowScreen = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream!.distinct(),
      initialData: true,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final RxBool isUserLoggedIn = ctr!.userLogin;
        final double top = MediaQuery.of(context).padding.top;
        return AnimatedOpacity(
          opacity: snapshot.data ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: AnimatedContainer(
            curve: Curves.easeInOutCubicEmphasized,
            duration: const Duration(milliseconds: 500),
            height: snapshot.data ? top + 52 : top,
            padding: EdgeInsets.fromLTRB(14, top + 6, 14, 0),
            child: UserInfoWidget(
              top: top,
              ctr: ctr,
              userLogin: isUserLoggedIn,
              userFace: ctr?.userFace.value,
              callback: () => callback!(),
              isNarrowScreen: isNarrowScreen,
            ),
          ),
        );
      },
    );
  }
}

class UserInfoWidget extends StatelessWidget {
  const UserInfoWidget({
    Key? key,
    required this.top,
    required this.userLogin,
    required this.userFace,
    required this.callback,
    required this.ctr,
    required this.isNarrowScreen,
  }) : super(key: key);

  final double top;
  final RxBool userLogin;
  final String? userFace;
  final VoidCallback? callback;
  final HomeController? ctr;
  final bool isNarrowScreen;

  Widget buildLoggedInWidget(context) {
    return Stack(
      children: [
        NetworkImgLayer(
          type: 'avatar',
          width: 34,
          height: 34,
          src: userFace,
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (isNarrowScreen) {
                  final mainController = Get.find<MainController>();
                  if (mainController.useDrawerForUser) {
                    mainController.scaffoldKey.currentState?.openDrawer();
                  } else {
                    Get.toNamed('/mine');
                  }
                } else {
                  Get.toNamed('/mine');
                }
              },
              splashColor: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.3),
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isNarrowScreen) ...[
          Obx(
            () => userLogin.value
                ? buildLoggedInWidget(context)
                : DefaultUser(
                    callback: () => callback!(),
                    isNarrowScreen: isNarrowScreen,
                  ),
          ),
          const SizedBox(width: 8),
        ],
        HomeSearchBar(ctr: ctr),
        if (!isNarrowScreen) ...[
          if (userLogin.value) ...[
            const SizedBox(width: 4),
            ClipRect(
              child: IconButton(
                onPressed: () => Get.toNamed('/whisper'),
                icon: const Icon(Icons.notifications_none),
              ),
            ),
          ],
          const SizedBox(width: 8),
          Obx(
            () => userLogin.value
                ? buildLoggedInWidget(context)
                : DefaultUser(
                    callback: () => callback!(),
                    isNarrowScreen: isNarrowScreen,
                  ),
          ),
        ],
      ],
    );
  }
}

class DefaultUser extends StatelessWidget {
  const DefaultUser({super.key, this.callback, this.isNarrowScreen = false});
  final Function? callback;
  final bool isNarrowScreen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: IconButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return Theme.of(context)
                .colorScheme
                .onSecondaryContainer
                .withValues(alpha: 0.05);
          }),
        ),
        onPressed: () {
          if (isNarrowScreen) {
            final mainController = Get.find<MainController>();
            if (mainController.useDrawerForUser) {
              mainController.scaffoldKey.currentState?.openDrawer();
            } else {
              callback?.call();
            }
          } else {
            callback?.call();
          }
        },
        icon: Icon(
          Icons.person_rounded,
          size: 22,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class CustomTabs extends StatefulWidget {
  const CustomTabs({super.key});

  @override
  State<CustomTabs> createState() => _CustomTabsState();
}

class _CustomTabsState extends State<CustomTabs> {
  final HomeController _homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      margin: const EdgeInsets.only(top: 4),
      child: TabBar(
        controller: _homeController.tabController,
        tabs: [for (var i in _homeController.tabs) Tab(text: i['label'])],
        isScrollable: true,
        dividerColor: Colors.transparent,
        onTap: (value) {
          feedBack();
          if (_homeController.initialIndex.value == value) {
            _homeController.tabsCtrList[value]().animateToTop();
          }
          _homeController.initialIndex.value = value;
        },
      ),
    );
  }
}

class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({
    Key? key,
    required this.ctr,
  }) : super(key: key);

  final HomeController? ctr;

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final SearchController _searchController = SearchController();
  final Box _historyBox = GStrorage.historyword;
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  void _loadSearchHistory() {
    final history = _historyBox.get('searchHistory', defaultValue: <String>[]);
    setState(() {
      _searchHistory = List<String>.from(history);
    });
  }

  void _saveSearchHistory(String keyword) {
    if (keyword.trim().isEmpty) return;
    _searchHistory.remove(keyword);
    _searchHistory.insert(0, keyword);
    if (_searchHistory.length > 20) {
      _searchHistory = _searchHistory.sublist(0, 20);
    }
    _historyBox.put('searchHistory', _searchHistory);
  }

  void _clearSearchHistory() {
    setState(() {
      _searchHistory.clear();
    });
    _historyBox.put('searchHistory', <String>[]);
  }

  void _onSearch(String keyword, {bool closeView = true}) {
    if (keyword.trim().isEmpty) return;
    _saveSearchHistory(keyword.trim());
    if (closeView) {
      _searchController.closeView(null);
    }
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.toNamed('/search', parameters: {'keyword': keyword.trim()});
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    return Expanded(
      child: Center(
        child: Obx(
          () => ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWideScreen ? 500 : double.infinity,
            ),
            child: SearchAnchor(
              searchController: _searchController,
              viewHintText: widget.ctr!.defaultSearch.value,
              viewOnSubmitted: (value) {
                _onSearch(value);
              },
              viewTrailing: [
                IconButton(
                  onPressed: () {
                    _onSearch(_searchController.text);
                  },
                  icon: const Icon(Icons.search),
                ),
              ],
              builder: (context, controller) {
                return SearchBar(
                  controller: controller,
                  hintText: widget.ctr!.defaultSearch.value,
                  leading: const Icon(Icons.search_outlined),
                  onTap: () {
                    controller.openView();
                  },
                  onChanged: (_) {
                    controller.openView();
                  },
                  onSubmitted: (value) {
                    _onSearch(value);
                  },
                  elevation: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.focused)) {
                      return 3.0;
                    }
                    return 0.0;
                  }),
                );
              },
              suggestionsBuilder: (context, controller) {
                final query = controller.text.toLowerCase();
                final filteredHistory = query.isEmpty
                    ? _searchHistory
                    : _searchHistory
                        .where((item) => item.toLowerCase().contains(query))
                        .toList();

                if (filteredHistory.isEmpty && query.isEmpty) {
                  return [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          '暂无搜索历史',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    ),
                  ];
                }

                final List<Widget> suggestions = [
                  if (_searchHistory.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '搜索历史',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          TextButton(
                            onPressed: _clearSearchHistory,
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('清空'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ];

                suggestions.addAll(
                  filteredHistory.map((item) {
                    return ListTile(
                      leading: const Icon(Icons.history, size: 20),
                      title: Text(item),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          setState(() {
                            _searchHistory.remove(item);
                            _historyBox.put('searchHistory', _searchHistory);
                          });
                        },
                      ),
                      onTap: () {
                        controller.closeView(item);
                        _onSearch(item, closeView: false);
                      },
                      dense: true,
                      visualDensity: VisualDensity.compact,
                    );
                  }),
                );

                return suggestions;
              },
            ),
          ),
        ),
      ),
    );
  }
}
