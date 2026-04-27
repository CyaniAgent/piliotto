import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/api/models/video.dart';
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/models/user/info.dart';
import 'package:piliotto/utils/responsive_util.dart';
import 'package:piliotto/utils/storage.dart';

class HistoryController extends GetxController {
  final IVideoRepository _videoRepo = Get.find<IVideoRepository>();
  final ScrollController scrollController = ScrollController();
  RxList<Video> historyList = <Video>[].obs;
  RxBool isLoadingMore = false.obs;
  RxBool pauseStatus = false.obs;
  Box localCache = GStrorage.localCache;
  RxBool isLoading = false.obs;
  RxBool enableMultiple = false.obs;
  RxInt checkedCount = 0.obs;
  RxInt crossAxisCount = 1.obs;
  Box userInfoCache = GStrorage.userInfo;
  UserInfoData? userInfo;

  @override
  void onInit() {
    super.onInit();
    userInfo = userInfoCache.get('userInfoCache');
    updateCrossAxisCount();
    queryHistoryList();
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

  Future<Map<String, dynamic>> queryHistoryList({String type = 'init'}) async {
    if (userInfo == null) {
      return {'status': false, 'msg': '账号未登录', 'code': -101};
    }

    isLoadingMore.value = true;

    try {
      final response = await _videoRepo.getHistoryVideos();
      historyList.value = response.videoList;
    } catch (e) {
      SmartDialog.showToast('请求失败: $e');
    }

    isLoadingMore.value = false;
    return {'status': true};
  }

  Future onLoad() async {
    SmartDialog.showToast('没有更多了');
  }

  Future onRefresh() async {
    queryHistoryList(type: 'onRefresh');
  }

  Future onPauseHistory() async {
    SmartDialog.showToast('Ottohub API 不支持暂停历史记录');
  }

  Future historyStatus() async {
    pauseStatus.value = false;
  }

  Future onClearHistory() async {
    SmartDialog.showToast('Ottohub API 不支持清空历史记录');
  }

  Future<void> delHistory(int kid, String business) async {
    SmartDialog.showToast('Ottohub API 不支持删除历史记录');
  }

  Future onDelHistory() async {
    SmartDialog.showToast('Ottohub API 不支持删除历史记录');
  }

  Future onDelCheckedHistory() async {
    SmartDialog.showToast('Ottohub API 不支持删除历史记录');
  }
}
