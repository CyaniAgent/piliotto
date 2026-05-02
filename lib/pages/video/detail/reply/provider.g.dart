// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VideoReplyNotifier)
final videoReplyProvider = VideoReplyNotifierFamily._();

final class VideoReplyNotifierProvider
    extends $NotifierProvider<VideoReplyNotifier, VideoReplyState> {
  VideoReplyNotifierProvider._(
      {required VideoReplyNotifierFamily super.from,
      required int super.argument})
      : super(
          retry: null,
          name: r'videoReplyProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$videoReplyNotifierHash();

  @override
  String toString() {
    return r'videoReplyProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  VideoReplyNotifier create() => VideoReplyNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VideoReplyState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VideoReplyState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VideoReplyNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$videoReplyNotifierHash() =>
    r'52451ce879be1bf48f99c3a5ca51580f64f3d91f';

final class VideoReplyNotifierFamily extends $Family
    with
        $ClassFamilyOverride<VideoReplyNotifier, VideoReplyState,
            VideoReplyState, VideoReplyState, int> {
  VideoReplyNotifierFamily._()
      : super(
          retry: null,
          name: r'videoReplyProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  VideoReplyNotifierProvider call(
    int vid,
  ) =>
      VideoReplyNotifierProvider._(argument: vid, from: this);

  @override
  String toString() => r'videoReplyProvider';
}

abstract class _$VideoReplyNotifier extends $Notifier<VideoReplyState> {
  late final _$args = ref.$arg as int;
  int get vid => _$args;

  VideoReplyState build(
    int vid,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<VideoReplyState, VideoReplyState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<VideoReplyState, VideoReplyState>,
        VideoReplyState,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
