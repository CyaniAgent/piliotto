import 'package:piliotto/ottohub/api/models/video.dart';
import 'package:piliotto/providers/repository_provider.dart';
import 'package:piliotto/services/loggeer.dart';
import 'package:piliotto/utils/route_arguments.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

final _logger = getLogger();

class FavDetailState {
  final String title;
  final List<Video> favList;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String loadingText;
  final int currentPage;

  const FavDetailState({
    this.title = '',
    this.favList = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.loadingText = '加载中...',
    this.currentPage = 0,
  });

  FavDetailState copyWith({
    String? title,
    List<Video>? favList,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? loadingText,
    int? currentPage,
  }) {
    return FavDetailState(
      title: title ?? this.title,
      favList: favList ?? this.favList,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      loadingText: loadingText ?? this.loadingText,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

@riverpod
class FavDetailNotifier extends _$FavDetailNotifier {
  static const int _pageSize = 20;

  @override
  FavDetailState build() {
    final title = routeArguments.queryParameters['title'] ?? '我的收藏';
    final initialState = FavDetailState(title: title);
    Future.microtask(() => queryFavorites());
    return initialState;
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

      final newList = isLoadMore ? [...state.favList, ...videos] : videos;

      final newHasMore = videos.length >= _pageSize;
      String newLoadingText = state.loadingText;
      if (!newHasMore && newList.isNotEmpty) {
        newLoadingText = '没有更多了';
      }

      state = state.copyWith(
        favList: newList,
        isLoading: false,
        isLoadingMore: false,
        hasMore: newHasMore,
        loadingText: newLoadingText,
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
      final newList = state.favList.where((v) => v.vid != vid).toList();
      state = state.copyWith(favList: newList);
    } catch (e) {
      _logger.e('取消收藏失败: $e');
    }
  }
}
