// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HistoryNotifier)
final historyProvider = HistoryNotifierProvider._();

final class HistoryNotifierProvider
    extends $NotifierProvider<HistoryNotifier, HistoryState> {
  HistoryNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'historyProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$historyNotifierHash();

  @$internal
  @override
  HistoryNotifier create() => HistoryNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HistoryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HistoryState>(value),
    );
  }
}

String _$historyNotifierHash() => r'053137d73a6c58f2b995dd80c7864eeadc41ef1d';

abstract class _$HistoryNotifier extends $Notifier<HistoryState> {
  HistoryState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<HistoryState, HistoryState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<HistoryState, HistoryState>,
        HistoryState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(isUserLoggedInForHistory)
final isUserLoggedInForHistoryProvider = IsUserLoggedInForHistoryProvider._();

final class IsUserLoggedInForHistoryProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  IsUserLoggedInForHistoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isUserLoggedInForHistoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isUserLoggedInForHistoryHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isUserLoggedInForHistory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isUserLoggedInForHistoryHash() =>
    r'a88451c9eabaf9e3954c09478343b2073443f537';
