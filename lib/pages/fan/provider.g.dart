// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FanNotifier)
final fanProvider = FanNotifierProvider._();

final class FanNotifierProvider
    extends $NotifierProvider<FanNotifier, FanState> {
  FanNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'fanProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$fanNotifierHash();

  @$internal
  @override
  FanNotifier create() => FanNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FanState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FanState>(value),
    );
  }
}

String _$fanNotifierHash() => r'a12f2301995c5920033f374d4fec973162735be5';

abstract class _$FanNotifier extends $Notifier<FanState> {
  FanState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FanState, FanState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<FanState, FanState>, FanState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
