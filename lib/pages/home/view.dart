import 'dart:async';
import 'dart:io';

import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:piliotto/common/widgets/network_img_layer.dart';
import 'package:piliotto/pages/home/provider.dart';
import 'package:piliotto/pages/main/view.dart';
import 'package:piliotto/pages/mine/index.dart';
import 'package:piliotto/services/search_history_service.dart';
import 'package:piliotto/utils/feed_back.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late TabController _tabController;
  late Stream<bool> _stream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final state = ref.read(homeProvider);
    _tabController = TabController(
      initialIndex: state.initialIndex,
      length: state.tabs.length,
      vsync: this,
    );
    _stream = ref.read(homeProvider.notifier).searchBarStream.stream;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    EasyThrottle.throttle(
        'homePageDidChange', const Duration(milliseconds: 100), () {});
  }

  void showUserBottomSheet() {
    feedBack();
    final mainState = ref.read(mainAppProvider);
    if (mainState.useDrawerForUser) {
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
      context.push('/mine');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(homeProvider);
    final notifier = ref.read(homeProvider.notifier);
    final isNarrowScreen = MediaQuery.of(context).size.width < 600;

    if (_tabController.length != state.tabs.length) {
      _tabController.dispose();
      _tabController = TabController(
        initialIndex: state.initialIndex,
        length: state.tabs.length,
        vsync: this,
      );
    }

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
            stream: state.hideSearchBar
                ? _stream
                : StreamController<bool>.broadcast().stream,
            isNarrowScreen: isNarrowScreen,
            callback: showUserBottomSheet,
          ),
          if (state.tabs.length > 1) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: Align(
                alignment: Alignment.center,
                child: TabBar(
                  controller: _tabController,
                  tabs: [
                    for (var i in state.tabs) Tab(text: i['label'])
                  ],
                  isScrollable: true,
                  dividerColor: Colors.transparent,
                  enableFeedback: true,
                  splashBorderRadius: BorderRadius.circular(10),
                  tabAlignment: TabAlignment.center,
                  onTap: (value) {
                    feedBack();
                    if (state.initialIndex == value) {
                      final ctr = state.tabs[value]['ctr'] as Function;
                      (ctr() as dynamic).animateToTop();
                    }
                    notifier.setInitialIndex(value);
                  },
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 6),
          ],
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: state.tabs.map<Widget>((e) => e['page'] as Widget).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final Stream<bool>? stream;
  final Function? callback;
  final bool isNarrowScreen;

  const CustomAppBar({
    super.key,
    this.height = kToolbarHeight,
    this.stream,
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
        final double top = MediaQuery.of(context).padding.top;
        return AnimatedOpacity(
          opacity: snapshot.data ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: AnimatedContainer(
            curve: Curves.easeInOutCubicEmphasized,
            duration: const Duration(milliseconds: 500),
            height: snapshot.data ? top + 52 : top,
            padding: EdgeInsets.fromLTRB(14, top + 6, 14, 0),
            child: _AppBarContent(
              top: top,
              callback: callback,
              isNarrowScreen: isNarrowScreen,
            ),
          ),
        );
      },
    );
  }
}

class _AppBarContent extends ConsumerWidget {
  final double top;
  final Function? callback;
  final bool isNarrowScreen;

  const _AppBarContent({
    required this.top,
    this.callback,
    required this.isNarrowScreen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    final mainState = ref.watch(mainAppProvider);

    return Row(
      children: [
        if (isNarrowScreen) ...[
          _UserAvatar(
            userLogin: state.userLogin,
            userFace: state.userFace,
            useDrawer: mainState.useDrawerForUser,
            callback: callback,
            isNarrowScreen: isNarrowScreen,
          ),
          const SizedBox(width: 8),
        ],
        HomeSearchBar(defaultSearch: state.defaultSearch),
        if (!isNarrowScreen) ...[
          if (state.userLogin) ...[
            const SizedBox(width: 4),
            ClipRect(
              child: IconButton(
                onPressed: () => context.push('/message'),
                icon: const Icon(Icons.notifications_none),
              ),
            ),
          ],
          const SizedBox(width: 8),
          _UserAvatar(
            userLogin: state.userLogin,
            userFace: state.userFace,
            useDrawer: mainState.useDrawerForUser,
            callback: callback,
            isNarrowScreen: isNarrowScreen,
          ),
        ],
      ],
    );
  }
}

class _UserAvatar extends ConsumerWidget {
  final bool userLogin;
  final String userFace;
  final bool useDrawer;
  final Function? callback;
  final bool isNarrowScreen;

  const _UserAvatar({
    required this.userLogin,
    required this.userFace,
    required this.useDrawer,
    this.callback,
    required this.isNarrowScreen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userLogin) {
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
                  if (isNarrowScreen && useDrawer) {
                    final mainNotifier = ref.read(mainAppProvider.notifier);
                    mainNotifier.scaffoldKey.currentState?.openDrawer();
                  } else {
                    context.push('/mine');
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
          if (isNarrowScreen && useDrawer) {
            final mainNotifier = ref.read(mainAppProvider.notifier);
            mainNotifier.scaffoldKey.currentState?.openDrawer();
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

class HomeSearchBar extends StatefulWidget {
  final String defaultSearch;

  const HomeSearchBar({
    super.key,
    required this.defaultSearch,
  });

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final SearchController _searchController = SearchController();
  final SearchHistoryService _historyService = SearchHistoryService();

  @override
  void initState() {
    super.initState();
    _historyService.loadSearchHistory();
  }

  void _onSearch(String keyword, {bool closeView = true}) {
    if (keyword.trim().isEmpty) return;
    _historyService.saveSearchHistory(keyword.trim());
    if (closeView) {
      _searchController.closeView(null);
    }
    final context = this.context;
    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
        context.push('/search?keyword=${Uri.encodeComponent(keyword.trim())}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    return Expanded(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWideScreen ? 500 : double.infinity,
          ),
          child: SearchAnchor(
            searchController: _searchController,
            viewHintText: widget.defaultSearch,
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
                hintText: widget.defaultSearch,
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
              final query = controller.text;
              final filteredHistory = _historyService.filterSearchHistory(query);

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
                if (_historyService.currentHistory.isNotEmpty) ...[
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
                          onPressed: () {
                            setState(() {});
                            _historyService.clearSearchHistory();
                          },
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
                        setState(() {});
                        _historyService.removeSearchHistory(item);
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
    );
  }
}
