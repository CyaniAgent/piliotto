// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DynamicDetailNotifier)
final dynamicDetailProvider = DynamicDetailNotifierFamily._();

final class DynamicDetailNotifierProvider
    extends $NotifierProvider<DynamicDetailNotifier, DynamicDetailState> {
  DynamicDetailNotifierProvider._(
      {required DynamicDetailNotifierFamily super.from,
      required int super.argument})
      : super(
          retry: null,
          name: r'dynamicDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dynamicDetailNotifierHash();

  @override
  String toString() {
    return r'dynamicDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DynamicDetailNotifier create() => DynamicDetailNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DynamicDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DynamicDetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DynamicDetailNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dynamicDetailNotifierHash() =>
    r'ac8df1a10c3a46c6a7424547a90e100a0eac7fcd';

final class DynamicDetailNotifierFamily extends $Family
    with
        $ClassFamilyOverride<DynamicDetailNotifier, DynamicDetailState,
            DynamicDetailState, DynamicDetailState, int> {
  DynamicDetailNotifierFamily._()
      : super(
          retry: null,
          name: r'dynamicDetailProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  DynamicDetailNotifierProvider call(
    int oid,
  ) =>
      DynamicDetailNotifierProvider._(argument: oid, from: this);

  @override
  String toString() => r'dynamicDetailProvider';
}

abstract class _$DynamicDetailNotifier extends $Notifier<DynamicDetailState> {
  late final _$args = ref.$arg as int;
  int get oid => _$args;

  DynamicDetailState build(
    int oid,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DynamicDetailState, DynamicDetailState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<DynamicDetailState, DynamicDetailState>,
        DynamicDetailState,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
