import 'package:get/get.dart';
import 'package:piliotto/api/models/message.dart';
import 'package:piliotto/api/services/message_service.dart';
import 'package:piliotto/api/services/old_api_service.dart';
import 'package:piliotto/utils/storage.dart';

class MessageController extends GetxController {
  RxList<Friend> friendList = <Friend>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  Rxn<Friend> selectedFriend = Rxn<Friend>();

  int _offset = 0;
  final int _pageSize = 20;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    _checkInitialFriend();
    loadFriendList();
  }

  void _checkInitialFriend() {
    final parameters = Get.parameters;
    final mid = parameters['mid'];
    final name = parameters['name'];
    final face = parameters['face'];

    if (mid != null && name != null) {
      selectedFriend.value = Friend(
        uid: int.tryParse(mid) ?? 0,
        username: name,
        avatarUrl: face,
      );
    }
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
      final myUid = GStrorage.userInfo.get('userInfoCache')?.mid ?? 0;

      final List<Future<List<Friend>>> futures = [];

      futures.add(_getFollowingFriends(myUid, _offset));

      futures.add(MessageService.getFriendList(
        offset: _offset,
        num: _pageSize,
      ));

      final results = await Future.wait(futures);

      final followingFriends = results[0];
      final messageFriends = results[1];

      final Map<int, Friend> mergedMap = {};

      for (final friend in messageFriends) {
        mergedMap[friend.uid] = friend;
      }

      for (final friend in followingFriends) {
        if (!mergedMap.containsKey(friend.uid)) {
          mergedMap[friend.uid] = friend;
        }
      }

      final allFriends = mergedMap.values.toList();
      allFriends.sort((a, b) {
        if (a.lastTime != null && b.lastTime != null) {
          return b.lastTime!.compareTo(a.lastTime!);
        }
        if (a.lastTime != null) return -1;
        if (b.lastTime != null) return 1;
        return 0;
      });

      if (allFriends.length < _pageSize) {
        _hasMore = false;
      }

      friendList.addAll(allFriends);
      _offset += allFriends.length;
    } catch (e) {
      errorMessage.value = '加载失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Friend>> _getFollowingFriends(int uid, int offset) async {
    try {
      final response = await OldApiService.getFollowingList(
        uid: uid,
        offset: offset,
        num: 18,
      );

      if (response['status'] == 'success') {
        final list = response['user_list'] as List?;
        return list
                ?.map((e) => Friend(
                      uid: int.tryParse(e['uid']?.toString() ?? '0') ?? 0,
                      username: e['username']?.toString() ?? '',
                      avatarUrl: e['avatar_url']?.toString(),
                      intro: e['intro']?.toString(),
                    ))
                .toList() ??
            [];
      }
    } catch (e) {
      // Ignore errors for following list
    }
    return [];
  }

  void selectFriend(Friend friend) {
    selectedFriend.value = friend;
  }

  void clearSelection() {
    selectedFriend.value = null;
  }
}
