// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VideoIntroNotifier)
final videoIntroProvider = VideoIntroNotifierFamily._();

final class VideoIntroNotifierProvider
    extends $NotifierProvider<VideoIntroNotifier, VideoIntroState> {
  VideoIntroNotifierProvider._(
      {required VideoIntroNotifierFamily super.from,
      required int super.argument})
      : super(
          retry: null,
          name: r'videoIntroProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$videoIntroNotifierHash();

  @override
  String toString() {
    return r'videoIntroProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  VideoIntroNotifier create() => VideoIntroNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VideoIntroState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VideoIntroState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VideoIntroNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$videoIntroNotifierHash() =>
    r'3858dbf6af0ac82e3fc4180bc4c38222635f4ce0';

final class VideoIntroNotifierFamily extends $Family
    with
        $ClassFamilyOverride<VideoIntroNotifier, VideoIntroState,
            VideoIntroState, VideoIntroState, int> {
  VideoIntroNotifierFamily._()
      : super(
          retry: null,
          name: r'videoIntroProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  VideoIntroNotifierProvider call(
    int vid,
  ) =>
      VideoIntroNotifierProvider._(argument: vid, from: this);

  @override
  String toString() => r'videoIntroProvider';
}

abstract class _$VideoIntroNotifier extends $Notifier<VideoIntroState> {
  late final _$args = ref.$arg as int;
  int get vid => _$args;

  VideoIntroState build(
    int vid,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<VideoIntroState, VideoIntroState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<VideoIntroState, VideoIntroState>,
        VideoIntroState,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
