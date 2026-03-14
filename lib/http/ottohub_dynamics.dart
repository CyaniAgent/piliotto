import 'package:piliotto/api/services/old_api_service.dart';
import '../models/dynamics/result.dart';

class OttohubDynamicsHttp {
  static Future<Map<String, dynamic>> getNewBlogList({
    int offset = 0,
    int num = 10,
  }) async {
    try {
      final res = await OldApiService.getNewBlogList(
        offset: offset,
        num: num,
      );

      if (res['status'] == 'success') {
        final List<dynamic> blogList = res['blog_list'] as List;
        final items = blogList.map((blog) {
          return DynamicItemModel.fromJson(blog);
        }).toList();

        return {
          'status': true,
          'data': DynamicsDataModel(
            hasMore: blogList.length >= num,
            items: items,
            offset: (offset + num).toString(),
          ),
        };
      } else {
        return {
          'status': false,
          'data': DynamicsDataModel(),
          'msg': res['message'] ?? '获取动态失败',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'data': DynamicsDataModel(),
        'msg': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getPopularBlogList({
    int timeLimit = 7,
    int offset = 0,
    int num = 10,
  }) async {
    try {
      final res = await OldApiService.getPopularBlogList(
        timeLimit: timeLimit,
        offset: offset,
        num: num,
      );

      if (res['status'] == 'success') {
        final List<dynamic> blogList = res['blog_list'] as List;
        final items = blogList.map((blog) {
          return DynamicItemModel.fromJson(blog);
        }).toList();

        return {
          'status': true,
          'data': DynamicsDataModel(
            hasMore: blogList.length >= num,
            items: items,
            offset: (offset + num).toString(),
          ),
        };
      } else {
        return {
          'status': false,
          'data': DynamicsDataModel(),
          'msg': res['message'] ?? '获取热门动态失败',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'data': DynamicsDataModel(),
        'msg': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getBlogDetail({
    required int bid,
  }) async {
    try {
      final res = await OldApiService.getBlogDetail(bid: bid);

      if (res['status'] == 'success') {
        return {
          'status': true,
          'data': res,
        };
      } else {
        return {
          'status': false,
          'data': {},
          'msg': res['message'] ?? '获取动态详情失败',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'data': {},
        'msg': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getRelatedBlogList({
    required int bid,
    int offset = 0,
    int num = 10,
  }) async {
    try {
      final res = await OldApiService.getRelatedBlogList(
        bid: bid,
        offset: offset,
        num: num,
      );

      if (res['status'] == 'success') {
        final List<dynamic> blogList = res['blog_list'] as List;
        final items = blogList.map((blog) {
          return DynamicItemModel.fromJson(blog);
        }).toList();

        return {
          'status': true,
          'data': DynamicsDataModel(
            hasMore: blogList.length >= num,
            items: items,
            offset: (offset + num).toString(),
          ),
        };
      } else {
        return {
          'status': false,
          'data': DynamicsDataModel(),
          'msg': res['message'] ?? '获取相关动态失败',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'data': DynamicsDataModel(),
        'msg': e.toString(),
      };
    }
  }
}
