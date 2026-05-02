import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:piliotto/ottohub/api/models/message.dart';
import 'package:piliotto/providers/repository_provider.dart';

part 'provider.g.dart';

class MessageListState {
  final List<Friend> friendList;
  final bool isLoading;
  final String errorMessage;
  final bool hasMore;

  const MessageListState({
    this.friendList = const [],
    this.isLoading = false,
    this.errorMessage = '',
    this.hasMore = true,
  });

  MessageListState copyWith({
    List<Friend>? friendList,
    bool? isLoading,
    String? errorMessage,
    bool? hasMore,
  }) {
    return MessageListState(
      friendList: friendList ?? this.friendList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

@riverpod
class MessageListNotifier extends _$MessageListNotifier {
  final ScrollController scrollController = ScrollController();

  int _offset = 0;
  final int _pageSize = 20;

  @override
  MessageListState build() {
    ref.onDispose(() {
      scrollController.dispose();
    });
    return const MessageListState();
  }

  Future<void> loadFriendList({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      _offset = 0;
      state = state.copyWith(friendList: [], hasMore: true);
    }

    if (!state.hasMore) return;

    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      final List<Friend> newFriends = await ref
          .read(messageRepositoryProvider)
          .getFriendList(
            offset: _offset,
            num: _pageSize,
          );

      final hasMore = newFriends.length >= _pageSize;
      final friendList = [...state.friendList, ...newFriends];
      _offset = friendList.length;

      state = state.copyWith(
        friendList: friendList,
        isLoading: false,
        hasMore: hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '加载失败: $e',
      );
    }
  }

  Future<void> onRefresh() async {
    await loadFriendList(refresh: true);
  }
}
