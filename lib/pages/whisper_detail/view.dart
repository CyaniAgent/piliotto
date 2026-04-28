import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/ottohub/api/models/message.dart';
import 'package:piliotto/utils/storage.dart';
import 'controller.dart';

class WhisperDetailPage extends StatefulWidget {
  const WhisperDetailPage({super.key});

  @override
  State<WhisperDetailPage> createState() => _WhisperDetailPageState();
}

class _WhisperDetailPageState extends State<WhisperDetailPage> {
  late WhisperDetailController controller;
  late final int friendUid;
  late final String friendName;
  late final String? friendAvatar;
  late final String heroTag;

  @override
  void initState() {
    super.initState();
    final parameters = Get.parameters;
    friendUid = int.tryParse(parameters['mid'] ?? '0') ?? 0;
    friendName = parameters['name'] ?? '';
    friendAvatar = parameters['face'];
    heroTag = parameters['heroTag'] ?? '';

    controller = Get.put(
      WhisperDetailController(
        friendUid: friendUid,
        friendName: friendName,
        friendAvatar: friendAvatar,
        heroTag: heroTag,
      ),
      tag: heroTag,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userInfo = GStrorage.userInfo.get('userInfoCache');
    final myUid = userInfo?.mid ?? 0;
    final myAvatar = userInfo?.face;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (friendAvatar != null && friendAvatar!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(friendAvatar!),
                ),
              ),
            Text(friendName),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Obx(() {
            if (controller.snackbarMessage.value.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(controller.snackbarMessage.value)),
                );
                controller.snackbarMessage.value = '';
              });
            }
            return const SizedBox.shrink();
          }),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.value.isNotEmpty &&
                  controller.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(controller.errorMessage.value),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => controller.loadMessages(refresh: true),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.messages.isEmpty) {
                return const Center(child: Text('暂无消息'));
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadMessages(refresh: true),
                child: ListView.builder(
                  controller: controller.scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    final isMe = message.sender == myUid;
                    return _buildMessageItem(message, isMe, theme, myAvatar);
                  },
                ),
              );
            }),
          ),
          _buildInputArea(theme),
        ],
      ),
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
              backgroundImage: friendAvatar != null && friendAvatar!.isNotEmpty
                  ? NetworkImage(friendAvatar!)
                  : null,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: friendAvatar == null || friendAvatar!.isEmpty
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
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
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
              controller: controller.messageController,
              focusNode: controller.focusNode,
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
              onSubmitted: (_) => controller.sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => IconButton.filled(
                onPressed:
                    controller.isSending.value ? null : controller.sendMessage,
                icon: controller.isSending.value
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
