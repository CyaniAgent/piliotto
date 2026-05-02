// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VideoDetailNotifier)
final videoDetailProvider = VideoDetailNotifierProvider._();

final class VideoDetailNotifierProvider
    extends $NotifierProvider<VideoDetailNotifier, VideoDetailState> {
  VideoDetailNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'videoDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$videoDetailNotifierHash();

  @$internal
  @override
  VideoDetailNotifier create() => VideoDetailNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VideoDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VideoDetailState>(value),
    );
  }
}

String _$videoDetailNotifierHash() =>
    r'4489af73426ecc2e75cba337fdd4b4e48e053e99';

abstract class _$VideoDetailNotifier extends $Notifier<VideoDetailState> {
  VideoDetailState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<VideoDetailState, VideoDetailState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<VideoDetailState, VideoDetailState>,
        VideoDetailState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
