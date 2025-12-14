class ChatThread {
  final String id;
  final String userId;
  final DateTime createdAt;

  ChatThread({
    required this.id,
    required this.userId,
    required this.createdAt,
  });

  factory ChatThread.fromMap(Map<String, dynamic> map) {
    return ChatThread(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
