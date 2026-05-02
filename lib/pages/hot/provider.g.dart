// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HotNotifier)
final hotProvider = HotNotifierProvider._();

final class HotNotifierProvider
    extends $NotifierProvider<HotNotifier, HotState> {
  HotNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'hotProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$hotNotifierHash();

  @$internal
  @override
  HotNotifier create() => HotNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HotState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HotState>(value),
    );
  }
}

String _$hotNotifierHash() => r'2eb3d50d326c2ff4161edc1a4a203ee97c7e9cda';

abstract class _$HotNotifier extends $Notifier<HotState> {
  HotState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<HotState, HotState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<HotState, HotState>, HotState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
