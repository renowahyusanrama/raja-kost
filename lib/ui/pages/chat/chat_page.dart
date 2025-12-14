import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../controllers/chat_controller.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  static final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ChatController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final unread = c.unreadCount.value;
          return Row(
            children: [
              const Text('Chat dengan Admin'),
              if (unread > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unread',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ]
            ],
          );
        }),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final msgs = c.messages;
                if (msgs.isEmpty) {
                  return const Center(child: Text('Belum ada pesan'));
                }
                final currentUserId =
                    Supabase.instance.client.auth.currentUser?.id;
                return NotificationListener<SizeChangedLayoutNotification>(
                  onNotification: (_) {
                    if (c.autoScrollPending.value &&
                        _scrollController.hasClients) {
                      Future.microtask(() {
                        final maxExtent =
                            _scrollController.position.maxScrollExtent;
                        _scrollController.jumpTo(maxExtent);
                        c.autoScrollPending.value = false;
                      });
                    }
                    return true;
                  },
                  child: SizeChangedLayoutNotifier(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: msgs.length,
                      itemBuilder: (_, i) {
                        final m = msgs[i];
                        final isMe = m.senderId == currentUserId;
                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? Colors.blue.withOpacity(0.12)
                                  : Colors.grey.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(m.text),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom),
              child: _InputBar(controller: c),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller});
  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Tulis pesan...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              controller: controller.textCtrl,
              onChanged: (v) => controller.inputText.value = v,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: controller.sendMessage,
          ),
        ],
      ),
    );
  }
}
