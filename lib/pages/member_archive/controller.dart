import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/ottohub/models/member/archive.dart';

class MemberArchiveController extends GetxController {
  final IVideoRepository _videoRepo = Get.find<IVideoRepository>();
  final ScrollController scrollController = ScrollController();
  late int mid;
  int offset = 0;
  int count = 0;
  RxMap<String, String> currentOrder = <String, String>{}.obs;
  RxList<Map<String, String>> orderList = [
    {'type': 'pubdate', 'label': '最新发布'},
    {'type': 'click', 'label': '最多播放'},
    {'type': 'stow', 'label': '最多收藏'},
  ].obs;
  RxList<VListItemModel> archivesList = <VListItemModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    mid = int.parse(Get.parameters['mid']!);
    currentOrder.value = orderList.first;
  }

  Future<void> getMemberArchive(String type) async {
    if (isLoading.value) {
      return;
    }
    isLoading.value = true;
    if (type == 'init') {
      offset = 0;
      archivesList.clear();
    }
    try {
      final items = await _videoRepo.getUserVideoList(uid: mid, offset: offset, num: 20);
      if (type == 'init') {
        archivesList.value = items;
      } else {
        archivesList.addAll(items);
      }
      offset += items.length;
      count = items.length;
    } catch (e) {
      SmartDialog.showToast('请求失败: $e');
    }
    isLoading.value = false;
  }

  Future<void> toggleSort() async {
    List<String> typeList = orderList.map((e) => e['type']!).toList();
    int index = typeList.indexOf(currentOrder['type']!);
    if (index == orderList.length - 1) {
      currentOrder.value = orderList.first;
    } else {
      currentOrder.value = orderList[index + 1];
    }
    getMemberArchive('init');
  }

  Future onLoad() async {
    getMemberArchive('onLoad');
  }
}
