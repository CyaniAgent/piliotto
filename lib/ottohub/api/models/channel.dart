class Channel {
  final int channelId;
  final String channelName;
  final String channelTitle;
  final String description;
  final String coverUrl;
  final int creatorUid;
  final int ownerUid;
  final List<int>? adminUids;
  final int joinPermission;
  final int memberCount;
  final int followerCount;
  final String createdAt;
  final String? updatedAt;
  final bool? isMember;
  final bool? isFollowing;
  final int? userRole;
  final bool? isBlacklisted;

  Channel({
    required this.channelId,
    required this.channelName,
    required this.channelTitle,
    required this.description,
    required this.coverUrl,
    required this.creatorUid,
    required this.ownerUid,
    this.adminUids,
    required this.joinPermission,
    required this.memberCount,
    required this.followerCount,
    required this.createdAt,
    this.updatedAt,
    this.isMember,
    this.isFollowing,
    this.userRole,
    this.isBlacklisted,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      channelId: json['channel_id'] ?? 0,
      channelName: json['channel_name'] ?? '',
      channelTitle: json['channel_title'] ?? '',
      description: json['description'] ?? '',
      coverUrl: json['cover_url'] ?? '',
      creatorUid: json['creator_uid'] ?? 0,
      ownerUid: json['owner_uid'] ?? 0,
      adminUids: json['admin_uids'] != null
          ? List<int>.from(json['admin_uids'])
          : null,
      joinPermission: json['join_permission'] ?? 0,
      memberCount: json['member_count'] ?? 0,
      followerCount: json['follower_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'],
      isMember: json['is_member'],
      isFollowing: json['is_following'],
      userRole: json['user_role'],
      isBlacklisted: json['is_blacklisted'],
    );
  }
}

class ChannelMember {
  final int uid;
  final String username;
  final String avatarUrl;
  final int role;
  final int status;
  final String joinedAt;

  ChannelMember({
    required this.uid,
    required this.username,
    required this.avatarUrl,
    required this.role,
    required this.status,
    required this.joinedAt,
  });

  factory ChannelMember.fromJson(Map<String, dynamic> json) {
    return ChannelMember(
      uid: json['uid'] ?? 0,
      username: json['username'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      role: json['role'] ?? 0,
      status: json['status'] ?? 0,
      joinedAt: json['joined_at'] ?? '',
    );
  }
}

class ChannelSection {
  final int channelSectionId;
  final int channelId;
  final String sectionName;
  final String description;
  final String iconUrl;
  final int sortOrder;
  final int creatorUid;
  final String createdAt;
  final String updatedAt;
  final int isDeleted;
  final ContentCount? contentCount;

  ChannelSection({
    required this.channelSectionId,
    required this.channelId,
    required this.sectionName,
    required this.description,
    required this.iconUrl,
    required this.sortOrder,
    required this.creatorUid,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.contentCount,
  });

  factory ChannelSection.fromJson(Map<String, dynamic> json) {
    return ChannelSection(
      channelSectionId: json['channel_section_id'] ?? 0,
      channelId: json['channel_id'] ?? 0,
      sectionName: json['section_name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['icon_url'] ?? '',
      sortOrder: json['sort_order'] ?? 0,
      creatorUid: json['creator_uid'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      isDeleted: json['is_deleted'] ?? 0,
      contentCount: json['content_count'] != null
          ? ContentCount.fromJson(json['content_count'])
          : null,
    );
  }
}

class ContentCount {
  final int videoCount;
  final int blogCount;
  final int totalCount;

  ContentCount({
    required this.videoCount,
    required this.blogCount,
    required this.totalCount,
  });

  factory ContentCount.fromJson(Map<String, dynamic> json) {
    return ContentCount(
      videoCount: json['video_count'] ?? 0,
      blogCount: json['blog_count'] ?? 0,
      totalCount: json['total_count'] ?? 0,
    );
  }
}

class ChannelContent {
  final String type;
  final int? vid;
  final int? bid;
  final int uid;
  final String title;
  final String? coverUrl;
  final List<String>? thumbnails;
  final int viewCount;
  final int likeCount;
  final String createdAt;

  ChannelContent({
    required this.type,
    this.vid,
    this.bid,
    required this.uid,
    required this.title,
    this.coverUrl,
    this.thumbnails,
    required this.viewCount,
    required this.likeCount,
    required this.createdAt,
  });

  factory ChannelContent.fromJson(Map<String, dynamic> json) {
    return ChannelContent(
      type: json['type'] ?? '',
      vid: json['vid'],
      bid: json['bid'],
      uid: json['uid'] ?? 0,
      title: json['title'] ?? '',
      coverUrl: json['cover_url'],
      thumbnails: json['thumbnails'] != null
          ? List<String>.from(json['thumbnails'])
          : null,
      viewCount: json['view_count'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class ChannelNotice {
  final int noticeId;
  final int channelId;
  final String title;
  final String content;
  final int sortOrder;
  final int creatorUid;
  final String createdAt;
  final String updatedAt;
  final int isDeleted;

  ChannelNotice({
    required this.noticeId,
    required this.channelId,
    required this.title,
    required this.content,
    required this.sortOrder,
    required this.creatorUid,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  factory ChannelNotice.fromJson(Map<String, dynamic> json) {
    return ChannelNotice(
      noticeId: json['notice_id'] ?? 0,
      channelId: json['channel_id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      sortOrder: json['sort_order'] ?? 0,
      creatorUid: json['creator_uid'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      isDeleted: json['is_deleted'] ?? 0,
    );
  }
}

class Pagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final int? offset;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    this.offset,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      offset: json['offset'],
    );
  }
}
