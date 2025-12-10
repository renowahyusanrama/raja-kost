class ReportModel {
  ReportModel({
    required this.id,
    required this.createdAt,
    required this.subject,
    required this.message,
    required this.status,
    this.userId,
    this.userEmail,
    this.category,
    this.adminNote,
  });

  final String id;
  final DateTime createdAt;
  final String subject;
  final String message;
  final String status; // open | resolved | closed (sesuaikan dengan DB)
  final String? userId;
  final String? userEmail;
  final String? category;
  final String? adminNote;

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      subject: map['subject'] as String? ?? '',
      message: map['message'] as String? ?? '',
      status: map['status'] as String? ?? 'open',
      userId: map['user_id'] as String?,
      userEmail: map['user_email'] as String?,
      category: map['category'] as String?,
      adminNote: map['admin_note'] as String?,
    );
  }
}
