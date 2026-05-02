// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VideoReplyReplyNotifier)
final videoReplyReplyProvider = VideoReplyReplyNotifierFamily._();

final class VideoReplyReplyNotifierProvider
    extends $NotifierProvider<VideoReplyReplyNotifier, VideoReplyReplyState> {
  VideoReplyReplyNotifierProvider._(
      {required VideoReplyReplyNotifierFamily super.from,
      required (
        int,
        int,
        ReplyType,
      )
          super.argument})
      : super(
          retry: null,
          name: r'videoReplyReplyProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$videoReplyReplyNotifierHash();

  @override
  String toString() {
    return r'videoReplyReplyProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  VideoReplyReplyNotifier create() => VideoReplyReplyNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VideoReplyReplyState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VideoReplyReplyState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VideoReplyReplyNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$videoReplyReplyNotifierHash() =>
    r'0b78c099c898158637c26224989b3b6bcdcd53fb';

final class VideoReplyReplyNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
            VideoReplyReplyNotifier,
            VideoReplyReplyState,
            VideoReplyReplyState,
            VideoReplyReplyState,
            (
              int,
              int,
              ReplyType,
            )> {
  VideoReplyReplyNotifierFamily._()
      : super(
          retry: null,
          name: r'videoReplyReplyProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  VideoReplyReplyNotifierProvider call(
    int vid,
    int parentVcid,
    ReplyType replyType,
  ) =>
      VideoReplyReplyNotifierProvider._(argument: (
        vid,
        parentVcid,
        replyType,
      ), from: this);

  @override
  String toString() => r'videoReplyReplyProvider';
}

abstract class _$VideoReplyReplyNotifier
    extends $Notifier<VideoReplyReplyState> {
  late final _$args = ref.$arg as (
    int,
    int,
    ReplyType,
  );
  int get vid => _$args.$1;
  int get parentVcid => _$args.$2;
  ReplyType get replyType => _$args.$3;

  VideoReplyReplyState build(
    int vid,
    int parentVcid,
    ReplyType replyType,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<VideoReplyReplyState, VideoReplyReplyState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<VideoReplyReplyState, VideoReplyReplyState>,
        VideoReplyReplyState,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args.$1,
              _$args.$2,
              _$args.$3,
            ));
  }
}
