import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:piliotto/ottohub/api/models/message.dart';
import 'package:piliotto/providers/repository_provider.dart';

part 'provider.g.dart';

class WhisperDetailState {
  final List<Message> messages;
  final bool isLoading;
  final bool isSending;
  final String errorMessage;
  final String snackbarMessage;
  final bool hasMore;

  const WhisperDetailState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.errorMessage = '',
    this.snackbarMessage = '',
    this.hasMore = true,
  });

  WhisperDetailState copyWith({
    List<Message>? messages,
    bool? isLoading,
    bool? isSending,
    String? errorMessage,
    String? snackbarMessage,
    bool? hasMore,
  }) {
    return WhisperDetailState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage ?? this.errorMessage,
      snackbarMessage: snackbarMessage ?? this.snackbarMessage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

@riverpod
class WhisperDetailNotifier extends _$WhisperDetailNotifier {
  final ScrollController scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  int _offset = 0;
  final int _pageSize = 20;

  @override
  WhisperDetailState build() {
    ref.onDispose(() {
      scrollController.dispose();
      messageController.dispose();
      focusNode.dispose();
    });
    return const WhisperDetailState();
  }

  Future<void> loadMessages(int friendUid, {bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      _offset = 0;
      state = state.copyWith(messages: [], hasMore: true);
    }

    if (!state.hasMore) return;

    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      final List<Message> newMessages = await ref
          .read(messageRepositoryProvider)
          .getFriendMessage(
            friendUid: friendUid,
            offset: _offset,
            num: _pageSize,
          );

      final hasMore = newMessages.length >= _pageSize;
      final messages = refresh ? newMessages : [...state.messages, ...newMessages];
      _offset = messages.length;

      state = state.copyWith(
        messages: messages,
        isLoading: false,
        hasMore: hasMore,
      );

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
      state = state.copyWith(
        isLoading: false,
        errorMessage: '加载失败: $e',
      );
    }
  }

  Future<void> sendMessage(int friendUid) async {
    final text = messageController.text.trim();
    if (text.isEmpty || state.isSending) return;

    state = state.copyWith(isSending: true);

    try {
      final success = await ref.read(messageRepositoryProvider).sendMessage(
            receiver: friendUid,
            message: text,
          );

      if (success) {
        messageController.clear();
        await loadMessages(friendUid, refresh: true);
      } else {
        state = state.copyWith(
          isSending: false,
          snackbarMessage: '消息发送失败，请重试',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        snackbarMessage: '消息发送失败: $e',
      );
    }
  }

  void clearSnackbarMessage() {
    state = state.copyWith(snackbarMessage: '');
  }
}
