import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list_app/core/constants/appcolor.dart';
import 'package:to_do_list_app/data/controller/task_controller.dart';
import 'package:to_do_list_app/main.dart';
import 'package:to_do_list_app/data/models/task_model.dart';

class SpecialReminderScreen extends StatefulWidget {
  const SpecialReminderScreen({super.key});

  @override
  State<SpecialReminderScreen> createState() => _SpecialReminderScreenState();
}

class _SpecialReminderScreenState extends State<SpecialReminderScreen> {
  final TaskController taskController = Get.find<TaskController>();
  final Color _primaryRed = const Color.fromARGB(255, 191, 2, 24);

  void _showTaskDialog(bool isDark, {TaskModel? taskToEdit}) {
    TextEditingController taskInputController = TextEditingController();
    TextEditingController monthController = TextEditingController();
    TextEditingController dayController = TextEditingController();

    TimeOfDay? selectedTime;
    String timeText = "set_time_default".tr; // Translated

    String? titleError;
    String? dateErrorText; // Error message for date fields

    if (taskToEdit != null) {
      taskInputController.text = taskToEdit.text;

      try {
        DateTime tempDate = DateFormat("MMM d").parse(taskToEdit.date);
        monthController.text = tempDate.month.toString();
        dayController.text = tempDate.day.toString();
      } catch (_) {
        try {
          DateTime tempDate = DateFormat("MMM d, yyyy").parse(taskToEdit.date);
          monthController.text = tempDate.month.toString();
          dayController.text = tempDate.day.toString();
        } catch (e) {
          debugPrint("Date parse error: $e");
        }
      }

      if (taskToEdit.time.isNotEmpty && taskToEdit.time != "All Day") {
        try {
          DateTime parsed = DateFormat("h:mm a").parse(taskToEdit.time);
          selectedTime = TimeOfDay.fromDateTime(parsed);
          timeText = taskToEdit.time;
        } catch (_) {}
      }
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
                            ? "new_special_event"
                                  .tr // Translated
                            : "edit_event".tr, // Translated
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
                            taskController.deleteSpecialTask(taskToEdit.id);
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
                        hintText: "event_name_hint".tr, // Translated
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
                          Icons.star_rounded,
                          color: AppColors.text(isDark).withOpacity(0.7),
                        ),
                        errorText: titleError,
                        errorStyle: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: Theme(
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
                            controller: monthController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            style: TextStyle(color: AppColors.text(isDark)),
                            decoration: InputDecoration(
                              hintText: "month".tr, // Translated
                              hintStyle: TextStyle(
                                color: AppColors.text(isDark).withOpacity(0.6),
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
                                Icons.calendar_view_month,
                                color: _primaryRed,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Theme(
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
                            controller: dayController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            style: TextStyle(color: AppColors.text(isDark)),
                            decoration: InputDecoration(
                              hintText: "day".tr, // Translated
                              hintStyle: TextStyle(
                                color: AppColors.text(isDark).withOpacity(0.6),
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
                                Icons.calendar_today,
                                color: _primaryRed,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (dateErrorText != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 5),
                      child: Text(
                        dateErrorText!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  const SizedBox(height: 15),

                  GestureDetector(
                    onTap: () async {
                      final bool dark =
                          Theme.of(context).brightness == Brightness.dark;
                      final Color contentColor = dark
                          ? Colors.white
                          : Colors.black;

                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime:
                            selectedTime ??
                            const TimeOfDay(hour: 0, minute: 0),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              textSelectionTheme: TextSelectionThemeData(
                                cursorColor: AppColors.text(dark),
                                selectionColor: AppColors.text(
                                  dark,
                                ).withValues(alpha: 0.2),
                                selectionHandleColor: AppColors.text(dark),
                              ),
                              colorScheme: dark
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
                                backgroundColor: dark
                                    ? AppColors.card(true)
                                    : const Color(0xfff3ecfa),
                                hourMinuteTextColor: contentColor,
                                hourMinuteColor: dark
                                    ? AppColors.primary(true).withOpacity(0.2)
                                    : const Color.fromARGB(255, 255, 212, 212),
                                dayPeriodTextColor: contentColor,
                                dayPeriodColor: dark
                                    ? AppColors.primary(true).withOpacity(0.2)
                                    : const Color.fromARGB(255, 255, 230, 230),
                                dialHandColor: AppColors.primary(isDark),
                                dialBackgroundColor: dark
                                    ? AppColors.card(true).withOpacity(0.3)
                                    : const Color.fromARGB(255, 255, 230, 230),
                                dialTextColor: contentColor,
                                entryModeIconColor: contentColor,
                                cancelButtonStyle: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all(
                                    contentColor,
                                  ),
                                ),
                                confirmButtonStyle: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all(
                                    contentColor,
                                  ),
                                ),
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
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selectedTime != null
                                ? Icons.access_time_filled
                                : Icons.access_time,
                            color: _primaryRed,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            timeText,
                            style: TextStyle(
                              color: AppColors.text(isDark),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          if (selectedTime != null)
                            GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedTime = null;
                                  timeText = "set_time_default"
                                      .tr; // Reset translation
                                });
                              },
                              child: Icon(
                                Icons.close,
                                color: AppColors.text(isDark).withOpacity(0.5),
                              ),
                            )
                          else
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: AppColors.text(isDark).withOpacity(0.3),
                              size: 14,
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: _primaryRed.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active_rounded,
                          color: _primaryRed,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "reminder_always_on".tr, // Translated
                          style: TextStyle(
                            color: _primaryRed,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.lock, color: _primaryRed, size: 18),
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
                          titleError = taskInputController.text.trim().isEmpty
                              ? "event_empty_error"
                                    .tr // Translated
                              : null;

                          String mStr = monthController.text.trim();
                          String dStr = dayController.text.trim();

                          dateErrorText = null;
                          int m = int.tryParse(mStr) ?? 0;
                          int d = int.tryParse(dStr) ?? 0;

                          if (m < 1 || m > 12) {
                            dateErrorText = "month_error".tr; // Translated
                          } else if (d < 1 || d > 31) {
                            dateErrorText = "day_error".tr; // Translated
                          }
                        });

                        if (titleError == null && dateErrorText == null) {
                          int m = int.parse(monthController.text.trim());
                          int d = int.parse(dayController.text.trim());

                          DateTime displayDateObj = DateTime(2024, m, d);

                          String displayDate = DateFormat(
                            "MMM d",
                            "en_US",
                          ).format(displayDateObj);

                          String displayTime = selectedTime != null
                              ? selectedTime!.format(context)
                              : "12:00 AM";

                          String mm = m.toString().padLeft(2, '0');
                          String dd = d.toString().padLeft(2, '0');

                          int h = selectedTime?.hour ?? 0;
                          int min = selectedTime?.minute ?? 0;
                          String hh = h.toString().padLeft(2, '0');
                          String minStr = min.toString().padLeft(2, '0');

                          String specialTimestamp =
                              "0000-$mm-${dd}T$hh:$minStr:00.000";

                          final newTask = TaskModel(
                            id: taskToEdit?.id ?? '',
                            date: displayDate,
                            time: displayTime,
                            text: taskInputController.text.trim(),
                            checked: false,
                            reminder: true, // FORCED ON
                            reminderTime: specialTimestamp,
                            taskTimestamp: specialTimestamp,
                          );

                          if (taskToEdit == null) {
                            taskController.addSpecialTask(newTask);
                          } else {
                            taskController.updateSpecialTask(newTask);
                          }
                          Navigator.pop(context);
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
                            ? "save_event"
                                  .tr // Translated
                            : "update_event".tr, // Translated
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode,
      builder: (context, bool dark, child) {
        return Scaffold(
          backgroundColor: AppColors.background(dark),
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "special_reminders_title".tr, // Translated
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "upcoming_events".tr, // Translated
                    style: TextStyle(
                      color: AppColors.text(dark),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Obx(() {
                    if (taskController.specialTasks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_note_rounded,
                              size: 100,
                              color: AppColors.text(dark).withOpacity(0.1),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              "no_special_events".tr, // Translated
                              style: TextStyle(
                                color: AppColors.text(dark).withOpacity(0.4),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: taskController.specialTasks.length,
                        itemBuilder: (context, index) {
                          final task = taskController.specialTasks[index];
                          return GestureDetector(
                            onTap: () =>
                                _showTaskDialog(dark, taskToEdit: task),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
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
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _primaryRed,
                                      borderRadius: BorderRadius.circular(4),
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
                                        Text(
                                          "${task.date} • ${task.time}",
                                          style: TextStyle(
                                            color: AppColors.text(
                                              dark,
                                            ).withOpacity(0.6),
                                            fontSize: 13,
                                          ),
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
                          );
                        },
                      );
                    }
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
