class TaskModel {
  String id;
  String date;
  String time;
  String text;
  bool checked;
  bool reminder;
  String? reminderTime;
  String? taskTimestamp;

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
      'taskTimestamp': taskTimestamp,
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
      taskTimestamp: map['taskTimestamp'],
    );
  }

  // Add copyWith for easier updates
  TaskModel copyWith({
    String? id,
    String? date,
    String? time,
    String? text,
    bool? checked,
    bool? reminder,
    String? reminderTime,
    String? taskTimestamp,
  }) {
    return TaskModel(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      text: text ?? this.text,
      checked: checked ?? this.checked,
      reminder: reminder ?? this.reminder,
      reminderTime: reminderTime ?? this.reminderTime,
      taskTimestamp: taskTimestamp ?? this.taskTimestamp,
    );
  }
}
