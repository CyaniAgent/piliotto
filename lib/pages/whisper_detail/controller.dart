import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/models/msg/session.dart';
import '../../utils/feed_back.dart';
import '../../utils/storage.dart';

class WhisperDetailController extends GetxController {
  int? talkerId;
  late String name;
  late String face;
  late String mid;
  late String heroTag;
  RxList<MessageItem> messageList = <MessageItem>[].obs;
  RxList<dynamic> eInfos = [].obs;
  final TextEditingController replyContentController = TextEditingController();
  Box userInfoCache = GStrorage.userInfo;
  List emoteList = [];
  List<String> picList = [];

  @override
  void onInit() {
    super.onInit();
    if (Get.parameters.containsKey('talkerId')) {
      talkerId = int.parse(Get.parameters['talkerId']!);
    } else {
      talkerId = int.parse(Get.parameters['mid']!);
    }
    name = Get.parameters['name']!;
    face = Get.parameters['face']!;
    mid = Get.parameters['mid']!;
    heroTag = Get.parameters['heroTag']!;
  }

  // TODO: 迁移到 Ottohub 消息 API（如果有）
  Future querySessionMsg() async {
    return {'status': false, 'msg': 'TODO: 迁移到 Ottohub 消息 API'};
  }

  Future ackSessionMsg() async {}

  Future sendMsg() async {
    feedBack();
    String message = replyContentController.text;
    final userInfo = userInfoCache.get('userInfoCache');
    if (userInfo == null) {
      SmartDialog.showToast('请先登录');
      return;
    }
    if (message == '') {
      SmartDialog.showToast('请输入内容');
      return;
    }
    SmartDialog.showToast('TODO: 迁移到 Ottohub 消息 API');
  }

  void removeSession(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          clipBehavior: Clip.hardEdge,
          title: const Text('提示'),
          content: const Text('确认清空会话内容并移除会话？'),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: Text(
                '取消',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                SmartDialog.showToast('TODO: 迁移到 Ottohub 消息 API');
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }
}
