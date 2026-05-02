// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MessageListNotifier)
final messageListProvider = MessageListNotifierProvider._();

final class MessageListNotifierProvider
    extends $NotifierProvider<MessageListNotifier, MessageListState> {
  MessageListNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'messageListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$messageListNotifierHash();

  @$internal
  @override
  MessageListNotifier create() => MessageListNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MessageListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MessageListState>(value),
    );
  }
}

String _$messageListNotifierHash() =>
    r'8ea233800e54200e1f4028bc14b32d2e4818eebc';

abstract class _$MessageListNotifier extends $Notifier<MessageListState> {
  MessageListState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MessageListState, MessageListState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<MessageListState, MessageListState>,
        MessageListState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
