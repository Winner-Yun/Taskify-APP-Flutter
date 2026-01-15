class NotificationModel {
  final String id;
  final String title;
  final String date;
  final String message;

  NotificationModel({
    required this.id,
    required this.title,
    required this.date,
    required this.message,
  });

  // ✅ UNCOMMENTED & FIXED
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'message': message,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    return NotificationModel(
      id: docId,
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      message: map['message'] ?? '',
    );
  }
}