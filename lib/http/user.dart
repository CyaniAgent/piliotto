import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hive/hive.dart';
import '../api/services/video_service.dart';
import '../models/user/fav_folder.dart';
import '../utils/storage.dart';

class UserHttp {
  static Box userInfoCache = GStrorage.userInfo;

  // 用户信息
  static Future<dynamic> userInfo() async {
    var userInfo = userInfoCache.get('userInfoCache');
    if (userInfo != null) {
      return {'status': true, 'data': userInfo};
    }
    return {'status': false, 'msg': '未登录'};
  }

  // 收藏夹列表
  static Future<dynamic> userfavFolder({
    required int pn,
    required int ps,
    required int mid,
  }) async {
    try {
      final response = await VideoService.getFavoriteVideos(
        offset: (pn - 1) * ps,
        num: ps,
      );
      return {
        'status': true,
        'data': FavFolderData(
          count: response.favoriteVideoCount,
          list: [],
        ),
      };
    } catch (err) {
      return {'status': false, 'msg': err.toString()};
    }
  }

  // 第三方登录（Ottohub 不需要）
  static Future thirdLogin() async {
    SmartDialog.showToast('Ottohub 使用 token 认证，不需要第三方登录');
  }

  // ========== 以下为兼容旧接口的方法（不支持或已移除） ==========

  // 用户统计（Ottohub 不支持）
  static Future<dynamic> userStat({required int mid}) async {
    return {'status': false, 'msg': 'Ottohub API 不支持用户统计功能'};
  }

  // 用户统计（自己）（Ottohub 不支持）
  static Future<dynamic> userStatOwner() async {
    return {'status': false, 'msg': 'Ottohub API 不支持用户统计功能'};
  }

  // 收藏夹详情（使用 VideoService.getFavoriteVideos 替代）
  static Future<dynamic> userFavFolderDetail({
    required int mediaId,
    required int pn,
    required int ps,
    String keyword = '',
    String order = 'mtime',
    int type = 0,
  }) async {
    try {
      final response = await VideoService.getFavoriteVideos(
        offset: (pn - 1) * ps,
        num: ps,
      );
      return {
        'status': true,
        'data': {
          'medias': response.videoList,
          'count': response.favoriteVideoCount,
        },
      };
    } catch (err) {
      return {'status': false, 'msg': err.toString()};
    }
  }

  // 稍后再看（功能已移除）
  static Future<dynamic> seeYouLater() async {
    throw UnimplementedError('稍后再看功能已移除');
  }

  // 历史记录列表（使用 VideoService.getHistoryVideos 替代）
  static Future historyList(int? max, int? viewAt) async {
    try {
      final response = await VideoService.getHistoryVideos();
      return {
        'status': true,
        'data': {'list': response.videoList}
      };
    } catch (err) {
      return {'status': false, 'msg': err.toString()};
    }
  }

  // 暂停历史记录（Ottohub 不支持）
  static Future pauseHistory(bool switchStatus) async {
    throw UnimplementedError('Ottohub API 不支持暂停历史记录');
  }

  // 历史记录状态（Ottohub 不支持）
  static Future historyStatus() async {
    throw UnimplementedError('Ottohub API 不支持历史记录状态查询');
  }

  // 清空历史记录（Ottohub 不支持）
  static Future clearHistory() async {
    throw UnimplementedError('Ottohub API 不支持清空历史记录');
  }

  // 添加稍后再看（功能已移除）
  static Future toViewLater({String? bvid, dynamic aid}) async {
    throw UnimplementedError('稍后再看功能已移除');
  }

  // 删除稍后再看（功能已移除）
  static Future toViewDel({int? aid}) async {
    throw UnimplementedError('稍后再看功能已移除');
  }

  // 清空稍后再看（功能已移除）
  static Future toViewClear() async {
    throw UnimplementedError('稍后再看功能已移除');
  }

  // 删除历史记录（Ottohub 不支持）
  static Future<void> delHistory(int kid) async {
    throw UnimplementedError('Ottohub API 不支持删除历史记录');
  }

  // 是否关注（Ottohub 不支持）
  static Future hasFollow(int mid) async {
    return {'status': false, 'msg': 'Ottohub API 不支持关注状态查询'};
  }

  // 搜索历史记录（Ottohub 不支持）
  static Future searchHistory(
      {required int pn, required String keyword}) async {
    return {'status': false, 'msg': 'Ottohub API 不支持搜索历史记录'};
  }

  // 用户订阅文件夹（功能已移除）
  static Future userSubFolder({
    required int mid,
    required int pn,
    required int ps,
  }) async {
    throw UnimplementedError('订阅功能已移除');
  }

  // 用户订阅列表（功能已移除）
  static Future userSeasonList({
    required int seasonId,
    required int pn,
    required int ps,
  }) async {
    throw UnimplementedError('订阅功能已移除');
  }

  // 用户资源列表（功能已移除）
  static Future userResourceList({
    required int seasonId,
    required int pn,
    required int ps,
  }) async {
    throw UnimplementedError('订阅功能已移除');
  }

  // 取消订阅（功能已移除）
  static Future cancelSub({required int seasonId}) async {
    throw UnimplementedError('订阅功能已移除');
  }

  // 删除收藏夹（Ottohub 不支持）
  static Future delFavFolder({required int mediaIds}) async {
    return {'status': false, 'msg': 'Ottohub API 不支持删除收藏夹'};
  }

  // 获取媒体列表（功能已移除）
  static Future getMediaList({
    required int type,
    required int bizId,
    required int ps,
    int? oid,
  }) async {
    throw UnimplementedError('稍后再看功能已移除');
  }

  // 解析收藏视频（Ottohub 不支持）
  static Future parseFavVideo({
    required int mediaId,
    required int oid,
    required String bvid,
  }) async {
    return {'status': false, 'msg': 'Ottohub API 不支持此功能'};
  }
}
