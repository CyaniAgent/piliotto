// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FavDetailNotifier)
final favDetailProvider = FavDetailNotifierProvider._();

final class FavDetailNotifierProvider
    extends $NotifierProvider<FavDetailNotifier, FavDetailState> {
  FavDetailNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'favDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$favDetailNotifierHash();

  @$internal
  @override
  FavDetailNotifier create() => FavDetailNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavDetailState>(value),
    );
  }
}

String _$favDetailNotifierHash() => r'9f3eb3b3161fe5ebed3bb260e9b22fb0de57ebd6';

abstract class _$FavDetailNotifier extends $Notifier<FavDetailState> {
  FavDetailState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FavDetailState, FavDetailState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<FavDetailState, FavDetailState>,
        FavDetailState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
