import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/services/ottohub_service.dart';
import 'package:piliotto/api/models/video.dart';
import 'package:piliotto/utils/responsive_util.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/services/loggeer.dart';

class RcmdController extends GetxController {
  final ScrollController scrollController = ScrollController();
  RxBool isLoadingMore = true.obs;
  OverlayEntry? popupDialog;
  Box setting = GStrorage.setting;
  RxInt crossAxisCount = 2.obs;
  late bool enableSaveLastData;
  late RxList<Video> videoList;

  @override
  void onInit() {
    super.onInit();
    enableSaveLastData =
        setting.get(SettingBoxKey.enableSaveLastData, defaultValue: false);
    videoList = <Video>[].obs;
    // 初始计算列数
    updateCrossAxisCount();
  }

  // 根据屏幕宽度更新列数
  void updateCrossAxisCount() {
    try {
      int customRows = setting.get(SettingBoxKey.customRows, defaultValue: 2);

      // 使用ResponsiveUtil计算列数
      int baseCount = ResponsiveUtil.calculateCrossAxisCount(
        baseCount: customRows,
        minCount: 1,
        maxCount: 4,
      );

      crossAxisCount.value = baseCount;
    } catch (e) {
      // 捕获异常，避免在没有 context 时崩溃
      crossAxisCount.value = 2;
    }
  }

  // 获取推荐
  Future queryRcmdFeed(type) async {
    if (isLoadingMore.value == false) {
      return;
    }
    try {
      final response = await OttohubService.getRandomVideos(num: 20);
      final List<Video> videos = response.videoList;

      if (type == 'init') {
        videoList.clear();
        videoList.addAll(videos);
      } else if (type == 'onRefresh') {
        if (enableSaveLastData) {
          videoList.insertAll(0, videos);
        } else {
          videoList.clear();
          videoList.addAll(videos);
        }
      } else if (type == 'onLoad') {
        videoList.addAll(videos);
      }
      isLoadingMore.value = false;
      return {'status': true, 'data': videos};
    } catch (error) {
      isLoadingMore.value = false;
      getLogger().log(Level.error, 'Error fetching videos: $error');
      return {'status': false, 'data': [], 'msg': error.toString()};
    }
  }

  // 下拉刷新
  Future onRefresh() async {
    isLoadingMore.value = true;
    await queryRcmdFeed('onRefresh');
  }

  Future onLoad() async {
    if (!isLoadingMore.value) {
      isLoadingMore.value = true;
      await queryRcmdFeed('onLoad');
    }
  }

  // 返回顶部
  void animateToTop() async {
    if (scrollController.offset >=
        MediaQuery.of(Get.context!).size.height * 5) {
      scrollController.jumpTo(0);
    } else {
      await scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  void blockUserCb(int uid) {
    videoList.removeWhere((e) => e.uid == uid);
    videoList.refresh();
    SmartDialog.showToast('已移除相关视频');
  }
}
