// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'notification_model.dart';
import 'reminder_model.dart';
import 'task_model.dart';

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

  // ✅ 1. ADD "toMap" so we can save to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'createdAt': createdAt,
      'profileImage': profileImage,
      // We don't save sub-collections (tasks) here, they are saved separately
    };
  }

  // ✅ 2. FIX "fromMap" to accept (Map, String id) and handle Lists safely
  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      id: docId, // Use the ID passed from Firestore
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      createdAt: map['createdAt'] ?? '',
      profileImage: map['profileImage'] ?? '',
      
      // Handle potential nulls or wrong types for lists
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