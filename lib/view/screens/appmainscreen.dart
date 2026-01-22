import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list_app/controller/task_controller.dart';
import 'package:to_do_list_app/data/local_db_helper.dart';
import 'package:to_do_list_app/model/task_model.dart';
import 'package:to_do_list_app/view/screens/add_update_list.dart';
import 'package:to_do_list_app/view/screens/homepagescreen.dart';
import 'package:to_do_list_app/view/screens/menu_grid_sheet.dart';
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
  DateTime _currentSelectedDate = DateTime.now();

  // 0=Cal, 1=Week, 2=Day
  int _currentMode = 0;
  String _currentRoutineDay = "Mon";

  bool hasInternet = true;
  StreamSubscription? internetSubscription;

  @override
  void initState() {
    super.initState();
    _currentRoutineDay = DateFormat('E').format(DateTime.now());
    _loadSettings();
    _startInternetListener();
  }

  Future<void> _loadSettings() async {
    final db = LocalDbHelper();
    int savedMode = await db.getRoutineMode();
    // Assuming you handle theme loading here or in main

    setState(() {
      _currentMode = savedMode;
    });
    // Sync notifications
    taskController.switchNotificationMode(savedMode);
  }

  @override
  void dispose() {
    internetSubscription?.cancel();
    super.dispose();
  }

  void _startInternetListener() {
    internetSubscription = InternetConnection().onStatusChange.listen((status) {
      if (mounted) {
        setState(() {
          hasInternet = (status == InternetStatus.connected);
        });
      }
    });
  }

  Future<void> _simulateLoading(VoidCallback action) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _isLoading = false);
      action();
    }
  }

  bool _isFutureOrToday() {
    if (_currentMode > 0) return true; // Always allow routines

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      _currentSelectedDate.year,
      _currentSelectedDate.month,
      _currentSelectedDate.day,
    );
    return !selected.isBefore(today);
  }

  void _updateSelectedDate(DateTime date) {
    setState(() {
      _currentSelectedDate = date;
    });
  }

  void _updateMode(int mode, String dayValue) {
    setState(() {
      _currentMode = mode;
      if (mode == 1) {
        _currentRoutineDay = dayValue;
      } else if (mode == 0) {
        _currentSelectedDate = DateTime.parse(dayValue);
      }
    });
    LocalDbHelper().setRoutineMode(mode);
    taskController.switchNotificationMode(mode);
  }

  void _goSetting() {
    _simulateLoading(() {
      setState(() => _index = 3);
    });
  }

  List<Widget> screens() => [
    Homepagescreen(
      onGoSetting: _goSetting,
      onDateSelected: _updateSelectedDate,
      onModeChanged: _updateMode,
      initialMode: _currentMode,
    ),
    MenuGridSheet(selectedDate: _currentSelectedDate),
    NotificationScreen(currentMode: _currentMode),
    const SettingScreen(),
  ];

  // CHANGED: Use a getter so translation updates immediately when language changes
  List<String> get titles => [
    'taskify'.tr,
    'menu'.tr,
    'notification'.tr,
    'settings'.tr,
  ];

  List<IconData> icons = [
    Icons.abc,
    Icons.category_rounded,
    Icons.notifications,
    Icons.settings,
  ];

  @override
  Widget build(BuildContext context) {
    bool hasEvents;

    if (_currentMode == 2) {
      hasEvents = taskController.dayTasks.isNotEmpty;
    } else if (_currentMode == 1) {
      hasEvents = taskController
          .getWeekTasksByDay(_currentRoutineDay)
          .isNotEmpty;
    } else {
      String dateStr = DateFormat('MMM d, yyyy').format(_currentSelectedDate);
      hasEvents = taskController.getTasksByDate(dateStr).isNotEmpty;
    }

    bool isFutureOrToday = _isFutureOrToday();
    bool showFab = _index == 0 && (isFutureOrToday || hasEvents);

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
            // UPDATED: Use the getter for titles
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
                  // UPDATED: Translate Online/Offline
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
                  isFutureOrToday ? Icons.add : Icons.edit_note,
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
            _navItem(Icons.category_rounded, 1),
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

  // --- NAV ITEM LOGIC ---
  Widget _navItem(IconData icon, int index) {
    bool isSelected = _index == index;
    return GestureDetector(
      onTap: () {
        if (_index != index) {
          _simulateLoading(() {
            setState(() {
              _index = index;
              if (index == 0) {
                _updateSelectedDate(DateTime.now());
              }
            });
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

  // --- MENU LOGIC FOR TASKS ---
  List<TaskModel> _getValidReminderTasks(List<TaskModel> allTasks) {
    return allTasks.where((task) {
      if (task.reminder) return true;
      if (_currentMode == 0 &&
          task.taskTimestamp != null &&
          task.taskTimestamp!.isNotEmpty) {
        DateTime? tDate = DateTime.tryParse(task.taskTimestamp!);
        if (tDate != null && tDate.isBefore(DateTime.now())) return false;
      }
      return true;
    }).toList();
  }

  void showCalendarMenu(BuildContext context) {
    List<TaskModel> currentEvents;
    if (_currentMode == 2) {
      currentEvents = taskController.dayTasks;
    } else if (_currentMode == 1) {
      currentEvents = taskController.getWeekTasksByDay(_currentRoutineDay);
    } else {
      String dateStr = DateFormat('MMM d, yyyy').format(_currentSelectedDate);
      currentEvents = taskController.getTasksByDate(dateStr);
    }

    List<TaskModel> validReminderTasks = _getValidReminderTasks(currentEvents);
    bool showReminderOption = validReminderTasks.isNotEmpty;
    bool hasEvents = currentEvents.isNotEmpty;
    bool isTodayOrFuture = _isFutureOrToday();

    // UPDATED: Translated Reminder logic
    String reminderText = "reminder".tr;
    IconData reminderIcon = Icons.alarm;

    if (validReminderTasks.length == 1) {
      if (validReminderTasks.first.reminder) {
        reminderText = "remove_reminder".tr;
        reminderIcon = Icons.alarm_off;
      } else {
        reminderText = "add_reminder".tr;
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
          // UPDATED: Translated Menu Items
          PopupMenuItem(
            value: "add",
            child: _buildMenuItem(Icons.add, "add".tr),
          ),
        if (hasEvents) ...[
          if (showReminderOption)
            PopupMenuItem(
              value: "toggleReminder",
              child: _buildMenuItem(reminderIcon, reminderText),
            ),
          PopupMenuItem(
            value: "edit",
            child: _buildMenuItem(Icons.edit, "edit".tr),
          ),
          PopupMenuItem(
            value: "delete",
            child: _buildMenuItem(Icons.delete, "delete".tr),
          ),
          PopupMenuItem(
            value: "deleteAll",
            child: _buildMenuItem(Icons.delete_forever, "delete_all".tr),
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
              builder: (context) => TaskHomeScreen(
                initialDate: _currentSelectedDate,
                currentMode: _currentMode,
                routineDayName: _currentRoutineDay,
              ),
            ),
          );
        });
        break;
      case "toggleReminder":
        List<TaskModel> validTasks = _getValidReminderTasks(currentEvents);
        if (validTasks.isEmpty) return;
        _selectTaskAndAction(
          validTasks,
          (task) => taskController.addReminder(task, mode: _currentMode),
        );
        break;
      case "edit":
        _selectTaskAndAction(currentEvents, (task) {
          _simulateLoading(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskHomeScreen(
                  task: task,
                  currentMode: _currentMode,
                  routineDayName: _currentRoutineDay,
                ),
              ),
            );
          });
        });
        break;
      case "delete":
        _selectTaskAndAction(currentEvents, (task) {
          if (_currentMode == 2) {
            taskController.deleteDayTask(task.id);
          } else if (_currentMode == 1) {
            taskController.deleteWeekTask(task.id);
          } else {
            taskController.deleteTask(task.id);
          }
          // UPDATED: Translated Snackbar
          Get.snackbar(
            "deleted".tr,
            "task_removed".tr,
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
        // UPDATED: Translated Dialog Title
        title: Text("delete_all_confirm".tr),
        // UPDATED: Translated Dialog Content
        content: Text("delete_all_msg".tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            // UPDATED: Translated Cancel
            child: Text("cancel".tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              for (var task in tasks) {
                if (_currentMode == 2) {
                  taskController.deleteDayTask(task.id);
                } else if (_currentMode == 1) {
                  taskController.deleteWeekTask(task.id);
                } else {
                  taskController.deleteTask(task.id);
                }
              }
              // UPDATED: Translated Snackbar
              Get.snackbar(
                "deleted".tr,
                "all_tasks_removed".tr,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            child: Text(
              "delete_all".tr, // UPDATED: Translated Delete All
              style: const TextStyle(color: Colors.red),
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
            // UPDATED: Translated Title
            title: Text("select_task".tr),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final task = events[index];
                  // UPDATED: Translated Status
                  final status = task.reminder ? "has_reminder".tr : "";
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
