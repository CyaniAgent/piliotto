import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:piliotto/services/ottohub_service.dart';
import 'package:piliotto/api/models/video.dart';
import 'package:piliotto/utils/responsive_util.dart';

class HotController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final int _count = 20;
  int _currentPage = 1;
  RxList<Video> videoList = <Video>[].obs;
  bool isLoadingMore = false;
  bool flag = false;
  OverlayEntry? popupDialog;
  RxInt crossAxisCount = 1.obs;

  @override
  void onInit() {
    super.onInit();
    // 初始计算列数
    updateCrossAxisCount();
  }

  // 根据屏幕宽度更新列数
  void updateCrossAxisCount() {
    try {
      // 使用ResponsiveUtil计算列数
      int baseCount = ResponsiveUtil.calculateCrossAxisCount(
        baseCount: 1,
        minCount: 1,
        maxCount: 3,
      );

      crossAxisCount.value = baseCount;
    } catch (e) {
      // 捕获异常，避免在没有 context 时崩溃
      crossAxisCount.value = 1;
    }
  }

  // 获取热门视频
  Future queryHotFeed(type) async {
    try {
      int offset = (_currentPage - 1) * _count;
      final response = await OttohubService.getPopularVideos(
        timeLimit: 7,
        offset: offset,
        num: _count,
      );
      final List<Video> videos = response.videoList;

      if (type == 'init') {
        videoList.clear();
        videoList.addAll(videos);
      } else if (type == 'onRefresh') {
        videoList.insertAll(0, videos);
      } else if (type == 'onLoad') {
        videoList.addAll(videos);
      }
      _currentPage += 1;
      isLoadingMore = false;
      return {'status': true, 'data': videos};
    } catch (error) {
      isLoadingMore = false;
      return {'status': false, 'data': [], 'msg': error.toString()};
    }
  }

  // 下拉刷新
  Future onRefresh() async {
    queryHotFeed('onRefresh');
  }

  // 上拉加载
  Future onLoad() async {
    queryHotFeed('onLoad');
  }

  // 返回顶部并刷新
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
