import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/models/live/follow.dart';
import 'package:piliotto/models/live/item.dart';
import 'package:piliotto/utils/storage.dart';

class LiveController extends GetxController {
  final ScrollController scrollController = ScrollController();
  int count = 12;
  RxInt crossAxisCount = 2.obs;
  RxList<LiveItemModel> liveList = <LiveItemModel>[].obs;
  RxList<LiveFollowingItemModel> liveFollowingList =
      <LiveFollowingItemModel>[].obs;
  bool flag = false;
  OverlayEntry? popupDialog;
  Box setting = GStrorage.setting;

  @override
  void onInit() {
    super.onInit();
    crossAxisCount.value =
        setting.get(SettingBoxKey.customRows, defaultValue: 2);
  }

  Future queryLiveList(type) async {
    SmartDialog.showToast('直播功能暂未开放');
    return {'status': false, 'data': []};
  }

  Future onRefresh() async {
    await queryLiveList('init');
    await fetchLiveFollowing();
  }

  Future onLoad() async {
    await queryLiveList('onLoad');
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

  Future fetchLiveFollowing() async {
    return {'status': false, 'data': []};
  }
}
