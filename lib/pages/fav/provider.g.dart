// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FavNotifier)
final favProvider = FavNotifierProvider._();

final class FavNotifierProvider
    extends $NotifierProvider<FavNotifier, FavState> {
  FavNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'favProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$favNotifierHash();

  @$internal
  @override
  FavNotifier create() => FavNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavState>(value),
    );
  }
}

String _$favNotifierHash() => r'3d6e2de21232a57f437320b36b723cd0118c1100';

abstract class _$FavNotifier extends $Notifier<FavState> {
  FavState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FavState, FavState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<FavState, FavState>, FavState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
