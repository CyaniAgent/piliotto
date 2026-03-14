import 'package:hive/hive.dart';
import '../api/services/following_service.dart';
import '../api/services/video_service.dart';
import '../utils/storage.dart';

class MemberHttp {
  static Box localCache = GStrorage.localCache;
  static Box setting = GStrorage.setting;
  static Box userInfoCache = GStrorage.userInfo;

  // 获取用户视频列表
  static Future memberArchive({
    required int uid,
    int ps = 30,
    int tid = 0,
    int pn = 1,
    String? keyword,
    String order = 'pubdate',
    bool orderAvoided = true,
  }) async {
    try {
      final response = await VideoService.getUserVideos(
        uid,
        offset: (pn - 1) * ps,
        num: ps,
      );
      return {
        'status': true,
        'data': {
          'list': response.videoList,
          'page': {'pn': pn, 'ps': ps},
        },
      };
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err.toString()};
    }
  }

  // 获取用户时间线（动态）
  static Future memberDynamic({String? offset, int? uid}) async {
    try {
      final response = await FollowingService.getUserTimeline(
        uid: uid!,
        offset: int.tryParse(offset ?? '0') ?? 0,
        num: 20,
      );
      return {
        'status': true,
        'data': {
          'items': response.timelineList,
          'offset': response.timelineList.length,
          'has_more': response.timelineList.length >= 20,
        },
      };
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err.toString()};
    }
  }

  // 关注/取消关注
  static Future relationMod({
    required int mid,
    required int act,
    required int reSrc,
  }) async {
    try {
      final response = await FollowingService.followUser(followingUid: mid);
      return {
        'status': true,
        'data': {
          'follow_status': response.followStatus,
          'fans_count': response.newFansCount,
        },
      };
    } catch (err) {
      return {'status': false, 'msg': err.toString()};
    }
  }

  // 获取关注状态
  static Future hasFollow({required int mid}) async {
    try {
      final response = await FollowingService.getFollowStatus(followingUid: mid);
      return {
        'status': true,
        'data': {
          'attribute': response.followStatus,
        },
      };
    } catch (err) {
      return {'status': false, 'msg': err.toString()};
    }
  }

  // 获取关注列表
  static Future followings({
    required int vmid,
    int pn = 1,
    int ps = 20,
    String order = 'desc',
    String orderType = 'attention',
  }) async {
    try {
      final response = await FollowingService.getFollowingList(
        uid: vmid,
        offset: (pn - 1) * ps,
        num: ps,
      );
      return {
        'status': true,
        'data': {
          'list': response.userList,
          'total': response.userList.length,
        },
      };
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err.toString()};
    }
  }

  // 获取粉丝列表
  static Future fans({
    required int vmid,
    int pn = 1,
    int ps = 20,
    String order = 'desc',
    String orderType = 'attention',
  }) async {
    try {
      final response = await FollowingService.getFansList(
        uid: vmid,
        offset: (pn - 1) * ps,
        num: ps,
      );
      return {
        'status': true,
        'data': {
          'list': response.userList,
          'total': response.userList.length,
        },
      };
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err.toString()};
    }
  }

  // 获取关注者的时间线
  static Future getFollowingTimeline({
    int offset = 0,
    int num = 20,
  }) async {
    try {
      final response = await FollowingService.getFollowingTimeline(
        offset: offset,
        num: num,
      );
      return {
        'status': true,
        'data': response.timelineList,
      };
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err.toString()};
    }
  }

  // 获取活跃关注者
  static Future getActiveFollowers({
    required int uid,
    int offset = 0,
    int num = 20,
  }) async {
    try {
      final response = await FollowingService.getActiveFollowers(
        uid: uid,
        offset: offset,
        num: num,
      );
      return {
        'status': true,
        'data': response.userList,
      };
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err.toString()};
    }
  }

  // ========== 以下为兼容旧接口的方法（不支持或已移除） ==========

  // 用户信息（Ottohub 需要从视频详情或用户列表获取）
  static Future memberInfo({int? mid, String token = ''}) async {
    return {
      'status': false,
      'msg': '请使用视频详情接口获取用户信息',
    };
  }

  // 用户统计（Ottohub 不支持）
  static Future memberStat({int? mid}) async {
    return {'status': false, 'msg': 'Ottohub API 不支持用户统计功能'};
  }

  // 用户卡片信息（Ottohub 不支持）
  static Future memberCardInfo({int? mid}) async {
    return {'status': false, 'msg': 'Ottohub API 不支持用户卡片功能'};
  }

  // 搜索用户动态（Ottohub 不支持）
  static Future memberDynamicSearch({int? pn, int? ps, int? mid}) async {
    return {'status': false, 'msg': 'Ottohub API 不支持搜索动态功能'};
  }

  // 查询分组（Ottohub 不支持）
  static Future followUpTags() async {
    return {'status': false, 'msg': 'Ottohub API 不支持分组功能'};
  }

  // 设置分组（Ottohub 不支持）
  static Future addUsers(int? fids, String? tagids) async {
    return {'status': false, 'msg': 'Ottohub API 不支持分组功能'};
  }

  // 获取某分组下的up（Ottohub 不支持）
  static Future followUpGroup(int? mid, int? tagid, int? pn, int? ps) async {
    return {'status': false, 'msg': 'Ottohub API 不支持分组功能'};
  }

  // 获取up置顶（Ottohub 不支持）
  static Future getTopVideo(String? vmid) async {
    return {'status': false, 'msg': 'Ottohub API 不支持置顶视频功能'};
  }

  // 获取up专栏（Ottohub 不支持）
  static Future getMemberSeasons(int? mid, int? pn, int? ps) async {
    return {'status': false, 'msg': 'Ottohub API 不支持专栏功能'};
  }

  // 最近投币（Ottohub 不支持）
  static Future getRecentCoinVideo({required int mid}) async {
    return {'status': false, 'msg': 'Ottohub API 不支持投币功能'};
  }

  // 最近点赞（Ottohub 不支持）
  static Future getRecentLikeVideo({required int mid}) async {
    return {'status': false, 'msg': 'Ottohub API 不支持点赞历史功能'};
  }

  // 查看某个专栏（Ottohub 不支持）
  static Future getSeasonDetail({
    required int mid,
    required int seasonId,
    bool sortReverse = false,
    required int pn,
    required int ps,
  }) async {
    return {'status': false, 'msg': 'Ottohub API 不支持专栏功能'};
  }

  // 获取TV authCode（Ottohub 不需要）
  static Future getTVCode() async {
    return {'status': false, 'msg': 'Ottohub 不需要 TV 授权'};
  }

  // 获取access_key（Ottohub 不需要）
  static Future cookieToKey() async {
    return {'status': false, 'msg': 'Ottohub 使用 token 认证'};
  }

  // 获取up播放数、点赞数（Ottohub 不支持）
  static Future memberView({required int mid}) async {
    return {'status': false, 'msg': 'Ottohub API 不支持用户播放统计功能'};
  }

  // 搜索follow（Ottohub 不支持）
  static Future getfollowSearch({
    required int mid,
    required int ps,
    required int pn,
    required String name,
  }) async {
    return {'status': false, 'msg': 'Ottohub API 不支持搜索关注功能'};
  }

  // 获取系列详情（Ottohub 不支持）
  static Future getSeriesDetail({
    required int mid,
    required int currentMid,
    required int seriesId,
    required int pn,
  }) async {
    return {'status': false, 'msg': 'Ottohub API 不支持系列功能'};
  }

  // 获取w_webid（Ottohub 不需要）
  static Future getWWebid({required int mid}) async {
    return {'status': false, 'msg': 'Ottohub 不需要 w_webid'};
  }

  // 获取用户专栏（Ottohub 不支持）
  static Future getMemberArticle({
    required int mid,
    required int pn,
    required String wWebid,
    String? offset,
  }) async {
    return {'status': false, 'msg': 'Ottohub API 不支持专栏功能'};
  }
}
