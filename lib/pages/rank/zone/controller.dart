import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:piliotto/utils/responsive_util.dart';

class ZoneController extends GetxController {
  final ScrollController scrollController = ScrollController();
  RxList<Map<String, dynamic>> videoList = <Map<String, dynamic>>[].obs;
  bool isLoadingMore = false;
  bool flag = false;
  OverlayEntry? popupDialog;
  int zoneID = 0;
  RxInt crossAxisCount = 1.obs;

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

  Future<dynamic> queryRankFeed(String type, int rid) async {
    zoneID = rid;
    var res = {'status': true, 'data': <Map<String, dynamic>>[]};
    if (res['status'] == true) {
      if (type == 'init') {
        videoList.value = res['data'] as List<Map<String, dynamic>>;
      } else if (type == 'onRefresh') {
        videoList.clear();
        videoList.addAll(res['data'] as List<Map<String, dynamic>>);
      } else if (type == 'onLoad') {
        videoList.clear();
        videoList.addAll(res['data'] as List<Map<String, dynamic>>);
      }
    }
    isLoadingMore = false;
    return res;
  }

  Future onRefresh() async {
    queryRankFeed('onRefresh', zoneID);
  }

  Future onLoad() async {
    queryRankFeed('onLoad', zoneID);
  }

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
