// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MemberNotifier)
final memberProvider = MemberNotifierFamily._();

final class MemberNotifierProvider
    extends $NotifierProvider<MemberNotifier, MemberState> {
  MemberNotifierProvider._(
      {required MemberNotifierFamily super.from, required int super.argument})
      : super(
          retry: null,
          name: r'memberProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$memberNotifierHash();

  @override
  String toString() {
    return r'memberProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MemberNotifier create() => MemberNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MemberNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberNotifierHash() => r'a404bdcbfa1a111333c2d80965c986d75fe8de3c';

final class MemberNotifierFamily extends $Family
    with
        $ClassFamilyOverride<MemberNotifier, MemberState, MemberState,
            MemberState, int> {
  MemberNotifierFamily._()
      : super(
          retry: null,
          name: r'memberProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  MemberNotifierProvider call(
    int mid,
  ) =>
      MemberNotifierProvider._(argument: mid, from: this);

  @override
  String toString() => r'memberProvider';
}

abstract class _$MemberNotifier extends $Notifier<MemberState> {
  late final _$args = ref.$arg as int;
  int get mid => _$args;

  MemberState build(
    int mid,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MemberState, MemberState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<MemberState, MemberState>, MemberState, Object?, Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}

@ProviderFor(MemberArchiveNotifier)
final memberArchiveProvider = MemberArchiveNotifierFamily._();

final class MemberArchiveNotifierProvider
    extends $NotifierProvider<MemberArchiveNotifier, List<VListItemModel>> {
  MemberArchiveNotifierProvider._(
      {required MemberArchiveNotifierFamily super.from,
      required int super.argument})
      : super(
          retry: null,
          name: r'memberArchiveProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$memberArchiveNotifierHash();

  @override
  String toString() {
    return r'memberArchiveProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MemberArchiveNotifier create() => MemberArchiveNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<VListItemModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<VListItemModel>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MemberArchiveNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberArchiveNotifierHash() =>
    r'7a954bc6a7b7f08da4c653d8b41f347f3de3dfb5';

final class MemberArchiveNotifierFamily extends $Family
    with
        $ClassFamilyOverride<MemberArchiveNotifier, List<VListItemModel>,
            List<VListItemModel>, List<VListItemModel>, int> {
  MemberArchiveNotifierFamily._()
      : super(
          retry: null,
          name: r'memberArchiveProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  MemberArchiveNotifierProvider call(
    int mid,
  ) =>
      MemberArchiveNotifierProvider._(argument: mid, from: this);

  @override
  String toString() => r'memberArchiveProvider';
}

abstract class _$MemberArchiveNotifier extends $Notifier<List<VListItemModel>> {
  late final _$args = ref.$arg as int;
  int get mid => _$args;

  List<VListItemModel> build(
    int mid,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<VListItemModel>, List<VListItemModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<VListItemModel>, List<VListItemModel>>,
        List<VListItemModel>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
