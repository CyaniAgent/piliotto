import 'package:hive/hive.dart';
import '../api/services/video_service.dart';
import '../models/common/reply_type.dart';
import '../utils/storage.dart';

class VideoHttp {
  static Box localCache = GStrorage.localCache;
  static Box setting = GStrorage.setting;
  static Box userInfoCache = GStrorage.userInfo;

  // 随机视频列表（替代推荐）
  static Future randomVideoList({int num = 20}) async {
    try {
      final response = await VideoService.getRandomVideos(num: num);
      return {'status': true, 'data': response.videoList};
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err.toString()};
    }
  }

  // 最新视频列表
  static Future newVideoList({
    int offset = 0,
    int num = 20,
    String type = 'all',
  }) async {
    try {
      final response = await VideoService.getNewVideos(
        offset: offset,
        num: num,
        type: type,
      );
      return {'status': true, 'data': response.videoList};
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err.toString()};
    }
  }

  // 热门视频列表
  static Future popularVideoList({
    int timeLimit = 7,
    int offset = 0,
    int num = 20,
  }) async {
    try {
      final response = await VideoService.getPopularVideos(
        timeLimit: timeLimit,
        offset: offset,
        num: num,
      );
      return {'status': true, 'data': response.videoList};
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err.toString()};
    }
  }

  // 分类视频列表
  static Future categoryVideoList(String category, {int num = 20}) async {
    try {
      final response = await VideoService.getCategoryVideos(category, num: num);
      return {'status': true, 'data': response.videoList};
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err.toString()};
    }
  }

  // 搜索视频列表
  static Future searchVideoList({
    String? searchTerm,
    int offset = 0,
    int num = 20,
    int vidDesc = 0,
    int viewCountDesc = 0,
    int likeCountDesc = 0,
    int favoriteCountDesc = 0,
    int? uid,
    String? type,
  }) async {
    try {
      final response = await VideoService.searchVideos(
        searchTerm: searchTerm,
        offset: offset,
        num: num,
        vidDesc: vidDesc,
        viewCountDesc: viewCountDesc,
        likeCountDesc: likeCountDesc,
        favoriteCountDesc: favoriteCountDesc,
        uid: uid,
        type: type,
      );
      return {
        'status': true,
        'data': response.videoList,
        'count': response.totalCount,
      };
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err.toString()};
    }
  }

  // 视频详情
  static Future videoIntro({required int vid}) async {
    try {
      final video = await VideoService.getVideoDetail(vid);
      return {'status': true, 'data': video};
    } catch (err) {
      return {'status': false, 'data': null, 'msg': err.toString()};
    }
  }

  // 用户视频列表
  static Future userVideoList(int uid, {int offset = 0, int num = 20}) async {
    try {
      final response = await VideoService.getUserVideos(
        uid,
        offset: offset,
        num: num,
      );
      return {'status': true, 'data': response.videoList};
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err.toString()};
    }
  }

  // 相关视频列表
  static Future relatedVideoList({required int vid, int num = 20}) async {
    try {
      final response = await VideoService.getRelatedVideos(vid, num: num);
      return {'status': true, 'data': response.videoList};
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err.toString()};
    }
  }

  // 收藏视频列表
  static Future favoriteVideoList({int offset = 0, int num = 20}) async {
    try {
      final response = await VideoService.getFavoriteVideos(
        offset: offset,
        num: num,
      );
      return {
        'status': true,
        'data': response.videoList,
        'count': response.favoriteVideoCount,
      };
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err.toString()};
    }
  }

  // 管理视频列表
  static Future manageVideoList({int offset = 0, int num = 20}) async {
    try {
      final response = await VideoService.getManageVideos(
        offset: offset,
        num: num,
      );
      return {
        'status': true,
        'data': response.videoList,
        'count': response.manageVideoCount,
      };
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err.toString()};
    }
  }

  // 历史视频列表
  static Future historyVideoList() async {
    try {
      final response = await VideoService.getHistoryVideos();
      return {'status': true, 'data': response.videoList};
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err.toString()};
    }
  }

  // 保存观看历史
  static Future saveWatchHistory({
    required int vid,
    required int lastWatchSecond,
  }) async {
    try {
      await VideoService.saveWatchHistory(
        vid: vid,
        lastWatchSecond: lastWatchSecond,
      );
      return {'status': true};
    } catch (err) {
      return {'status': false, 'msg': err.toString()};
    }
  }

  // 收藏/取消收藏视频
  static Future toggleFavorite({required int vid}) async {
    try {
      final response = await VideoService.toggleFavorite(vid: vid);
      return {
        'status': true,
        'data': {
          'if_favorite': response.ifFavorite,
          'favorite_count': response.favoriteCount,
        },
      };
    } catch (err) {
      return {'status': false, 'msg': err.toString()};
    }
  }

  // 点赞/取消点赞视频
  static Future toggleLike({required int vid}) async {
    try {
      final response = await VideoService.toggleLike(vid: vid);
      return {
        'status': true,
        'data': {
          'if_like': response.ifLike,
          'like_count': response.likeCount,
        },
      };
    } catch (err) {
      return {'status': false, 'msg': err.toString()};
    }
  }

  // 删除视频
  static Future deleteVideo({required int vid}) async {
    try {
      await VideoService.deleteVideo(vid: vid);
      return {'status': true};
    } catch (err) {
      return {'status': false, 'msg': err.toString()};
    }
  }

  // ========== 以下为兼容旧接口的方法 ==========

  // 兼容：首页推荐视频（使用随机视频替代）
  static Future rcmdVideoList({required int ps, required int freshIdx}) async {
    return randomVideoList(num: ps);
  }

  // 兼容：首页推荐视频 App（使用随机视频替代）
  static Future rcmdVideoListApp({
    bool loginStatus = true,
    required int freshIdx,
  }) async {
    return randomVideoList(num: 20);
  }

  // 兼容：最热视频（使用热门视频替代）
  static Future hotVideoList({required int pn, required int ps}) async {
    return popularVideoList(offset: (pn - 1) * ps, num: ps);
  }

  // 兼容：视频流（Ottohub 视频详情中包含 video_url）
  static Future videoUrl({
    int? avid,
    String? bvid,
    required int cid,
    int? qn,
  }) async {
    return {
      'status': false,
      'msg': '请使用视频详情接口获取 video_url',
    };
  }

  // 兼容：相关视频（使用 vid）
  static Future relatedVideoListByBvid({required String bvid}) async {
    return {
      'status': false,
      'msg': '请使用 vid 参数调用 relatedVideoList',
    };
  }

  // 兼容：获取点赞状态（从视频详情获取）
  static Future hasLikeVideo({required String bvid}) async {
    return {
      'status': false,
      'msg': '请使用视频详情接口获取 if_like 字段',
    };
  }

  // 兼容：获取投币状态（Ottohub 不支持）
  static Future hasCoinVideo({required String bvid}) async {
    return {'status': false, 'msg': 'Ottohub API 不支持投币功能'};
  }

  // 兼容：投币（Ottohub 不支持）
  static Future coinVideo({required String bvid, required int multiply}) async {
    return {'status': false, 'msg': 'Ottohub API 不支持投币功能'};
  }

  // 兼容：获取收藏状态（从视频详情获取）
  static Future hasFavVideo({required int aid}) async {
    return {
      'status': false,
      'msg': '请使用视频详情接口获取 if_favorite 字段',
    };
  }

  // 兼容：一键三连（Ottohub 不支持）
  static Future oneThree({required String bvid}) async {
    return {'status': false, 'msg': 'Ottohub API 不支持一键三连功能'};
  }

  // 兼容：点赞（使用 toggleLike）
  static Future likeVideo({required String bvid, required bool type}) async {
    return {
      'status': false,
      'msg': '请使用 vid 参数调用 toggleLike',
    };
  }

  // 兼容：收藏（使用 toggleFavorite）
  static Future favVideo({
    required int aid,
    String? addIds,
    String? delIds,
  }) async {
    return {
      'status': false,
      'msg': '请使用 vid 参数调用 toggleFavorite',
    };
  }

  // 兼容：查看视频被收藏在哪个文件夹（Ottohub 不支持文件夹）
  static Future videoInFolder({required int mid, required int rid}) async {
    return {'status': false, 'msg': 'Ottohub API 不支持收藏夹功能'};
  }

  // 兼容：发表评论（Ottohub 不支持）
  static Future replyAdd({
    required ReplyType type,
    required int oid,
    required String message,
    int? root,
    int? parent,
  }) async {
    return {'status': false, 'msg': 'Ottohub API 不支持发表评论功能'};
  }

  // 兼容：查询是否关注 up（Ottohub 不支持）
  static Future hasFollow({required int mid}) async {
    return {'status': false, 'msg': 'Ottohub API 不支持关注功能'};
  }

  // 兼容：操作用户关系（Ottohub 不支持）
  static Future relationMod({
    required int mid,
    required int act,
    required int reSrc,
  }) async {
    return {'status': false, 'msg': 'Ottohub API 不支持关注功能'};
  }

  // 兼容：视频播放进度（使用 saveWatchHistory）
  static Future heartBeat({bvid, cid, progress, realtime}) async {
    // 不执行任何操作，使用 saveWatchHistory 替代
  }

  // 兼容：查看视频同时在看人数（Ottohub 不支持）
  static Future onlineTotal({int? aid, String? bvid, int? cid}) async {
    return {'status': false, 'msg': 'Ottohub API 不支持在线人数功能'};
  }

  // 兼容：AI 总结（Ottohub 不支持）
  static Future aiConclusion({String? bvid, int? cid, int? upMid}) async {
    return {'status': false, 'msg': 'Ottohub API 不支持 AI 总结功能'};
  }

  // 兼容：获取字幕（Ottohub 不支持）
  static Future getSubtitle({int? cid, String? bvid}) async {
    return {'status': false, 'msg': 'Ottohub API 不支持字幕功能'};
  }

  // 兼容：视频排行（使用热门视频替代）
  static Future getRankVideoList(int rid) async {
    return popularVideoList();
  }

  // 兼容：获取字幕内容（Ottohub 不支持）
  static Future<Map<String, dynamic>> getSubtitleContent(url) async {
    return {'status': false, 'msg': 'Ottohub API 不支持字幕功能'};
  }

}
