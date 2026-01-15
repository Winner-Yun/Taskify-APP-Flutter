class TaskModel {
  final String id;
  final String date;
  final String time;
  final String text;
  final bool checked;
  final bool reminder;
  final String? reminderTime;
  final String? taskTimestamp; // <--- This exists, but was ignored below

  TaskModel({
    required this.id,
    required this.date,
    required this.time,
    required this.text,
    required this.checked,
    required this.reminder,
    this.reminderTime,
    this.taskTimestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'time': time,
      'text': text,
      'checked': checked,
      'reminder': reminder,
      'reminderTime': reminderTime,
      'taskTimestamp': taskTimestamp, // <--- ADD THIS LINE
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map, String docId) {
    return TaskModel(
      id: docId,
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      text: map['text'] ?? '',
      checked: map['checked'] ?? false,
      reminder: map['reminder'] ?? false,
      reminderTime: map['reminderTime'],
      taskTimestamp: map['taskTimestamp'], // <--- ADD THIS LINE
    );
  }
}
