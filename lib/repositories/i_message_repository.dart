import 'package:piliotto/ottohub/api/models/message.dart';
import 'base_repository.dart';

abstract class IMessageRepository {
  Future<List<Friend>> getFriendList({int offset = 0, int num = 20, CacheConfig? cacheConfig});
  Future<List<Message>> getFriendMessage({required int friendUid, int offset = 0, int num = 20});
  Future<bool> sendMessage({required int receiver, required String message});
  Future<int> getUnreadMessageNum();
  Future<List<Friend>> getMergedFriendList({required int uid, int offset = 0, int pageSize = 20});
}
