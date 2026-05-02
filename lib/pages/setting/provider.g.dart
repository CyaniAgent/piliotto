// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SettingNotifier)
final settingProvider = SettingNotifierProvider._();

final class SettingNotifierProvider
    extends $NotifierProvider<SettingNotifier, SettingState> {
  SettingNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'settingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$settingNotifierHash();

  @$internal
  @override
  SettingNotifier create() => SettingNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingState>(value),
    );
  }
}

String _$settingNotifierHash() => r'177b0a6e25a8421e2a5cf4977f7dc7d871f5180a';

abstract class _$SettingNotifier extends $Notifier<SettingState> {
  SettingState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SettingState, SettingState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SettingState, SettingState>,
        SettingState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ColorSelectNotifier)
final colorSelectProvider = ColorSelectNotifierProvider._();

final class ColorSelectNotifierProvider
    extends $NotifierProvider<ColorSelectNotifier, ColorSelectState> {
  ColorSelectNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'colorSelectProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$colorSelectNotifierHash();

  @$internal
  @override
  ColorSelectNotifier create() => ColorSelectNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ColorSelectState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ColorSelectState>(value),
    );
  }
}

String _$colorSelectNotifierHash() =>
    r'f4f3c45630b478fe9952288c661e8a0b7dd6e3cf';

abstract class _$ColorSelectNotifier extends $Notifier<ColorSelectState> {
  ColorSelectState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ColorSelectState, ColorSelectState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ColorSelectState, ColorSelectState>,
        ColorSelectState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
