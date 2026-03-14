import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/api/models/video.dart';
import 'package:piliotto/services/ottohub_service.dart';
import 'package:piliotto/services/loggeer.dart';

final _logger = getLogger();

class FavController extends GetxController {
  final ScrollController scrollController = ScrollController();

  RxList<Video> favoriteList = <Video>[].obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool hasMore = true.obs;

  int _currentPage = 0;
  final int _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    queryFavorites();
  }

  Future<void> queryFavorites({bool isLoadMore = false}) async {
    if (isLoading.value || isLoadingMore.value) return;

    if (!isLoadMore) {
      isLoading.value = true;
      _currentPage = 0;
    } else {
      if (!hasMore.value) return;
      isLoadingMore.value = true;
    }

    try {
      final response = await OttohubService.getFavoriteVideos(
        offset: _currentPage,
        num: _pageSize,
      );

      final List<Video> videos = response.videoList;

      if (isLoadMore) {
        favoriteList.addAll(videos);
      } else {
        favoriteList.value = videos;
      }

      hasMore.value = videos.length >= _pageSize;
      _currentPage++;
    } catch (e) {
      _logger.e('获取收藏列表失败: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
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
      await OttohubService.toggleFavorite(vid: vid);
      favoriteList.removeWhere((v) => v.vid == vid);
    } catch (e) {
      _logger.e('取消收藏失败: $e');
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
