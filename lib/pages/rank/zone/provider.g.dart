// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ZoneNotifier)
final zoneProvider = ZoneNotifierProvider._();

final class ZoneNotifierProvider
    extends $NotifierProvider<ZoneNotifier, ZoneState> {
  ZoneNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'zoneProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$zoneNotifierHash();

  @$internal
  @override
  ZoneNotifier create() => ZoneNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ZoneState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ZoneState>(value),
    );
  }
}

String _$zoneNotifierHash() => r'3fb7ef4285337ac914a4d8ad2cc8161393fc34e9';

abstract class _$ZoneNotifier extends $Notifier<ZoneState> {
  ZoneState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ZoneState, ZoneState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ZoneState, ZoneState>, ZoneState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
