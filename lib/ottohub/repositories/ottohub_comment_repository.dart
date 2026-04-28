import '../api/services/legacy_api_service.dart';
import '../models/video/reply/item.dart';
import '../models/video/reply/member.dart';
import '../models/video/reply/content.dart';
import 'package:piliotto/repositories/base_repository.dart';
import 'package:piliotto/repositories/i_comment_repository.dart';

class OttohubCommentRepository extends BaseRepository implements ICommentRepository {
  ReplyItemModel _convertCommentToReplyItemModel(
    Map<String, dynamic> comment, {
    int? oid,
    bool includeChildPreview = false,
  }) {
    final member = ReplyMember(
      mid: (comment['uid'] ?? '0').toString(),
      uname: comment['username'] ?? '',
      sign: '',
      avatar: comment['avatar_url'] ?? '',
      level: 1,
      pendant: Pendant(pid: 0, name: '', image: ''),
      officialVerify: {},
      vip: {'vipStatus': 0, 'vipType': 0},
      fansDetail: {},
    );

    final content = ReplyContent(
      message: comment['content'] ?? '',
      atNameToMid: {},
      members: [],
      emote: {},
      jumpUrl: {},
      pictures: [],
      vote: {},
      richText: {},
      isText: true,
      topicsMeta: {},
    );

    final upAction = UpAction(like: false, reply: false);
    final childCommentNum = comment['child_comment_num'] ?? 0;

    List<ReplyItemModel> childReplies = [];
    if (includeChildPreview &&
        comment['child_comments'] != null &&
        comment['child_comments'] is List) {
      final List childCommentsList = comment['child_comments'];
      final previewCount =
          childCommentsList.length > 3 ? 3 : childCommentsList.length;
      for (int i = 0; i < previewCount; i++) {
        childReplies.add(_convertCommentToReplyItemModel(
          childCommentsList[i],
          oid: oid,
          includeChildPreview: false,
        ));
      }
    }

    final replyControl = ReplyControl(
      upReply: false,
      isUpTop: false,
      upLike: false,
      isShow: childCommentNum > 0,
      entryText: childCommentNum > 0 ? '共$childCommentNum条回复' : '',
      titleText: '',
      time: comment['time'] ?? '',
      location: '',
    );

    return ReplyItemModel(
      rpid: int.tryParse(comment['vcid'] ?? '0') ?? 0,
      oid: oid ?? 0,
      type: 1,
      mid: int.tryParse(comment['uid'] ?? '0') ?? 0,
      root: 0,
      parent: int.tryParse(comment['parent_vcid'] ?? '0') ?? 0,
      dialog: 0,
      count: childCommentNum,
      ctime: comment['time'] != null
          ? DateTime.parse(comment['time'].replaceAll(' ', 'T'))
                  .millisecondsSinceEpoch ~/
              1000
          : 0,
      like: 0,
      member: member,
      content: content,
      replies: childReplies,
      upAction: upAction,
      invisible: false,
      replyControl: replyControl,
      isUp: false,
      isTop: false,
      cardLabel: [],
    );
  }

  @override
  Future<CommentListResult> getVideoComments({
    required int vid,
    int parentVcid = 0,
    int offset = 0,
    int num = 12,
  }) async {
    final response = await LegacyApiService.getVideoComments(
      vid: vid,
      parentVcid: parentVcid,
      offset: offset,
      num: num,
    );

    if (response['status'] == 'success') {
      final List comments = response['comment_list'] ?? [];
      final replies = comments
          .map((comment) => _convertCommentToReplyItemModel(
                comment,
                oid: vid,
                includeChildPreview: parentVcid == 0,
              ))
          .toList();
      return CommentListResult(
        replies: replies,
        hasMore: replies.length >= num,
      );
    }
    throw Exception(response['message'] ?? '获取评论失败');
  }

  @override
  Future<List<ReplyItemModel>> getBlogComments({
    required int bid,
    int parentBcid = 0,
    int offset = 0,
    int num = 12,
  }) async {
    final res = await LegacyApiService.getBlogCommentList(
      bid: bid,
      parentBcid: parentBcid,
      offset: offset,
      num: num,
    );

    if (res['status'] == 'success') {
      final List<dynamic> comments = res['comment_list'] ?? [];
      return comments.map((comment) {
        return ReplyItemModel.fromOttohubJson(comment);
      }).toList();
    }
    throw Exception(res['message'] ?? '获取博客评论失败');
  }

  @override
  Future<Map<String, dynamic>> commentVideo({
    required int vid,
    int parentVcid = 0,
    required String content,
  }) {
    return LegacyApiService.commentVideo(
        vid: vid, parentVcid: parentVcid, content: content);
  }

  @override
  Future<Map<String, dynamic>> deleteVideoComment({required int vcid}) {
    return LegacyApiService.deleteVideoComment(vcid: vcid);
  }

  @override
  Future<Map<String, dynamic>> commentBlog({
    required int bid,
    int parentBcid = 0,
    required String content,
  }) {
    return LegacyApiService.commentBlog(
        bid: bid, parentBcid: parentBcid, content: content);
  }

  @override
  Future<Map<String, dynamic>> deleteBlogComment({required int bcid}) {
    return LegacyApiService.deleteBlogComment(bcid: bcid);
  }
}
