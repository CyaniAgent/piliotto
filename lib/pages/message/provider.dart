import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:piliotto/ottohub/api/models/message.dart';
import 'package:piliotto/providers/repository_provider.dart';
import 'package:piliotto/utils/route_arguments.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

class MessageState {
  final List<Friend> friendList;
  final bool isLoading;
  final String errorMessage;
  final Friend? selectedFriend;
  final bool hasMore;

  const MessageState({
    this.friendList = const [],
    this.isLoading = false,
    this.errorMessage = '',
    this.selectedFriend,
    this.hasMore = true,
  });

  MessageState copyWith({
    List<Friend>? friendList,
    bool? isLoading,
    String? errorMessage,
    Friend? selectedFriend,
    bool? hasMore,
    bool clearSelectedFriend = false,
  }) {
    return MessageState(
      friendList: friendList ?? this.friendList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedFriend: clearSelectedFriend ? null : (selectedFriend ?? this.selectedFriend),
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

@riverpod
class MessageNotifier extends _$MessageNotifier {
  int _offset = 0;
  final int _pageSize = 20;

  @override
  MessageState build() {
    _checkInitialFriend();
    Future.microtask(() => loadFriendList());
    return const MessageState();
  }

  void _checkInitialFriend() {
    final parameters = routeArguments.queryParameters;
    final mid = parameters['mid'];
    final name = parameters['name'];
    final face = parameters['face'];

    if (mid != null && name != null) {
      state = state.copyWith(
        selectedFriend: Friend(
          uid: int.tryParse(mid) ?? 0,
          username: name,
          avatarUrl: face,
        ),
      );
    }
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
      dynamic userInfo;
      try {
        userInfo = GStrorage.userInfo.get('userInfoCache');
      } catch (_) {
        userInfo = null;
      }
      final myUid = userInfo?.mid ?? 0;

      final messageRepo = ref.read(messageRepositoryProvider);
      final allFriends = await messageRepo.getMergedFriendList(
        uid: myUid,
        offset: _offset,
        pageSize: _pageSize,
      );

      final newHasMore = allFriends.length >= _pageSize;
      final newList = [...state.friendList, ...allFriends];

      state = state.copyWith(
        friendList: newList,
        isLoading: false,
        hasMore: newHasMore,
      );
      _offset += allFriends.length;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '加载失败: $e',
      );
    }
  }

  void selectFriend(Friend friend) {
    state = state.copyWith(selectedFriend: friend);
  }

  void clearSelection() {
    state = state.copyWith(clearSelectedFriend: true);
  }
}

class ChatDetailState {
  final List<Message> messages;
  final bool isLoading;
  final bool isSending;
  final String errorMessage;
  final bool hasMore;

  const ChatDetailState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.errorMessage = '',
    this.hasMore = true,
  });

  ChatDetailState copyWith({
    List<Message>? messages,
    bool? isLoading,
    bool? isSending,
    String? errorMessage,
    bool? hasMore,
  }) {
    return ChatDetailState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

@riverpod
class ChatDetailNotifier extends _$ChatDetailNotifier {
  int _offset = 0;
  final int _pageSize = 20;
  late int _friendUid;

  @override
  ChatDetailState build(int friendUid) {
    _friendUid = friendUid;
    Future.microtask(() => loadMessages());
    return const ChatDetailState();
  }

  Future<void> loadMessages({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      _offset = 0;
      state = state.copyWith(messages: [], hasMore: true);
    }

    if (!state.hasMore) return;

    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      final messageRepo = ref.read(messageRepositoryProvider);
      final newMessages = await messageRepo.getFriendMessage(
        friendUid: _friendUid,
        offset: _offset,
        num: _pageSize,
      );

      final newHasMore = newMessages.length >= _pageSize;
      final newList = refresh ? newMessages : [...newMessages, ...state.messages];

      state = state.copyWith(
        messages: newList,
        isLoading: false,
        hasMore: newHasMore,
      );
      _offset += newMessages.length;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '加载失败: $e',
      );
    }
  }

  Future<bool> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isSending) return false;

    state = state.copyWith(isSending: true);

    try {
      final messageRepo = ref.read(messageRepositoryProvider);
      final success = await messageRepo.sendMessage(
        receiver: _friendUid,
        message: text.trim(),
      );

      if (success) {
        await loadMessages(refresh: true);
      }
      state = state.copyWith(isSending: false);
      return success;
    } catch (e) {
      SmartDialog.showToast('发送失败');
      state = state.copyWith(isSending: false);
      return false;
    }
  }
}
