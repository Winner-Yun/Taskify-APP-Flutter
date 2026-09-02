import 'package:firebase_auth/firebase_auth.dart';
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
  RxList<TaskModel> weekTasks = <TaskModel>[].obs;
  RxList<TaskModel> dayTasks = <TaskModel>[].obs;
  RxList<TaskModel> specialTasks = <TaskModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    String? uid = _auth.currentUser?.uid;
    if (uid != null) {
      tasks.bindStream(dbController.getUserTasks(uid));
      weekTasks.bindStream(dbController.getWeekRoutineTasks(uid));
      dayTasks.bindStream(dbController.getDayRoutineTasks(uid));
      specialTasks.bindStream(dbController.getSpecialRoutineTasks(uid));
    }

    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        tasks.bindStream(dbController.getUserTasks(user.uid));
        weekTasks.bindStream(dbController.getWeekRoutineTasks(user.uid));
        dayTasks.bindStream(dbController.getDayRoutineTasks(user.uid));
        specialTasks.bindStream(dbController.getSpecialRoutineTasks(user.uid));
      } else {
        tasks.clear();
        weekTasks.clear();
        dayTasks.clear();
        specialTasks.clear();
      }
    });
  }

  // ================= MODE SWITCH LOGIC =================
  void switchNotificationMode(int mode) async {
    await NotificationService().cancelAllNotifications();

    // 1. ALWAYS SCHEDULE SPECIAL TASKS
    for (var task in specialTasks) {
      if (task.reminder && !task.checked) {
        DateTime? scheduledTime;
        if (task.taskTimestamp != null &&
            task.taskTimestamp!.startsWith("0000")) {
          scheduledTime = _getNextAnnualInstanceFrom0000(task.taskTimestamp!);
        } else {
          scheduledTime = _parseDateTimeRegex(task.date, task.time);
        }

        if (scheduledTime != null && scheduledTime.isAfter(DateTime.now())) {
          NotificationService().scheduleNotification(
            id: task.id.hashCode.abs(),
            title: "Special: ${task.text}",
            body: "Don't forget this special event!",
            scheduledTime: scheduledTime,
            repeatMode: 3,
          );
        }
      }
    }

    // 2. SCHEDULE ACTIVE MODE TASKS
    if (mode == 2) {
      // DAILY
      for (var task in dayTasks) {
        if (task.reminder && !task.checked) {
          DateTime? scheduledTime = _getNextInstanceForDaily(task.time);
          if (scheduledTime != null) {
            NotificationService().scheduleNotification(
              id: task.id.hashCode.abs(),
              title: "Daily: ${task.text}",
              body: "Time for your daily routine!",
              scheduledTime: scheduledTime,
              repeatMode: 2,
            );
          }
        }
      }
    } else if (mode == 1) {
      // WEEKLY
      for (var task in weekTasks) {
        if (task.reminder && !task.checked) {
          DateTime? scheduledTime = _getNextInstance(task.date, task.time);
          if (scheduledTime != null) {
            NotificationService().scheduleNotification(
              id: task.id.hashCode.abs(),
              title: "Routine: ${task.text}",
              body: "It's time for your weekly routine!",
              scheduledTime: scheduledTime,
              repeatMode: 1,
            );
          }
        }
      }
    } else {
      // CALENDAR
      for (var task in tasks) {
        if (task.reminder && !task.checked) {
          DateTime? scheduledTime = _parseDateTimeRegex(task.date, task.time);
          if (scheduledTime != null && scheduledTime.isAfter(DateTime.now())) {
            NotificationService().scheduleNotification(
              id: task.id.hashCode.abs(),
              title: "Reminder: ${task.text}",
              body: "Don't forget this task!",
              scheduledTime: scheduledTime,
              repeatMode: 0,
            );
          }
        }
      }
    }
  }

  // ================= CALENDAR TASKS =================
  void toggleTaskChecked(TaskModel task) {
    String? uid = _auth.currentUser?.uid;
    if (uid != null) {
      bool newStatus = !task.checked;

      if (newStatus) {
        NotificationService().cancelNotification(task.id.hashCode.abs());
      } else if (task.reminder) {
        if (dayTasks.any((t) => t.id == task.id)) {
          _scheduleDayNotification(uid, task);
        } else if (weekTasks.any((t) => t.id == task.id)) {
          _scheduleWeekNotification(uid, task);
        } else {
          DateTime? st = _parseDateTimeRegex(task.date, task.time);
          if (st != null && st.isAfter(DateTime.now())) {
            NotificationService().scheduleNotification(
              id: task.id.hashCode.abs(),
              title: "Reminder: ${task.text}",
              body: "Don't forget this task!",
              scheduledTime: st,
              repeatMode: 0,
            );
            _updateOrAddNotification(
              uid,
              task.text,
              st,
              task.id,
              type: 0,
              forceReset: true,
            );
          }
        }
      }

      dbController.updateTaskStatus(uid, task.id, newStatus);
    }
  }

  // ================= DAY ROUTINE ACTIONS =================
  void addDayTask(TaskModel task) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;
    if (task.reminder) task.reminderTime = task.time;
    String newId = await dbController.addDayTask(uid, task);
    task.id = newId;
    if (task.reminder && !task.checked) {
      await _scheduleDayNotification(uid, task);
    }
  }

  void updateDayTask(TaskModel task) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await NotificationService().cancelNotification(task.id.hashCode.abs());

    if (task.reminder && !task.checked) {
      task.reminderTime = task.time;
      await _scheduleDayNotification(uid, task);
    } else {
      task.reminderTime = "";
      if (!task.reminder) {
        dbController.deleteNotificationByTaskId(uid, task.id);
      }
    }
    dbController.updateDayTask(uid, task);
    if (Get.currentRoute.contains('TaskHomeScreen')) Get.back();
  }

  void deleteDayTask(String taskId) {
    String? uid = _auth.currentUser?.uid;
    if (uid != null) {
      NotificationService().cancelNotification(taskId.hashCode.abs());
      dbController.deleteNotificationByTaskId(uid, taskId);
      dbController.deleteDayTask(uid, taskId);
    }
  }

  // ================= WEEK ROUTINE ACTIONS =================
  void addWeekTask(TaskModel task) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;
    if (task.reminder) {
      task.reminderTime = _calculateWeeklyReminderString(task.date, task.time);
    }
    String newId = await dbController.addWeekTask(uid, task);
    task.id = newId;
    if (task.reminder && !task.checked) {
      await _scheduleWeekNotification(uid, task);
    }
  }

  void updateWeekTask(TaskModel task) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await NotificationService().cancelNotification(task.id.hashCode.abs());

    if (task.reminder && !task.checked) {
      task.reminderTime = _calculateWeeklyReminderString(task.date, task.time);
      await _scheduleWeekNotification(uid, task);
    } else {
      task.reminderTime = "";
      if (!task.reminder) dbController.deleteNotificationByTaskId(uid, task.id);
    }
    dbController.updateWeekTask(uid, task);
    if (Get.currentRoute.contains('TaskHomeScreen')) Get.back();
  }

  void deleteWeekTask(String taskId) {
    if (_auth.currentUser?.uid != null) {
      NotificationService().cancelNotification(taskId.hashCode.abs());
      dbController.deleteNotificationByTaskId(_auth.currentUser!.uid, taskId);
      dbController.deleteWeekTask(_auth.currentUser!.uid, taskId);
    }
  }

  // ================= CALENDAR ACTIONS =================
  List<TaskModel> getTasksByDate(String selectedDate) =>
      tasks.where((task) => task.date == selectedDate).toList();
  List<TaskModel> getWeekTasksByDay(String dayName) =>
      weekTasks.where((task) => task.date == dayName).toList();

  void addTask(TaskModel task) {
    if (_auth.currentUser?.uid != null) {
      dbController.addTask(_auth.currentUser!.uid, task);
    }
  }

  void updateTask(TaskModel task) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await NotificationService().cancelNotification(task.id.hashCode.abs());

    if (task.reminder && !task.checked) {
      DateTime? st = _parseDateTimeRegex(task.date, task.time);
      if (st != null && st.isAfter(DateTime.now())) {
        NotificationService().scheduleNotification(
          id: task.id.hashCode.abs(),
          title: "Reminder: ${task.text}",
          body: "Don't forget!",
          scheduledTime: st,
          repeatMode: 0,
        );
        _updateOrAddNotification(
          uid,
          task.text,
          st,
          task.id,
          type: 0,
          forceReset: true,
        );
      }
    } else {
      if (!task.reminder) dbController.deleteNotificationByTaskId(uid, task.id);
    }
    dbController.updateTask(uid, task);
    Get.back();
  }

  void deleteTask(String taskId) {
    if (_auth.currentUser?.uid != null) {
      NotificationService().cancelNotification(taskId.hashCode.abs());
      dbController.deleteNotificationByTaskId(_auth.currentUser!.uid, taskId);
      dbController.deleteTask(_auth.currentUser!.uid, taskId);
    }
  }

  // ================= SPECIAL ROUTINE ACTIONS =================
  void addSpecialTask(TaskModel task) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    String newId = await dbController.addSpecialTask(uid, task);
    task.id = newId;

    if (task.reminder && !task.checked) {
      _scheduleSpecialNotification(uid, task);
    }
    specialTasks.refresh();
  }

  void updateSpecialTask(TaskModel task) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await NotificationService().cancelNotification(task.id.hashCode.abs());
    await dbController.updateSpecialTask(uid, task);

    if (task.reminder && !task.checked) {
      _scheduleSpecialNotification(uid, task);
    } else {
      if (!task.reminder) dbController.deleteNotificationByTaskId(uid, task.id);
    }
    specialTasks.refresh();
  }

  void deleteSpecialTask(String taskId) {
    String? uid = _auth.currentUser?.uid;
    if (uid != null) {
      NotificationService().cancelNotification(taskId.hashCode.abs());
      dbController.deleteNotificationByTaskId(uid, taskId);
      dbController.deleteSpecialTask(uid, taskId);
    }
  }

  void _scheduleSpecialNotification(String uid, TaskModel task) async {
    DateTime? scheduledTime;
    if (task.taskTimestamp != null && task.taskTimestamp!.startsWith("0000")) {
      scheduledTime = _getNextAnnualInstanceFrom0000(task.taskTimestamp!);
    } else {
      scheduledTime = _parseDateTimeRegex(task.date, task.time);
    }

    if (scheduledTime != null && scheduledTime.isAfter(DateTime.now())) {
      await NotificationService().scheduleNotification(
        id: task.id.hashCode.abs(),
        title: "Special: ${task.text}",
        body: "Don't forget this special event!",
        scheduledTime: scheduledTime,
        repeatMode: 3,
      );
      _updateOrAddNotification(
        uid,
        task.text,
        scheduledTime,
        task.id,
        type: 3,
        forceReset: true,
      );
    }
  }

  // ================= ADD REMINDER (SMART) =================
  void addReminder(TaskModel task, {int mode = 0}) async {
    String? uid = _auth.currentUser?.uid;
    if (uid != null && task.id.isNotEmpty) {
      bool newStatus = !task.reminder;
      if (mode == 3) newStatus = true;

      String? dbVal = "";

      if (newStatus && !task.checked) {
        DateTime? scheduledTime;
        if (mode == 3) {
          if (task.taskTimestamp != null &&
              task.taskTimestamp!.startsWith("0000")) {
            scheduledTime = _getNextAnnualInstanceFrom0000(task.taskTimestamp!);
            dbVal = task.taskTimestamp;
          } else {
            scheduledTime = _parseDateTimeRegex(task.date, task.time);
            if (scheduledTime != null) dbVal = scheduledTime.toIso8601String();
          }
        } else if (mode == 2) {
          scheduledTime = _getNextInstanceForDaily(task.time);
          dbVal = task.time;
        } else if (mode == 1) {
          dbVal = _calculateWeeklyReminderString(task.date, task.time);
          scheduledTime = _getNextInstance(task.date, task.time);
        } else {
          scheduledTime = _parseDateTimeRegex(task.date, task.time);
          if (scheduledTime != null) dbVal = scheduledTime.toIso8601String();
        }

        if (scheduledTime == null) {
          Get.snackbar("Error", "Could not calculate time.");
          return;
        }

        bool isPast =
            (mode == 0 || mode == 3) && scheduledTime.isBefore(DateTime.now());

        if (isPast) {
          DateTime now = DateTime.now();
          DateTime adjustedTime = DateTime(
            now.year,
            now.month,
            now.day,
            scheduledTime.hour,
            scheduledTime.minute,
          );

          _updateOrAddNotification(
            uid,
            task.text,
            adjustedTime,
            task.id,
            type: mode,
            forceReset: true,
          );
        } else {
          await NotificationService().scheduleNotification(
            id: task.id.hashCode.abs(),
            title: mode == 0
                ? "Reminder: ${task.text}"
                : (mode == 1
                      ? "Routine: ${task.text}"
                      : (mode == 2
                            ? "Daily: ${task.text}"
                            : "Special: ${task.text}")),
            body: mode == 3 ? "Special Event!" : "It's time!",
            scheduledTime: scheduledTime,
            repeatMode: mode,
          );

          _updateOrAddNotification(
            uid,
            task.text,
            scheduledTime,
            task.id,
            type: mode,
            forceReset: true,
          );
        }
      } else {
        await NotificationService().cancelNotification(task.id.hashCode.abs());
        await dbController.deleteNotificationByTaskId(uid, task.id);
      }

      task.reminder = newStatus;
      task.reminderTime = dbVal;

      if (mode == 3) {
        specialTasks.refresh();
      } else if (mode == 2) {
        dayTasks.refresh();
      } else if (mode == 1) {
        weekTasks.refresh();
      } else {
        tasks.refresh();
      }

      if (mode == 2) {
        dbController.updateDayTaskStatus(
          uid,
          task.id,
          reminder: newStatus,
          reminderTime: dbVal,
        );
      } else if (mode == 1) {
        dbController.updateWeekTaskStatus(
          uid,
          task.id,
          reminder: newStatus,
          reminderTime: dbVal,
        );
      } else if (mode == 0) {
        dbController.updateTaskStatus(
          uid,
          task.id,
          task.checked,
          reminder: newStatus,
          reminderTime: dbVal,
        );
      }
    }
  }

  // ================= HELPERS =================
  Future<void> _scheduleDayNotification(String uid, TaskModel task) async {
    DateTime? st = _getNextInstanceForDaily(task.time);
    if (st != null) {
      await NotificationService().scheduleNotification(
        id: task.id.hashCode.abs(),
        title: "Daily: ${task.text}",
        body: "Time for your daily routine!",
        scheduledTime: st,
        repeatMode: 2,
      );
      _updateOrAddNotification(
        uid,
        task.text,
        st,
        task.id,
        type: 2,
        forceReset: true,
      );
    }
  }

  Future<void> _scheduleWeekNotification(String uid, TaskModel task) async {
    DateTime? st = _getNextInstance(task.date, task.time);
    if (st != null) {
      await NotificationService().scheduleNotification(
        id: task.id.hashCode.abs(),
        title: "Routine: ${task.text}",
        body: "Weekly routine!",
        scheduledTime: st,
        repeatMode: 1,
      );
      _updateOrAddNotification(
        uid,
        task.text,
        st,
        task.id,
        type: 1,
        forceReset: true,
      );
    }
  }

  void _updateOrAddNotification(
    String uid,
    String title,
    DateTime scheduledTime,
    String taskId, {
    int type = 0,
    bool forceReset = false,
  }) {
    String msg;
    String dateStr;
    String timeStr = DateFormat('h:mm a').format(scheduledTime);
    String task = '';

    if (type == 3) {
      dateStr = DateFormat("MMM d").format(scheduledTime);
      msg = "Special: $title at $timeStr";
      task = 'Special Event';
    } else if (type == 2) {
      dateStr = "Daily";
      msg = "Reminder set for $title at $timeStr everyday";
      task = 'Daily Task';
    } else if (type == 1) {
      dateStr = DateFormat('EEEE').format(scheduledTime);
      msg = "Reminder set for $title at $timeStr";
      task = 'Routine';
    } else {
      dateStr = DateFormat("MMM d, yyyy").format(scheduledTime);
      msg = "Reminder set for $title at $dateStr $timeStr";
      task = 'Callender Task';
    }

    NotificationModel notif = NotificationModel(
      id: '',
      taskId: taskId,
      title: task,
      message: msg,
      date: dateStr,
    );

    // --- UPDATED LOGIC ---
    DateTime now = DateTime.now();
    bool isRecurring = type == 1 || type == 2;

    // Check if the scheduled date is TOMORROW or later
    // If we schedule for tomorrow (because today's time passed), we MUST add hiddenDate
    // so the background loop doesn't check "today" and trigger an immediate alert.
    bool scheduledForTomorrowOrLater =
        scheduledTime.year > now.year ||
        scheduledTime.month > now.month ||
        scheduledTime.day > now.day;

    if (isRecurring && scheduledForTomorrowOrLater) {
      // Hides it for Today so it doesn't alert.
      notif.hiddenDate = DateFormat('yyyy-MM-dd').format(now);
    } else {
      // For future time on SAME DAY, we do NOT hide it.
      // NotificationController checks time, sees it's future, so isAlert stays false.
      notif.hiddenDate = null;
    }

    // Forces reset of isAlert to false
    bool shouldReset = forceReset || scheduledTime.isAfter(DateTime.now());

    dbController.upsertNotification(uid, notif, resetAlert: shouldReset);
  }

  String? _calculateWeeklyReminderString(String date, String time) {
    DateTime? next = _getNextInstance(date, time);
    if (next != null) {
      String iso = next.toIso8601String();
      int tIndex = iso.indexOf('T');
      if (tIndex != -1) return iso.substring(tIndex);
    }
    return null;
  }

  DateTime? _getNextInstanceForDaily(String timeStr) {
    try {
      DateTime now = DateTime.now();
      DateTime timeOnly = DateFormat("h:mm a").parse(timeStr);
      DateTime scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        timeOnly.hour,
        timeOnly.minute,
      );
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      return scheduled;
    } catch (e) {
      return null;
    }
  }

  DateTime? _getNextInstance(String dayName, String timeStr) {
    try {
      DateTime now = DateTime.now();
      DateTime timeOnly = DateFormat("h:mm a").parse(timeStr);
      List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
      int target = days.indexOf(dayName) + 1;
      if (target == 0) return null;
      int daysUntil = target - now.weekday;
      if (daysUntil < 0) daysUntil += 7;
      if (daysUntil == 0) {
        DateTime pot = DateTime(
          now.year,
          now.month,
          now.day,
          timeOnly.hour,
          timeOnly.minute,
        );
        if (pot.isBefore(now)) daysUntil = 7;
      }
      DateTime next = now.add(Duration(days: daysUntil));
      return DateTime(
        next.year,
        next.month,
        next.day,
        timeOnly.hour,
        timeOnly.minute,
      );
    } catch (e) {
      return null;
    }
  }

  DateTime? _parseDateTimeRegex(String dateStr, String timeStr) {
    try {
      return DateFormat(
        "MMM d, yyyy h:mm a",
        "en_US",
      ).parse("$dateStr $timeStr");
    } catch (_) {
      return null;
    }
  }

  DateTime? _getNextAnnualInstanceFrom0000(String isoString) {
    try {
      List<String> parts = isoString.split('T');
      List<String> dateParts = parts[0].split('-');
      List<String> timeParts = parts[1].split(':');

      int month = int.parse(dateParts[1]);
      int day = int.parse(dateParts[2]);
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      DateTime now = DateTime.now();
      DateTime candidate = DateTime(now.year, month, day, hour, minute);

      if (candidate.isBefore(now)) {
        candidate = DateTime(now.year + 1, month, day, hour, minute);
      }
      return candidate;
    } catch (e) {
      return null;
    }
  }
}
