// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FollowNotifier)
final followProvider = FollowNotifierProvider._();

final class FollowNotifierProvider
    extends $NotifierProvider<FollowNotifier, FollowState> {
  FollowNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'followProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$followNotifierHash();

  @$internal
  @override
  FollowNotifier create() => FollowNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FollowState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FollowState>(value),
    );
  }
}

String _$followNotifierHash() => r'fce1821281e26f20e4a7c19346a72b27b7cc3eb5';

abstract class _$FollowNotifier extends $Notifier<FollowState> {
  FollowState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FollowState, FollowState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<FollowState, FollowState>, FollowState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
