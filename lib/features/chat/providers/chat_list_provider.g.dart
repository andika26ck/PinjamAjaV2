// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$conversationListHash() => r'0c48d6d36d80880a168b00e14c02d100e7ec2a1d';

/// Daftar percakapan (RPC get_conversations) yang auto-refresh saat ada
/// pesan baru lewat Supabase Realtime.
///
/// Copied from [ConversationList].
@ProviderFor(ConversationList)
final conversationListProvider = AutoDisposeAsyncNotifierProvider<
    ConversationList, List<Conversation>>.internal(
  ConversationList.new,
  name: r'conversationListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$conversationListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ConversationList = AutoDisposeAsyncNotifier<List<Conversation>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
