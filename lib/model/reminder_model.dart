class ReminderModel {
  final String id;
  final String taskId;
  final String title;
  final String time;
  final String date;

  ReminderModel({
    required this.id,
    required this.taskId,
    required this.title,
    required this.time,
    required this.date,
  });

  // ✅ UNCOMMENTED & FIXED
  Map<String, dynamic> toMap() {
    return {'taskId': taskId, 'title': title, 'time': time, 'date': date};
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map, String docId) {
    return ReminderModel(
      id: docId,
      taskId: map['taskId'] ?? '',
      title: map['title'] ?? '',
      time: map['time'] ?? '',
      date: map['date'] ?? '',
    );
  }
}
