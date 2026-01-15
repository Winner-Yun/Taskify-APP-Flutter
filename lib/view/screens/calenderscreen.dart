import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:to_do_list_app/config/appcolor.dart';
import 'package:to_do_list_app/controller/task_controller.dart'; // Import TaskController
import 'package:to_do_list_app/main.dart';
import 'package:to_do_list_app/model/task_model.dart'; // Import Model

class Calenderscreen extends StatefulWidget {
  final void Function(DateTime?, List<TaskModel>) onDayUpdated;

  const Calenderscreen({super.key, required this.onDayUpdated});

  @override
  State<Calenderscreen> createState() => _CalenderscreenState();
}

class _CalenderscreenState extends State<Calenderscreen> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay = DateTime.now();

  // CHANGE: Use TaskController directly
  final TaskController taskController = Get.find<TaskController>();

  Map<DateTime, List<TaskModel>> generateEventsFromTasks() {
    Map<DateTime, List<TaskModel>> eventMap = {};

    for (var task in taskController.tasks) {
      try {
        DateTime date = parseDate(task.date);
        // Normalize date to UTC midnight for TableCalendar
        final key = DateTime.utc(date.year, date.month, date.day);

        if (!eventMap.containsKey(key)) {
          eventMap[key] = [];
        }
        // STORE THE FULL TASK OBJECT, NOT JUST STRING
        eventMap[key]!.add(task);
      } catch (e) {
        // ignore invalid dates
      }
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

  /// 2. Get Events for a specific day
  List<TaskModel> getEventsForDay(DateTime day) {
    final events = generateEventsFromTasks();
    final key = DateTime.utc(day.year, day.month, day.day);
    return events[key] ?? [];
  }

  @override
  void initState() {
    super.initState();
    // Delay callback to ensure parent is built
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
          // Listen to task changes
          // ignore: unused_local_variable
          final _ = taskController.tasks.length;

          final eventsForDay = selectedDay != null
              ? getEventsForDay(selectedDay!)
              : <TaskModel>[];

          return Container(
            color: AppColors.background(dark),
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _buildCalendar(dark),
                const SizedBox(height: 10),
                Expanded(child: _buildEventList(dark, eventsForDay)),
              ],
            ),
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
        // Pass the List<TaskModel> back to parent
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

  // ==========================================
  // UPDATED LIST WITH REMINDER NOTE
  // ==========================================
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

                            // ---- SHOW NOTE IF REMINDER IS ON ----
                            if (task.reminder) ...[
                              const SizedBox(width: 12),
                              Icon(
                                Icons.alarm,
                                size: 14,
                                color: AppColors.primary(dark),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Reminder On",
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
              "No events for this day...",
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
