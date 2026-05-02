import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:piliotto/ottohub/api/models/video.dart';
import 'package:piliotto/providers/repository_provider.dart';
import 'package:piliotto/router/app_router.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

class MediaState {
  final VideoListResponse? favFolderData;
  final bool userLogin;
  final bool isLoading;

  const MediaState({
    this.favFolderData,
    this.userLogin = false,
    this.isLoading = false,
  });

  MediaState copyWith({
    VideoListResponse? favFolderData,
    bool? userLogin,
    bool? isLoading,
    bool clearFavFolderData = false,
  }) {
    return MediaState(
      favFolderData: clearFavFolderData ? null : (favFolderData ?? this.favFolderData),
      userLogin: userLogin ?? this.userLogin,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@riverpod
class MediaNotifier extends _$MediaNotifier {
  final ScrollController scrollController = ScrollController();

  List<Map<String, dynamic>> get list => [
        {
          'icon': Icons.history,
          'title': '观看记录',
          'onTap': () {
            final BuildContext? context = rootNavigatorKey.currentContext;
            if (context != null) context.push('/history');
          },
        },
        {
          'icon': Icons.star_border,
          'title': '我的收藏',
          'onTap': () {
            final BuildContext? context = rootNavigatorKey.currentContext;
            if (context != null) context.push('/fav');
          },
        },
      ];

  @override
  MediaState build() {
    dynamic userInfo;
    bool userLogin = false;
    try {
      userInfo = GStrorage.userInfo.get('userInfoCache');
      userLogin = userInfo != null;
    } catch (_) {
      userInfo = null;
      userLogin = false;
    }

    return MediaState(userLogin: userLogin);
  }

  Future<Map<String, dynamic>> queryFavFolder() async {
    if (!state.userLogin) {
      return {'status': false, 'data': [], 'msg': '未登录'};
    }

    state = state.copyWith(isLoading: true);

    try {
      final videoRepo = ref.read(videoRepositoryProvider);
      final response = await videoRepo.getFavoriteVideos(offset: 0, num: 5);
      state = state.copyWith(
        favFolderData: response,
        isLoading: false,
      );
      return {'status': true, 'data': response};
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return {'status': false, 'msg': e.toString()};
    }
  }
}
