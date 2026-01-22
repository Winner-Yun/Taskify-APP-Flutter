import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list_app/config/appcolor.dart'; // Import AppColors
import 'package:to_do_list_app/controller/task_controller.dart';
import 'package:to_do_list_app/main.dart'; // Import isDarkMode
import 'package:to_do_list_app/model/task_model.dart';

class WeekRoutineScreen extends StatefulWidget {
  const WeekRoutineScreen({super.key});

  @override
  State<WeekRoutineScreen> createState() => _WeekRoutineScreenState();
}

class _WeekRoutineScreenState extends State<WeekRoutineScreen> {
  final TaskController taskController = Get.find<TaskController>();
  int _selectedDayIndex = 0;
  final Color _primaryRed = const Color.fromARGB(255, 191, 2, 24);

  // Logic keys (Keep English for logic, translate in UI)
  final List<String> _days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  String _getDateStringFromDayIndex(int index) {
    return _days[index];
  }

  void _showTaskDialog(bool isDark, {TaskModel? taskToEdit}) {
    TextEditingController taskInputController = TextEditingController();
    TimeOfDay? selectedTime;
    String timeText = "select_time".tr; // Translated
    String targetDate = _getDateStringFromDayIndex(_selectedDayIndex);
    String displayDay = _days[_selectedDayIndex].tr; // Translated Day Name
    final Color contentColor = isDark ? Colors.white : Colors.black;

    String? titleError;
    bool timeError = false;
    bool setReminder = false;

    if (taskToEdit != null) {
      taskInputController.text = taskToEdit.text;
      timeText = taskToEdit.time;
      setReminder = taskToEdit.reminder;
      try {
        DateTime parsed = DateFormat("h:mm a").parse(taskToEdit.time);
        selectedTime = TimeOfDay.fromDateTime(parsed);
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        taskToEdit == null
                            ? 'add_task'
                                  .tr // Reusing "Add Task"
                            : 'edit_task'.tr,
                        style: TextStyle(
                          color: AppColors.text(isDark),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (taskToEdit != null)
                        IconButton(
                          icon: const Icon(
                            Icons.delete_rounded,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            taskController.deleteWeekTask(taskToEdit.id);
                            Navigator.pop(context);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Theme(
                    data: Theme.of(context).copyWith(
                      textSelectionTheme: TextSelectionThemeData(
                        cursorColor: AppColors.text(isDark),
                        selectionHandleColor: AppColors.text(isDark),
                        selectionColor: AppColors.text(
                          isDark,
                        ).withValues(alpha: 0.2),
                      ),
                    ),
                    child: TextField(
                      controller: taskInputController,
                      style: TextStyle(color: AppColors.text(isDark)),
                      decoration: InputDecoration(
                        // "Enter task" + " (Mon)"
                        hintText: "${'enter_task'.tr} ($displayDay)",
                        hintStyle: TextStyle(
                          color: AppColors.text(isDark).withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(
                          Icons.task_alt,
                          color: AppColors.text(isDark).withOpacity(0.7),
                        ),
                        errorText: titleError,
                        errorStyle: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () async {
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime ?? TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              textSelectionTheme: TextSelectionThemeData(
                                cursorColor: AppColors.text(isDark),
                                selectionColor: AppColors.text(
                                  isDark,
                                ).withValues(alpha: 0.2),
                                selectionHandleColor: AppColors.text(isDark),
                              ),
                              colorScheme: isDark
                                  ? ColorScheme.dark(
                                      surface: AppColors.card(true),
                                      onSurface: Colors.white,
                                      primary: AppColors.primary(true),
                                      onPrimary: Colors.white,
                                    )
                                  : ColorScheme.light(
                                      surface: const Color(0xfff3ecfa),
                                      onSurface: Colors.black,
                                      primary: AppColors.primary(false),
                                      onPrimary: Colors.white,
                                    ),
                              timePickerTheme: TimePickerThemeData(
                                backgroundColor: isDark
                                    ? AppColors.card(true)
                                    : const Color(0xfff3ecfa),
                                hourMinuteTextColor: contentColor,
                                hourMinuteColor: isDark
                                    ? AppColors.primary(true).withOpacity(0.2)
                                    : const Color.fromARGB(255, 255, 212, 212),
                                dayPeriodTextColor: contentColor,
                                dayPeriodColor: isDark
                                    ? AppColors.primary(true).withOpacity(0.2)
                                    : const Color.fromARGB(255, 255, 230, 230),
                                dialHandColor: AppColors.primary(isDark),
                                dialBackgroundColor: isDark
                                    ? AppColors.card(true).withOpacity(0.3)
                                    : const Color.fromARGB(255, 255, 230, 230),
                                dialTextColor: contentColor,
                                entryModeIconColor: contentColor,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (time != null) {
                        setModalState(() {
                          selectedTime = time;
                          timeText = time.format(context);
                          timeError = false;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: timeError
                            ? Border.all(color: Colors.redAccent, width: 1.5)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time_rounded, color: _primaryRed),
                          const SizedBox(width: 10),
                          Text(
                            timeText,
                            style: TextStyle(
                              color: timeError
                                  ? Colors.redAccent
                                  : AppColors.text(isDark),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.text(isDark).withOpacity(0.3),
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (timeError)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 5),
                      child: Text(
                        "please_select_time".tr, // Translated
                        style: TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              setReminder
                                  ? Icons.notifications_active_rounded
                                  : Icons.notifications_off_rounded,
                              color: setReminder
                                  ? _primaryRed
                                  : AppColors.text(isDark).withOpacity(0.5),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "set_reminder".tr, // Translated
                              style: TextStyle(
                                color: AppColors.text(isDark),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: setReminder,
                          activeColor: _primaryRed,
                          onChanged: (value) {
                            setModalState(() {
                              setReminder = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setModalState(() {
                          if (taskInputController.text.trim().isEmpty) {
                            titleError = "task_empty_error".tr; // Translated
                          } else {
                            titleError = null;
                          }
                          if (selectedTime == null && taskToEdit == null) {
                            timeError = true;
                          } else {
                            timeError = false;
                          }
                        });

                        if (titleError == null && !timeError) {
                          final newTask = TaskModel(
                            id: taskToEdit?.id ?? '',
                            date: targetDate,
                            time: timeText,
                            text: taskInputController.text.trim(),
                            checked: taskToEdit?.checked ?? false,
                            reminder: setReminder,
                            reminderTime: setReminder
                                ? taskToEdit?.reminderTime
                                : null,
                          );

                          if (taskToEdit == null) {
                            taskController.addWeekTask(newTask);
                          } else {
                            taskController.updateWeekTask(newTask);
                          }
                          if (taskToEdit == null) Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        taskToEdit == null
                            ? "add_to_schedule"
                                  .tr // Translated
                            : "save_changes".tr, // Translated
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _toggleAllRemindersForDay(List<TaskModel> dayTasks) {
    if (dayTasks.isEmpty) return;
    bool allOn = dayTasks.every((task) => task.reminder);
    for (var task in dayTasks) {
      if (task.reminder == allOn) {
        taskController.addReminder(task, mode: 1);
      }
    }
  }

  void _confirmDeleteAll(bool isDark, List<TaskModel> dayTasks) {
    if (dayTasks.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(isDark),
        title: Text(
          "clear_all".tr, // Translated "Clear All"
          style: TextStyle(color: AppColors.text(isDark)),
        ),
        content: Text(
          "delete_all_msg".tr, // Translated warning
          style: TextStyle(color: AppColors.text(isDark).withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "cancel".tr, // Translated
              style: TextStyle(color: AppColors.text(isDark)),
            ),
          ),
          TextButton(
            onPressed: () {
              for (var task in dayTasks) {
                taskController.deleteWeekTask(task.id);
              }
              Navigator.pop(context);
            },
            child: Text(
              "delete_all".tr, // Translated
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode,
      builder: (context, bool dark, child) {
        return Obx(() {
          String targetDate = _getDateStringFromDayIndex(_selectedDayIndex);
          String currentDay = _days[_selectedDayIndex].tr; // Translated

          List<TaskModel> currentTasks = taskController.weekTasks
              .where((task) => task.date == targetDate)
              .toList();

          currentTasks.sort((a, b) {
            try {
              DateTime t1 = DateFormat("h:mm a").parse(a.time);
              DateTime t2 = DateFormat("h:mm a").parse(b.time);
              return t1.compareTo(t2);
            } catch (_) {
              return 0;
            }
          });

          bool isAllRemindersOn =
              currentTasks.isNotEmpty &&
              currentTasks.every((task) => task.reminder);

          return Scaffold(
            backgroundColor: AppColors.background(dark),
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                // Cleans up the newline from the translation key
                'weeks_routine'.tr.replaceAll('\n', ' '),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
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
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showTaskDialog(dark),
              backgroundColor: _primaryRed,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 55,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: _days.length,
                      itemBuilder: (context, index) {
                        bool isSelected = _selectedDayIndex == index;
                        String indexDate = _getDateStringFromDayIndex(index);
                        int taskCount = taskController.weekTasks
                            .where((t) => t.date == indexDate)
                            .length;

                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedDayIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _primaryRed
                                  : AppColors.card(dark),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: _primaryRed.withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                              border: Border.all(
                                color: isSelected
                                    ? _primaryRed
                                    : AppColors.text(dark).withOpacity(0.1),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  _days[index].tr, // Translated Day
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.text(dark).withOpacity(0.6),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                if (taskCount > 0)
                                  Positioned(
                                    top: -19,
                                    right: -20,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white
                                            : _primaryRed,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? _primaryRed
                                              : AppColors.card(dark),
                                          width: 1.5,
                                        ),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 18,
                                        minHeight: 18,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "$taskCount",
                                        style: TextStyle(
                                          color: isSelected
                                              ? _primaryRed
                                              : Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$currentDay's Plan", // Using translated day
                              style: TextStyle(
                                color: AppColors.text(dark),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${currentTasks.length} ${"tasks_scheduled".tr}", // Translated
                              style: TextStyle(
                                color: AppColors.text(dark).withOpacity(0.5),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        if (currentTasks.isNotEmpty)
                          Row(
                            children: [
                              IconButton(
                                onPressed: () =>
                                    _toggleAllRemindersForDay(currentTasks),
                                icon: Icon(
                                  isAllRemindersOn
                                      ? Icons.notifications_off_rounded
                                      : Icons.notification_add_rounded,
                                ),
                                color: isAllRemindersOn
                                    ? _primaryRed
                                    : AppColors.text(
                                        dark,
                                      ).withValues(alpha: 0.6),
                                tooltip: isAllRemindersOn
                                    ? "disable_all"
                                          .tr // Translated
                                    : "enable_all".tr, // Translated
                              ),
                              IconButton(
                                onPressed: () =>
                                    _confirmDeleteAll(dark, currentTasks),
                                icon: const Icon(Icons.delete_sweep_rounded),
                                color: AppColors.text(dark).withOpacity(0.6),
                                tooltip: "clear_all".tr, // Translated
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: currentTasks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/communication.png',
                                  width: 170,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  // Translated Empty State with Parameter
                                  "no_routine_day".trParams({
                                    'day': currentDay,
                                  }),
                                  style: TextStyle(
                                    color: AppColors.text(
                                      dark,
                                    ).withOpacity(0.4),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            itemCount: currentTasks.length,
                            itemBuilder: (context, index) {
                              final task = currentTasks[index];
                              final bool hasReminder = task.reminder;
                              return GestureDetector(
                                onTap: () =>
                                    _showTaskDialog(dark, taskToEdit: task),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.card(dark),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      if (!dark)
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: _primaryRed,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                task.text,
                                                style: TextStyle(
                                                  color: AppColors.text(dark),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 14,
                                                    color: _primaryRed,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    task.time,
                                                    style: TextStyle(
                                                      color: AppColors.text(
                                                        dark,
                                                      ).withOpacity(0.6),
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  if (hasReminder) ...[
                                                    const SizedBox(width: 8),
                                                    Icon(
                                                      Icons
                                                          .notifications_active_rounded,
                                                      size: 14,
                                                      color: _primaryRed,
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.edit_rounded,
                                          size: 18,
                                          color: AppColors.text(
                                            dark,
                                          ).withOpacity(0.2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
