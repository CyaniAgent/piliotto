import '../api/services/following_service.dart';
import '../api/services/block_service.dart';
import '../api/services/legacy_api_service.dart';
import '../api/models/following.dart';
import '../api/models/block.dart';
import '../models/member/info.dart';
import 'package:piliotto/repositories/base_repository.dart';
import 'package:piliotto/repositories/i_user_repository.dart';

class OttohubUserRepository extends BaseRepository implements IUserRepository {
  @override
  Future<MemberInfoModel> getUserDetail(
      {required int uid, CacheConfig? cacheConfig}) async {
    return withCache(
      'getUserDetail_$uid',
      () async {
        final res = await LegacyApiService.getUserDetail(uid: uid);
        if (res['status'] == 'success') {
          return MemberInfoModel(
            mid: int.tryParse(res['uid'].toString()) ?? 0,
            name: res['username']?.toString() ?? '',
            sign: res['intro']?.toString() ?? '',
            face: res['avatar_url']?.toString() ?? '',
            cover: res['cover_url']?.toString() ?? '',
            sex: res['sex']?.toString() ?? '',
            fans: int.tryParse(res['fans_count'].toString()) ?? 0,
            attention: int.tryParse(res['followings_count'].toString()) ?? 0,
            archiveCount: int.tryParse(res['video_num'].toString()) ?? 0,
            articleCount: int.tryParse(res['blog_num'].toString()) ?? 0,
          );
        }
        throw Exception(res['message'] ?? '获取用户信息失败');
      },
      cacheConfig:
          cacheConfig ?? const CacheConfig(duration: Duration(minutes: 5)),
    );
  }

  @override
  Future<UserProfileInfo> getUserProfileInfo({required int uid}) async {
    final res = await LegacyApiService.getUserDetail(uid: uid);
    if (res['status'] == 'success') {
      return UserProfileInfo(
        coverUrl: res['cover_url']?.toString(),
        followingCount:
            int.tryParse(res['followings_count']?.toString() ?? '0') ?? 0,
        fansCount: int.tryParse(res['fans_count']?.toString() ?? '0') ?? 0,
      );
    }
    throw Exception(res['message'] ?? '获取用户资料失败');
  }

  @override
  Future<FollowStatusResponse> getFollowStatus({required int followingUid}) {
    return FollowingService.getFollowStatus(followingUid: followingUid);
  }

  @override
  Future<FollowResponse> followUser({required int followingUid}) {
    invalidateCache('getUserDetail_$followingUid');
    return FollowingService.followUser(followingUid: followingUid);
  }

  @override
  Future<UserListResponse> getFollowingList(
      {required int uid, int offset = 0, int num = 20}) {
    return FollowingService.getFollowingList(
        uid: uid, offset: offset, num: num);
  }

  @override
  Future<UserListResponse> getFansList(
      {required int uid, int offset = 0, int num = 20}) {
    return FollowingService.getFansList(uid: uid, offset: offset, num: num);
  }

  @override
  Future<BlockResponse> blockUser(
      {required int blockedId, String? reason, int? reasonVisible}) {
    return BlockService.blockUser(
        blockedId: blockedId, reason: reason, reasonVisible: reasonVisible);
  }

  @override
  Future<void> unblockUser({required int blockedId}) {
    return BlockService.unblockUser(blockedId: blockedId);
  }
}
