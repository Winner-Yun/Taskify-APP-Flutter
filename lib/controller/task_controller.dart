import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list_app/controller/db_controller.dart';
import 'package:to_do_list_app/model/notification_model.dart';
import 'package:to_do_list_app/model/task_model.dart';
import 'package:to_do_list_app/services/notification_service.dart';

class TaskController extends GetxController {
  final DbController dbController = Get.find<DbController>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxList<TaskModel> tasks = <TaskModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    String? uid = _auth.currentUser?.uid;
    if (uid != null) {
      tasks.bindStream(dbController.getUserTasks(uid));
    }

    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        tasks.bindStream(dbController.getUserTasks(user.uid));
      } else {
        tasks.clear();
      }
    });
  }

  // ================= ACTIONS =================

  List<TaskModel> getTasksByDate(String selectedDate) {
    return tasks.where((task) => task.date == selectedDate).toList();
  }

  void addTask(TaskModel task) {
    String? uid = _auth.currentUser?.uid;
    if (uid != null) dbController.addTask(uid, task);
  }

  void toggleTaskChecked(TaskModel task) {
    String? uid = _auth.currentUser?.uid;
    if (uid != null && task.id.isNotEmpty) {
      dbController.updateTaskStatus(uid, task.id, !task.checked);
    }
  }

  void deleteTask(String taskId) {
    String? uid = _auth.currentUser?.uid;
    if (uid != null) dbController.deleteTask(uid, taskId);
  }

  void updateTask(TaskModel task) {
    String? uid = _auth.currentUser?.uid;
    if (uid != null && task.id.isNotEmpty) {
      dbController.updateTask(uid, task);
      Get.back();
    }
  }

  // ================= REMINDER LOGIC (FIXED) =================
  void addReminder(TaskModel task) async {
    String? uid = _auth.currentUser?.uid;

    if (uid != null && task.id.isNotEmpty) {
      bool newReminderStatus = !task.reminder;
      String? isoReminderTime;

      if (newReminderStatus) {
        DateTime? scheduledTime;

        // 1. TRY SAFE TIMESTAMP
        if (task.taskTimestamp != null && task.taskTimestamp!.isNotEmpty) {
          scheduledTime = DateTime.tryParse(task.taskTimestamp!);
        }

        // 2. FALLBACK
        scheduledTime ??= _parseDateTimeRegex(task.date, task.time);

        // VALIDATION
        if (scheduledTime == null) {
          Get.snackbar("Error", "Could not read time: ${task.time}");
          return;
        }

        // Fix: Ensure time is in the future (add 5 seconds buffer if it's too close)
        if (scheduledTime.isBefore(DateTime.now())) {
          Get.snackbar(
            "Expired",
            "You cannot set a reminder for the past.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        // 3. SCHEDULE ALARM
        try {
          // FIX: Use .abs() to ensure positive integer for ID
          int notificationId = task.id.hashCode.abs();

          await NotificationService().scheduleNotification(
            id: notificationId,
            title: "Reminder: ${task.text}",
            body: "It's time to complete your task!",
            scheduledTime: scheduledTime,
          );
        } catch (e) {
          debugPrint("CRITICAL NOTIFICATION ERROR: $e");
          String errorMsg = e.toString();
          if (errorMsg.contains("exact_alarms_not_permitted")) {
            errorMsg =
                "Please allow 'Alarms & Reminders' in your phone settings.";
          }
          Get.snackbar(
            "Notification Failed",
            errorMsg,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
          return;
        }

        // 4. ADD HISTORY (CRITICAL FIX HERE)
        // We now use 'scheduledTime' for the date, NOT DateTime.now()
        NotificationModel newNotif = NotificationModel(
          id: '',
          title: "Reminder Set",
          // Detailed message including the date
          message:
              "Reminder set for ${task.text} at ${DateFormat('MMM d, h:mm a').format(scheduledTime)}",
          // IMPORTANT: Save the FUTURE date, so the Notification Screen knows when to show it
          date: DateFormat("MMM d, yyyy").format(scheduledTime),
        );
        dbController.addNotification(uid, newNotif);

        isoReminderTime = scheduledTime.toIso8601String();
      } else {
        // Cancel logic
        await NotificationService().cancelNotification(task.id.hashCode.abs());
      }

      // 5. UPDATE DB
      dbController.updateTaskStatus(
        uid,
        task.id,
        task.checked,
        reminder: newReminderStatus,
        reminderTime: isoReminderTime,
      );

      Get.snackbar(
        "Reminder",
        newReminderStatus ? "Reminder Saved!" : "Reminder Removed",
        backgroundColor: newReminderStatus ? Colors.amber : Colors.grey,
        colorText: Colors.white,
      );
    }
  }

  // ================= HELPER METHODS =================
  DateTime? _parseDateTimeRegex(String dateStr, String timeStr) {
    try {
      RegExp yearReg = RegExp(r'20\d{2}');
      var yearMatch = yearReg.firstMatch(dateStr);
      int year = yearMatch != null
          ? int.parse(yearMatch.group(0)!)
          : DateTime.now().year;

      int month = 1;
      List<String> months = [
        "jan",
        "feb",
        "mar",
        "apr",
        "may",
        "jun",
        "jul",
        "aug",
        "sep",
        "oct",
        "nov",
        "dec",
      ];
      String lower = dateStr.toLowerCase();
      for (int i = 0; i < months.length; i++) {
        if (lower.contains(months[i])) {
          month = i + 1;
          break;
        }
      }

      RegExp dayReg = RegExp(r'\b\d{1,2}\b');
      String noYearDate = dateStr.replaceAll(year.toString(), '');
      var dayMatch = dayReg.firstMatch(noYearDate);
      int day = dayMatch != null ? int.parse(dayMatch.group(0)!) : 1;

      String cleanTime = timeStr.replaceAll(RegExp(r'[^0-9:]'), '');
      List<String> parts = cleanTime.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      bool isPm = timeStr.toLowerCase().contains("pm");
      if (isPm && hour < 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      try {
        return DateFormat(
          "MMM d, yyyy h:mm a",
          "en_US",
        ).parse("$dateStr $timeStr");
      } catch (_) {
        return null;
      }
    }
  }
}
