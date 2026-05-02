// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MessageNotifier)
final messageProvider = MessageNotifierProvider._();

final class MessageNotifierProvider
    extends $NotifierProvider<MessageNotifier, MessageState> {
  MessageNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'messageProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$messageNotifierHash();

  @$internal
  @override
  MessageNotifier create() => MessageNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MessageState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MessageState>(value),
    );
  }
}

String _$messageNotifierHash() => r'3b9392e539bc50282d979928a13938d38f158e67';

abstract class _$MessageNotifier extends $Notifier<MessageState> {
  MessageState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MessageState, MessageState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<MessageState, MessageState>,
        MessageState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ChatDetailNotifier)
final chatDetailProvider = ChatDetailNotifierFamily._();

final class ChatDetailNotifierProvider
    extends $NotifierProvider<ChatDetailNotifier, ChatDetailState> {
  ChatDetailNotifierProvider._(
      {required ChatDetailNotifierFamily super.from,
      required int super.argument})
      : super(
          retry: null,
          name: r'chatDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$chatDetailNotifierHash();

  @override
  String toString() {
    return r'chatDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatDetailNotifier create() => ChatDetailNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatDetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatDetailNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatDetailNotifierHash() =>
    r'715818370def8e164e8bd8f186abcc55fc9fffde';

final class ChatDetailNotifierFamily extends $Family
    with
        $ClassFamilyOverride<ChatDetailNotifier, ChatDetailState,
            ChatDetailState, ChatDetailState, int> {
  ChatDetailNotifierFamily._()
      : super(
          retry: null,
          name: r'chatDetailProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ChatDetailNotifierProvider call(
    int friendUid,
  ) =>
      ChatDetailNotifierProvider._(argument: friendUid, from: this);

  @override
  String toString() => r'chatDetailProvider';
}

abstract class _$ChatDetailNotifier extends $Notifier<ChatDetailState> {
  late final _$args = ref.$arg as int;
  int get friendUid => _$args;

  ChatDetailState build(
    int friendUid,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ChatDetailState, ChatDetailState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ChatDetailState, ChatDetailState>,
        ChatDetailState,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
