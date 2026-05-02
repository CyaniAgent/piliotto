// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RankNotifier)
final rankProvider = RankNotifierProvider._();

final class RankNotifierProvider
    extends $NotifierProvider<RankNotifier, RankState> {
  RankNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'rankProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$rankNotifierHash();

  @$internal
  @override
  RankNotifier create() => RankNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RankState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RankState>(value),
    );
  }
}

String _$rankNotifierHash() => r'aa1bb78e3288cb5c195e3a3b81d18de927deca1b';

abstract class _$RankNotifier extends $Notifier<RankState> {
  RankState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RankState, RankState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<RankState, RankState>, RankState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
