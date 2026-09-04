import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list_app/data/models/notification_model.dart';
import 'package:to_do_list_app/data/models/task_model.dart';
import 'package:to_do_list_app/data/models/user_model.dart';

class DbController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  TaskModel _checkAndResetTask(
    Map<String, dynamic> data,
    String docId,
    DocumentReference ref,
  ) {
    if (data['checked'] == true) {
      String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String? lastChecked = data['lastCheckedDate'];
      String taskDate = data['date'] ?? '';

      bool shouldReset = false;

      if (taskDate == 'Daily') {
        if (lastChecked != todayStr) {
          shouldReset = true;
        }
      }
      else {
        String todayDayName = DateFormat('EEEE').format(DateTime.now());

        if (taskDate == todayDayName) {
          if (lastChecked != todayStr) {
            shouldReset = true;
          }
        }
      }

      if (shouldReset) {
        data['checked'] = false;
        ref.update({'checked': false});
      }
    }
    return TaskModel.fromMap(data, docId);
  }

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

  Future<void> updateTaskStatus(
    String uid,
    String taskId,
    bool isChecked, {
    bool? reminder,
    String? reminderTime,
  }) async {
    Map<String, dynamic> data = {'checked': isChecked};

    if (isChecked) {
      data['lastCheckedDate'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }

    if (reminder != null) data['reminder'] = reminder;

    if (reminderTime != null && reminderTime.isNotEmpty) {
      data['reminderTime'] = reminderTime;
    } else if (reminder == false ||
        (reminderTime != null && reminderTime.isEmpty)) {
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

  Stream<List<TaskModel>> getWeekRoutineTasks(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('week_routine')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => _checkAndResetTask(doc.data(), doc.id, doc.reference),
              )
              .toList(),
        );
  }

  Future<String> addWeekTask(String uid, TaskModel task) async {
    DocumentReference docRef = await _db
        .collection('users')
        .doc(uid)
        .collection('week_routine')
        .add(task.toMap());
    return docRef.id;
  }

  Future<void> updateWeekTask(String uid, TaskModel task) async {
    Map<String, dynamic> data = task.toMap();
    if (task.checked) {
      data['lastCheckedDate'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
    await _db
        .collection('users')
        .doc(uid)
        .collection('week_routine')
        .doc(task.id)
        .update(data);
  }

  Future<void> deleteWeekTask(String uid, String taskId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('week_routine')
        .doc(taskId)
        .delete();
  }

  Future<void> updateWeekTaskStatus(
    String uid,
    String taskId, {
    bool? isChecked,
    bool? reminder,
    String? reminderTime,
  }) async {
    Map<String, dynamic> data = {};
    if (isChecked != null) {
      data['checked'] = isChecked;
      if (isChecked) {
        data['lastCheckedDate'] = DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime.now());
      }
    }
    if (reminder != null) data['reminder'] = reminder;
    if (reminderTime != null && reminderTime.isNotEmpty) {
      data['reminderTime'] = reminderTime;
    } else if (reminder == false ||
        (reminderTime != null && reminderTime.isEmpty)) {
      data['reminderTime'] = FieldValue.delete();
    }

    if (data.isNotEmpty) {
      await _db
          .collection('users')
          .doc(uid)
          .collection('week_routine')
          .doc(taskId)
          .update(data);
    }
  }

  Stream<List<TaskModel>> getDayRoutineTasks(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('day_routine')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => _checkAndResetTask(doc.data(), doc.id, doc.reference),
              )
              .toList(),
        );
  }

  Future<String> addDayTask(String uid, TaskModel task) async {
    DocumentReference docRef = await _db
        .collection('users')
        .doc(uid)
        .collection('day_routine')
        .add(task.toMap());
    return docRef.id;
  }

  Future<void> updateDayTask(String uid, TaskModel task) async {
    Map<String, dynamic> data = task.toMap();
    if (task.checked) {
      data['lastCheckedDate'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
    await _db
        .collection('users')
        .doc(uid)
        .collection('day_routine')
        .doc(task.id)
        .update(data);
  }

  Future<void> deleteDayTask(String uid, String taskId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('day_routine')
        .doc(taskId)
        .delete();
  }

  Future<void> updateDayTaskStatus(
    String uid,
    String taskId, {
    bool? isChecked,
    bool? reminder,
    String? reminderTime,
  }) async {
    Map<String, dynamic> data = {};
    if (isChecked != null) {
      data['checked'] = isChecked;
      if (isChecked) {
        data['lastCheckedDate'] = DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime.now());
      }
    }
    if (reminder != null) data['reminder'] = reminder;
    if (reminderTime != null && reminderTime.isNotEmpty) {
      data['reminderTime'] = reminderTime;
    } else if (reminder == false ||
        (reminderTime != null && reminderTime.isEmpty)) {
      data['reminderTime'] = FieldValue.delete();
    }
    if (data.isNotEmpty) {
      await _db
          .collection('users')
          .doc(uid)
          .collection('day_routine')
          .doc(taskId)
          .update(data);
    }
  }

  Stream<List<TaskModel>> getSpecialRoutineTasks(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('special_routine')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<String> addSpecialTask(String uid, TaskModel task) async {
    DocumentReference docRef = await _db
        .collection('users')
        .doc(uid)
        .collection('special_routine')
        .add(task.toMap());
    return docRef.id;
  }

  Future<void> updateSpecialTask(String uid, TaskModel task) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('special_routine')
        .doc(task.id)
        .update(task.toMap());
  }

  Future<void> deleteSpecialTask(String uid, String taskId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('special_routine')
        .doc(taskId)
        .delete();
  }


  Future<void> upsertNotification(
    String uid,
    NotificationModel notification, {
    bool? resetAlert,
  }) async {
    final query = await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('taskId', isEqualTo: notification.taskId)
        .get();

    if (query.docs.isNotEmpty) {
      var docRef = query.docs.first.reference;
      Map<String, dynamic> updateData = {
        'title': notification.title,
        'message': notification.message,
        'date': notification.date,
      };

      if (resetAlert == true) {
        updateData['isAlert'] = false;

        if (notification.hiddenDate != null) {
          updateData['hiddenDate'] = notification.hiddenDate;
        } else {
          updateData['hiddenDate'] = FieldValue.delete();
        }
      }

      await docRef.update(updateData);
    } else {
      notification.isAlert = false;
      await _db
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .add(notification.toMap());
    }
  }

  Future<void> markNotificationAsAlerted(
    String uid,
    String notificationId,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'isAlert': true});
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<void> resetNotificationForNextCycle(
    String uid,
    String notificationId,
    String newDateStr,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .update({
          'isAlert': false, // Reset to pending
          'date': newDateStr,
          'hiddenDate': FieldValue.delete(),
        });
  }

  Stream<List<NotificationModel>> getUserNotifications(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

          return snapshot.docs
              .where((doc) {
                final data = doc.data();
                if (data.containsKey('hiddenDate')) {
                  return data['hiddenDate'] != todayStr;
                }
                return true;
              })
              .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> hideNotification(String uid, String notificationId) async {
    String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'hiddenDate': todayStr});
  }

  Future<void> deleteNotification(String uid, String notificationId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  Future<void> deleteNotificationByTaskId(String uid, String taskId) async {
    try {
      var snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .where('taskId', isEqualTo: taskId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint("Error deleting notification for task: $e");
    }
  }
}
