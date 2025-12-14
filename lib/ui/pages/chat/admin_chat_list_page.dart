import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/admin_chat_list_controller.dart';
import 'chat_page.dart';

class AdminChatListPage extends StatelessWidget {
  const AdminChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AdminChatListController());

    return Scaffold(
      appBar: AppBar(title: const Text('Chat User')),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.threads.isEmpty) {
          return const Center(child: Text('Belum ada chat'));
        }
        return ListView.builder(
          itemCount: c.threads.length,
          itemBuilder: (_, i) {
            final t = c.threads[i];
            final unread = c.unreadCounts[t.id] ?? 0;
            return ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: Text('User ${t.userId.substring(0, 8)}'),
              subtitle: Text(t.createdAt.toLocal().toString()),
              trailing: unread > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '$unread',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    )
                  : null,
              onTap: () {
                // buka chat detail sebagai admin dengan chatId specific
                Get.to(() => const ChatPage(), arguments: {'chatId': t.id});
              },
            );
          },
        );
      }),
    );
  }
}
