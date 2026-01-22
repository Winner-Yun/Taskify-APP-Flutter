import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list_app/config/appcolor.dart';
import 'package:to_do_list_app/controller/task_controller.dart';
import 'package:to_do_list_app/main.dart';
import 'package:to_do_list_app/model/task_model.dart';

class TaskHomeScreen extends StatefulWidget {
  final TaskModel? task;
  final DateTime? initialDate;
  final int currentMode; // 0=Cal, 1=Week, 2=Day
  final String? routineDayName;

  const TaskHomeScreen({
    super.key,
    this.task,
    this.initialDate,
    this.currentMode = 0,
    this.routineDayName,
  });

  @override
  State<TaskHomeScreen> createState() => _TaskHomeScreenState();
}

class _TaskHomeScreenState extends State<TaskHomeScreen> {
  final TaskController controller = Get.find<TaskController>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      titleController.text = widget.task!.text;
      timeController.text = widget.task!.time;
    }
  }

  void pickTime(bool dark) async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color contentColor = isDark ? Colors.white : Colors.black;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: AppColors.text(dark),
              selectionColor: AppColors.text(dark).withValues(alpha: 0.2),
              selectionHandleColor: AppColors.text(dark),
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
              cancelButtonStyle: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(contentColor),
              ),
              confirmButtonStyle: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(contentColor),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
        timeController.text = format12Hour(picked);
      });
    }
  }

  void saveTask() {
    if (!formKey.currentState!.validate()) return;

    String finalDateString;
    String safeIsoTimestamp = "";

    if (widget.currentMode == 2) {
      // DAILY
      finalDateString = "Daily";
      safeIsoTimestamp = DateTime.now().toIso8601String();
    } else if (widget.currentMode == 1) {
      // WEEK ROUTINE
      if (widget.task != null) {
        finalDateString = widget.task!.date;
      } else {
        // Use English day name for Week Logic consistency if possible,
        // or ensure week routine logic matches translated days.
        // For safety, defaulting to Standard English E (Mon, Tue) for logic storage is safer
        // unless you refactor the whole DB to use numbers.
        // Assuming routineDayName passed in is the stored value (e.g. "Mon").
        finalDateString =
            widget.routineDayName ?? DateFormat('E').format(DateTime.now());
      }
      safeIsoTimestamp = DateTime.now().toIso8601String();
    } else {
      // REGULAR TASK
      DateTime dateBase;
      if (widget.task != null) {
        try {
          dateBase = DateFormat('MMM d, yyyy').parse(widget.task!.date);
        } catch (e) {
          dateBase = DateTime.now();
        }
      } else {
        dateBase = widget.initialDate ?? DateTime.now();
      }
      finalDateString = DateFormat('MMM d, yyyy').format(dateBase);

      TimeOfDay finalTime;
      if (selectedTime != null) {
        finalTime = selectedTime!;
      } else if (widget.task != null) {
        try {
          DateTime parsedTime = DateFormat("h:mm a").parse(widget.task!.time);
          finalTime = TimeOfDay.fromDateTime(parsedTime);
        } catch (e) {
          finalTime = TimeOfDay.now();
        }
      } else {
        finalTime = TimeOfDay.now();
      }

      DateTime finalDateTime = DateTime(
        dateBase.year,
        dateBase.month,
        dateBase.day,
        finalTime.hour,
        finalTime.minute,
      );
      safeIsoTimestamp = finalDateTime.toIso8601String();
    }

    if (widget.task != null) {
      // UPDATE
      String? updatedReminderTime = widget.task!.reminderTime;
      if (widget.task!.reminder) {
        if (widget.currentMode == 0) {
          updatedReminderTime = safeIsoTimestamp;
        } else {
          updatedReminderTime = widget.task!.time;
        }
      }

      final updatedTask = TaskModel(
        id: widget.task!.id,
        text: titleController.text,
        time: timeController.text,
        date: finalDateString,
        checked: widget.task!.checked,
        reminder: widget.task!.reminder,
        reminderTime: updatedReminderTime,
        taskTimestamp: safeIsoTimestamp,
      );

      if (widget.currentMode == 2) {
        controller.updateDayTask(updatedTask);
      } else if (widget.currentMode == 1) {
        controller.updateWeekTask(updatedTask);
      } else {
        controller.updateTask(updatedTask);
      }
    } else {
      // ADD NEW
      final newTask = TaskModel(
        id: "",
        text: titleController.text,
        time: timeController.text,
        date: finalDateString,
        checked: false,
        reminder: false,
        taskTimestamp: safeIsoTimestamp,
      );

      if (widget.currentMode == 2) {
        controller.addDayTask(newTask);
      } else if (widget.currentMode == 1) {
        controller.addWeekTask(newTask);
      } else {
        controller.addTask(newTask);
      }
    }
    Navigator.pop(context);

    titleController.clear();
    timeController.clear();
  }

  String format12Hour(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode,
      builder: (context, bool dark, child) {
        return Scaffold(
          backgroundColor: AppColors.background(dark),
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
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
            title: Text(
              widget.task != null
                  ? 'edit_task'
                        .tr // Translated
                  : 'add_task'.tr, // Translated
              style: const TextStyle(color: Colors.white),
            ),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card(dark),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            textSelectionTheme: TextSelectionThemeData(
                              cursorColor: AppColors.text(dark),
                              selectionHandleColor: AppColors.text(dark),
                              selectionColor: AppColors.text(
                                dark,
                              ).withValues(alpha: 0.2),
                            ),
                          ),
                          child: TextFormField(
                            cursorColor: AppColors.text(dark),
                            controller: titleController,
                            style: TextStyle(color: AppColors.text(dark)),
                            maxLength: 50,
                            validator: (v) {
                              if (v!.isEmpty) {
                                return "enter_task".tr; // Translated
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "activity".tr, // Translated
                              labelStyle: TextStyle(
                                color: AppColors.text(dark),
                              ),
                              counterStyle: TextStyle(
                                color: AppColors.text(dark).withOpacity(0.6),
                                fontSize: 12,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1,
                                  color: AppColors.text(dark),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(
                                Icons.task,
                                color: AppColors.text(dark),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextFormField(
                          controller: timeController,
                          readOnly: true,
                          onTap: () => pickTime(dark),
                          style: TextStyle(color: AppColors.text(dark)),
                          validator: (v) =>
                              v!.isEmpty ? "pick_time".tr : null, // Translated
                          decoration: InputDecoration(
                            labelText: "time".tr, // Translated
                            labelStyle: TextStyle(color: AppColors.text(dark)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 1,
                                color: AppColors.text(dark),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.access_time,
                              color: AppColors.text(dark),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: saveTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary(dark),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              widget.task != null
                                  ? 'update_task'
                                        .tr // Translated
                                  : 'add_task_btn'.tr, // Translated
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
