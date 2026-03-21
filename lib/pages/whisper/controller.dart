import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/api/services/message_service.dart';
import 'package:piliotto/api/models/message.dart';

class WhisperController extends GetxController {
  RxList<Friend> friendList = <Friend>[].obs;
  RxInt unreadCount = 0.obs;
  bool isLoading = false;

  RxList noticesList = [
    {
      'icon': Icons.message_outlined,
      'title': '回复我的',
      'path': '/messageReply',
      'count': 0,
    },
    {
      'icon': Icons.alternate_email,
      'title': '@我的',
      'path': '/messageAt',
      'count': 0,
    },
    {
      'icon': Icons.thumb_up_outlined,
      'title': '收到的赞',
      'path': '/messageLike',
      'count': 0,
    },
    {
      'icon': Icons.notifications_none_outlined,
      'title': '系统通知',
      'path': '/messageSystem',
      'count': 0,
    }
  ].obs;

  @override
  void onInit() {
    super.onInit();
    queryFriendList();
    getUnreadCount();
  }

  Future queryFriendList({bool refresh = false}) async {
    if (isLoading) return;
    isLoading = true;

    try {
      final friends = await MessageService.getFriendList(
        offset: refresh ? 0 : friendList.length,
        num: 20,
      );
      if (refresh) {
        friendList.value = friends;
      } else {
        friendList.addAll(friends);
      }
    } catch (e) {
      Get.log('获取好友列表失败: $e');
    } finally {
      isLoading = false;
    }
  }

  Future getUnreadCount() async {
    try {
      unreadCount.value = await MessageService.getUnreadMessageNum();
    } catch (e) {
      Get.log('获取未读消息数失败: $e');
    }
  }

  Future onLoad() async {
    await queryFriendList();
  }

  Future onRefresh() async {
    await queryFriendList(refresh: true);
    await getUnreadCount();
  }

  void refreshLastMsg(int uid, String content) {
    final index = friendList.indexWhere((p0) => p0.uid == uid);
    if (index != -1) {
      final friend = friendList[index];
      friendList.removeAt(index);
      friendList.insert(
          0,
          Friend(
            uid: friend.uid,
            username: friend.username,
            intro: friend.intro,
            avatarUrl: friend.avatarUrl,
            lastTime: DateTime.now().toString(),
            lastMessage: content,
            newMessageNum: (friend.newMessageNum ?? 0) + 1,
          ));
      friendList.refresh();
    }
  }

  void removeFriend(int uid) {
    friendList.removeWhere((p0) => p0.uid == uid);
    friendList.refresh();
  }
}
