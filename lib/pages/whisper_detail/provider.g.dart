// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WhisperDetailNotifier)
final whisperDetailProvider = WhisperDetailNotifierProvider._();

final class WhisperDetailNotifierProvider
    extends $NotifierProvider<WhisperDetailNotifier, WhisperDetailState> {
  WhisperDetailNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'whisperDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$whisperDetailNotifierHash();

  @$internal
  @override
  WhisperDetailNotifier create() => WhisperDetailNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WhisperDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WhisperDetailState>(value),
    );
  }
}

String _$whisperDetailNotifierHash() =>
    r'6f7ee85af790b3b1fb8c29d8021dabfbe3387215';

abstract class _$WhisperDetailNotifier extends $Notifier<WhisperDetailState> {
  WhisperDetailState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<WhisperDetailState, WhisperDetailState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<WhisperDetailState, WhisperDetailState>,
        WhisperDetailState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
