import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:piliotto/ottohub/api/models/message.dart';
import 'package:piliotto/pages/whisper_detail/provider.dart';
import 'package:piliotto/utils/route_arguments.dart';
import 'package:piliotto/utils/storage.dart';

class WhisperDetailPage extends ConsumerStatefulWidget {
  const WhisperDetailPage({super.key});

  @override
  ConsumerState<WhisperDetailPage> createState() => _WhisperDetailPageState();
}

class _WhisperDetailPageState extends ConsumerState<WhisperDetailPage> {
  late final int friendUid;
  late final String friendName;
  late final String? friendAvatar;
  late final String heroTag;

  @override
  void initState() {
    super.initState();
    final parameters = routeArguments.queryParameters;
    friendUid = int.tryParse(parameters['mid'] ?? '0') ?? 0;
    friendName = parameters['name'] ?? '';
    friendAvatar = parameters['face'];
    heroTag = parameters['heroTag'] ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(whisperDetailProvider.notifier).loadMessages(friendUid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(whisperDetailProvider);
    final notifier = ref.read(whisperDetailProvider.notifier);

    dynamic userInfo;
    try {
      userInfo = GStrorage.userInfo.get('userInfoCache');
    } catch (_) {
      userInfo = null;
    }
    final myUid = userInfo?.mid ?? 0;
    final myAvatar = userInfo?.face;

    if (state.snackbarMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.snackbarMessage)),
        );
        notifier.clearSnackbarMessage();
      });
    }

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
          Expanded(
            child: _buildMessageList(state, notifier, theme, myUid, myAvatar),
          ),
          _buildInputArea(theme, notifier),
        ],
      ),
    );
  }

  Widget _buildMessageList(
    WhisperDetailState state,
    WhisperDetailNotifier notifier,
    ThemeData theme,
    int myUid,
    String? myAvatar,
  ) {
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
              onPressed: () => notifier.loadMessages(friendUid, refresh: true),
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
      onRefresh: () => notifier.loadMessages(friendUid, refresh: true),
      child: ListView.builder(
        controller: notifier.scrollController,
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

  Widget _buildInputArea(ThemeData theme, WhisperDetailNotifier notifier) {
    final state = ref.watch(whisperDetailProvider);
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
              controller: notifier.messageController,
              focusNode: notifier.focusNode,
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
              onSubmitted: (_) => notifier.sendMessage(friendUid),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: state.isSending ? null : () => notifier.sendMessage(friendUid),
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
