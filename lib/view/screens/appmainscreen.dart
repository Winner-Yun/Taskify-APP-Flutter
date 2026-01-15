import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart'; // ✅ NEW PACKAGE
import 'package:intl/intl.dart';
import 'package:to_do_list_app/controller/task_controller.dart';
import 'package:to_do_list_app/model/task_model.dart';
import 'package:to_do_list_app/view/screens/add_update_list.dart';
import 'package:to_do_list_app/view/screens/calenderscreen.dart';
import 'package:to_do_list_app/view/screens/homepagescreen.dart';
import 'package:to_do_list_app/view/screens/notification.dart';
import 'package:to_do_list_app/view/screens/setting.dart';

class AppmainScreen extends StatefulWidget {
  const AppmainScreen({super.key});

  @override
  State<AppmainScreen> createState() => _AppmainScreenState();
}

class _AppmainScreenState extends State<AppmainScreen>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  bool _isLoading = false;

  final TaskController taskController = Get.put(TaskController());
  DateTime calendarSelectedDay = DateTime.now();

  // --- INTERNET VARS ---
  bool hasInternet = true;
  StreamSubscription? internetSubscription;

  @override
  void initState() {
    super.initState();
    _startInternetListener();
  }

  @override
  void dispose() {
    internetSubscription?.cancel();
    super.dispose();
  }

  // --- REAL INTERNET CHECK (PING) ---
  void _startInternetListener() {
    // 1. Listen for real internet status changes (Connected vs Disconnected)
    internetSubscription = InternetConnection().onStatusChange.listen((
      InternetStatus status,
    ) {
      if (mounted) {
        setState(() {
          // Connected = We have real internet
          hasInternet = (status == InternetStatus.connected);
        });
      }
    });
  }

  Future<void> _simulateLoading(VoidCallback action) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isLoading = false);
      action();
    }
  }

  bool _isFutureOrToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      calendarSelectedDay.year,
      calendarSelectedDay.month,
      calendarSelectedDay.day,
    );
    return !selected.isBefore(today);
  }

  void _goSetting() {
    _simulateLoading(() {
      setState(() => _index = 3);
    });
  }

  List<Widget> screens() => [
    Homepagescreen(onGoSetting: _goSetting),
    Calenderscreen(
      onDayUpdated: (day, events) {
        if (day != null) {
          setState(() {
            calendarSelectedDay = day;
          });
        }
      },
    ),
    NotificationScreen(),
    const SettingScreen(),
  ];

  List<String> titles = ["Taskify", "Calender", "Notification", "Setting"];
  List<IconData> icons = [
    Icons.abc,
    Icons.calendar_month,
    Icons.notifications,
    Icons.settings,
  ];

  @override
  Widget build(BuildContext context) {
    String dateStr = DateFormat('MMM d, yyyy').format(calendarSelectedDay);
    bool hasEvents = taskController.getTasksByDate(dateStr).isNotEmpty;
    bool showFab = _index == 1 && (_isFutureOrToday() || hasEvents);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      appBar: AppBar(
        toolbarHeight: 75,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 191, 2, 24),
                Color.fromARGB(255, 23, 0, 40),
              ],
            ),
          ),
        ),
        title: Row(
          children: [
            SizedBox(
              height: 50,
              width: _index == 0 ? 50 : 0,
              child: _index == 0
                  ? Image.asset("assets/icons/logoApp.png", fit: BoxFit.cover)
                  : Icon(icons[_index], color: Colors.white),
            ),
            const SizedBox(width: 30),
            Text(
              titles[_index],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),

        // --- INTERNET STATUS BADGE ---
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: hasInternet
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: hasInternet ? Colors.greenAccent : Colors.redAccent,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasInternet ? Icons.wifi : Icons.wifi_off,
                    color: hasInternet ? Colors.greenAccent : Colors.redAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    hasInternet ? "Online" : "Offline",
                    style: TextStyle(
                      color: hasInternet
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // -----------------------------
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: showFab
          ? Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 191, 2, 24),
                    Color.fromARGB(255, 23, 0, 40),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  _isFutureOrToday() ? Icons.add : Icons.edit_note,
                  color: Colors.white,
                  size: 23,
                ),
                onPressed: () => showCalendarMenu(context),
              ),
            )
          : null,
      bottomNavigationBar: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 191, 2, 24),
              Color.fromARGB(255, 23, 0, 40),
            ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navItem(Icons.home, 0),
            _navItem(Icons.calendar_today, 1),
            const SizedBox(width: 55),
            _navItem(Icons.notifications, 2),
            _navItem(Icons.settings, 3),
          ],
        ),
      ),
      body: Stack(
        children: [
          screens()[_index],
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    bool isSelected = _index == index;
    return GestureDetector(
      onTap: () {
        if (_index != index) {
          _simulateLoading(() {
            setState(() => _index = index);
          });
        }
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: 1.0,
        curve: Curves.easeOutBack,
        child: Icon(
          icon,
          size: 28,
          color: Colors.white.withOpacity(isSelected ? 1 : 0.55),
        ),
      ),
    );
  }

  List<TaskModel> _getValidReminderTasks(List<TaskModel> allTasks) {
    return allTasks.where((task) {
      if (task.reminder) return true;
      if (task.taskTimestamp != null && task.taskTimestamp!.isNotEmpty) {
        DateTime? tDate = DateTime.tryParse(task.taskTimestamp!);
        if (tDate != null && tDate.isBefore(DateTime.now())) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void showCalendarMenu(BuildContext context) {
    String dateStr = DateFormat('MMM d, yyyy').format(calendarSelectedDay);
    List<TaskModel> currentEvents = taskController.getTasksByDate(dateStr);
    List<TaskModel> validReminderTasks = _getValidReminderTasks(currentEvents);
    bool showReminderOption = validReminderTasks.isNotEmpty;
    bool hasEvents = currentEvents.isNotEmpty;
    bool isTodayOrFuture = _isFutureOrToday();

    String reminderText = "Reminder";
    IconData reminderIcon = Icons.alarm;

    if (validReminderTasks.length == 1) {
      if (validReminderTasks.first.reminder) {
        reminderText = "Remove Reminder";
        reminderIcon = Icons.alarm_off;
      } else {
        reminderText = "Add Reminder";
        reminderIcon = Icons.alarm_add;
      }
    }

    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(200, 600, 20, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.redAccent,
      items: [
        if (isTodayOrFuture)
          PopupMenuItem(value: "add", child: _buildMenuItem(Icons.add, "Add")),
        if (hasEvents) ...[
          if (showReminderOption)
            PopupMenuItem(
              value: "toggleReminder",
              child: _buildMenuItem(reminderIcon, reminderText),
            ),
          PopupMenuItem(
            value: "edit",
            child: _buildMenuItem(Icons.edit, "Edit"),
          ),
          PopupMenuItem(
            value: "delete",
            child: _buildMenuItem(Icons.delete, "Delete"),
          ),
          PopupMenuItem(
            value: "deleteAll",
            child: _buildMenuItem(Icons.delete_forever, "Delete All"),
          ),
        ],
      ],
    ).then((value) {
      if (value == null) return;
      _handleMenuSelection(value, currentEvents);
    });
  }

  Widget _buildMenuItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _handleMenuSelection(String value, List<TaskModel> currentEvents) {
    switch (value) {
      case "add":
        _simulateLoading(() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TaskHomeScreen(initialDate: calendarSelectedDay),
            ),
          );
        });
        break;
      case "toggleReminder":
        List<TaskModel> validTasks = _getValidReminderTasks(currentEvents);
        if (validTasks.isEmpty) {
          Get.snackbar(
            "Expired",
            "No valid tasks available for reminders.",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return;
        }
        _selectTaskAndAction(
          validTasks,
          (task) => taskController.addReminder(task),
        );
        break;
      case "edit":
        _selectTaskAndAction(currentEvents, (task) {
          _simulateLoading(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskHomeScreen(task: task),
              ),
            );
          });
        });
        break;
      case "delete":
        _selectTaskAndAction(currentEvents, (task) {
          taskController.deleteTask(task.id);
          Get.snackbar(
            "Deleted",
            "Task removed",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        });
        break;
      case "deleteAll":
        _confirmDeleteAll(currentEvents);
        break;
    }
  }

  void _confirmDeleteAll(List<TaskModel> tasks) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete All Tasks?"),
        content: const Text(
          "Are you sure you want to delete all tasks for this day?\nThis cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.amber)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              for (var task in tasks) {
                taskController.deleteTask(task.id);
              }
              Get.snackbar(
                "Deleted All",
                "All tasks for this day have been removed.",
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            child: const Text(
              "Delete All",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _selectTaskAndAction(
    List<TaskModel> events,
    Function(TaskModel) onTaskSelected,
  ) {
    if (events.isEmpty) return;
    if (events.length == 1) {
      onTaskSelected(events.first);
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Select Task"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final task = events[index];
                  final status = task.reminder ? "(Has Reminder)" : "";
                  return ListTile(
                    title: Text(task.text),
                    subtitle: Text("${task.time} $status"),
                    onTap: () {
                      Navigator.pop(context);
                      onTaskSelected(task);
                    },
                  );
                },
              ),
            ),
          );
        },
      );
    }
  }
}
