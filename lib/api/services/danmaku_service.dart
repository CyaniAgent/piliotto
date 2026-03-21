import '../services/api_service.dart';
import '../models/danmaku.dart';

class DanmakuService {
  static const String baseEndpoint = '/danmaku';

  // 获取视频滚幕
  static Future<List<Danmaku>> getDanmakus(int vid) async {
    final response =
        await ApiService.request('$baseEndpoint/$vid', requireToken: false);
    final data = response['data'] as List;
    return data.map((item) => Danmaku.fromJson(item)).toList();
  }

  // 发送滚幕
  static Future<void> sendDanmaku({
    required dynamic vid,
    required String text,
    required dynamic time,
    required String mode,
    required String color,
    required String fontSize,
    required String render,
  }) async {
    await ApiService.request(
      baseEndpoint,
      method: 'POST',
      requireToken: true,
      body: {
        'vid': vid,
        'text': text,
        'time': time,
        'mode': mode,
        'color': color,
        'font_size': fontSize,
        'render': render,
      },
    );
  }

  // 删除滚幕
  static Future<void> deleteDanmaku({
    required int danmakuId,
  }) async {
    await ApiService.request(
      '$baseEndpoint/$danmakuId',
      method: 'DELETE',
      requireToken: true,
    );
  }
}
