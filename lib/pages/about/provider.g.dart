// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AboutNotifier)
final aboutProvider = AboutNotifierProvider._();

final class AboutNotifierProvider
    extends $NotifierProvider<AboutNotifier, AboutState> {
  AboutNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'aboutProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$aboutNotifierHash();

  @$internal
  @override
  AboutNotifier create() => AboutNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AboutState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AboutState>(value),
    );
  }
}

String _$aboutNotifierHash() => r'047b8998827e7ef6adb239c4fef6322afe90368c';

abstract class _$AboutNotifier extends $Notifier<AboutState> {
  AboutState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AboutState, AboutState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AboutState, AboutState>, AboutState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
