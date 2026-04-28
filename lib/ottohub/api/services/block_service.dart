import '../services/api_service.dart';
import '../models/block.dart';

class BlockService {
  static const String baseEndpoint = '/block';

  // 拉黑用户
  static Future<BlockResponse> blockUser({
    required int blockedId,
    String? reason,
    int? reasonVisible,
  }) async {
    final response = await ApiService.request(
      baseEndpoint,
      method: 'POST',
      body: {
        'blocked_id': blockedId,
        'reason': reason,
        'reason_visible': reasonVisible,
      }..removeWhere((key, value) => value == null),
    );
    return BlockResponse.fromJson(response['data']);
  }

  // 解除拉黑
  static Future<void> unblockUser({
    required int blockedId,
  }) async {
    await ApiService.request(
      '$baseEndpoint/$blockedId',
      method: 'DELETE',
    );
  }

  // 获取拉黑列表
  static Future<BlockListResponse> getBlockList({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/list',
      queryParams: {
        'page': page,
        'page_size': pageSize,
      },
    );
    return BlockListResponse.fromJson(response['data']);
  }

  // 获取被拉黑列表
  static Future<BlockedListResponse> getBlockedList({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/blocked/list',
      queryParams: {
        'page': page,
        'page_size': pageSize,
      },
    );
    return BlockedListResponse.fromJson(response['data']);
  }

  // 检查拉黑状态
  static Future<BlockStatus> checkBlockStatus({
    required int userId,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/status/$userId',
    );
    return BlockStatus.fromJson(response['data']);
  }
}
