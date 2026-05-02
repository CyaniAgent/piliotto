// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MainAppNotifier)
final mainAppProvider = MainAppNotifierProvider._();

final class MainAppNotifierProvider
    extends $NotifierProvider<MainAppNotifier, MainAppState> {
  MainAppNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mainAppProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mainAppNotifierHash();

  @$internal
  @override
  MainAppNotifier create() => MainAppNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MainAppState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MainAppState>(value),
    );
  }
}

String _$mainAppNotifierHash() => r'76f0ab4d0e7679573f1d25afb3a799868f6445c1';

abstract class _$MainAppNotifier extends $Notifier<MainAppState> {
  MainAppState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MainAppState, MainAppState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<MainAppState, MainAppState>,
        MainAppState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
