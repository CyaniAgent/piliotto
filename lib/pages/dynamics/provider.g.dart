// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DynamicsNotifier)
final dynamicsProvider = DynamicsNotifierProvider._();

final class DynamicsNotifierProvider
    extends $NotifierProvider<DynamicsNotifier, DynamicsState> {
  DynamicsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dynamicsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dynamicsNotifierHash();

  @$internal
  @override
  DynamicsNotifier create() => DynamicsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DynamicsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DynamicsState>(value),
    );
  }
}

String _$dynamicsNotifierHash() => r'5c1073dfd326ed80ccfdb2d28963ad610044a76a';

abstract class _$DynamicsNotifier extends $Notifier<DynamicsState> {
  DynamicsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DynamicsState, DynamicsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<DynamicsState, DynamicsState>,
        DynamicsState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
