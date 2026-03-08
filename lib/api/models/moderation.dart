class VideoModeration {
  final int vid;
  final int uid;
  final String title;
  final String intro;
  final String tag;
  final String coverUrl;
  final String videoUrl;
  final String? reportReason;

  VideoModeration({
    required this.vid,
    required this.uid,
    required this.title,
    required this.intro,
    required this.tag,
    required this.coverUrl,
    required this.videoUrl,
    this.reportReason,
  });

  factory VideoModeration.fromJson(Map<String, dynamic> json) {
    return VideoModeration(
      vid: json['vid'],
      uid: json['uid'],
      title: json['title'],
      intro: json['intro'],
      tag: json['tag'],
      coverUrl: json['cover_url'],
      videoUrl: json['video_url'],
      reportReason: json['report_reason'],
    );
  }
}

class BlogModeration {
  final int bid;
  final String title;
  final String content;
  final String? reportReason;

  BlogModeration({
    required this.bid,
    required this.title,
    required this.content,
    this.reportReason,
  });

  factory BlogModeration.fromJson(Map<String, dynamic> json) {
    return BlogModeration(
      bid: json['bid'],
      title: json['title'],
      content: json['content'],
      reportReason: json['report_reason'],
    );
  }
}

class AvatarModeration {
  final int uid;
  final String username;
  final String avatarUrl;
  final String? reportReason;

  AvatarModeration({
    required this.uid,
    required this.username,
    required this.avatarUrl,
    this.reportReason,
  });

  factory AvatarModeration.fromJson(Map<String, dynamic> json) {
    return AvatarModeration(
      uid: json['uid'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
      reportReason: json['report_reason'],
    );
  }
}

class CoverModeration {
  final int uid;
  final String username;
  final String coverUrl;
  final String? reportReason;

  CoverModeration({
    required this.uid,
    required this.username,
    required this.coverUrl,
    this.reportReason,
  });

  factory CoverModeration.fromJson(Map<String, dynamic> json) {
    return CoverModeration(
      uid: json['uid'],
      username: json['username'],
      coverUrl: json['cover_url'],
      reportReason: json['report_reason'],
    );
  }
}

class DanmakuModeration {
  final int danmakuId;
  final String text;
  final double time;
  final int mode;
  final String color;
  final int fontSize;
  final String render;
  final String? reportReason;

  DanmakuModeration({
    required this.danmakuId,
    required this.text,
    required this.time,
    required this.mode,
    required this.color,
    required this.fontSize,
    required this.render,
    this.reportReason,
  });

  factory DanmakuModeration.fromJson(Map<String, dynamic> json) {
    return DanmakuModeration(
      danmakuId: json['danmaku_id'],
      text: json['text'],
      time: json['time'].toDouble(),
      mode: json['mode'],
      color: json['color'],
      fontSize: json['font_size'],
      render: json['render'],
      reportReason: json['report_reason'],
    );
  }
}

class VideoCommentModeration {
  final int vcid;
  final int parentVcid;
  final int vid;
  final int uid;
  final String content;
  final String time;
  final String username;
  final String? reportReason;

  VideoCommentModeration({
    required this.vcid,
    required this.parentVcid,
    required this.vid,
    required this.uid,
    required this.content,
    required this.time,
    required this.username,
    this.reportReason,
  });

  factory VideoCommentModeration.fromJson(Map<String, dynamic> json) {
    return VideoCommentModeration(
      vcid: json['vcid'],
      parentVcid: json['parent_vcid'],
      vid: json['vid'],
      uid: json['uid'],
      content: json['content'],
      time: json['time'],
      username: json['username'],
      reportReason: json['report_reason'],
    );
  }
}

class BlogCommentModeration {
  final int bcid;
  final int parentBcid;
  final int bid;
  final int uid;
  final String content;
  final String time;
  final String username;
  final String? reportReason;

  BlogCommentModeration({
    required this.bcid,
    required this.parentBcid,
    required this.bid,
    required this.uid,
    required this.content,
    required this.time,
    required this.username,
    this.reportReason,
  });

  factory BlogCommentModeration.fromJson(Map<String, dynamic> json) {
    return BlogCommentModeration(
      bcid: json['bcid'],
      parentBcid: json['parent_bcid'],
      bid: json['bid'],
      uid: json['uid'],
      content: json['content'],
      time: json['time'],
      username: json['username'],
      reportReason: json['report_reason'],
    );
  }
}

class ModerationLog {
  final int logId;
  final int operatorUid;
  final String operatorUsername;
  final int ownerUid;
  final String ownerUsername;
  final String auditType;
  final int action;
  final String? rejectReason;
  final int targetId;
  final int isRead;
  final int isUnread;
  final String createdAt;
  final String viewRole;
  final Map<String, dynamic> targetDetail;

  ModerationLog({
    required this.logId,
    required this.operatorUid,
    required this.operatorUsername,
    required this.ownerUid,
    required this.ownerUsername,
    required this.auditType,
    required this.action,
    this.rejectReason,
    required this.targetId,
    required this.isRead,
    required this.isUnread,
    required this.createdAt,
    required this.viewRole,
    required this.targetDetail,
  });

  factory ModerationLog.fromJson(Map<String, dynamic> json) {
    return ModerationLog(
      logId: json['log_id'],
      operatorUid: json['operator_uid'],
      operatorUsername: json['operator_username'],
      ownerUid: json['owner_uid'],
      ownerUsername: json['owner_username'],
      auditType: json['audit_type'],
      action: json['action'],
      rejectReason: json['reject_reason'],
      targetId: json['target_id'],
      isRead: json['is_read'],
      isUnread: json['is_unread'],
      createdAt: json['created_at'],
      viewRole: json['view_role'],
      targetDetail: json['target_detail'],
    );
  }
}

class LogsResponse {
  final String role;
  final int isAdmin;
  final int isAudit;
  final int offset;
  final int num;
  final List<ModerationLog> logs;

  LogsResponse({
    required this.role,
    required this.isAdmin,
    required this.isAudit,
    required this.offset,
    required this.num,
    required this.logs,
  });

  factory LogsResponse.fromJson(Map<String, dynamic> json) {
    return LogsResponse(
      role: json['role'],
      isAdmin: json['is_admin'],
      isAudit: json['is_audit'],
      offset: json['offset'],
      num: json['num'],
      logs: (json['logs'] as List)
          .map((item) => ModerationLog.fromJson(item))
          .toList(),
    );
  }
}

class UnreadCountResponse {
  final int unreadCount;
  final int unreadApproved;
  final int unreadRejected;

  UnreadCountResponse({
    required this.unreadCount,
    required this.unreadApproved,
    required this.unreadRejected,
  });

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponse(
      unreadCount: json['unread_count'],
      unreadApproved: json['unread_approved'],
      unreadRejected: json['unread_rejected'],
    );
  }
}

class VideoModerationList {
  final List<VideoModeration> videoList;

  VideoModerationList({required this.videoList});

  factory VideoModerationList.fromJson(Map<String, dynamic> json) {
    return VideoModerationList(
      videoList: (json['video_list'] as List)
          .map((item) => VideoModeration.fromJson(item))
          .toList(),
    );
  }
}

class BlogModerationList {
  final List<BlogModeration> blogList;

  BlogModerationList({required this.blogList});

  factory BlogModerationList.fromJson(Map<String, dynamic> json) {
    return BlogModerationList(
      blogList: (json['blog_list'] as List)
          .map((item) => BlogModeration.fromJson(item))
          .toList(),
    );
  }
}

class AvatarModerationList {
  final List<AvatarModeration> avatarList;

  AvatarModerationList({required this.avatarList});

  factory AvatarModerationList.fromJson(Map<String, dynamic> json) {
    return AvatarModerationList(
      avatarList: (json['avatar_list'] as List)
          .map((item) => AvatarModeration.fromJson(item))
          .toList(),
    );
  }
}

class CoverModerationList {
  final List<CoverModeration> coverList;

  CoverModerationList({required this.coverList});

  factory CoverModerationList.fromJson(Map<String, dynamic> json) {
    return CoverModerationList(
      coverList: (json['cover_list'] as List)
          .map((item) => CoverModeration.fromJson(item))
          .toList(),
    );
  }
}

class DanmakuModerationList {
  final List<DanmakuModeration> danmakuList;

  DanmakuModerationList({required this.danmakuList});

  factory DanmakuModerationList.fromJson(Map<String, dynamic> json) {
    return DanmakuModerationList(
      danmakuList: (json['danmaku_list'] as List)
          .map((item) => DanmakuModeration.fromJson(item))
          .toList(),
    );
  }
}

class VideoCommentModerationList {
  final List<VideoCommentModeration> commentList;

  VideoCommentModerationList({required this.commentList});

  factory VideoCommentModerationList.fromJson(Map<String, dynamic> json) {
    return VideoCommentModerationList(
      commentList: (json['comment_list'] as List)
          .map((item) => VideoCommentModeration.fromJson(item))
          .toList(),
    );
  }
}

class BlogCommentModerationList {
  final List<BlogCommentModeration> commentList;

  BlogCommentModerationList({required this.commentList});

  factory BlogCommentModerationList.fromJson(Map<String, dynamic> json) {
    return BlogCommentModerationList(
      commentList: (json['comment_list'] as List)
          .map((item) => BlogCommentModeration.fromJson(item))
          .toList(),
    );
  }
}
