import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:piliotto/providers/repository_provider.dart';
import 'package:piliotto/ottohub/api/models/video.dart';
import 'package:piliotto/utils/route_arguments.dart';

part 'provider.g.dart';

class RelatedState {
  final int vid;
  final List<Video> relatedVideoList;
  final bool isLoading;

  const RelatedState({
    this.vid = 0,
    this.relatedVideoList = const [],
    this.isLoading = false,
  });

  RelatedState copyWith({
    int? vid,
    List<Video>? relatedVideoList,
    bool? isLoading,
  }) {
    return RelatedState(
      vid: vid ?? this.vid,
      relatedVideoList: relatedVideoList ?? this.relatedVideoList,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@riverpod
class RelatedNotifier extends _$RelatedNotifier {
  OverlayEntry? popupDialog;

  @override
  RelatedState build() {
    final vid = int.parse(routeArguments.queryParameters['vid'] ?? '0');
    final initialState = RelatedState(vid: vid);
    Future.microtask(() => queryRelatedVideo());
    return initialState;
  }

  Future<dynamic> queryRelatedVideo() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await ref.read(videoRepositoryProvider).getRelatedVideos(state.vid);
      state = state.copyWith(
        relatedVideoList: response.videoList,
        isLoading: false,
      );
      return {'status': true, 'data': response.videoList};
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return {'status': false, 'message': e.toString()};
    }
  }
}
