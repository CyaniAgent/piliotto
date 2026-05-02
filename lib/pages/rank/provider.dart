import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:piliotto/providers/repository_provider.dart';
import 'package:piliotto/ottohub/api/models/video.dart';
import 'package:piliotto/router/app_router.dart';
import 'package:piliotto/services/loggeer.dart';
import 'package:piliotto/utils/responsive_util.dart';

part 'provider.g.dart';

class RankState {
  final List<Video> videoList;
  final bool isLoading;
  final int crossAxisCount;
  final int currentTabIndex;

  const RankState({
    this.videoList = const [],
    this.isLoading = true,
    this.crossAxisCount = 1,
    this.currentTabIndex = 0,
  });

  RankState copyWith({
    List<Video>? videoList,
    bool? isLoading,
    int? crossAxisCount,
    int? currentTabIndex,
  }) {
    return RankState(
      videoList: videoList ?? this.videoList,
      isLoading: isLoading ?? this.isLoading,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }
}

@riverpod
class RankNotifier extends _$RankNotifier {
  final ScrollController scrollController = ScrollController();
  late TabController tabController;

  final List<Map<String, dynamic>> tabs = [
    {'label': '热门', 'timeLimit': 1},
    {'label': '周榜', 'timeLimit': 7},
    {'label': '月榜', 'timeLimit': 30},
  ];

  @override
  RankState build() {
    final crossAxisCount = _calculateCrossAxisCount();
    return RankState(crossAxisCount: crossAxisCount);
  }

  int _calculateCrossAxisCount() {
    try {
      return ResponsiveUtil.calculateCrossAxisCount(
        baseCount: 1,
        minCount: 1,
        maxCount: 3,
      );
    } catch (e) {
      return 1;
    }
  }

  void initTabController(TickerProvider vsync) {
    tabController = TabController(length: tabs.length, vsync: vsync);
    tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (tabController.index != state.currentTabIndex) {
      state = state.copyWith(currentTabIndex: tabController.index);
      loadVideos();
    }
  }

  void updateCrossAxisCount() {
    final count = _calculateCrossAxisCount();
    state = state.copyWith(crossAxisCount: count);
  }

  Future<void> loadVideos() async {
    state = state.copyWith(isLoading: true);
    try {
      final timeLimit = tabs[state.currentTabIndex]['timeLimit'] as int;
      final response = await ref.read(videoRepositoryProvider).getPopularVideos(
        timeLimit: timeLimit,
        offset: 0,
        num: 50,
      );
      state = state.copyWith(videoList: response.videoList, isLoading: false);
    } catch (e) {
      getLogger().e('加载排行榜失败: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> onRefresh() async {
    await loadVideos();
  }

  void animateToTop() {
    final BuildContext? context = rootNavigatorKey.currentContext;
    if (context == null) return;
    if (scrollController.hasClients) {
      if (scrollController.offset >= MediaQuery.of(context).size.height * 5) {
        scrollController.jumpTo(0);
      } else {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void dispose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    scrollController.dispose();
  }
}
