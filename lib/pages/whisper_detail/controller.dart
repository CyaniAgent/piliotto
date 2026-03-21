import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/api/models/message.dart';
import 'package:piliotto/api/services/message_service.dart';
import '../../utils/feed_back.dart';
import '../../utils/storage.dart';

class WhisperDetailController extends GetxController {
  int? friendUid;
  late String name;
  late String face;
  late String mid;
  late String heroTag;
  RxList<Message> messageList = <Message>[].obs;
  final TextEditingController replyContentController = TextEditingController();
  Box userInfoCache = GStrorage.userInfo;
  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    if (Get.parameters.containsKey('friendUid')) {
      friendUid = int.parse(Get.parameters['friendUid']!);
    } else {
      friendUid = int.parse(Get.parameters['mid']!);
    }
    name = Get.parameters['name']!;
    face = Get.parameters['face']!;
    mid = Get.parameters['mid']!;
    heroTag = Get.parameters['heroTag']!;
    queryMessages();
  }

  Future queryMessages({bool refresh = false}) async {
    if (isLoading) return;
    isLoading = true;

    try {
      final messages = await MessageService.getFriendMessage(
        friendUid: friendUid!,
        offset: refresh ? 0 : messageList.length,
        num: 20,
      );
      if (refresh) {
        messageList.value = messages;
      } else {
        messageList.addAll(messages);
      }
    } catch (e) {
      Get.log('获取消息失败: $e');
    } finally {
      isLoading = false;
    }
  }

  Future sendMessage() async {
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

    try {
      final success = await MessageService.sendMessage(
        receiver: friendUid!,
        message: message,
      );
      if (success) {
        replyContentController.clear();
        await queryMessages(refresh: true);
        SmartDialog.showToast('发送成功');
      } else {
        SmartDialog.showToast('发送失败');
      }
    } catch (e) {
      SmartDialog.showToast('发送失败: $e');
    }
  }

  Future deleteMessage(int msgId) async {
    try {
      final success = await MessageService.deleteMessage(msgId: msgId);
      if (success) {
        messageList.removeWhere((m) => m.msgId == msgId);
        messageList.refresh();
        SmartDialog.showToast('删除成功');
      } else {
        SmartDialog.showToast('删除失败');
      }
    } catch (e) {
      SmartDialog.showToast('删除失败: $e');
    }
  }

  void removeSession(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          clipBehavior: Clip.hardEdge,
          title: const Text('提示'),
          content: const Text('确认清空会话内容？'),
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
                Get.back();
                messageList.clear();
                messageList.refresh();
                SmartDialog.showToast('已清空');
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }
}
