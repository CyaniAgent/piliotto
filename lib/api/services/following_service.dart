import '../services/api_service.dart';
import '../models/following.dart';

class FollowingService {
  static const String baseEndpoint = '/following';

  // 关注/取消关注
  static Future<FollowResponse> followUser({
    required int followingUid,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/follow/$followingUid',
      method: 'POST',
      requireToken: true,
    );
    return FollowResponse.fromJson(response);
  }

  // 获取关注状态
  static Future<FollowStatusResponse> getFollowStatus({
    required int followingUid,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/status/$followingUid',
      requireToken: true,
    );
    return FollowStatusResponse.fromJson(response);
  }

  // 获取关注列表
  static Future<UserListResponse> getFollowingList({
    required int uid,
    int offset = 0,
    int num = 20,
  }) async {
    final queryParams = {
      'offset': offset,
      'num': num,
    };

    final response = await ApiService.request(
      '$baseEndpoint/list/$uid',
      queryParams: queryParams,
    );
    return UserListResponse.fromJson(response['data']);
  }

  // 获取粉丝列表
  static Future<UserListResponse> getFansList({
    required int uid,
    int offset = 0,
    int num = 20,
  }) async {
    final queryParams = {
      'offset': offset,
      'num': num,
    };

    final response = await ApiService.request(
      '$baseEndpoint/fans/$uid',
      queryParams: queryParams,
    );
    return UserListResponse.fromJson(response['data']);
  }

  // 获取所有关注者的时间线
  static Future<TimelineResponse> getFollowingTimeline({
    int offset = 0,
    int num = 20,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/timeline',
      queryParams: {
        'offset': offset,
        'num': num,
      },
      requireToken: true,
    );
    return TimelineResponse.fromJson(response['data']);
  }

  // 获取某个用户的时间线
  static Future<TimelineResponse> getUserTimeline({
    required int uid,
    int offset = 0,
    int num = 20,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/timeline/$uid',
      queryParams: {
        'offset': offset,
        'num': num,
      },
    );
    return TimelineResponse.fromJson(response['data']);
  }

  // 获取活跃关注者列表
  static Future<ActiveUserListResponse> getActiveFollowers({
    required int uid,
    int offset = 0,
    int num = 20,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/active/$uid',
      queryParams: {
        'offset': offset,
        'num': num,
      },
    );
    return ActiveUserListResponse.fromJson(response['data']);
  }
}
