// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MediaNotifier)
final mediaProvider = MediaNotifierProvider._();

final class MediaNotifierProvider
    extends $NotifierProvider<MediaNotifier, MediaState> {
  MediaNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mediaProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mediaNotifierHash();

  @$internal
  @override
  MediaNotifier create() => MediaNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaState>(value),
    );
  }
}

String _$mediaNotifierHash() => r'9a100e58cde1d4b4ae15dc165372fa2989fae2ac';

abstract class _$MediaNotifier extends $Notifier<MediaState> {
  MediaState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MediaState, MediaState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<MediaState, MediaState>, MediaState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
