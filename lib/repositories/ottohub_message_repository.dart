import '../api/services/message_service.dart';
import '../api/services/legacy_api_service.dart';
import '../api/models/message.dart';
import 'base_repository.dart';
import 'i_message_repository.dart';

class OttohubMessageRepository extends BaseRepository implements IMessageRepository {
  @override
  Future<List<Friend>> getFriendList(
      {int offset = 0, int num = 20, CacheConfig? cacheConfig}) {
    return withCache(
      'getFriendList_$offset',
      () => MessageService.getFriendList(offset: offset, num: num),
      cacheConfig:
          cacheConfig ?? const CacheConfig(duration: Duration(minutes: 1)),
    );
  }

  @override
  Future<List<Message>> getFriendMessage(
      {required int friendUid, int offset = 0, int num = 20}) {
    return MessageService.getFriendMessage(
        friendUid: friendUid, offset: offset, num: num);
  }

  @override
  Future<bool> sendMessage({required int receiver, required String message}) {
    invalidateCache('getFriendList');
    return MessageService.sendMessage(receiver: receiver, message: message);
  }

  @override
  Future<int> getUnreadMessageNum() {
    return MessageService.getUnreadMessageNum();
  }

  Future<List<Friend>> _getFollowingFriends(int uid, int offset) async {
    try {
      final response = await LegacyApiService.getFollowingList(
          uid: uid, offset: offset, num: 18);
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
      return [];
    }
    return [];
  }

  @override
  Future<List<Friend>> getMergedFriendList(
      {required int uid, int offset = 0, int pageSize = 20}) async {
    final futures = <Future<List<Friend>>>[];

    futures.add(_getFollowingFriends(uid, offset));
    futures.add(MessageService.getFriendList(offset: offset, num: pageSize));

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

    return allFriends;
  }
}
