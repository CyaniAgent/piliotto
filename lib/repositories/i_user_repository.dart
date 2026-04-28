import 'package:piliotto/ottohub/api/models/following.dart';
import 'package:piliotto/ottohub/api/models/block.dart';
import 'package:piliotto/ottohub/models/member/info.dart';
import 'base_repository.dart';

class UserProfileInfo {
  final String? coverUrl;
  final int followingCount;
  final int fansCount;

  UserProfileInfo({
    this.coverUrl,
    this.followingCount = 0,
    this.fansCount = 0,
  });
}

abstract class IUserRepository {
  Future<MemberInfoModel> getUserDetail({required int uid, CacheConfig? cacheConfig});
  Future<UserProfileInfo> getUserProfileInfo({required int uid});
  Future<FollowStatusResponse> getFollowStatus({required int followingUid});
  Future<FollowResponse> followUser({required int followingUid});
  Future<UserListResponse> getFollowingList({required int uid, int offset = 0, int num = 20});
  Future<UserListResponse> getFansList({required int uid, int offset = 0, int num = 20});
  Future<BlockResponse> blockUser({required int blockedId, String? reason, int? reasonVisible});
  Future<void> unblockUser({required int blockedId});
}
