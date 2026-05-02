import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:piliotto/ottohub/api/models/message.dart';
import 'package:piliotto/pages/message/provider.dart';
import 'package:piliotto/utils/route_arguments.dart';
import 'package:piliotto/utils/storage.dart';

class MessagePage extends ConsumerStatefulWidget {
  const MessagePage({super.key});

  @override
  ConsumerState<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends ConsumerState<MessagePage> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final screenWidth = view.physicalSize.width / view.devicePixelRatio;
    final isWideScreen = screenWidth >= 800;

    if (!isWideScreen) {
      final parameters = routeArguments.queryParameters;
      final mid = parameters['mid'];
      final name = parameters['name'];
      final face = parameters['face'];

      if (mid != null && name != null && !_hasNavigated) {
        _hasNavigated = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.push('/whisperDetail', extra: {
            'friendUid': int.tryParse(mid),
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
      ),
      body: isWideScreen ? _buildWideLayout(theme) : _buildNarrowLayout(theme),
    );
  }

  Widget _buildWideLayout(ThemeData theme) {
    final state = ref.watch(messageProvider);
    final notifier = ref.read(messageProvider.notifier);

    return Row(
      children: [
        SizedBox(
          width: 320,
          child: _buildFriendListPanel(theme, state, notifier),
        ),
        Container(
          width: 1,
          color: theme.colorScheme.outlineVariant.withAlpha(50),
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              final friend = state.selectedFriend;
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
                friendUid: friend.uid,
                friendName: friend.username,
                friendAvatar: friend.avatarUrl,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(ThemeData theme) {
    final state = ref.watch(messageProvider);
    final notifier = ref.read(messageProvider.notifier);
    return _buildFriendListPanel(theme, state, notifier);
  }

  Widget _buildFriendListPanel(ThemeData theme, MessageState state, MessageNotifier notifier) {
    if (state.isLoading && state.friendList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage.isNotEmpty && state.friendList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => notifier.loadFriendList(refresh: true),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (state.friendList.isEmpty) {
      return const Center(child: Text('暂无消息'));
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadFriendList(refresh: true),
      child: ListView.builder(
        itemCount: state.friendList.length,
        itemBuilder: (context, index) {
          final friend = state.friendList[index];
          return _buildFriendItem(friend, theme, state, notifier);
        },
      ),
    );
  }

  Widget _buildFriendItem(Friend friend, ThemeData theme, MessageState state, MessageNotifier notifier) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 800;
    final isSelected = state.selectedFriend?.uid == friend.uid;

    return Container(
      color: isSelected
          ? theme.colorScheme.primaryContainer.withAlpha(100)
          : null,
      child: ListTile(
        onTap: () {
          if (isWideScreen) {
            notifier.selectFriend(friend);
          } else {
            context.push('/whisperDetail', extra: {
              'friendUid': friend.uid,
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

class _ChatDetailPanel extends ConsumerStatefulWidget {
  final int friendUid;
  final String friendName;
  final String? friendAvatar;

  const _ChatDetailPanel({
    required this.friendUid,
    required this.friendName,
    this.friendAvatar,
  });

  @override
  ConsumerState<_ChatDetailPanel> createState() => _ChatDetailPanelState();
}

class _ChatDetailPanelState extends ConsumerState<_ChatDetailPanel> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    scrollController.dispose();
    messageController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(chatDetailProvider(widget.friendUid));
    final notifier = ref.read(chatDetailProvider(widget.friendUid).notifier);

    dynamic userInfo;
    try {
      userInfo = GStrorage.userInfo.get('userInfoCache');
    } catch (_) {
      userInfo = null;
    }
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
          child: Builder(
            builder: (context) {
              if (state.isLoading && state.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.errorMessage.isNotEmpty && state.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.errorMessage),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => notifier.loadMessages(refresh: true),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                );
              }

              if (state.messages.isEmpty) {
                return const Center(child: Text('暂无消息'));
              }

              return RefreshIndicator(
                onRefresh: () => notifier.loadMessages(refresh: true),
                child: ListView.builder(
                  controller: scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    final isMe = message.sender == myUid;
                    return _buildMessageItem(message, isMe, theme, myAvatar);
                  },
                ),
              );
            },
          ),
        ),
        _buildInputArea(theme, state, notifier),
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

  Widget _buildInputArea(ThemeData theme, ChatDetailState state, ChatDetailNotifier notifier) {
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
              onSubmitted: (_) async {
                await notifier.sendMessage(messageController.text);
                messageController.clear();
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: state.isSending
                ? null
                : () async {
                    await notifier.sendMessage(messageController.text);
                    messageController.clear();
                  },
            icon: state.isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}
