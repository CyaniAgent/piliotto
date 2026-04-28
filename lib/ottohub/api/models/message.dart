class Message {
  final int msgId;
  final int sender;
  final int receiver;
  final String content;
  final String time;
  final String? senderName;
  final String? senderAvatarUrl;
  final String? receiverName;
  final String? receiverAvatarUrl;
  final bool? isRead;

  Message({
    required this.msgId,
    required this.sender,
    required this.receiver,
    required this.content,
    required this.time,
    this.senderName,
    this.senderAvatarUrl,
    this.receiverName,
    this.receiverAvatarUrl,
    this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      msgId: int.tryParse(json['msg_id']?.toString() ?? '0') ?? 0,
      sender: int.tryParse(json['sender']?.toString() ?? '0') ?? 0,
      receiver: int.tryParse(json['receiver']?.toString() ?? '0') ?? 0,
      content: json['content']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      senderName: json['sender_name']?.toString(),
      senderAvatarUrl: json['sender_avatar_url']?.toString(),
      receiverName: json['receiver_name']?.toString(),
      receiverAvatarUrl: json['receiver_avatar_url']?.toString(),
      isRead: json['is_read'] == true || json['is_read'] == 1,
    );
  }
}

class Friend {
  final int uid;
  final String username;
  final String? intro;
  final String? avatarUrl;
  final String? lastTime;
  final String? lastMessage;
  final int? newMessageNum;

  Friend({
    required this.uid,
    required this.username,
    this.intro,
    this.avatarUrl,
    this.lastTime,
    this.lastMessage,
    this.newMessageNum,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      uid: int.tryParse(json['uid']?.toString() ?? '0') ?? 0,
      username: json['username']?.toString() ?? '',
      intro: json['intro']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      lastTime: json['last_time']?.toString(),
      lastMessage: json['last_message']?.toString(),
      newMessageNum: int.tryParse(json['new_message_num']?.toString() ?? '0'),
    );
  }
}
