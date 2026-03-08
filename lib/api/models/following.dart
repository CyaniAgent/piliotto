class FollowingUser {
  final int uid;
  final String username;
  final String avatarUrl;
  final int? followStatus;

  FollowingUser({
    required this.uid,
    required this.username,
    required this.avatarUrl,
    this.followStatus,
  });

  factory FollowingUser.fromJson(Map<String, dynamic> json) {
    return FollowingUser(
      uid: json['uid'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
      followStatus: json['follow_status'],
    );
  }
}

class ActiveUser {
  final int uid;
  final String username;
  final String avatarUrl;
  final String latestActivityTime;

  ActiveUser({
    required this.uid,
    required this.username,
    required this.avatarUrl,
    required this.latestActivityTime,
  });

  factory ActiveUser.fromJson(Map<String, dynamic> json) {
    return ActiveUser(
      uid: json['uid'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
      latestActivityTime: json['latest_activity_time'],
    );
  }
}

class TimelineItem {
  final String contentType;
  final int? vid;
  final int? bid;
  final int uid;
  final String title;
  final String? content;
  final String time;
  final int likeCount;
  final int favoriteCount;
  final int viewCount;
  final String? coverUrl;
  final String username;
  final String avatarUrl;
  final List<String>? thumbnails;

  TimelineItem({
    required this.contentType,
    this.vid,
    this.bid,
    required this.uid,
    required this.title,
    this.content,
    required this.time,
    required this.likeCount,
    required this.favoriteCount,
    required this.viewCount,
    this.coverUrl,
    required this.username,
    required this.avatarUrl,
    this.thumbnails,
  });

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    return TimelineItem(
      contentType: json['content_type'],
      vid: json['vid'],
      bid: json['bid'],
      uid: json['uid'],
      title: json['title'],
      content: json['content'],
      time: json['time'],
      likeCount: json['like_count'],
      favoriteCount: json['favorite_count'],
      viewCount: json['view_count'],
      coverUrl: json['cover_url'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
      thumbnails: json['thumbnails'] != null
          ? List<String>.from(json['thumbnails'])
          : null,
    );
  }
}

class UserListResponse {
  final List<FollowingUser> userList;

  UserListResponse({required this.userList});

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    return UserListResponse(
      userList: (json['user_list'] as List)
          .map((item) => FollowingUser.fromJson(item))
          .toList(),
    );
  }
}

class TimelineResponse {
  final List<TimelineItem> timelineList;

  TimelineResponse({required this.timelineList});

  factory TimelineResponse.fromJson(Map<String, dynamic> json) {
    return TimelineResponse(
      timelineList: (json['timeline_list'] as List)
          .map((item) => TimelineItem.fromJson(item))
          .toList(),
    );
  }
}

class ActiveUserListResponse {
  final List<ActiveUser> userList;

  ActiveUserListResponse({required this.userList});

  factory ActiveUserListResponse.fromJson(Map<String, dynamic> json) {
    return ActiveUserListResponse(
      userList: (json['user_list'] as List)
          .map((item) => ActiveUser.fromJson(item))
          .toList(),
    );
  }
}

class FollowResponse {
  final int newFansCount;
  final int followStatus;

  FollowResponse({required this.newFansCount, required this.followStatus});

  factory FollowResponse.fromJson(Map<String, dynamic> json) {
    return FollowResponse(
      newFansCount: json['new_fans_count'],
      followStatus: json['follow_status'],
    );
  }
}

class FollowStatusResponse {
  final int followStatus;

  FollowStatusResponse({required this.followStatus});

  factory FollowStatusResponse.fromJson(Map<String, dynamic> json) {
    return FollowStatusResponse(
      followStatus: json['follow_status'],
    );
  }
}
