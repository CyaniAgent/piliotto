import 'package:piliotto/ottohub/api/services/video_service.dart';

class Data {
  static Future init() async {
    await historyStatus();
  }

  static Future historyStatus() async {
    try {
      await VideoService.getHistoryVideos();
    } catch (e) {
      // 历史记录功能需要登录
    }
  }
}
