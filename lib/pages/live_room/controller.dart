import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:piliotto/models/live/message.dart';
import 'package:piliotto/models/live/room_info_h5.dart';
import 'package:piliotto/plugin/pl_player/index.dart';
import 'package:piliotto/utils/storage.dart';

class LiveRoomController extends GetxController {
  String cover = '';
  late int roomId;
  dynamic liveItem;
  late String heroTag;
  double volume = 0.0;
  RxBool volumeOff = false.obs;
  late PlPlayerController plPlayerController;
  Rx<RoomInfoH5Model> roomInfoH5 = RoomInfoH5Model().obs;
  Box userInfoCache = GStrorage.userInfo;
  int userId = 0;
  DanmakuController? danmakuController;
  TextEditingController inputController = TextEditingController();
  RxMap<String, String> joinRoomTip = {'userName': '', 'message': ''}.obs;
  RxBool danmakuSwitch = true.obs;
  RxBool isPortrait = false.obs;
  RxList<LiveMessageModel> messageList = <LiveMessageModel>[].obs;
  RxString currentQnDesc = ''.obs;
  List<Map<String, dynamic>> acceptQnList = [];

  @override
  void onInit() {
    super.onInit();
    plPlayerController = PlPlayerController(videoType: 'live');
    roomId = int.parse(Get.parameters['roomid']!);
    if (Get.arguments != null) {
      liveItem = Get.arguments['liveItem'];
      heroTag = Get.arguments['heroTag'] ?? '';
      if (liveItem != null) {
        cover = (liveItem.pic != null && liveItem.pic != '')
            ? liveItem.pic
            : (liveItem.cover != null && liveItem.cover != '')
                ? liveItem.cover
                : null;
      }
    }
    final userInfo = userInfoCache.get('userInfoCache');
    if (userInfo != null && userInfo.mid != null) {
      userId = userInfo.mid;
    }
    SmartDialog.showToast('直播功能暂未开放');
  }

  void setVolumn(value) {
    if (value == 0) {
      volumeOff.value = false;
    } else {
      volume = value;
      volumeOff.value = true;
    }
  }

  Future queryLiveInfo() async {
    SmartDialog.showToast('直播功能暂未开放');
    return {'status': false};
  }

  Future queryLiveInfoH5() async {
    SmartDialog.showToast('直播功能暂未开放');
    return {'status': false};
  }

  void changeQn(int qn) {
    SmartDialog.showToast('直播功能暂未开放');
  }

  void sendMsg() {
    SmartDialog.showToast('直播功能暂未开放');
  }

  @override
  void onClose() {
    plPlayerController.dispose();
    super.onClose();
  }
}
