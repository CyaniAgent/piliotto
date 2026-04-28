class Block {
  final int blockId;
  final int blockedId;
  final String username;
  final String avatar;
  final String reason;
  final int reasonVisible;
  final String createdAt;

  Block({
    required this.blockId,
    required this.blockedId,
    required this.username,
    required this.avatar,
    required this.reason,
    required this.reasonVisible,
    required this.createdAt,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      blockId: json['block_id'],
      blockedId: json['blocked_id'],
      username: json['username'],
      avatar: json['avatar'],
      reason: json['reason'] ?? '',
      reasonVisible: json['reason_visible'],
      createdAt: json['created_at'],
    );
  }
}

class BlockedUser {
  final int blockId;
  final int blockerId;
  final String username;
  final String avatar;
  final String reason;
  final int reasonVisible;
  final String createdAt;

  BlockedUser({
    required this.blockId,
    required this.blockerId,
    required this.username,
    required this.avatar,
    required this.reason,
    required this.reasonVisible,
    required this.createdAt,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      blockId: json['block_id'],
      blockerId: json['blocker_id'],
      username: json['username'],
      avatar: json['avatar'],
      reason: json['reason'] ?? '',
      reasonVisible: json['reason_visible'],
      createdAt: json['created_at'],
    );
  }
}

class BlockStatus {
  final int targetUserId;
  final bool iBlocked;
  final bool heBlocked;
  final bool mutualBlock;
  final bool anyBlock;
  final String myReason;
  final String hisReason;
  final bool hisReasonVisible;

  BlockStatus({
    required this.targetUserId,
    required this.iBlocked,
    required this.heBlocked,
    required this.mutualBlock,
    required this.anyBlock,
    required this.myReason,
    required this.hisReason,
    required this.hisReasonVisible,
  });

  factory BlockStatus.fromJson(Map<String, dynamic> json) {
    return BlockStatus(
      targetUserId: json['target_user_id'],
      iBlocked: json['i_blocked'],
      heBlocked: json['he_blocked'],
      mutualBlock: json['mutual_block'],
      anyBlock: json['any_block'],
      myReason: json['my_reason'] ?? '',
      hisReason: json['his_reason'] ?? '',
      hisReasonVisible: json['his_reason_visible'],
    );
  }
}

class BlockListResponse {
  final List<Block> list;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  BlockListResponse({
    required this.list,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory BlockListResponse.fromJson(Map<String, dynamic> json) {
    return BlockListResponse(
      list: (json['list'] as List).map((item) => Block.fromJson(item)).toList(),
      total: json['total'],
      page: json['page'],
      pageSize: json['page_size'],
      totalPages: json['total_pages'],
    );
  }
}

class BlockedListResponse {
  final List<BlockedUser> list;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  BlockedListResponse({
    required this.list,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory BlockedListResponse.fromJson(Map<String, dynamic> json) {
    return BlockedListResponse(
      list: (json['list'] as List)
          .map((item) => BlockedUser.fromJson(item))
          .toList(),
      total: json['total'],
      page: json['page'],
      pageSize: json['page_size'],
      totalPages: json['total_pages'],
    );
  }
}

class BlockResponse {
  final int blockId;
  final int blockedId;
  final String reason;
  final int reasonVisible;

  BlockResponse({
    required this.blockId,
    required this.blockedId,
    required this.reason,
    required this.reasonVisible,
  });

  factory BlockResponse.fromJson(Map<String, dynamic> json) {
    return BlockResponse(
      blockId: json['block_id'],
      blockedId: json['blocked_id'],
      reason: json['reason'] ?? '',
      reasonVisible: json['reason_visible'],
    );
  }
}
