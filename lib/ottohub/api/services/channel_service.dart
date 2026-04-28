import '../services/api_service.dart';
import '../models/channel.dart';

class ChannelService {
  static const String baseEndpoint = '/channel';

  // 创建频道
  static Future<Channel> createChannel({
    required String channelName,
    required String channelTitle,
    String? description,
    String? coverUrl,
    int joinPermission = 0,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/create',
      method: 'POST',
      body: {
        'channel_name': channelName,
        'channel_title': channelTitle,
        'description': description,
        'cover_url': coverUrl,
        'join_permission': joinPermission,
      }..removeWhere((key, value) => value == null),
    );
    return Channel.fromJson(response['data']);
  }

  // 获取频道详情
  static Future<Channel> getChannelDetail(int channelId) async {
    final response = await ApiService.request(
      '$baseEndpoint/$channelId',
    );
    return Channel.fromJson(response['data']);
  }

  // 更新频道信息
  static Future<void> updateChannel({
    required int channelId,
    String? channelTitle,
    String? description,
    String? coverUrl,
    int? joinPermission,
  }) async {
    final body = {
      'channel_title': channelTitle,
      'description': description,
      'cover_url': coverUrl,
      'join_permission': joinPermission,
    }..removeWhere((key, value) => value == null);

    await ApiService.request(
      '$baseEndpoint/$channelId',
      method: 'PUT',
      body: body,
    );
  }

  // 删除频道
  static Future<void> deleteChannel({
    required int channelId,
    required String verificationCode,
  }) async {
    await ApiService.request(
      '$baseEndpoint/$channelId',
      method: 'DELETE',
      body: {
        'verification_code': verificationCode,
      },
    );
  }

  // 获取频道列表
  static Future<List<Channel>> getChannels({
    int page = 1,
    int limit = 20,
    String sort = 'created_at',
    String order = 'desc',
    String? keyword,
  }) async {
    final queryParams = {
      'page': page,
      'limit': limit,
      'sort': sort,
      'order': order,
      'keyword': keyword,
    }..removeWhere((key, value) => value == null);

    final response = await ApiService.request(
      baseEndpoint,
      queryParams: queryParams,
      requireToken: false,
    );
    final channels = (response['data']['channels'] as List<dynamic>)
        .map((e) => Channel.fromJson(e as Map<String, dynamic>))
        .toList();
    return channels;
  }

  // 申请加入频道
  static Future<void> joinChannel({
    required int channelId,
  }) async {
    await ApiService.request(
      '$baseEndpoint/$channelId/members',
      method: 'POST',
    );
  }

  // 获取成员列表
  static Future<List<ChannelMember>> getMembers({
    required int channelId,
    int page = 1,
    int limit = 20,
    int? role,
    int? status,
  }) async {
    final queryParams = {
      'page': page,
      'limit': limit,
      'role': role,
      'status': status,
    }..removeWhere((key, value) => value == null);

    final response = await ApiService.request(
      '$baseEndpoint/$channelId/members',
      queryParams: queryParams,
    );
    final members = (response['data']['members'] as List<dynamic>)
        .map((e) => ChannelMember.fromJson(e as Map<String, dynamic>))
        .toList();
    return members;
  }

  // 审批成员申请
  static Future<void> approveMember({
    required int channelId,
    required int uid,
    required String action,
    String? reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/$channelId/members/$uid',
      method: 'PUT',
      body: {
        'action': action,
        'reason': reason,
      }..removeWhere((key, value) => value == null),
    );
  }

  // 踢出成员
  static Future<void> kickMember({
    required int channelId,
    required int uid,
    String? reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/$channelId/members/$uid',
      method: 'DELETE',
      body: {
        'reason': reason,
      }..removeWhere((key, value) => value == null),
    );
  }

  // 退出频道
  static Future<void> leaveChannel({
    required int channelId,
  }) async {
    await ApiService.request(
      '$baseEndpoint/$channelId/members/me',
      method: 'DELETE',
    );
  }

  // 设置成员角色
  static Future<void> setMemberRole({
    required int channelId,
    required int uid,
    required int role,
    String? verificationCode,
  }) async {
    final body = {
      'role': role,
      'verification_code': verificationCode,
    }..removeWhere((key, value) => value == null);

    await ApiService.request(
      '$baseEndpoint/$channelId/members/$uid/role',
      method: 'PUT',
      body: body,
    );
  }

  // 获取待审核申请列表
  static Future<List<ChannelMember>> getPendingApplications({
    required int channelId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/$channelId/members/pending',
      queryParams: {
        'page': page,
        'limit': limit,
      },
    );
    final applications = (response['data']['applications'] as List<dynamic>)
        .map((e) => ChannelMember.fromJson(e as Map<String, dynamic>))
        .toList();
    return applications;
  }

  // 获取频道内容
  static Future<List<ChannelContent>> getChannelContent({
    required int channelId,
    String type = 'all',
    int page = 1,
    int limit = 20,
    String sort = 'created_at',
    String order = 'desc',
    int? channelSectionId,
    bool random = false,
  }) async {
    final queryParams = {
      'type': type,
      'page': page,
      'limit': limit,
      'sort': sort,
      'order': order,
      'channel_section_id': channelSectionId,
      'random': random ? 1 : 0,
    }..removeWhere((key, value) => value == null);

    final response = await ApiService.request(
      '$baseEndpoint/$channelId/content',
      queryParams: queryParams,
    );
    final content = (response['data']['content'] as List<dynamic>)
        .map((e) => ChannelContent.fromJson(e as Map<String, dynamic>))
        .toList();
    return content;
  }

  // 添加内容到频道
  static Future<void> addContentToChannel({
    required int channelId,
    required String type,
    required int contentId,
    int channelSectionId = 0,
  }) async {
    await ApiService.request(
      '$baseEndpoint/$channelId/content',
      method: 'POST',
      body: {
        'type': type,
        'content_id': contentId,
        'channel_section_id': channelSectionId,
      },
    );
  }

  // 从频道移除内容
  static Future<void> removeContentFromChannel({
    required int channelId,
    required String type,
    required int contentId,
  }) async {
    await ApiService.request(
      '$baseEndpoint/$channelId/content/$type/$contentId',
      method: 'DELETE',
    );
  }

  // 关注频道
  static Future<void> followChannel({
    required int channelId,
  }) async {
    await ApiService.request(
      '$baseEndpoint/$channelId/follow',
      method: 'POST',
    );
  }

  // 取消关注频道
  static Future<void> unfollowChannel({
    required int channelId,
  }) async {
    await ApiService.request(
      '$baseEndpoint/$channelId/follow',
      method: 'DELETE',
    );
  }

  // 获取用户关注的频道列表
  static Future<List<Channel>> getFollowingChannels({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/following',
      queryParams: {
        'page': page,
        'limit': limit,
      },
    );
    final channels = (response['data']['channels'] as List<dynamic>)
        .map((e) => Channel.fromJson(e as Map<String, dynamic>))
        .toList();
    return channels;
  }

  // 获取频道统计信息
  static Future<Map<String, dynamic>> getChannelStats(int channelId) async {
    final response = await ApiService.request(
      '$baseEndpoint/$channelId/stats',
    );
    return response['data'];
  }

  // 获取用户的操作历史
  static Future<List<dynamic>> getChannelHistory({
    required int channelId,
    int? uid,
    int? operationType,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = {
      'uid': uid,
      'operation_type': operationType,
      'page': page,
      'limit': limit,
    }..removeWhere((key, value) => value == null);

    final response = await ApiService.request(
      '$baseEndpoint/$channelId/history',
      queryParams: queryParams,
    );
    return response['data']['history'];
  }

  // 获取用户加入的频道列表
  static Future<List<Channel>> getMyChannels({
    int page = 1,
    int limit = 20,
    int? role,
  }) async {
    final queryParams = {
      'page': page,
      'limit': limit,
      'role': role,
    }..removeWhere((key, value) => value == null);

    final response = await ApiService.request(
      '$baseEndpoint/my/channels',
      queryParams: queryParams,
    );
    final channels = (response['data']['channels'] as List<dynamic>)
        .map((e) => Channel.fromJson(e as Map<String, dynamic>))
        .toList();
    return channels;
  }

  // 搜索频道
  static Future<List<Channel>> searchChannels({
    required String keyword,
    int offset = 0,
    int num = 20,
    int channelIdDesc = 0,
    int memberCountDesc = 0,
    int followerCountDesc = 0,
    int createdAtDesc = 0,
    int? creatorUid,
    int? ownerUid,
    int? joinPermission,
    int? minMemberCount,
    int? maxMemberCount,
    int? minFollowerCount,
    int? maxFollowerCount,
  }) async {
    final queryParams = {
      'keyword': keyword,
      'offset': offset,
      'num': num,
      'channel_id_desc': channelIdDesc,
      'member_count_desc': memberCountDesc,
      'follower_count_desc': followerCountDesc,
      'created_at_desc': createdAtDesc,
      'creator_uid': creatorUid,
      'owner_uid': ownerUid,
      'join_permission': joinPermission,
      'min_member_count': minMemberCount,
      'max_member_count': maxMemberCount,
      'min_follower_count': minFollowerCount,
      'max_follower_count': maxFollowerCount,
    }..removeWhere((key, value) => value == null);

    final response = await ApiService.request(
      '$baseEndpoint/search',
      queryParams: queryParams,
    );
    final channels = (response['data']['channels'] as List<dynamic>)
        .map((e) => Channel.fromJson(e as Map<String, dynamic>))
        .toList();
    return channels;
  }

  // 拉黑用户
  static Future<void> blacklistUser({
    required int channelId,
    required int uid,
    String? reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/$channelId/blacklist',
      method: 'POST',
      body: {
        'uid': uid,
        'reason': reason,
      }..removeWhere((key, value) => value == null),
    );
  }

  // 解除拉黑
  static Future<void> unblacklistUser({
    required int channelId,
    required int uid,
  }) async {
    await ApiService.request(
      '$baseEndpoint/$channelId/blacklist/$uid',
      method: 'DELETE',
    );
  }

  // 获取黑名单列表
  static Future<List<dynamic>> getBlacklist({
    required int channelId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/$channelId/blacklist',
      queryParams: {
        'page': page,
        'limit': limit,
      },
    );
    return response['data']['blacklist'];
  }

  // 获取频道二级分区列表
  static Future<List<ChannelSection>> getChannelSections({
    required int channelId,
    bool includeDeleted = false,
  }) async {
    final queryParams = {
      'include_deleted': includeDeleted ? 1 : 0,
    };

    final response = await ApiService.request(
      '$baseEndpoint/$channelId/sections',
      queryParams: queryParams,
    );
    final sections = (response['data']['sections'] as List<dynamic>)
        .map((e) => ChannelSection.fromJson(e as Map<String, dynamic>))
        .toList();
    return sections;
  }

  // 获取二级分区详情
  static Future<ChannelSection> getSectionDetail({
    required int channelId,
    required int sectionId,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/$channelId/sections/$sectionId',
    );
    return ChannelSection.fromJson(response['data']);
  }

  // 创建二级分区
  static Future<ChannelSection> createSection({
    required int channelId,
    required String sectionName,
    String? description,
    String? iconUrl,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/$channelId/sections',
      method: 'POST',
      body: {
        'section_name': sectionName,
        'description': description,
        'icon_url': iconUrl,
      }..removeWhere((key, value) => value == null),
    );
    return ChannelSection.fromJson(response['data']);
  }

  // 修改二级分区信息
  static Future<ChannelSection> updateSection({
    required int channelId,
    required int sectionId,
    String? description,
    String? iconUrl,
    int? sortOrder,
  }) async {
    final body = {
      'description': description,
      'icon_url': iconUrl,
      'sort_order': sortOrder,
    }..removeWhere((key, value) => value == null);

    final response = await ApiService.request(
      '$baseEndpoint/$channelId/sections/$sectionId',
      method: 'PUT',
      body: body,
    );
    return ChannelSection.fromJson(response['data']);
  }

  // 删除二级分区
  static Future<void> deleteSection({
    required int channelId,
    required int sectionId,
    int? transferToSectionId,
  }) async {
    final body = {
      'transfer_to_section_id': transferToSectionId,
    }..removeWhere((key, value) => value == null);

    await ApiService.request(
      '$baseEndpoint/$channelId/sections/$sectionId',
      method: 'DELETE',
      body: body,
    );
  }

  // 更改内容所属的二级分区
  static Future<void> updateContentSection({
    required int channelId,
    required String type,
    required int contentId,
    required int channelSectionId,
  }) async {
    await ApiService.request(
      '$baseEndpoint/$channelId/content/$type/$contentId/section',
      method: 'PUT',
      body: {
        'channel_section_id': channelSectionId,
      },
    );
  }

  // 发送删除频道验证码
  static Future<void> sendDeleteVerificationCode({
    required int channelId,
  }) async {
    await ApiService.request(
      '$baseEndpoint/$channelId/delete_verification_code',
      method: 'POST',
    );
  }

  // 发送频道所有权转让验证码
  static Future<void> sendTransferVerificationCode({
    required int channelId,
  }) async {
    await ApiService.request(
      '$baseEndpoint/$channelId/transfer_verification_code',
      method: 'POST',
    );
  }

  // 获取订阅频道内容时间线
  static Future<List<dynamic>> getFollowingTimeline({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/following/timeline',
      queryParams: {
        'page': page,
        'limit': limit,
      },
    );
    return response['data']['timeline'];
  }

  // 获取单个频道内容时间线
  static Future<List<dynamic>> getChannelTimeline({
    required int channelId,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = {
      'page': page,
      'limit': limit,
    };

    final response = await ApiService.request(
      '$baseEndpoint/$channelId/timeline',
      queryParams: queryParams,
    );
    return response['data']['timeline'];
  }

  // 创建频道公告
  static Future<ChannelNotice> createNotice({
    required int channelId,
    String? title,
    required String content,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/$channelId/notices',
      method: 'POST',
      body: {
        'title': title,
        'content': content,
      }..removeWhere((key, value) => value == null),
    );
    return ChannelNotice.fromJson(response['data']);
  }

  // 删除频道公告
  static Future<void> deleteNotice({
    required int channelId,
    required int noticeId,
  }) async {
    await ApiService.request(
      '$baseEndpoint/$channelId/notices/$noticeId',
      method: 'DELETE',
    );
  }

  // 调整公告排序
  static Future<void> updateNoticeSort({
    required int channelId,
    required int noticeId,
    required int sortOrder,
  }) async {
    await ApiService.request(
      '$baseEndpoint/$channelId/notices/$noticeId/sort',
      method: 'PUT',
      body: {
        'sort_order': sortOrder,
      },
    );
  }

  // 获取频道公告列表
  static Future<List<ChannelNotice>> getNotices({
    required int channelId,
    bool includeDeleted = false,
  }) async {
    final queryParams = {
      'include_deleted': includeDeleted ? 1 : 0,
    };

    final response = await ApiService.request(
      '$baseEndpoint/$channelId/notices',
      queryParams: queryParams,
    );
    final notices = (response['data']['notices'] as List<dynamic>)
        .map((e) => ChannelNotice.fromJson(e as Map<String, dynamic>))
        .toList();
    return notices;
  }
}
