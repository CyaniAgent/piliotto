// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RelatedNotifier)
final relatedProvider = RelatedNotifierProvider._();

final class RelatedNotifierProvider
    extends $NotifierProvider<RelatedNotifier, RelatedState> {
  RelatedNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'relatedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$relatedNotifierHash();

  @$internal
  @override
  RelatedNotifier create() => RelatedNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RelatedState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RelatedState>(value),
    );
  }
}

String _$relatedNotifierHash() => r'774ea69b08736ffa65c425dec02ed8fad526bdc1';

abstract class _$RelatedNotifier extends $Notifier<RelatedState> {
  RelatedState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RelatedState, RelatedState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<RelatedState, RelatedState>,
        RelatedState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
