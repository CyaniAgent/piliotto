import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:piliotto/services/ottohub_service.dart';
import 'package:piliotto/api/models/video.dart';
import 'package:piliotto/utils/responsive_util.dart';

class HotController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final int pageSize = 20;
  
  RxList<Video> videoList = <Video>[].obs;
  int currentPage = 0;
  bool isLoadingMore = false;
  String noMore = '';
  int count = 0;
  
  OverlayEntry? popupDialog;
  RxInt crossAxisCount = 1.obs;

  final List<Map<String, dynamic>> tabs = [
    {'label': '热门', 'timeLimit': 1},
    {'label': '周榜', 'timeLimit': 7},
    {'label': '月榜', 'timeLimit': 30},
  ];
  RxInt currentTabIndex = 0.obs;

  int get currentTimeLimit => tabs[currentTabIndex.value]['timeLimit'] as int;

  @override
  void onInit() {
    super.onInit();
    updateCrossAxisCount();
  }

  void updateCrossAxisCount() {
    try {
      int baseCount = ResponsiveUtil.calculateCrossAxisCount(
        baseCount: 1,
        minCount: 1,
        maxCount: 3,
      );
      crossAxisCount.value = baseCount;
    } catch (e) {
      crossAxisCount.value = 1;
    }
  }

  void onTabChanged(int index) {
    if (currentTabIndex.value == index) return;
    currentTabIndex.value = index;
    videoList.clear();
    currentPage = 0;
    noMore = '';
    queryHotFeed(type: 'init');
  }

  Future queryHotFeed({String type = 'init'}) async {
    if (isLoadingMore) {
      return;
    }

    isLoadingMore = true;

    if (type == 'init') {
      currentPage = 0;
      noMore = '';
    }

    if (noMore == '没有更多了') {
      isLoadingMore = false;
      return;
    }

    try {
      final response = await OttohubService.getPopularVideos(
        timeLimit: currentTimeLimit,
        offset: currentPage * pageSize,
        num: pageSize,
      );
      final List<Video> videos = response.videoList;

      if (type == 'init') {
        count = videos.length;
        videoList.clear();
        videoList.addAll(videos);
      } else {
        videoList.addAll(videos);
      }

      if (videos.length < pageSize) {
        noMore = '没有更多了';
      } else {
        currentPage++;
        noMore = '';
      }

      update();
    } catch (error) {
      noMore = '加载失败';
      update();
    }

    isLoadingMore = false;
  }

  Future onRefresh() async {
    currentPage = 0;
    noMore = '';
    await queryHotFeed(type: 'init');
  }

  Future onLoad() async {
    await queryHotFeed(type: 'onLoad');
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
