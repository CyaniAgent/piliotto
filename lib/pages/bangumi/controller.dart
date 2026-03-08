import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/http/bangumi.dart';
import 'package:piliotto/models/bangumi/list.dart';
import 'package:piliotto/utils/responsive_util.dart';
import 'package:piliotto/utils/storage.dart';

class BangumiController extends GetxController {
  final ScrollController scrollController = ScrollController();
  RxList<BangumiListItemModel> bangumiList = <BangumiListItemModel>[].obs;
  RxList<BangumiListItemModel> bangumiFollowList = <BangumiListItemModel>[].obs;
  int _currentPage = 1;
  bool isLoadingMore = true;
  Box userInfoCache = GStrorage.userInfo;
  RxBool userLogin = false.obs;
  late int mid;
  dynamic userInfo;
  RxInt crossAxisCount = 3.obs;

  @override
  void onInit() {
    super.onInit();
    userInfo = userInfoCache.get('userInfoCache');
    if (userInfo != null) {
      mid = userInfo.mid;
    }
    userLogin.value = userInfo != null;
    // 初始列数设为3
    crossAxisCount.value = 3;
  }

  // 根据屏幕宽度更新列数
  void updateCrossAxisCount() {
    try {
      // 使用ResponsiveUtil计算列数
      int baseCount = ResponsiveUtil.calculateCrossAxisCount(
        baseCount: 3,
        minCount: 1,
        maxCount: 5,
      );

      crossAxisCount.value = baseCount;
    } catch (e) {
      // 捕获异常，避免在没有 context 时崩溃
      crossAxisCount.value = 3;
    }
  }

  Future queryBangumiListFeed({type = 'init'}) async {
    if (type == 'init') {
      _currentPage = 1;
    }
    var result = await BangumiHttp.bangumiList(page: _currentPage);
    if (result['status']) {
      if (type == 'init') {
        bangumiList.value = result['data'].list;
      } else {
        bangumiList.addAll(result['data'].list);
      }
      _currentPage += 1;
    } else {}
    isLoadingMore = false;
    return result;
  }

  // 上拉加载
  Future onLoad() async {
    queryBangumiListFeed(type: 'onLoad');
  }

  // 我的订阅
  Future queryBangumiFollow() async {
    userInfo = userInfo ?? userInfoCache.get('userInfoCache');
    if (userInfo == null) {
      return;
    }
    var result = await BangumiHttp.bangumiFollow(mid: userInfo.mid);
    if (result['status']) {
      bangumiFollowList.value = result['data'].list;
    } else {}
    return result;
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
