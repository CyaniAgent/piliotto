// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WebviewNotifier)
final webviewProvider = WebviewNotifierProvider._();

final class WebviewNotifierProvider
    extends $NotifierProvider<WebviewNotifier, WebviewState> {
  WebviewNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'webviewProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$webviewNotifierHash();

  @$internal
  @override
  WebviewNotifier create() => WebviewNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WebviewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WebviewState>(value),
    );
  }
}

String _$webviewNotifierHash() => r'725e0550be2526972b7f2953281bab519578b456';

abstract class _$WebviewNotifier extends $Notifier<WebviewState> {
  WebviewState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<WebviewState, WebviewState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<WebviewState, WebviewState>,
        WebviewState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
