import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:piliotto/providers/repository_provider.dart';
import 'package:piliotto/services/loggeer.dart';
import 'package:piliotto/ottohub/models/video/reply/item.dart';

part 'provider.g.dart';

class VideoReplyState {
  final int vid;
  final List<ReplyItemModel> replyList;
  final int currentPage;
  final bool isLoadingMore;
  final bool hasLoaded;
  final String noMore;
  final int count;

  const VideoReplyState({
    this.vid = 0,
    this.replyList = const [],
    this.currentPage = 0,
    this.isLoadingMore = false,
    this.hasLoaded = false,
    this.noMore = '',
    this.count = 0,
  });

  VideoReplyState copyWith({
    int? vid,
    List<ReplyItemModel>? replyList,
    int? currentPage,
    bool? isLoadingMore,
    bool? hasLoaded,
    String? noMore,
    int? count,
  }) {
    return VideoReplyState(
      vid: vid ?? this.vid,
      replyList: replyList ?? this.replyList,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      noMore: noMore ?? this.noMore,
      count: count ?? this.count,
    );
  }
}

@riverpod
class VideoReplyNotifier extends _$VideoReplyNotifier {
  static const int ps = 12;

  @override
  VideoReplyState build(int vid) {
    return VideoReplyState(vid: vid);
  }

  void updateVid(int newVid) {
    if (state.vid != newVid) {
      state = VideoReplyState(vid: newVid);
    }
  }

  Future queryReplyList({String type = 'init'}) async {
    if (state.isLoadingMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    int currentPage = state.currentPage;
    String noMore = state.noMore;

    if (type == 'init') {
      currentPage = 0;
      noMore = '';
    }

    if (noMore == '没有更多了') {
      state = state.copyWith(isLoadingMore: false);
      return;
    }

    try {
      final logger = getLogger();
      logger.d('开始获取评论列表，vid: ${state.vid}, offset: ${currentPage * ps}, num: $ps');

      final result = await ref.read(commentRepositoryProvider).getVideoComments(
        vid: state.vid,
        offset: currentPage * ps,
        num: ps,
      );
      logger.d('获取评论列表成功，数量: ${result.replies.length}');

      final List<ReplyItemModel> replyItems = result.replies;
      final List<ReplyItemModel> newReplyList;

      if (type == 'init') {
        newReplyList = replyItems;
      } else {
        newReplyList = [...state.replyList, ...replyItems];
      }

      if (!result.hasMore) {
        noMore = '没有更多了';
      } else {
        currentPage++;
        noMore = '';
      }

      state = state.copyWith(
        replyList: newReplyList,
        currentPage: currentPage,
        noMore: noMore,
        hasLoaded: true,
        isLoadingMore: false,
        count: type == 'init' ? replyItems.length : state.count,
      );
    } catch (e) {
      final logger = getLogger();
      logger.e('获取评论异常: ${e.toString()}');
      state = state.copyWith(
        noMore: '获取评论失败',
        isLoadingMore: false,
      );
    }
  }

  Future onLoad() async {
    await queryReplyList(type: 'onLoad');
  }

  Future<List<ReplyItemModel>> queryChildComments(int parentVcid) async {
    try {
      final logger = getLogger();
      logger.d('开始获取二级评论，vid: ${state.vid}, parentVcid: $parentVcid, offset: 0, num: $ps');

      final result = await ref.read(commentRepositoryProvider).getVideoComments(
        vid: state.vid,
        parentVcid: parentVcid,
        offset: 0,
        num: ps,
      );
      logger.d('获取到二级评论数量: ${result.replies.length}');

      return result.replies;
    } catch (e) {
      final logger = getLogger();
      logger.e('获取二级评论异常: ${e.toString()}');
      return [];
    }
  }
}
