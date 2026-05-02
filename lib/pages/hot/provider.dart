import 'package:flutter/material.dart';
import 'package:piliotto/ottohub/api/models/video.dart';
import 'package:piliotto/providers/repository_provider.dart';
import 'package:piliotto/router/app_router.dart';
import 'package:piliotto/utils/responsive_util.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

class HotState {
  final List<Video> videoList;
  final int currentPage;
  final bool isLoadingMore;
  final String noMore;
  final int count;
  final int crossAxisCount;
  final int currentTabIndex;

  const HotState({
    this.videoList = const [],
    this.currentPage = 0,
    this.isLoadingMore = true,
    this.noMore = '',
    this.count = 0,
    this.crossAxisCount = 1,
    this.currentTabIndex = 0,
  });

  HotState copyWith({
    List<Video>? videoList,
    int? currentPage,
    bool? isLoadingMore,
    String? noMore,
    int? count,
    int? crossAxisCount,
    int? currentTabIndex,
  }) {
    return HotState(
      videoList: videoList ?? this.videoList,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      noMore: noMore ?? this.noMore,
      count: count ?? this.count,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }
}

@riverpod
class HotNotifier extends _$HotNotifier {
  final ScrollController scrollController = ScrollController();
  final int pageSize = 20;

  final List<Map<String, dynamic>> tabs = [
    {'label': '热门', 'timeLimit': 1},
    {'label': '周榜', 'timeLimit': 7},
    {'label': '月榜', 'timeLimit': 30},
  ];

  int get currentTimeLimit => tabs[state.currentTabIndex]['timeLimit'] as int;

  @override
  HotState build() {
    final crossAxisCount = _calculateCrossAxisCount();
    return HotState(crossAxisCount: crossAxisCount);
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

  void updateCrossAxisCount() {
    final count = _calculateCrossAxisCount();
    state = state.copyWith(crossAxisCount: count);
  }

  void onTabChanged(int index) {
    if (state.currentTabIndex == index) return;
    state = HotState(currentTabIndex: index, crossAxisCount: state.crossAxisCount);
    queryHotFeed(type: 'init');
  }

  Future<void> queryHotFeed({String type = 'init'}) async {
    if (state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);

    int newPage = state.currentPage;
    String newNoMore = state.noMore;
    List<Video> newList = state.videoList;

    if (type == 'init') {
      newPage = 0;
      newNoMore = '';
      newList = [];
    }

    if (newNoMore == '没有更多了') {
      state = state.copyWith(isLoadingMore: false);
      return;
    }

    try {
      final videoRepo = ref.read(videoRepositoryProvider);
      final response = await videoRepo.getPopularVideos(
        timeLimit: currentTimeLimit,
        offset: newPage * pageSize,
        num: pageSize,
      );
      final List<Video> videos = response.videoList;

      if (type == 'init') {
        newList = videos;
      } else {
        newList = [...newList, ...videos];
      }

      if (videos.length < pageSize) {
        newNoMore = '没有更多了';
      } else {
        newPage++;
        newNoMore = '';
      }

      state = state.copyWith(
        videoList: newList,
        currentPage: newPage,
        isLoadingMore: false,
        noMore: newNoMore,
        count: videos.length,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        noMore: '加载失败',
      );
    }
  }

  Future<void> onRefresh() async {
    await queryHotFeed(type: 'init');
  }

  Future<void> onLoad() async {
    await queryHotFeed(type: 'onLoad');
  }

  void animateToTop() async {
    final BuildContext? context = rootNavigatorKey.currentContext;
    if (context == null) return;
    if (scrollController.offset >= MediaQuery.of(context).size.height * 5) {
      scrollController.jumpTo(0);
    } else {
      await scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }
}
