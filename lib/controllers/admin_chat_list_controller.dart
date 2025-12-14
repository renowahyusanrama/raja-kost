import 'dart:async';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/chat_thread_model.dart';
import '../data/services/chat_service.dart';

class AdminChatListController extends GetxController {
  final ChatService _service = ChatService();
  final SupabaseClient _client = Supabase.instance.client;

  final RxList<ChatThread> threads = <ChatThread>[].obs;
  final RxBool isLoading = false.obs;
  final RxMap<String, int> unreadCounts = <String, int>{}.obs;

  StreamSubscription<dynamic>? _sub;

  @override
  void onInit() {
    super.onInit();
    fetchThreads();
    _loadUnread();
    _listenThreads();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  Future<void> fetchThreads() async {
    isLoading.value = true;
    try {
      final data = await _service.fetchThreadsForAdmin();
      threads.assignAll(data);
      await _loadUnread();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUnread() async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) return;
    final map = await _service.fetchUnreadCounts(currentUserId);
    unreadCounts.assignAll(map);
  }

  void _listenThreads() {
    _sub = _client
        .from('chat_threads')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .listen((rows) {
          final list = rows
              .map((e) => ChatThread.fromMap(Map<String, dynamic>.from(e)))
              .toList();
          threads.assignAll(list);
          _loadUnread();
        });
  }
}
