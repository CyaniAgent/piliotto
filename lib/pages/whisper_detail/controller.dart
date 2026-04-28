import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/ottohub/api/models/message.dart';
import 'package:piliotto/repositories/i_message_repository.dart';

class WhisperDetailController extends GetxController {
  final IMessageRepository _messageRepo = Get.find<IMessageRepository>();
  final int friendUid;
  final String friendName;
  final String? friendAvatar;
  final String heroTag;

  WhisperDetailController({
    required this.friendUid,
    required this.friendName,
    this.friendAvatar,
    required this.heroTag,
  });

  final ScrollController scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  RxList<Message> messages = <Message>[].obs;
  RxBool isLoading = false.obs;
  RxBool isSending = false.obs;
  RxString errorMessage = ''.obs;
  RxString snackbarMessage = ''.obs;

  int _offset = 0;
  final int _pageSize = 20;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    loadMessages();
  }

  @override
  void onClose() {
    scrollController.dispose();
    messageController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  Future loadMessages({bool refresh = false}) async {
    if (isLoading.value) return;

    if (refresh) {
      _offset = 0;
      _hasMore = true;
      messages.clear();
    }

    if (!_hasMore) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final List<Message> newMessages = await _messageRepo.getFriendMessage(
        friendUid: friendUid,
        offset: _offset,
        num: _pageSize,
      );

      if (newMessages.length < _pageSize) {
        _hasMore = false;
      }

      if (refresh) {
        messages.assignAll(newMessages);
      } else {
        messages.addAll(newMessages);
      }

      _offset += newMessages.length;

      if (messages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      errorMessage.value = '加载失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || isSending.value) return;

    isSending.value = true;

    try {
      final success = await _messageRepo.sendMessage(
        receiver: friendUid,
        message: text,
      );

      if (success) {
        messageController.clear();
        await loadMessages(refresh: true);
      } else {
        snackbarMessage.value = '消息发送失败，请重试';
      }
    } catch (e) {
      snackbarMessage.value = '消息发送失败: $e';
    } finally {
      isSending.value = false;
    }
  }
}
