// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MemberDynamicsNotifier)
final memberDynamicsProvider = MemberDynamicsNotifierFamily._();

final class MemberDynamicsNotifierProvider
    extends $NotifierProvider<MemberDynamicsNotifier, MemberDynamicsState> {
  MemberDynamicsNotifierProvider._(
      {required MemberDynamicsNotifierFamily super.from,
      required int super.argument})
      : super(
          retry: null,
          name: r'memberDynamicsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$memberDynamicsNotifierHash();

  @override
  String toString() {
    return r'memberDynamicsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MemberDynamicsNotifier create() => MemberDynamicsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberDynamicsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberDynamicsState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MemberDynamicsNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberDynamicsNotifierHash() =>
    r'538aa44f012526f9d8b548febadceb1ba8492878';

final class MemberDynamicsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<MemberDynamicsNotifier, MemberDynamicsState,
            MemberDynamicsState, MemberDynamicsState, int> {
  MemberDynamicsNotifierFamily._()
      : super(
          retry: null,
          name: r'memberDynamicsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  MemberDynamicsNotifierProvider call(
    int mid,
  ) =>
      MemberDynamicsNotifierProvider._(argument: mid, from: this);

  @override
  String toString() => r'memberDynamicsProvider';
}

abstract class _$MemberDynamicsNotifier extends $Notifier<MemberDynamicsState> {
  late final _$args = ref.$arg as int;
  int get mid => _$args;

  MemberDynamicsState build(
    int mid,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MemberDynamicsState, MemberDynamicsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<MemberDynamicsState, MemberDynamicsState>,
        MemberDynamicsState,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
