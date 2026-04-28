import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/ottohub/api/models/message.dart';
import 'package:piliotto/repositories/i_message_repository.dart';

class MessageListController extends GetxController {
  final IMessageRepository _messageRepo = Get.find<IMessageRepository>();
  final ScrollController scrollController = ScrollController();

  RxList<Friend> friendList = <Friend>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  int _offset = 0;
  final int _pageSize = 20;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    loadFriendList();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future loadFriendList({bool refresh = false}) async {
    if (isLoading.value) return;

    if (refresh) {
      _offset = 0;
      _hasMore = true;
      friendList.clear();
    }

    if (!_hasMore) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final List<Friend> newFriends = await _messageRepo.getFriendList(
        offset: _offset,
        num: _pageSize,
      );

      if (newFriends.length < _pageSize) {
        _hasMore = false;
      }

      friendList.addAll(newFriends);
      _offset += newFriends.length;
    } catch (e) {
      errorMessage.value = '加载失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future onRefresh() async {
    await loadFriendList(refresh: true);
  }
}
