class NotificationModel {
  String id;
  String taskId;
  String title;
  String message;
  String date;
  bool isAlert; // NEW: Controls visibility
  String? hiddenDate;

  NotificationModel({
    required this.id,
    this.taskId = '',
    required this.title,
    required this.message,
    required this.date,
    this.isAlert = false,
    this.hiddenDate,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      taskId: map['taskId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      date: map['date'] ?? '',
      hiddenDate: map['hiddenDate'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'title': title,
      'message': message,
      'date': date,
      'hiddenDate': hiddenDate,
    };
  }
}
