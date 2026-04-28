import 'package:piliotto/ottohub/models/video/reply/item.dart';

class CommentListResult {
  final List<ReplyItemModel> replies;
  final bool hasMore;

  CommentListResult({required this.replies, required this.hasMore});
}

abstract class ICommentRepository {
  Future<CommentListResult> getVideoComments({required int vid, int parentVcid = 0, int offset = 0, int num = 12});
  Future<List<ReplyItemModel>> getBlogComments({required int bid, int parentBcid = 0, int offset = 0, int num = 12});
  Future<Map<String, dynamic>> commentVideo({required int vid, int parentVcid = 0, required String content});
  Future<Map<String, dynamic>> deleteVideoComment({required int vcid});
  Future<Map<String, dynamic>> commentBlog({required int bid, int parentBcid = 0, required String content});
  Future<Map<String, dynamic>> deleteBlogComment({required int bcid});
}
