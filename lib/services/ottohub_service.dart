import '../api/services/video_service.dart';
import '../api/services/auth_service.dart';
import '../api/services/channel_service.dart';
import '../api/services/block_service.dart';
import '../api/services/danmaku_service.dart';
import '../api/services/following_service.dart';
import '../api/services/moderation_service.dart';
import '../api/models/video.dart';
import '../api/models/auth.dart';
import '../api/models/channel.dart';
import '../api/models/block.dart';
import '../api/models/danmaku.dart';
import '../api/models/following.dart';
import '../api/models/moderation.dart';

class OttohubService {
  // 视频相关方法
  static Future<VideoListResponse> getRandomVideos({int num = 20}) {
    return VideoService.getRandomVideos(num: num);
  }

  static Future<VideoListResponse> getNewVideos({
    int offset = 0,
    int num = 20,
    String type = 'all',
  }) {
    return VideoService.getNewVideos(
      offset: offset,
      num: num,
      type: type,
    );
  }

  static Future<VideoListResponse> getPopularVideos({
    int timeLimit = 7,
    int offset = 0,
    int num = 20,
  }) {
    return VideoService.getPopularVideos(
      timeLimit: timeLimit,
      offset: offset,
      num: num,
    );
  }

  static Future<VideoListResponse> getCategoryVideos(String category,
      {int num = 20}) {
    return VideoService.getCategoryVideos(category, num: num);
  }

  static Future<VideoListResponse> searchVideos({
    String? searchTerm,
    int offset = 0,
    int num = 20,
    int vidDesc = 0,
    int viewCountDesc = 0,
    int likeCountDesc = 0,
    int favoriteCountDesc = 0,
    int? uid,
    String? type,
  }) {
    return VideoService.searchVideos(
      searchTerm: searchTerm,
      offset: offset,
      num: num,
      vidDesc: vidDesc,
      viewCountDesc: viewCountDesc,
      likeCountDesc: likeCountDesc,
      favoriteCountDesc: favoriteCountDesc,
      uid: uid,
      type: type,
    );
  }

  static Future<Video> getVideoDetail(int vid) {
    return VideoService.getVideoDetail(vid);
  }

  static Future<VideoListResponse> getUserVideos(
    int uid, {
    int offset = 0,
    int num = 20,
  }) {
    return VideoService.getUserVideos(
      uid,
      offset: offset,
      num: num,
    );
  }

  static Future<VideoListResponse> getRelatedVideos(
    int vid, {
    int num = 20,
    int offset = 0,
  }) {
    return VideoService.getRelatedVideos(
      vid,
      num: num,
      offset: offset,
    );
  }

  static Future<VideoListResponse> getFavoriteVideos({
    int offset = 0,
    int num = 20,
  }) {
    return VideoService.getFavoriteVideos(
      offset: offset,
      num: num,
    );
  }

  static Future<VideoListResponse> getManageVideos({
    int offset = 0,
    int num = 20,
  }) {
    return VideoService.getManageVideos(
      offset: offset,
      num: num,
    );
  }

  static Future<VideoListResponse> getHistoryVideos() {
    return VideoService.getHistoryVideos();
  }

  static Future<void> saveWatchHistory({
    required int vid,
    required int lastWatchSecond,
  }) {
    return VideoService.saveWatchHistory(
      vid: vid,
      lastWatchSecond: lastWatchSecond,
    );
  }

  static Future<VideoActionResponse> toggleFavorite({
    required int vid,
  }) {
    return VideoService.toggleFavorite(
      vid: vid,
    );
  }

  static Future<VideoActionResponse> toggleLike({
    required int vid,
  }) {
    return VideoService.toggleLike(
      vid: vid,
    );
  }

  static Future<void> deleteVideo({
    required int vid,
  }) {
    return VideoService.deleteVideo(
      vid: vid,
    );
  }

  static Future<VideoSubmitResponse> submitVideo({
    required String title,
    required String intro,
    required int type,
    required int category,
    required String tag,
    required String fileMp4,
    required String fileJpg,
    int? channelId,
    int? channelSectionId,
  }) {
    return VideoService.submitVideo(
      title: title,
      intro: intro,
      type: type,
      category: category,
      tag: tag,
      fileMp4: fileMp4,
      fileJpg: fileJpg,
      channelId: channelId,
      channelSectionId: channelSectionId,
    );
  }

  static Future<void> updateVideo({
    required int vid,
    String? title,
    String? intro,
    String? tag,
    int? category,
    String? fileJpg,
    String? fileMp4,
  }) {
    return VideoService.updateVideo(
      vid: vid,
      title: title,
      intro: intro,
      tag: tag,
      category: category,
      fileJpg: fileJpg,
      fileMp4: fileMp4,
    );
  }

  // 认证相关方法
  static Future<LoginResponse> login({
    required String email,
    required String password,
  }) {
    return AuthService.login(
      email: email,
      password: password,
    );
  }

  static Future<LoginResponse> register({
    required String email,
    required String verificationCode,
    required String password,
  }) {
    return AuthService.register(
      email: email,
      password: password,
      verificationCode: verificationCode,
    );
  }

  static Future<void> sendRegisterVerificationCode({required String email}) {
    return AuthService.sendRegisterVerificationCode(email: email);
  }

  static Future<void> resetPassword({
    required String email,
    required String passwordresetVerificationCode,
    required String pw,
    required String confirmPw,
  }) {
    return AuthService.resetPassword(
      email: email,
      passwordresetVerificationCode: passwordresetVerificationCode,
      pw: pw,
      confirmPw: confirmPw,
    );
  }

  static Future<void> sendPasswordResetVerificationCode(
      {required String email}) {
    return AuthService.sendPasswordResetVerificationCode(email: email);
  }

  static Future<SignInResponse> signIn() {
    return AuthService.signIn();
  }

  // 频道相关方法
  static Future<Channel> createChannel({
    required String channelName,
    required String channelTitle,
    String? description,
    String? coverUrl,
    int joinPermission = 0,
  }) {
    return ChannelService.createChannel(
      channelName: channelName,
      channelTitle: channelTitle,
      description: description,
      coverUrl: coverUrl,
      joinPermission: joinPermission,
    );
  }

  static Future<Channel> getChannelDetail(int channelId) {
    return ChannelService.getChannelDetail(channelId);
  }

  static Future<void> updateChannel({
    required int channelId,
    String? channelTitle,
    String? description,
    String? coverUrl,
    int? joinPermission,
  }) {
    return ChannelService.updateChannel(
      channelId: channelId,
      channelTitle: channelTitle,
      description: description,
      coverUrl: coverUrl,
      joinPermission: joinPermission,
    );
  }

  static Future<void> deleteChannel({
    required int channelId,
    required String verificationCode,
  }) {
    return ChannelService.deleteChannel(
      channelId: channelId,
      verificationCode: verificationCode,
    );
  }

  static Future<List<Channel>> getChannels({
    int page = 1,
    int limit = 20,
    String sort = 'created_at',
    String order = 'desc',
    String? keyword,
  }) {
    return ChannelService.getChannels(
      page: page,
      limit: limit,
      sort: sort,
      order: order,
      keyword: keyword,
    );
  }

  static Future<void> joinChannel({
    required int channelId,
  }) {
    return ChannelService.joinChannel(
      channelId: channelId,
    );
  }

  static Future<List<ChannelMember>> getMembers({
    required int channelId,
    int page = 1,
    int limit = 20,
    int? role,
    int? status,
  }) {
    return ChannelService.getMembers(
      channelId: channelId,
      page: page,
      limit: limit,
      role: role,
      status: status,
    );
  }

  static Future<void> approveMember({
    required int channelId,
    required int uid,
    required String action,
    String? reason,
  }) {
    return ChannelService.approveMember(
      channelId: channelId,
      uid: uid,
      action: action,
      reason: reason,
    );
  }

  static Future<void> kickMember({
    required int channelId,
    required int uid,
    String? reason,
  }) {
    return ChannelService.kickMember(
      channelId: channelId,
      uid: uid,
      reason: reason,
    );
  }

  static Future<void> leaveChannel({
    required int channelId,
  }) {
    return ChannelService.leaveChannel(
      channelId: channelId,
    );
  }

  static Future<void> setMemberRole({
    required int channelId,
    required int uid,
    required int role,
    String? verificationCode,
  }) {
    return ChannelService.setMemberRole(
      channelId: channelId,
      uid: uid,
      role: role,
      verificationCode: verificationCode,
    );
  }

  static Future<List<ChannelMember>> getPendingApplications({
    required int channelId,
    int page = 1,
    int limit = 20,
  }) {
    return ChannelService.getPendingApplications(
      channelId: channelId,
      page: page,
      limit: limit,
    );
  }

  static Future<List<ChannelContent>> getChannelContent({
    required int channelId,
    String type = 'all',
    int page = 1,
    int limit = 20,
    String sort = 'created_at',
    String order = 'desc',
    int? channelSectionId,
    bool random = false,
  }) {
    return ChannelService.getChannelContent(
      channelId: channelId,
      type: type,
      page: page,
      limit: limit,
      sort: sort,
      order: order,
      channelSectionId: channelSectionId,
      random: random,
    );
  }

  static Future<void> addContentToChannel({
    required int channelId,
    required String type,
    required int contentId,
    int channelSectionId = 0,
  }) {
    return ChannelService.addContentToChannel(
      channelId: channelId,
      type: type,
      contentId: contentId,
      channelSectionId: channelSectionId,
    );
  }

  static Future<void> removeContentFromChannel({
    required int channelId,
    required String type,
    required int contentId,
  }) {
    return ChannelService.removeContentFromChannel(
      channelId: channelId,
      type: type,
      contentId: contentId,
    );
  }

  static Future<void> followChannel({
    required int channelId,
  }) {
    return ChannelService.followChannel(
      channelId: channelId,
    );
  }

  static Future<void> unfollowChannel({
    required int channelId,
  }) {
    return ChannelService.unfollowChannel(
      channelId: channelId,
    );
  }

  static Future<List<Channel>> getFollowingChannels({
    int page = 1,
    int limit = 20,
  }) {
    return ChannelService.getFollowingChannels(
      page: page,
      limit: limit,
    );
  }

  static Future<Map<String, dynamic>> getChannelStats(int channelId) {
    return ChannelService.getChannelStats(channelId);
  }

  static Future<List<dynamic>> getChannelHistory({
    required int channelId,
    int? uid,
    int? operationType,
    int page = 1,
    int limit = 20,
  }) {
    return ChannelService.getChannelHistory(
      channelId: channelId,
      uid: uid,
      operationType: operationType,
      page: page,
      limit: limit,
    );
  }

  static Future<List<Channel>> getMyChannels({
    int page = 1,
    int limit = 20,
    int? role,
  }) {
    return ChannelService.getMyChannels(
      page: page,
      limit: limit,
      role: role,
    );
  }

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
  }) {
    return ChannelService.searchChannels(
      keyword: keyword,
      offset: offset,
      num: num,
      channelIdDesc: channelIdDesc,
      memberCountDesc: memberCountDesc,
      followerCountDesc: followerCountDesc,
      createdAtDesc: createdAtDesc,
      creatorUid: creatorUid,
      ownerUid: ownerUid,
      joinPermission: joinPermission,
      minMemberCount: minMemberCount,
      maxMemberCount: maxMemberCount,
      minFollowerCount: minFollowerCount,
      maxFollowerCount: maxFollowerCount,
    );
  }

  static Future<void> blacklistUser({
    required int channelId,
    required int uid,
    String? reason,
  }) {
    return ChannelService.blacklistUser(
      channelId: channelId,
      uid: uid,
      reason: reason,
    );
  }

  static Future<void> unblacklistUser({
    required int channelId,
    required int uid,
  }) {
    return ChannelService.unblacklistUser(
      channelId: channelId,
      uid: uid,
    );
  }

  static Future<List<dynamic>> getBlacklist({
    required int channelId,
    int page = 1,
    int limit = 20,
  }) {
    return ChannelService.getBlacklist(
      channelId: channelId,
      page: page,
      limit: limit,
    );
  }

  static Future<List<ChannelSection>> getChannelSections({
    required int channelId,
    bool includeDeleted = false,
  }) {
    return ChannelService.getChannelSections(
      channelId: channelId,
      includeDeleted: includeDeleted,
    );
  }

  static Future<ChannelSection> getSectionDetail({
    required int channelId,
    required int sectionId,
  }) {
    return ChannelService.getSectionDetail(
      channelId: channelId,
      sectionId: sectionId,
    );
  }

  static Future<ChannelSection> createSection({
    required int channelId,
    required String sectionName,
    String? description,
    String? iconUrl,
  }) {
    return ChannelService.createSection(
      channelId: channelId,
      sectionName: sectionName,
      description: description,
      iconUrl: iconUrl,
    );
  }

  static Future<ChannelSection> updateSection({
    required int channelId,
    required int sectionId,
    String? description,
    String? iconUrl,
    int? sortOrder,
  }) {
    return ChannelService.updateSection(
      channelId: channelId,
      sectionId: sectionId,
      description: description,
      iconUrl: iconUrl,
      sortOrder: sortOrder,
    );
  }

  static Future<void> deleteSection({
    required int channelId,
    required int sectionId,
    int? transferToSectionId,
  }) {
    return ChannelService.deleteSection(
      channelId: channelId,
      sectionId: sectionId,
      transferToSectionId: transferToSectionId,
    );
  }

  static Future<void> updateContentSection({
    required int channelId,
    required String type,
    required int contentId,
    required int channelSectionId,
  }) {
    return ChannelService.updateContentSection(
      channelId: channelId,
      type: type,
      contentId: contentId,
      channelSectionId: channelSectionId,
    );
  }

  static Future<void> sendDeleteVerificationCode({
    required int channelId,
  }) {
    return ChannelService.sendDeleteVerificationCode(
      channelId: channelId,
    );
  }

  static Future<void> sendTransferVerificationCode({
    required int channelId,
  }) {
    return ChannelService.sendTransferVerificationCode(
      channelId: channelId,
    );
  }

  static Future<List<dynamic>> getChannelFollowingTimeline({
    int page = 1,
    int limit = 20,
  }) {
    return ChannelService.getFollowingTimeline(
      page: page,
      limit: limit,
    );
  }

  static Future<List<dynamic>> getChannelTimeline({
    required int channelId,
    int page = 1,
    int limit = 20,
  }) {
    return ChannelService.getChannelTimeline(
      channelId: channelId,
      page: page,
      limit: limit,
    );
  }

  static Future<ChannelNotice> createNotice({
    required int channelId,
    String? title,
    required String content,
  }) {
    return ChannelService.createNotice(
      channelId: channelId,
      title: title,
      content: content,
    );
  }

  static Future<void> deleteNotice({
    required int channelId,
    required int noticeId,
  }) {
    return ChannelService.deleteNotice(
      channelId: channelId,
      noticeId: noticeId,
    );
  }

  static Future<void> updateNoticeSort({
    required int channelId,
    required int noticeId,
    required int sortOrder,
  }) {
    return ChannelService.updateNoticeSort(
      channelId: channelId,
      noticeId: noticeId,
      sortOrder: sortOrder,
    );
  }

  static Future<List<ChannelNotice>> getNotices({
    required int channelId,
    bool includeDeleted = false,
  }) {
    return ChannelService.getNotices(
      channelId: channelId,
      includeDeleted: includeDeleted,
    );
  }

  // Block 相关方法
  static Future<BlockResponse> blockUser({
    required int blockedId,
    String? reason,
    int? reasonVisible,
  }) {
    return BlockService.blockUser(
      blockedId: blockedId,
      reason: reason,
      reasonVisible: reasonVisible,
    );
  }

  static Future<void> unblockUser({
    required int blockedId,
  }) {
    return BlockService.unblockUser(
      blockedId: blockedId,
    );
  }

  static Future<BlockListResponse> getBlockList({
    int page = 1,
    int pageSize = 20,
  }) {
    return BlockService.getBlockList(
      page: page,
      pageSize: pageSize,
    );
  }

  static Future<BlockedListResponse> getBlockedList({
    int page = 1,
    int pageSize = 20,
  }) {
    return BlockService.getBlockedList(
      page: page,
      pageSize: pageSize,
    );
  }

  static Future<BlockStatus> checkBlockStatus({
    required int userId,
  }) {
    return BlockService.checkBlockStatus(
      userId: userId,
    );
  }

  // Danmaku 相关方法
  static Future<List<Danmaku>> getDanmakus(int vid) {
    return DanmakuService.getDanmakus(vid);
  }

  static Future<void> sendDanmaku({
    required dynamic vid,
    required String text,
    required dynamic time,
    required String mode,
    required String color,
    required String fontSize,
    required String render,
  }) {
    return DanmakuService.sendDanmaku(
      vid: vid,
      text: text,
      time: time,
      mode: mode,
      color: color,
      fontSize: fontSize,
      render: render,
    );
  }

  static Future<void> deleteDanmaku({
    required int danmakuId,
  }) {
    return DanmakuService.deleteDanmaku(
      danmakuId: danmakuId,
    );
  }

  // Following 相关方法
  static Future<FollowResponse> followUser({
    required int followingUid,
  }) {
    return FollowingService.followUser(
      followingUid: followingUid,
    );
  }

  static Future<FollowStatusResponse> getFollowStatus({
    required int followingUid,
  }) {
    return FollowingService.getFollowStatus(
      followingUid: followingUid,
    );
  }

  static Future<UserListResponse> getFollowingList({
    required int uid,
    int offset = 0,
    int num = 20,
  }) {
    return FollowingService.getFollowingList(
      uid: uid,
      offset: offset,
      num: num,
    );
  }

  static Future<UserListResponse> getFansList({
    required int uid,
    int offset = 0,
    int num = 20,
  }) {
    return FollowingService.getFansList(
      uid: uid,
      offset: offset,
      num: num,
    );
  }

  static Future<TimelineResponse> getFollowingTimeline({
    int offset = 0,
    int num = 20,
  }) {
    return FollowingService.getFollowingTimeline(
      offset: offset,
      num: num,
    );
  }

  static Future<TimelineResponse> getUserTimeline({
    required int uid,
    int offset = 0,
    int num = 20,
  }) {
    return FollowingService.getUserTimeline(
      uid: uid,
      offset: offset,
      num: num,
    );
  }

  static Future<ActiveUserListResponse> getActiveFollowers({
    required int uid,
    int offset = 0,
    int num = 20,
  }) {
    return FollowingService.getActiveFollowers(
      uid: uid,
      offset: offset,
      num: num,
    );
  }

  // Moderation 相关方法
  static Future<VideoModerationList> getVideoModerationList({
    int offset = 0,
    int num = 20,
  }) {
    return ModerationService.getVideoModerationList(
      offset: offset,
      num: num,
    );
  }

  static Future<BlogModerationList> getBlogModerationList({
    int offset = 0,
    int num = 20,
  }) {
    return ModerationService.getBlogModerationList(
      offset: offset,
      num: num,
    );
  }

  static Future<AvatarModerationList> getAvatarModerationList({
    int offset = 0,
    int num = 20,
  }) {
    return ModerationService.getAvatarModerationList(
      offset: offset,
      num: num,
    );
  }

  static Future<CoverModerationList> getCoverModerationList({
    int offset = 0,
    int num = 20,
  }) {
    return ModerationService.getCoverModerationList(
      offset: offset,
      num: num,
    );
  }

  static Future<DanmakuModerationList> getDanmakuModerationList({
    int offset = 0,
    int num = 20,
  }) {
    return ModerationService.getDanmakuModerationList(
      offset: offset,
      num: num,
    );
  }

  static Future<VideoCommentModerationList> getVideoCommentModerationList({
    int offset = 0,
    int num = 20,
  }) {
    return ModerationService.getVideoCommentModerationList(
      offset: offset,
      num: num,
    );
  }

  static Future<BlogCommentModerationList> getBlogCommentModerationList({
    int offset = 0,
    int num = 20,
  }) {
    return ModerationService.getBlogCommentModerationList(
      offset: offset,
      num: num,
    );
  }

  static Future<UnreadCountResponse> getUnreadCount({
    int? isAdmin,
    int? isAudit,
  }) {
    return ModerationService.getUnreadCount(
      isAdmin: isAdmin,
      isAudit: isAudit,
    );
  }

  static Future<LogsResponse> getModerationLogs({
    int offset = 0,
    int num = 20,
    String? auditType,
    int? action,
    int? isRead,
    int? isAdmin,
    int? isAudit,
  }) {
    return ModerationService.getModerationLogs(
      offset: offset,
      num: num,
      auditType: auditType,
      action: action,
      isRead: isRead,
      isAdmin: isAdmin,
      isAudit: isAudit,
    );
  }

  static Future<void> approveVideo({
    required int vid,
  }) {
    return ModerationService.approveVideo(
      vid: vid,
    );
  }

  static Future<void> approveBlog({
    required int bid,
  }) {
    return ModerationService.approveBlog(
      bid: bid,
    );
  }

  static Future<void> approveAvatar({
    required int uid,
  }) {
    return ModerationService.approveAvatar(
      uid: uid,
    );
  }

  static Future<void> approveCover({
    required int uid,
  }) {
    return ModerationService.approveCover(
      uid: uid,
    );
  }

  static Future<void> approveDanmaku({
    required int danmakuId,
  }) {
    return ModerationService.approveDanmaku(
      danmakuId: danmakuId,
    );
  }

  static Future<void> approveVideoComment({
    required int vcid,
  }) {
    return ModerationService.approveVideoComment(
      vcid: vcid,
    );
  }

  static Future<void> approveBlogComment({
    required int bcid,
  }) {
    return ModerationService.approveBlogComment(
      bcid: bcid,
    );
  }

  static Future<void> rejectVideo({
    required int vid,
    required String reason,
  }) {
    return ModerationService.rejectVideo(
      vid: vid,
      reason: reason,
    );
  }

  static Future<void> rejectBlog({
    required int bid,
    required String reason,
  }) {
    return ModerationService.rejectBlog(
      bid: bid,
      reason: reason,
    );
  }

  static Future<void> rejectAvatar({
    required int uid,
    required String reason,
  }) {
    return ModerationService.rejectAvatar(
      uid: uid,
      reason: reason,
    );
  }

  static Future<void> rejectCover({
    required int uid,
    required String reason,
  }) {
    return ModerationService.rejectCover(
      uid: uid,
      reason: reason,
    );
  }

  static Future<void> rejectDanmaku({
    required int danmakuId,
    required String reason,
  }) {
    return ModerationService.rejectDanmaku(
      danmakuId: danmakuId,
      reason: reason,
    );
  }

  static Future<void> rejectVideoComment({
    required int vcid,
    required String reason,
  }) {
    return ModerationService.rejectVideoComment(
      vcid: vcid,
      reason: reason,
    );
  }

  static Future<void> rejectBlogComment({
    required int bcid,
    required String reason,
  }) {
    return ModerationService.rejectBlogComment(
      bcid: bcid,
      reason: reason,
    );
  }

  static Future<void> reportVideo({
    required int vid,
    required String reason,
  }) {
    return ModerationService.reportVideo(
      vid: vid,
      reason: reason,
    );
  }

  static Future<void> reportBlog({
    required int bid,
    required String reason,
  }) {
    return ModerationService.reportBlog(
      bid: bid,
      reason: reason,
    );
  }

  static Future<void> reportAvatar({
    required int uid,
    required String reason,
  }) {
    return ModerationService.reportAvatar(
      uid: uid,
      reason: reason,
    );
  }

  static Future<void> reportCover({
    required int uid,
    required String reason,
  }) {
    return ModerationService.reportCover(
      uid: uid,
      reason: reason,
    );
  }

  static Future<void> reportDanmaku({
    required int danmakuId,
    required String reason,
  }) {
    return ModerationService.reportDanmaku(
      danmakuId: danmakuId,
      reason: reason,
    );
  }

  static Future<void> reportVideoComment({
    required int vcid,
    required String reason,
  }) {
    return ModerationService.reportVideoComment(
      vcid: vcid,
      reason: reason,
    );
  }

  static Future<void> reportBlogComment({
    required int bcid,
    required String reason,
  }) {
    return ModerationService.reportBlogComment(
      bcid: bcid,
      reason: reason,
    );
  }

  static Future<void> appealVideo({
    required int vid,
    required String reason,
  }) {
    return ModerationService.appealVideo(
      vid: vid,
      reason: reason,
    );
  }

  static Future<void> appealBlog({
    required int bid,
    required String reason,
  }) {
    return ModerationService.appealBlog(
      bid: bid,
      reason: reason,
    );
  }

  static Future<void> appealAvatar({
    required int uid,
    required String reason,
  }) {
    return ModerationService.appealAvatar(
      uid: uid,
      reason: reason,
    );
  }

  static Future<void> appealCover({
    required int uid,
    required String reason,
  }) {
    return ModerationService.appealCover(
      uid: uid,
      reason: reason,
    );
  }

  static Future<void> appealDanmaku({
    required int danmakuId,
    required String reason,
  }) {
    return ModerationService.appealDanmaku(
      danmakuId: danmakuId,
      reason: reason,
    );
  }

  static Future<void> appealVideoComment({
    required int vcid,
    required String reason,
  }) {
    return ModerationService.appealVideoComment(
      vcid: vcid,
      reason: reason,
    );
  }

  static Future<void> appealBlogComment({
    required int bcid,
    required String reason,
  }) {
    return ModerationService.appealBlogComment(
      bcid: bcid,
      reason: reason,
    );
  }
}
