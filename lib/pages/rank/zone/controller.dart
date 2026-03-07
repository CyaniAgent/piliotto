import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:piliotto/http/video.dart';
import 'package:piliotto/models/model_hot_video_item.dart';
import 'package:piliotto/utils/responsive_util.dart';

class ZoneController extends GetxController {
  final ScrollController scrollController = ScrollController();
  RxList<HotVideoItemModel> videoList = <HotVideoItemModel>[].obs;
  bool isLoadingMore = false;
  bool flag = false;
  OverlayEntry? popupDialog;
  int zoneID = 0;
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

  // 获取推荐
  Future queryRankFeed(type, rid) async {
    zoneID = rid;
    var res = await VideoHttp.getRankVideoList(zoneID);
    if (res['status']) {
      if (type == 'init') {
        videoList.value = res['data'];
      } else if (type == 'onRefresh') {
        videoList.clear();
        videoList.addAll(res['data']);
      } else if (type == 'onLoad') {
        videoList.clear();
        videoList.addAll(res['data']);
      }
    }
    isLoadingMore = false;
    return res;
  }

  // 下拉刷新
  Future onRefresh() async {
    queryRankFeed('onRefresh', zoneID);
  }

  // 上拉加载
  Future onLoad() async {
    queryRankFeed('onLoad', zoneID);
  }

  // 返回顶部并刷新
  void animateToTop() async {
    if (scrollController.hasClients) {
      if (scrollController.offset >=
          MediaQuery.of(Get.context!).size.height * 5) {
        scrollController.jumpTo(0);
      } else {
        await scrollController.animateTo(0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
      }
    }
  }
}
