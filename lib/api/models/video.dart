class Video {
  final int vid;
  final int uid;
  final String title;
  final String time;
  final int likeCount;
  final int favoriteCount;
  final int viewCount;
  final int isDeleted;
  final int auditStatus;
  final String coverUrl;
  final String username;
  final String avatarUrl;
  final int? ifLike;
  final int? ifFavorite;
  final String? intro;
  final String? tag;
  final String? collection;
  final int? type;
  final String? category;
  final int? duration;
  final int? collectionSortOrder;
  final int? channelId;
  final ChannelDetail? channelDetail;

  Video({
    required this.vid,
    required this.uid,
    required this.title,
    required this.time,
    required this.likeCount,
    required this.favoriteCount,
    required this.viewCount,
    required this.isDeleted,
    required this.auditStatus,
    required this.coverUrl,
    required this.username,
    required this.avatarUrl,
    this.ifLike,
    this.ifFavorite,
    this.intro,
    this.tag,
    this.collection,
    this.type,
    this.category,
    this.duration,
    this.collectionSortOrder,
    this.channelId,
    this.channelDetail,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      vid: toInt(json['vid']),
      uid: toInt(json['uid']),
      title: json['title'] ?? '',
      time: json['time'] ?? '',
      likeCount: toInt(json['like_count']),
      favoriteCount: toInt(json['favorite_count']),
      viewCount: toInt(json['view_count']),
      isDeleted: toInt(json['is_deleted']),
      auditStatus: toInt(json['audit_status']),
      coverUrl: json['cover_url'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      ifLike: toInt(json['if_like']),
      ifFavorite: toInt(json['if_favorite']),
      intro: json['intro'],
      tag: json['tag'],
      collection: json['collection'],
      type: toInt(json['type']),
      category: json['category'],
      duration: toInt(json['duration']),
      collectionSortOrder: toInt(json['collection_sort_order']),
      channelId: toInt(json['channel_id']),
      channelDetail: json['channel_detail'] != null
          ? ChannelDetail.fromJson(json['channel_detail'])
          : null,
    );
  }

  static int toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }
}

class ChannelDetail {
  final int channelId;
  final String channelName;
  final String channelTitle;
  final String description;
  final String coverUrl;

  ChannelDetail({
    required this.channelId,
    required this.channelName,
    required this.channelTitle,
    required this.description,
    required this.coverUrl,
  });

  factory ChannelDetail.fromJson(Map<String, dynamic> json) {
    return ChannelDetail(
      channelId: Video.toInt(json['channel_id']),
      channelName: json['channel_name'] ?? '',
      channelTitle: json['channel_title'] ?? '',
      description: json['description'] ?? '',
      coverUrl: json['cover_url'] ?? '',
    );
  }
}

class VideoListResponse {
  final List<Video> videoList;
  final int? totalCount;
  final int? favoriteVideoCount;
  final int? manageVideoCount;

  VideoListResponse({
    required this.videoList,
    this.totalCount,
    this.favoriteVideoCount,
    this.manageVideoCount,
  });

  factory VideoListResponse.fromJson(Map<String, dynamic> json) {
    return VideoListResponse(
      videoList: (json['video_list'] as List<dynamic>)
          .map((e) => Video.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['total_count'],
      favoriteVideoCount: json['favorite_video_count'],
      manageVideoCount: json['manage_video_count'],
    );
  }
}

class VideoActionResponse {
  final int ifLike;
  final int likeCount;
  final int? ifFavorite;
  final int? favoriteCount;

  VideoActionResponse({
    this.ifLike = 0,
    this.likeCount = 0,
    this.ifFavorite,
    this.favoriteCount,
  });

  factory VideoActionResponse.fromJson(Map<String, dynamic> json) {
    return VideoActionResponse(
      ifLike: json['if_like'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      ifFavorite: json['if_favorite'],
      favoriteCount: json['favorite_count'],
    );
  }
}

class VideoSubmitResponse {
  final int vid;
  final int ifAddExperience;

  VideoSubmitResponse({
    required this.vid,
    required this.ifAddExperience,
  });

  factory VideoSubmitResponse.fromJson(Map<String, dynamic> json) {
    return VideoSubmitResponse(
      vid: json['vid'] ?? 0,
      ifAddExperience: json['if_add_experience'] ?? 0,
    );
  }
}
