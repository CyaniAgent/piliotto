import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/services/ottohub_service.dart';
import 'package:piliotto/api/models/video.dart';
import 'package:piliotto/api/services/api_service.dart';
import 'package:piliotto/utils/responsive_util.dart';
import 'package:piliotto/services/loggeer.dart';

final _logger = getLogger();

class VideoSearchController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchInputController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  final int _count = 20;
  int _currentPage = 1;
  RxList<Video> videoList = <Video>[].obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool hasMore = true.obs;
  RxString currentKeyword = ''.obs;
  RxInt crossAxisCount = 1.obs;
  RxString errorMessage = ''.obs;
  RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    updateCrossAxisCount();
  }

  void updateCrossAxisCount() {
    try {
      crossAxisCount.value = ResponsiveUtil.calculateCrossAxisCount(
        baseCount: 1,
        minCount: 1,
        maxCount: 3,
      );
    } catch (e) {
      crossAxisCount.value = 1;
    }
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
    errorMessage.value = '';
    hasError.value = false;
  }

  void _setError(String message) {
    errorMessage.value = message;
    hasError.value = true;
  }

  Future<void> searchVideos(String keyword, {bool isLoadMore = false}) async {
    if (keyword.isEmpty) return;

    final String trimmedKeyword = keyword.trim();

    if (_isOVNumber(trimmedKeyword)) {
      final int? vid = _extractVidFromOV(trimmedKeyword);
      if (vid != null) {
        Get.toNamed('/video?vid=$vid', arguments: {
          'heroTag': 'ov_$vid',
        });
        return;
      }
    }

    if (!isLoadMore) {
      isLoading.value = true;
      _currentPage = 1;
      currentKeyword.value = keyword;
      _clearError();
    } else {
      isLoadingMore.value = true;
    }

    try {
      int offset = (_currentPage - 1) * _count;
      final response = await OttohubService.searchVideos(
        searchTerm: keyword,
        offset: offset,
        num: _count,
      );

      final List<Video> videos = response.videoList;

      if (isLoadMore) {
        videoList.addAll(videos);
      } else {
        videoList.value = videos;
      }

      hasMore.value = videos.length >= _count;
      _currentPage++;
    } on ApiException catch (e) {
      _logger.w('搜索失败: ${e.message}');
      if (!isLoadMore) {
        _setError(e.message);
        videoList.clear();
      }
    } catch (e) {
      _logger.w('搜索失败: $e');
      if (!isLoadMore) {
        _setError('搜索失败，请稍后重试');
        videoList.clear();
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> onLoad() async {
    if (isLoadingMore.value || !hasMore.value) return;
    await searchVideos(currentKeyword.value, isLoadMore: true);
  }

  Future<void> onRefresh() async {
    if (currentKeyword.value.isNotEmpty) {
      await searchVideos(currentKeyword.value);
    }
  }

  void clearSearchResult() {
    videoList.clear();
    currentKeyword.value = '';
    searchInputController.clear();
    _clearError();
  }

  void retrySearch() {
    if (currentKeyword.value.isNotEmpty) {
      searchVideos(currentKeyword.value);
    }
  }

  void animateToTop() async {
    if (scrollController.offset >=
        MediaQuery.of(Get.context!).size.height * 5) {
      scrollController.jumpTo(0);
    } else {
      await scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }
}
