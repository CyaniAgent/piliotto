// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MemberArchiveNotifier)
final memberArchiveProvider = MemberArchiveNotifierProvider._();

final class MemberArchiveNotifierProvider
    extends $NotifierProvider<MemberArchiveNotifier, MemberArchiveState> {
  MemberArchiveNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'memberArchiveProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$memberArchiveNotifierHash();

  @$internal
  @override
  MemberArchiveNotifier create() => MemberArchiveNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberArchiveState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberArchiveState>(value),
    );
  }
}

String _$memberArchiveNotifierHash() =>
    r'25cb551d92efce2c4717f0a0a75612ee057a7271';

abstract class _$MemberArchiveNotifier extends $Notifier<MemberArchiveState> {
  MemberArchiveState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MemberArchiveState, MemberArchiveState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<MemberArchiveState, MemberArchiveState>,
        MemberArchiveState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
