import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:piliotto/ottohub/api/models/following.dart';
import 'package:piliotto/providers/repository_provider.dart';
import 'package:piliotto/services/loggeer.dart';
import 'package:piliotto/utils/route_arguments.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

final _logger = getLogger();

class FollowState {
  final List<FollowingUser> followList;
  final int mid;
  final String name;
  final String loadingText;
  final bool isLoading;
  final bool hasMore;
  final int offset;

  const FollowState({
    this.followList = const [],
    this.mid = 0,
    this.name = '',
    this.loadingText = '加载中...',
    this.isLoading = false,
    this.hasMore = true,
    this.offset = 0,
  });

  FollowState copyWith({
    List<FollowingUser>? followList,
    int? mid,
    String? name,
    String? loadingText,
    bool? isLoading,
    bool? hasMore,
    int? offset,
  }) {
    return FollowState(
      followList: followList ?? this.followList,
      mid: mid ?? this.mid,
      name: name ?? this.name,
      loadingText: loadingText ?? this.loadingText,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
    );
  }
}

@riverpod
class FollowNotifier extends _$FollowNotifier {
  static const int num = 12;

  @override
  FollowState build() {
    dynamic userInfo;
    try {
      userInfo = GStrorage.userInfo.get('userInfoCache');
    } catch (_) {
      userInfo = null;
    }
    
    final mid = routeArguments.queryParameters['mid'] != null
        ? int.parse(routeArguments.queryParameters['mid']!)
        : userInfo?.mid ?? 0;
    final name = routeArguments.queryParameters['name'] != null
        ? _safeDecodeURI(routeArguments.queryParameters['name']!)
        : userInfo?.uname ?? '';

    return FollowState(mid: mid, name: name);
  }

  String _safeDecodeURI(String value) {
    try {
      return Uri.decodeComponent(value);
    } catch (e) {
      return value;
    }
  }

  Future<void> queryFollowings({bool isLoadMore = false}) async {
    if (state.isLoading) return;

    if (!isLoadMore) {
      state = state.copyWith(offset: 0, loadingText: '加载中...');
    } else {
      if (!state.hasMore) return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final userRepo = ref.read(userRepositoryProvider);
      final response = await userRepo.getFollowingList(
        uid: state.mid,
        offset: state.offset,
        num: num,
      );

      final List<FollowingUser> users = response.userList;

      final newList = isLoadMore ? [...state.followList, ...users] : users;
      final newHasMore = users.length >= num;

      state = state.copyWith(
        followList: newList,
        isLoading: false,
        hasMore: newHasMore,
        loadingText: newHasMore ? state.loadingText : '没有更多了',
        offset: state.offset + users.length,
      );
    } catch (e) {
      _logger.e('获取关注列表失败: $e');
      SmartDialog.showToast('获取关注列表失败');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> onLoad() async {
    await queryFollowings(isLoadMore: true);
  }

  Future<void> onRefresh() async {
    await queryFollowings();
  }
}
