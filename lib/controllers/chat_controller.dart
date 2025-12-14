import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/chat_message_model.dart';
import '../data/models/chat_thread_model.dart';
import '../data/services/chat_service.dart';
import 'auth_controller.dart';

class ChatController extends GetxController {
  final ChatService _service = ChatService();
  final AuthController _auth = Get.find<AuthController>();
  final SupabaseClient _client = Supabase.instance.client;

  final Rx<ChatThread?> thread = Rx<ChatThread?>(null);
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxString inputText = ''.obs;
  final TextEditingController textCtrl = TextEditingController();
  final RxInt unreadCount = 0.obs;
  final RxBool autoScrollPending = false.obs;

  StreamSubscription<dynamic>? _sub;

  @override
  void onInit() {
    super.onInit();
    _initThread();
  }

  @override
  void onClose() {
    _sub?.cancel();
    textCtrl.dispose();
    super.onClose();
  }

  Future<void> _initThread() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    isLoading.value = true;
    try {
      ChatThread? th;
      final args = Get.arguments;
      final chatIdArg = (args is Map) ? args['chatId'] as String? : null;
      if (_auth.isAdmin && chatIdArg != null) {
        th = await _service.fetchThreadById(chatIdArg);
      } else {
        th = await _service.ensureThreadForUser(user.id);
      }
      if (th == null) return;
      thread.value = th;
      await _loadMessages();
      _listen(th.id);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadMessages() async {
    final th = thread.value;
    if (th == null) return;
    final data = await _service.fetchMessages(th.id);
    // simpan urut paling lama -> terbaru (untuk ditampilkan lama di atas)
    messages.assignAll(data);
    autoScrollPending.value = true;
    await _markRead();
    _computeUnread();
  }

  void _listen(String chatId) {
    _sub?.cancel();
    _sub = _service.subscribeMessages(chatId, (msgs) {
      // realtime: terima data urut lama -> baru
      messages.assignAll(msgs);
      autoScrollPending.value = true;
      _markRead();
      _computeUnread();
    });
  }

  void _computeUnread() {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) return;
    final count =
        messages.where((m) => m.senderId != currentUserId && !m.isRead).length;
    unreadCount.value = count;
  }

  Future<void> _markRead() async {
    final th = thread.value;
    final currentUserId = _client.auth.currentUser?.id;
    if (th == null || currentUserId == null) return;
    await _service.markRead(chatId: th.id, currentUserId: currentUserId);
  }

  Future<void> sendMessage() async {
    final txt = inputText.value.trim();
    if (txt.isEmpty) return;
    final th = thread.value;
    final user = _client.auth.currentUser;
    if (th == null || user == null) return;

    inputText.value = '';
    textCtrl.clear();
    final notifyType = _auth.isAdmin ? 'chat_user' : 'chat_admin';
    await _service.sendMessage(
      chatId: th.id,
      senderId: user.id,
      text: txt,
      notifyType: notifyType,
    );
  }
}
