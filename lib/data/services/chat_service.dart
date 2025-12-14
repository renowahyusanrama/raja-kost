import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat_thread_model.dart';
import '../models/chat_message_model.dart';

class ChatService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ChatThread> ensureThreadForUser(String userId) async {
    final existing = await _client
        .from('chat_threads')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (existing != null) {
      return ChatThread.fromMap(Map<String, dynamic>.from(existing));
    }

    final inserted = await _client
        .from('chat_threads')
        .insert({'user_id': userId})
        .select()
        .single();
    return ChatThread.fromMap(Map<String, dynamic>.from(inserted));
  }

  Future<List<ChatThread>> fetchThreadsForAdmin() async {
    final resp = await _client
        .from('chat_threads')
        .select()
        .order('created_at', ascending: false);
    return (resp as List<dynamic>)
        .map((e) => ChatThread.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ChatThread?> fetchThreadById(String chatId) async {
    final data = await _client
        .from('chat_threads')
        .select()
        .eq('id', chatId)
        .maybeSingle();
    if (data == null) return null;
    return ChatThread.fromMap(Map<String, dynamic>.from(data));
  }

  Future<List<ChatMessage>> fetchMessages(String chatId) async {
    final resp = await _client
        .from('chat_messages')
        .select()
        .eq('chat_id', chatId)
        .order('created_at');
    return (resp as List<dynamic>)
        .map((e) => ChatMessage.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String? notifyType, // 'chat_user' | 'chat_admin' | null
  }) async {
    await _client.from('chat_messages').insert({
      'chat_id': chatId,
      'sender_id': senderId,
      'text': text,
    });

    // Trigger notif via Edge Function (report-notifier)
    if (notifyType != null) {
      try {
        await _client.functions.invoke(
          'report-notifier',
          body: {'type': notifyType, 'chatId': chatId, 'text': text},
        );
      } catch (_) {
        // jangan blokir jika notif gagal
      }
    }
  }

  StreamSubscription<SupabaseStreamEvent> subscribeMessages(
    String chatId,
    void Function(List<ChatMessage>) onData,
  ) {
    return _client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at')
        .listen((rows) {
          final msgs = rows
              .map((e) => ChatMessage.fromMap(Map<String, dynamic>.from(e)))
              .toList();
          onData(msgs);
        });
  }
}
