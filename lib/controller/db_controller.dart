import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/model/notification_model.dart';
import 'package:to_do_list_app/model/task_model.dart';
import 'package:to_do_list_app/model/user_model.dart';

class DbController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // === USER ===
  Future<void> createUserInFirestore(UserModel user, String uid) async {
    try {
      await _db.collection('users').doc(uid).set(user.toMap());
    } catch (e) {
      debugPrint("Error creating user DB: $e");
    }
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      return (snapshot.exists && snapshot.data() != null)
          ? UserModel.fromMap(snapshot.data()!, snapshot.id)
          : null;
    });
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // === TASKS ===
  Stream<List<TaskModel>> getUserTasks(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addTask(String uid, TaskModel task) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .add(task.toMap());
  }

  // Updated to handle both "reminder" status and "reminderTime" string
  Future<void> updateTaskStatus(
    String uid,
    String taskId,
    bool isChecked, {
    bool? reminder,
    String? reminderTime,
  }) async {
    Map<String, dynamic> data = {'checked': isChecked};

    if (reminder != null) data['reminder'] = reminder;

    // Consistent Field Name: 'reminderTime'
    if (reminderTime != null) {
      data['reminderTime'] = reminderTime;
    } else if (reminder == false) {
      data['reminderTime'] = FieldValue.delete();
    }

    await _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(taskId)
        .update(data);
  }

  Future<void> updateTask(String uid, TaskModel task) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(task.id)
        .update(task.toMap());
  }

  Future<void> deleteTask(String uid, String taskId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  // === NOTIFICATIONS ===
  Future<void> addNotification(
    String uid,
    NotificationModel notification,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .add(notification.toMap());
  }

  Stream<List<NotificationModel>> getUserNotifications(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('date', descending: true) // Sort by newest
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> deleteNotification(String uid, String notificationId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }
}
