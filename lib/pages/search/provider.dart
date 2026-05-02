import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:piliotto/ottohub/api/models/video.dart';
import 'package:piliotto/ottohub/api/services/api_service.dart';
import 'package:piliotto/providers/repository_provider.dart';
import 'package:piliotto/router/app_router.dart';
import 'package:piliotto/services/loggeer.dart';
import 'package:piliotto/utils/responsive_util.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

final _logger = getLogger();

class SearchState {
  final List<Video> videoList;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String currentKeyword;
  final int crossAxisCount;
  final String errorMessage;
  final bool hasError;
  final int currentPage;

  const SearchState({
    this.videoList = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentKeyword = '',
    this.crossAxisCount = 1,
    this.errorMessage = '',
    this.hasError = false,
    this.currentPage = 1,
  });

  SearchState copyWith({
    List<Video>? videoList,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? currentKeyword,
    int? crossAxisCount,
    String? errorMessage,
    bool? hasError,
    int? currentPage,
  }) {
    return SearchState(
      videoList: videoList ?? this.videoList,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentKeyword: currentKeyword ?? this.currentKeyword,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      errorMessage: errorMessage ?? this.errorMessage,
      hasError: hasError ?? this.hasError,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

@riverpod
class SearchNotifier extends _$SearchNotifier {
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchInputController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  static const int _count = 20;

  @override
  SearchState build() {
    final crossAxisCount = _calculateCrossAxisCount();
    return SearchState(crossAxisCount: crossAxisCount);
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

  bool _isOVNumber(String input) {
    final RegExp ovPattern = RegExp(r'^OV(\d+)$', caseSensitive: false);
    return ovPattern.hasMatch(input.trim());
  }

  int? _extractVidFromOV(String input) {
    final RegExp ovPattern = RegExp(r'^OV(\d+)$', caseSensitive: false);
    final match = ovPattern.firstMatch(input.trim());
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  void _clearError() {
    state = state.copyWith(errorMessage: '', hasError: false);
  }

  void _setError(String message) {
    state = state.copyWith(errorMessage: message, hasError: true);
  }

  Future<void> searchVideos(String keyword, {bool isLoadMore = false}) async {
    if (keyword.isEmpty) return;

    final String trimmedKeyword = keyword.trim();

    if (_isOVNumber(trimmedKeyword)) {
      final int? vid = _extractVidFromOV(trimmedKeyword);
      if (vid != null) {
        final BuildContext? context = rootNavigatorKey.currentContext;
        if (context != null) {
          context.push('/video', extra: {
            'vid': vid,
            'heroTag': 'ov_$vid',
          });
        }
        return;
      }
    }

    if (!isLoadMore) {
      state = state.copyWith(
        isLoading: true,
        currentPage: 1,
        currentKeyword: keyword,
      );
      _clearError();
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      int offset = (state.currentPage - 1) * _count;
      final videoRepo = ref.read(videoRepositoryProvider);
      final response = await videoRepo.searchVideos(
        searchTerm: keyword,
        offset: offset,
        num: _count,
      );

      final List<Video> videos = response.videoList;

      final newList = isLoadMore ? [...state.videoList, ...videos] : videos;

      state = state.copyWith(
        videoList: newList,
        isLoading: false,
        isLoadingMore: false,
        hasMore: videos.length >= _count,
        currentPage: state.currentPage + 1,
      );
    } on ApiException catch (e) {
      _logger.w('搜索失败: ${e.message}');
      if (!isLoadMore) {
        _setError(e.message);
        state = state.copyWith(videoList: [], isLoading: false);
      } else {
        state = state.copyWith(isLoadingMore: false);
      }
    } catch (e) {
      _logger.w('搜索失败: $e');
      if (!isLoadMore) {
        _setError('搜索失败，请稍后重试');
        state = state.copyWith(videoList: [], isLoading: false);
      } else {
        state = state.copyWith(isLoadingMore: false);
      }
    }
  }

  Future<void> onLoad() async {
    if (state.isLoadingMore || !state.hasMore) return;
    await searchVideos(state.currentKeyword, isLoadMore: true);
  }

  Future<void> onRefresh() async {
    if (state.currentKeyword.isNotEmpty) {
      await searchVideos(state.currentKeyword);
    }
  }

  void clearSearchResult() {
    state = const SearchState();
    searchInputController.clear();
  }

  void retrySearch() {
    if (state.currentKeyword.isNotEmpty) {
      searchVideos(state.currentKeyword);
    }
  }

  void animateToTop() async {
    final BuildContext? context = rootNavigatorKey.currentContext;
    if (context == null) return;
    if (scrollController.offset >=
        MediaQuery.of(context).size.height * 5) {
      scrollController.jumpTo(0);
    } else {
      await scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }
}
