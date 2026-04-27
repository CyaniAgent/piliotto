import '../services/legacy_api_service.dart';
import '../models/message.dart';

class MessageService {
  // 获取未读消息数
  static Future<int> getUnreadMessageNum() async {
    final token = LegacyApiService.getToken();
    if (token == null) return 0;

    final response = await LegacyApiService.request(
      'im',
      'new_message_num',
      {'token': token},
    );
    if (response['status'] == 'success') {
      return int.tryParse(response['new_message_num']?.toString() ?? '0') ?? 0;
    }
    return 0;
  }

  // 获取已读消息列表
  static Future<List<Message>> getReadMessageList({
    int offset = 0,
    int num = 20,
  }) async {
    final token = LegacyApiService.getToken();
    if (token == null) return [];

    final response = await LegacyApiService.request(
      'im',
      'read_message_list',
      {'token': token, 'offset': offset.toString(), 'num': num.toString()},
    );
    if (response['status'] == 'success') {
      final list = response['read_message_list'] as List?;
      return list?.map((e) => Message.fromJson(e)).toList() ?? [];
    }
    return [];
  }

  // 获取未读消息列表
  static Future<List<Message>> getUnreadMessageList({
    int offset = 0,
    int num = 20,
  }) async {
    final token = LegacyApiService.getToken();
    if (token == null) return [];

    final response = await LegacyApiService.request(
      'im',
      'unread_message_list',
      {'token': token, 'offset': offset.toString(), 'num': num.toString()},
    );
    if (response['status'] == 'success') {
      final list = response['unread_message_list'] as List?;
      return list?.map((e) => Message.fromJson(e)).toList() ?? [];
    }
    return [];
  }

  // 获取已发消息列表
  static Future<List<Message>> getSentMessageList({
    int offset = 0,
    int num = 20,
  }) async {
    final token = LegacyApiService.getToken();
    if (token == null) return [];

    final response = await LegacyApiService.request(
      'im',
      'sent_message_list',
      {'token': token, 'offset': offset.toString(), 'num': num.toString()},
    );
    if (response['status'] == 'success') {
      final list = response['sent_message_list'] as List?;
      return list?.map((e) => Message.fromJson(e)).toList() ?? [];
    }
    return [];
  }

  // 发送消息
  static Future<bool> sendMessage({
    required int receiver,
    required String message,
  }) async {
    final token = LegacyApiService.getToken();
    if (token == null) return false;

    final response = await LegacyApiService.request(
      'im',
      'send_message',
      {'token': token, 'receiver': receiver.toString(), 'message': message},
    );
    return response['status'] == 'success';
  }

  // 读取消息
  static Future<Message?> readMessage({required int msgId}) async {
    final token = LegacyApiService.getToken();
    if (token == null) return null;

    final response = await LegacyApiService.request(
      'im',
      'read_message',
      {'token': token, 'msg_id': msgId.toString()},
    );
    if (response['status'] == 'success') {
      return Message.fromJson(response);
    }
    return null;
  }

  // 系统消息一键已读
  static Future<bool> readAllSystemMessage() async {
    final token = LegacyApiService.getToken();
    if (token == null) return false;

    final response = await LegacyApiService.request(
      'im',
      'read_all_system_message',
      {'token': token},
    );
    return response['status'] == 'success';
  }

  // 删除消息
  static Future<bool> deleteMessage({required int msgId}) async {
    final token = LegacyApiService.getToken();
    if (token == null) return false;

    final response = await LegacyApiService.request(
      'im',
      'delete_message',
      {'token': token, 'msg_id': msgId.toString()},
    );
    return response['status'] == 'success';
  }

  // 获取好友列表
  static Future<List<Friend>> getFriendList({
    int offset = 0,
    int num = 20,
    int ifTimeDesc = 1,
  }) async {
    final token = LegacyApiService.getToken();
    if (token == null) return [];

    final response = await LegacyApiService.request(
      'im',
      'friend_list',
      {
        'token': token,
        'offset': offset.toString(),
        'num': num.toString(),
        'if_time_desc': ifTimeDesc.toString(),
      },
    );
    if (response['status'] == 'success') {
      final list = response['user_list'] as List?;
      return list?.map((e) => Friend.fromJson(e)).toList() ?? [];
    }
    return [];
  }

  // 获取好友消息
  static Future<List<Message>> getFriendMessage({
    required int friendUid,
    int offset = 0,
    int num = 20,
    int ifTimeDesc = 1,
  }) async {
    final token = LegacyApiService.getToken();
    if (token == null) return [];

    final response = await LegacyApiService.request(
      'im',
      'friend_message',
      {
        'token': token,
        'friend_uid': friendUid.toString(),
        'offset': offset.toString(),
        'num': num.toString(),
        'if_time_desc': ifTimeDesc.toString(),
      },
    );
    if (response['status'] == 'success') {
      final list = response['message_list'] as List?;
      return list?.map((e) => Message.fromJson(e)).toList() ?? [];
    }
    return [];
  }
}
