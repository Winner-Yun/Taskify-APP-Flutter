import 'package:to_do_list_app/data/models/notification_model.dart';
import 'package:to_do_list_app/data/models/reminder_model.dart';
import 'package:to_do_list_app/data/models/task_model.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String createdAt;
  final String profileImage;

  final List<TaskModel> tasks;
  final List<NotificationModel> notifications;
  final List<ReminderModel> reminders;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.createdAt,
    required this.profileImage,
    required this.tasks,
    required this.notifications,
    required this.reminders,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'createdAt': createdAt,
      'profileImage': profileImage,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      id: docId, // Use the ID passed from Firestore
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      createdAt: map['createdAt'] ?? '',
      profileImage: map['profileImage'] ?? '',
      
      tasks: map['tasks'] != null
          ? List<TaskModel>.from((map['tasks'] as List<dynamic>).map((x) => TaskModel.fromMap(x, x['id'] ?? '')))
          : [],
      notifications: map['notifications'] != null
          ? List<NotificationModel>.from((map['notifications'] as List<dynamic>).map((x) => NotificationModel.fromMap(x, x['id'] ?? '')))
          : [],
      reminders: map['reminders'] != null
          ? List<ReminderModel>.from((map['reminders'] as List<dynamic>).map((x) => ReminderModel.fromMap(x, x['id'] ?? '')))
          : [],
    );
  }
}
