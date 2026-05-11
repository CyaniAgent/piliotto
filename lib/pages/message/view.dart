import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/ottohub/api/models/message.dart';
import 'package:piliotto/repositories/i_message_repository.dart';
import 'package:piliotto/utils/storage.dart';
import 'controller.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late MessageController controller;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MessageController());

    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final screenWidth = view.physicalSize.width / view.devicePixelRatio;
    final isWideScreen = screenWidth >= 800;

    if (!isWideScreen) {
      final parameters = Get.parameters;
      final mid = parameters['mid'];
      final name = parameters['name'];
      final face = parameters['face'];

      if (mid != null && name != null && !_hasNavigated) {
        _hasNavigated = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.toNamed('/whisperDetail', parameters: {
            'mid': mid,
            'name': name,
            'face': face ?? '',
            'heroTag': mid,
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        centerTitle: true,
        actions: [
          if (isWideScreen)
            IconButton(
              onPressed: () => _showUserSwitcher(context),
              icon: const Icon(Icons.swap_horiz),
              tooltip: '切换用户',
            ),
        ],
      ),
      body: isWideScreen ? _buildWideLayout(theme) : _buildNarrowLayout(theme),
    );
  }

  void _showUserSwitcher(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('切换用户'),
        content: Obx(() {
          if (controller.userList.isEmpty) {
            return const Text('暂无其他用户');
          }
          return SizedBox(
            width: 300,
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.userList.length,
              itemBuilder: (context, index) {
                final user = controller.userList[index];
                final isSelected =
                    controller.currentUser.value?.uid == user.uid;
                return ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                        ? Icon(Icons.person,
                            color: theme.colorScheme.onPrimaryContainer)
                        : null,
                  ),
                  title: Text(user.username),
                  subtitle: Text('UID: ${user.uid}'),
                  trailing: isSelected
                      ? Icon(Icons.check_circle,
                          color: theme.colorScheme.primary)
                      : null,
                  selected: isSelected,
                  onTap: () {
                    controller.switchUser(user);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWideLayout(ThemeData theme) {
    return Row(
      children: [
        SizedBox(
          width: 320,
          child: _buildFriendListPanel(theme),
        ),
        Container(
          width: 1,
          color: theme.colorScheme.outlineVariant.withAlpha(50),
        ),
        Expanded(
          child: Obx(() {
            final friend = controller.selectedFriend.value;
            if (friend == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: theme.colorScheme.outlineVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '选择一个对话开始聊天',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            return _ChatDetailPanel(
              key: ValueKey(friend.uid),
              friendUid: friend.uid,
              friendName: friend.username,
              friendAvatar: friend.avatarUrl,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(ThemeData theme) {
    return _buildFriendListPanel(theme);
  }

  Widget _buildFriendListPanel(ThemeData theme) {
    return Obx(() {
      if (controller.isLoading.value && controller.friendList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.isNotEmpty &&
          controller.friendList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(controller.errorMessage.value),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.loadFriendList(refresh: true),
                child: const Text('重试'),
              ),
            ],
          ),
        );
      }

      if (controller.friendList.isEmpty) {
        return const Center(child: Text('暂无消息'));
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadFriendList(refresh: true),
        child: ListView.builder(
          itemCount: controller.friendList.length,
          itemBuilder: (context, index) {
            final friend = controller.friendList[index];
            return _buildFriendItem(friend, theme);
          },
        ),
      );
    });
  }

  Widget _buildFriendItem(Friend friend, ThemeData theme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 800;

    return Obx(() {
      final isSelected = controller.selectedFriend.value?.uid == friend.uid;
      return Container(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withAlpha(100)
            : null,
        child: ListTile(
          onTap: () {
            if (isWideScreen) {
              controller.selectFriend(friend);
            } else {
              Get.toNamed('/whisperDetail', parameters: {
                'mid': friend.uid.toString(),
                'name': friend.username,
                'face': friend.avatarUrl ?? '',
                'heroTag': friend.uid.toString(),
              });
            }
          },
          leading: CircleAvatar(
            radius: 24,
            backgroundImage:
                friend.avatarUrl != null && friend.avatarUrl!.isNotEmpty
                    ? NetworkImage(friend.avatarUrl!)
                    : null,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: friend.avatarUrl == null || friend.avatarUrl!.isEmpty
                ? Icon(Icons.person,
                    size: 24, color: theme.colorScheme.onPrimaryContainer)
                : null,
          ),
          title: Text(
            friend.username,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: friend.lastMessage != null
              ? Text(
                  friend.lastMessage!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              : null,
          trailing: friend.lastTime != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(friend.lastTime!),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (friend.newMessageNum != null &&
                        friend.newMessageNum! > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          friend.newMessageNum! > 99
                              ? '99+'
                              : friend.newMessageNum.toString(),
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onError,
                          ),
                        ),
                      ),
                  ],
                )
              : null,
        ),
      );
    });
  }

  String _formatTime(String time) {
    try {
      final dateTime = DateTime.parse(time);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return '昨天';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}天前';
      } else {
        return '${dateTime.month}/${dateTime.day}';
      }
    } catch (e) {
      return time;
    }
  }
}

class _ChatDetailPanel extends StatefulWidget {
  final int friendUid;
  final String friendName;
  final String? friendAvatar;

  const _ChatDetailPanel({
    super.key,
    required this.friendUid,
    required this.friendName,
    this.friendAvatar,
  });

  @override
  State<_ChatDetailPanel> createState() => _ChatDetailPanelState();
}

class _ChatDetailPanelState extends State<_ChatDetailPanel> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  RxList<Message> messages = <Message>[].obs;
  RxBool isLoading = false.obs;
  RxBool isSending = false.obs;
  RxString errorMessage = ''.obs;

  int _offset = 0;
  final int _pageSize = 20;
  bool _hasMore = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    loadMessages();
    _startPolling();
  }

  @override
  void dispose() {
    _stopPolling();
    scrollController.dispose();
    messageController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _pollNewMessages();
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _pollNewMessages() async {
    if (isLoading.value || isSending.value) return;

    try {
      final newMessages = await Get.find<IMessageRepository>().getFriendMessage(
        friendUid: widget.friendUid,
        offset: 0,
        num: _pageSize,
      );

      if (newMessages.isNotEmpty && messages.isNotEmpty) {
        final latestMsgId = messages.first.msgId;
        final hasNew = newMessages.any((msg) => msg.msgId > latestMsgId);

        if (hasNew) {
          messages.assignAll(newMessages);
          _offset = newMessages.length;

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
      }
    } catch (e) {
      // 静默处理轮询错误
    }
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
      final List<Message> newMessages =
          await Get.find<IMessageRepository>().getFriendMessage(
        friendUid: widget.friendUid,
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
      final success = await Get.find<IMessageRepository>().sendMessage(
        receiver: widget.friendUid,
        message: text,
      );

      if (success) {
        messageController.clear();
        await loadMessages(refresh: true);
      }
    } catch (e) {
      // Handle error silently
    } finally {
      isSending.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userInfo = GStrorage.userInfo.get('userInfoCache');
    final myUid = userInfo?.mid ?? 0;
    final myAvatar = userInfo?.face;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withAlpha(50),
              ),
            ),
          ),
          child: Row(
            children: [
              if (widget.friendAvatar != null &&
                  widget.friendAvatar!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(widget.friendAvatar!),
                  ),
                ),
              Text(
                widget.friendName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (isLoading.value && messages.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (errorMessage.value.isNotEmpty && messages.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(errorMessage.value),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => loadMessages(refresh: true),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              );
            }

            if (messages.isEmpty) {
              return const Center(child: Text('暂无消息'));
            }

            return RefreshIndicator(
              onRefresh: () => loadMessages(refresh: true),
              child: ListView.builder(
                controller: scrollController,
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isMe = message.sender == myUid;
                  return _buildMessageItem(message, isMe, theme, myAvatar);
                },
              ),
            );
          }),
        ),
        _buildInputArea(theme),
      ],
    );
  }

  Widget _buildMessageItem(
      Message message, bool isMe, ThemeData theme, String? myAvatar) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage:
                  widget.friendAvatar != null && widget.friendAvatar!.isNotEmpty
                      ? NetworkImage(widget.friendAvatar!)
                      : null,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: widget.friendAvatar == null || widget.friendAvatar!.isEmpty
                  ? Icon(Icons.person,
                      size: 16, color: theme.colorScheme.onPrimaryContainer)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.5,
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: isMe
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: isMe
                      ? const EdgeInsets.only(right: 8)
                      : const EdgeInsets.only(left: 40),
                  child: Text(
                    message.time,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundImage: myAvatar != null && myAvatar.isNotEmpty
                  ? NetworkImage(myAvatar)
                  : null,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: myAvatar == null || myAvatar.isEmpty
                  ? Icon(Icons.person,
                      size: 16, color: theme.colorScheme.onPrimaryContainer)
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withAlpha(80),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: '输入消息...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => IconButton.filled(
                onPressed: isSending.value ? null : sendMessage,
                icon: isSending.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
              )),
        ],
      ),
    );
  }
}
