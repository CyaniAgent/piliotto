import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:piliotto/ottohub/api/models/video.dart';
import 'package:piliotto/providers/repository_provider.dart';
import 'package:piliotto/services/loggeer.dart';
import 'package:piliotto/utils/responsive_util.dart';

part 'provider.g.dart';

final _logger = getLogger();

class FavState {
  final List<Video> favoriteList;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int crossAxisCount;
  final int currentPage;

  const FavState({
    this.favoriteList = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.crossAxisCount = 1,
    this.currentPage = 0,
  });

  FavState copyWith({
    List<Video>? favoriteList,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? crossAxisCount,
    int? currentPage,
  }) {
    return FavState(
      favoriteList: favoriteList ?? this.favoriteList,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

@riverpod
class FavNotifier extends _$FavNotifier {
  static const int _pageSize = 20;

  @override
  FavState build() {
    return const FavState();
  }

  void updateCrossAxisCount() {
    try {
      int baseCount = ResponsiveUtil.calculateCrossAxisCount(
        baseCount: 1,
        minCount: 1,
        maxCount: 3,
      );
      state = state.copyWith(crossAxisCount: baseCount);
    } catch (e) {
      state = state.copyWith(crossAxisCount: 1);
    }
  }

  Future<void> queryFavorites({bool isLoadMore = false}) async {
    if (state.isLoading || state.isLoadingMore) return;

    if (!isLoadMore) {
      state = state.copyWith(isLoading: true, currentPage: 0);
    } else {
      if (!state.hasMore) return;
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final videoRepo = ref.read(videoRepositoryProvider);
      final response = await videoRepo.getFavoriteVideos(
        offset: state.currentPage,
        num: _pageSize,
      );

      final List<Video> videos = response.videoList;

      final newList = isLoadMore ? [...state.favoriteList, ...videos] : videos;

      state = state.copyWith(
        favoriteList: newList,
        isLoading: false,
        isLoadingMore: false,
        hasMore: videos.length >= _pageSize,
        currentPage: state.currentPage + 1,
      );
    } catch (e) {
      _logger.e('获取收藏列表失败: $e');
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
      );
    }
  }

  Future<void> onLoad() async {
    await queryFavorites(isLoadMore: true);
  }

  Future<void> onRefresh() async {
    await queryFavorites();
  }

  Future<void> removeFavorite(int vid) async {
    try {
      final videoRepo = ref.read(videoRepositoryProvider);
      await videoRepo.toggleFavorite(vid: vid);
      final newList = state.favoriteList.where((v) => v.vid != vid).toList();
      state = state.copyWith(favoriteList: newList);
    } catch (e) {
      _logger.e('取消收藏失败: $e');
    }
  }

  void animateToTop(
      ScrollController scrollController, BuildContext context) async {
    if (scrollController.offset >= MediaQuery.of(context).size.height * 5) {
      scrollController.jumpTo(0);
    } else {
      await scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
}
