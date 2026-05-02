// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ThemeNotifier)
final themeProvider = ThemeNotifierProvider._();

final class ThemeNotifierProvider
    extends $NotifierProvider<ThemeNotifier, AppThemeMode> {
  ThemeNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'themeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$themeNotifierHash();

  @$internal
  @override
  ThemeNotifier create() => ThemeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppThemeMode>(value),
    );
  }
}

String _$themeNotifierHash() => r'7cc38a63147aa4f6f1d8c133d99d1b7a1d65e24b';

abstract class _$ThemeNotifier extends $Notifier<AppThemeMode> {
  AppThemeMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppThemeMode, AppThemeMode>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AppThemeMode, AppThemeMode>,
        AppThemeMode,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(DynamicColorNotifier)
final dynamicColorProvider = DynamicColorNotifierProvider._();

final class DynamicColorNotifierProvider
    extends $NotifierProvider<DynamicColorNotifier, bool> {
  DynamicColorNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dynamicColorProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dynamicColorNotifierHash();

  @$internal
  @override
  DynamicColorNotifier create() => DynamicColorNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$dynamicColorNotifierHash() =>
    r'96e5179421eddbdf52739beeef01f5340ece83ce';

abstract class _$DynamicColorNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(CustomColorNotifier)
final customColorProvider = CustomColorNotifierProvider._();

final class CustomColorNotifierProvider
    extends $NotifierProvider<CustomColorNotifier, Color?> {
  CustomColorNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'customColorProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$customColorNotifierHash();

  @$internal
  @override
  CustomColorNotifier create() => CustomColorNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Color? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Color?>(value),
    );
  }
}

String _$customColorNotifierHash() =>
    r'9ff920790dff5904749c605a6dd6ea3d487dd914';

abstract class _$CustomColorNotifier extends $Notifier<Color?> {
  Color? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Color?, Color?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Color?, Color?>, Color?, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(currentThemeMode)
final currentThemeModeProvider = CurrentThemeModeProvider._();

final class CurrentThemeModeProvider
    extends $FunctionalProvider<ThemeMode, ThemeMode, ThemeMode>
    with $Provider<ThemeMode> {
  CurrentThemeModeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentThemeModeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentThemeModeHash();

  @$internal
  @override
  $ProviderElement<ThemeMode> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeMode create(Ref ref) {
    return currentThemeMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$currentThemeModeHash() => r'eb89efbf785eedbe17942b5b56d7c456626878b7';

@ProviderFor(isDarkMode)
final isDarkModeProvider = IsDarkModeProvider._();

final class IsDarkModeProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  IsDarkModeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isDarkModeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isDarkModeHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isDarkMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isDarkModeHash() => r'01f891b2ddc25745cc6740c16307497b654bb684';
