import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Added for DateFormat
import 'package:table_calendar/table_calendar.dart';
import 'package:to_do_list_app/config/appcolor.dart';
import 'package:to_do_list_app/controller/task_controller.dart';
import 'package:to_do_list_app/main.dart';
import 'package:to_do_list_app/model/task_model.dart';
import 'package:to_do_list_app/view/screens/add_update_list.dart'; // Added for Navigation

class Calenderscreen extends StatefulWidget {
  final void Function(DateTime?, List<TaskModel>) onDayUpdated;
  final DateTime? initialDate;

  const Calenderscreen({
    super.key,
    required this.onDayUpdated,
    this.initialDate,
  });

  @override
  State<Calenderscreen> createState() => _CalenderscreenState();
}

class _CalenderscreenState extends State<Calenderscreen> {
  late DateTime focusedDay;
  late DateTime? selectedDay;
  bool _isLoading = false; // Added for loading state

  final TaskController taskController = Get.find<TaskController>();

  // ==========================================
  //  LOGIC COPIED & ADAPTED FROM APPMAINSCREEN
  // ==========================================

  Future<void> _simulateLoading(VoidCallback action) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _isLoading = false);
      action();
    }
  }

  bool _isFutureOrToday() {
    if (selectedDay == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      selectedDay!.year,
      selectedDay!.month,
      selectedDay!.day,
    );
    return !selected.isBefore(today);
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
    if (selectedDay == null) return;

    // Keep date logic in English format for DB lookup
    String dateStr = DateFormat('MMM d, yyyy').format(selectedDay!);
    List<TaskModel> currentEvents = taskController.getTasksByDate(dateStr);
    List<TaskModel> validReminderTasks = _getValidReminderTasks(currentEvents);

    bool showReminderOption = validReminderTasks.isNotEmpty;
    bool hasEvents = currentEvents.isNotEmpty;
    bool isTodayOrFuture = _isFutureOrToday();

    String reminderText = "reminder".tr; // Translated
    IconData reminderIcon = Icons.alarm;

    if (validReminderTasks.length == 1) {
      if (validReminderTasks.first.reminder) {
        reminderText = "remove_reminder".tr; // Translated
        reminderIcon = Icons.alarm_off;
      } else {
        reminderText = "add_reminder".tr; // Translated
        reminderIcon = Icons.alarm_add;
      }
    }

    showMenu<String>(
      context: context,
      // Adjust position for Calendar Screen
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height * 0.5,
        0,
        0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.redAccent,
      items: [
        if (isTodayOrFuture)
          PopupMenuItem(
            value: "add",
            child: _buildMenuItem(Icons.add, "add".tr), // Translated
          ),
        if (hasEvents) ...[
          if (showReminderOption)
            PopupMenuItem(
              value: "toggleReminder",
              child: _buildMenuItem(reminderIcon, reminderText),
            ),
          PopupMenuItem(
            value: "edit",
            child: _buildMenuItem(Icons.edit, "edit".tr), // Translated
          ),
          PopupMenuItem(
            value: "delete",
            child: _buildMenuItem(Icons.delete, "delete".tr), // Translated
          ),
          PopupMenuItem(
            value: "deleteAll",
            child: _buildMenuItem(
              Icons.delete_forever,
              "delete_all".tr,
            ), // Translated
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
              // Pass selectedDay as initialDate
              builder: (context) => TaskHomeScreen(initialDate: selectedDay!),
            ),
          );
        });
        break;
      case "toggleReminder":
        List<TaskModel> validTasks = _getValidReminderTasks(currentEvents);
        if (validTasks.isEmpty) {
          Get.snackbar(
            "expired".tr, // Translated
            "no_valid_tasks".tr, // Translated
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
            "deleted".tr, // Translated
            "task_removed".tr, // Translated
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
        title: Text("delete_all_confirm".tr), // Translated
        content: Text("delete_all_msg".tr), // Translated
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "cancel".tr,
              style: const TextStyle(color: Colors.amber),
            ), // Translated
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              for (var task in tasks) {
                taskController.deleteTask(task.id);
              }
              Get.snackbar(
                "deleted".tr, // Translated (using 'Deleted' key roughly)
                "all_tasks_removed".tr, // Translated
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            child: Text(
              "delete_all".tr, // Translated
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
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
            title: Text("select_task".tr), // Translated
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final task = events[index];
                  final status = task.reminder
                      ? "has_reminder".tr
                      : ""; // Translated
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

  // ==========================================
  //  EXISTING CALENDAR LOGIC (Unchanged)
  // ==========================================

  // ... (generateEventsFromTasks, parseDate, getEventsForDay methods remain the same) ...
  // Hidden for brevity, no text to translate inside these logic functions.

  Map<DateTime, List<TaskModel>> generateEventsFromTasks() {
    Map<DateTime, List<TaskModel>> eventMap = {};
    for (var task in taskController.tasks) {
      try {
        DateTime date = parseDate(task.date);
        final key = DateTime.utc(date.year, date.month, date.day);
        if (!eventMap.containsKey(key)) {
          eventMap[key] = [];
        }
        eventMap[key]!.add(task);
        // ignore: empty_catches
      } catch (e) {}
    }
    return eventMap;
  }

  DateTime parseDate(String date) {
    final months = {
      "Jan": 1,
      "Feb": 2,
      "Mar": 3,
      "Apr": 4,
      "May": 5,
      "Jun": 6,
      "Jul": 7,
      "Aug": 8,
      "Sep": 9,
      "Oct": 10,
      "Nov": 11,
      "Dec": 12,
    };
    try {
      final parts = date.split(" ");
      final month = months[parts[0]]!;
      final day = int.parse(parts[1].replaceAll(",", ""));
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (e) {
      return DateTime.now();
    }
  }

  List<TaskModel> getEventsForDay(DateTime day) {
    final events = generateEventsFromTasks();
    final key = DateTime.utc(day.year, day.month, day.day);
    return events[key] ?? [];
  }

  @override
  void initState() {
    super.initState();
    focusedDay = widget.initialDate ?? DateTime.now();
    selectedDay = widget.initialDate ?? DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onDayUpdated(selectedDay, getEventsForDay(selectedDay!));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode,
      builder: (context, bool dark, child) {
        return Obx(() {
          // ignore: unused_local_variable
          final _ = taskController.tasks.length;

          final eventsForDay = selectedDay != null
              ? getEventsForDay(selectedDay!)
              : <TaskModel>[];

          // --- Determine FAB Visibility ---
          bool isTodayOrFuture = _isFutureOrToday();
          bool hasEvents = eventsForDay.isNotEmpty;
          bool showFab = isTodayOrFuture || hasEvents;

          return Stack(
            children: [
              Scaffold(
                backgroundColor: AppColors.background(dark),
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
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
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    "calendar_mode"
                        .tr, // Translated "Calendar Mode" or "Calendar"
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                // --- FLOATING ACTION BUTTON ---
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                floatingActionButton: showFab
                    ? Container(
                        height: 65,
                        width: 65,
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
                            isTodayOrFuture ? Icons.add : Icons.edit_note,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () => showCalendarMenu(context),
                        ),
                      )
                    : null,

                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      _buildCalendar(dark),
                      const SizedBox(height: 10),
                      Expanded(child: _buildEventList(dark, eventsForDay)),
                    ],
                  ),
                ),
              ),

              // --- LOADING OVERLAY ---
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          );
        });
      },
    );
  }

  Widget _buildCalendar(bool dark) {
    return TableCalendar(
      focusedDay: focusedDay,
      firstDay: DateTime(2020),
      lastDay: DateTime(2030),
      calendarFormat: CalendarFormat.month,

      selectedDayPredicate: (day) => isSameDay(day, selectedDay),

      onDaySelected: (selected, focused) {
        setState(() {
          selectedDay = selected;
          focusedDay = focused;
        });
        widget.onDayUpdated(selectedDay, getEventsForDay(selected));
      },

      onPageChanged: (focused) {
        setState(() => focusedDay = focused);
      },

      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.primary(dark),
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: AppColors.text(dark).withOpacity(0.6)),
        weekendStyle: TextStyle(color: AppColors.text(dark).withOpacity(0.6)),
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle: TextStyle(color: AppColors.text(dark)),
        weekendTextStyle: TextStyle(color: AppColors.text(dark)),
        selectedDecoration: BoxDecoration(
          color: AppColors.primary(dark),
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: AppColors.primary(dark).withOpacity(0.4),
          shape: BoxShape.circle,
        ),
      ),
      eventLoader: getEventsForDay,
    );
  }

  Widget _buildEventList(bool dark, List<TaskModel> events) {
    return ListView(
      children: [
        if (events.isNotEmpty)
          ...events.map((task) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card(dark),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (!dark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.primary(dark),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.text,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.text(dark),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              task.time,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.text(dark).withOpacity(0.6),
                              ),
                            ),
                            if (task.reminder) ...[
                              const SizedBox(width: 12),
                              Icon(
                                Icons.alarm,
                                size: 14,
                                color: AppColors.primary(dark),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "reminder_on".tr, // Translated
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary(dark),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          })
        else
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "no_events".tr, // Translated
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.text(dark).withOpacity(0.6),
              ),
            ),
          ),
      ],
    );
  }
}
