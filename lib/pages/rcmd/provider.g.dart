// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RcmdNotifier)
final rcmdProvider = RcmdNotifierProvider._();

final class RcmdNotifierProvider
    extends $NotifierProvider<RcmdNotifier, RcmdState> {
  RcmdNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'rcmdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$rcmdNotifierHash();

  @$internal
  @override
  RcmdNotifier create() => RcmdNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RcmdState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RcmdState>(value),
    );
  }
}

String _$rcmdNotifierHash() => r'814c72cc0a30834765a890eca9ec5772d188f0b0';

abstract class _$RcmdNotifier extends $Notifier<RcmdState> {
  RcmdState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RcmdState, RcmdState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<RcmdState, RcmdState>, RcmdState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
