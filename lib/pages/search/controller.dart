import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/services/ottohub_service.dart';
import 'package:piliotto/api/models/video.dart';
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

  Future<void> searchVideos(String keyword, {bool isLoadMore = false}) async {
    if (keyword.isEmpty) return;

    if (!isLoadMore) {
      isLoading.value = true;
      _currentPage = 1;
      currentKeyword.value = keyword;
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
    } catch (e) {
      _logger.i('搜索失败: $e');
      Get.snackbar('搜索失败', e.toString());
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
