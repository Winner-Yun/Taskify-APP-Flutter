import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list_app/core/constants/appcolor.dart';
import 'package:to_do_list_app/data/controller/app_controller.dart';
import 'package:to_do_list_app/data/controller/task_controller.dart';
import 'package:to_do_list_app/main.dart';
import 'package:to_do_list_app/data/models/task_model.dart';
import 'package:to_do_list_app/modules/task/add_update_list.dart';

class Homepagescreen extends StatefulWidget {
  final VoidCallback onGoSetting;
  final Function(DateTime) onDateSelected;
  final Function(int mode, String dayValue) onModeChanged;
  final int initialMode; // 0=Cal, 1=Week, 2=Day

  const Homepagescreen({
    super.key,
    required this.onGoSetting,
    required this.onDateSelected,
    required this.onModeChanged,
    this.initialMode = 0,
  });

  @override
  State<Homepagescreen> createState() => _HomepagescreenState();
}

class _HomepagescreenState extends State<Homepagescreen> {
  final TaskController taskController = Get.put(TaskController());
  final AppController appController = Get.find<AppController>();

  String searchQuery = "";
  late int currentMode;
  DateTime selectedDay = DateTime.now();

  final List<String> weekDays = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];
  late String selectedRoutineDay;
  late String fullRoutineDayName;

  @override
  void initState() {
    super.initState();
    currentMode = widget.initialMode;
    fullRoutineDayName = DateFormat('EEEE').format(DateTime.now());
    selectedRoutineDay = DateFormat('E').format(DateTime.now());
  }

  @override
  void didUpdateWidget(Homepagescreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialMode != widget.initialMode) {
      setState(() {
        currentMode = widget.initialMode;
      });
    }
  }

  void _switchMode(int mode) {
    setState(() {
      currentMode = mode;
    });
    if (mode == 1) {
      widget.onModeChanged(1, selectedRoutineDay);
    } else if (mode == 2) {
      widget.onModeChanged(2, "Daily");
    } else {
      widget.onModeChanged(0, selectedDay.toIso8601String());
      widget.onDateSelected(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode.value;

    String titleText = "";
    if (currentMode == 2) {
      titleText = "everyday_routine".tr;
    } else if (currentMode == 1) {
      titleText = "${fullRoutineDayName.tr}${"routine_for".tr}";
    } else {
      if (_isSameDay(selectedDay, DateTime.now())) {
        titleText = "todays_task".tr;
      } else {
        String monthRaw = DateFormat('MMM').format(selectedDay);
        String dayNum = selectedDay.day.toString();
        titleText = "${monthRaw.tr} $dayNum ${"tasks".tr}";
      }
    }

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildheaderTitle(isDark),
          const SizedBox(height: 20),
          _buildModeToggle(isDark),
          const SizedBox(height: 20),
          if (currentMode != 2) _buildTabbar(isDark), // Hide tabbar for Daily
          if (currentMode != 2) const SizedBox(height: 10),
          Text(
            titleText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.text(isDark),
            ),
          ),
          const SizedBox(height: 5),
          Expanded(child: _buildTaskList(isDark)),
        ],
      ),
    );
  }

  Widget _buildModeToggle(bool isDark) {
    return Container(
      height: 45,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.primary(isDark).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          _buildToggleBtn(
            "calendar".tr, // Translated
            currentMode == 0,
            isDark,
            () => _switchMode(0),
          ),
          _buildToggleBtn(
            "weekly".tr, // Translated
            currentMode == 1,
            isDark,
            () => _switchMode(1),
          ),
          _buildToggleBtn(
            "daily".tr, // Translated
            currentMode == 2,
            isDark,
            () => _switchMode(2),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(
    String text,
    bool isActive,
    bool isDark,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary(isDark) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : AppColors.text(isDark).withOpacity(0.6),
              fontWeight: FontWeight.bold,
              fontSize: 12, // Adjusted font size for Khmer
            ),
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildheaderTitle(bool isDark) {
    final hour = DateTime.now().hour;
    String greeting = hour < 12
        ? "good_morning".tr
        : (hour < 17 ? "good_afternoon".tr : "good_evening".tr);

    return Obx(() {
      final user = appController.firestoreUser.value;
      final name = user?.name ?? "User";
      final imageStr = user?.profileImage ?? "";
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: greeting,
                  style: TextStyle(color: AppColors.text(isDark)),
                ),
                TextSpan(
                  text: "\n$name",
                  style: TextStyle(
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 191, 2, 24),
                          Color.fromARGB(255, 255, 18, 125),
                        ],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: widget.onGoSetting,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 2, color: AppColors.primary(isDark)),
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
              child: ClipOval(child: _buildProfileImage(imageStr)),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildProfileImage(String imageStr) {
    if (imageStr.isEmpty) {
      return const Center(
        child: Icon(Icons.person, size: 30, color: Colors.grey),
      );
    }
    try {
      if (imageStr.startsWith('base64')) {
        return Image.memory(
          base64Decode(imageStr.split(',')[1]),
          fit: BoxFit.cover,
          width: 50,
          height: 50,
        );
      }
      if (imageStr.startsWith('http')) {
        return Image.network(
          imageStr,
          fit: BoxFit.cover,
          width: 50,
          height: 50,
        );
      }
    } catch (e) {
      // ignore: empty_catches
    }
    return const Center(
      child: Icon(Icons.person, size: 30, color: Colors.grey),
    );
  }

  Widget _buildTabbar(bool isDark) {
    if (currentMode == 1) {
      return SizedBox(
        height: 95,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: weekDays.length,
          itemBuilder: (context, i) {
            final dayShort = weekDays[i]; // Logic stays "Mon" (English)
            final isSelected = dayShort == selectedRoutineDay;

            final fullNames = [
              "Monday",
              "Tuesday",
              "Wednesday",
              "Thursday",
              "Friday",
              "Saturday",
              "Sunday",
            ];

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedRoutineDay = dayShort;
                  fullRoutineDayName = fullNames[i];
                });
                widget.onModeChanged(1, selectedRoutineDay);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Text(
                      fullNames[i].tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? Colors.red
                            : AppColors.text(isDark).withOpacity(0.5),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.red
                            : AppColors.softcontainer(isDark),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        dayShort.tr,
                        style: TextStyle(
                          fontSize: 11, // Smaller for Khmer
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : Colors.red.shade300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } else {
      final now = DateTime.now();
      final days = List.generate(7, (i) => now.add(Duration(days: i - 3)));
      return SizedBox(
        height: 95,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 7,
          itemBuilder: (context, i) {
            final day = days[i];
            final isSelected = _isSameDay(day, selectedDay);
            String dayShortRaw = DateFormat('E').format(day);

            return GestureDetector(
              onTap: () {
                setState(() => selectedDay = day);
                widget.onDateSelected(day);
                widget.onModeChanged(0, day.toIso8601String());
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Text(
                      dayShortRaw.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.red : AppColors.text(isDark),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.red
                            : AppColors.softcontainer(isDark),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        day.day.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : Colors.red.shade300,
                        ),
                      ),
                    ),
                    if (_isSameDay(day, now))
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "today".tr, // Translated "Today"
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildTaskList(bool isDark) {
    return Obx(() {
      List<TaskModel> tasks;
      if (currentMode == 2) {
        tasks = taskController.dayTasks;
      } else if (currentMode == 1) {
        tasks = taskController.weekTasks
            .where((task) => task.date == selectedRoutineDay)
            .toList();
      } else {
        final selectedDateStr = DateFormat('MMM d, yyyy').format(selectedDay);
        tasks = taskController.getTasksByDate(selectedDateStr);
      }

      tasks.sort((a, b) {
        if (a.checked != b.checked) return a.checked ? 1 : -1;
        try {
          return DateFormat(
            "h:mm a",
          ).parse(a.time).compareTo(DateFormat("h:mm a").parse(b.time));
        } catch (_) {
          return 0;
        }
      });

      if (tasks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/communication.png",
                width: 150,
                height: 150,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.task,
                  size: 100,
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                currentMode == 2
                    ? "no_daily_routines".tr
                    : (currentMode == 1
                          ? "no_routine_day".trParams({
                              'day': fullRoutineDayName.tr,
                            })
                          : "no_tasks".tr),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }

      final filteredTasks = tasks
          .where(
            (t) => t.text.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();

      return Column(
        children: [
          TextField(
            style: TextStyle(color: AppColors.text(isDark)),
            onChanged: (value) => setState(() => searchQuery = value),
            decoration: InputDecoration(
              hintText: "search".tr, // Translated
              hintStyle: TextStyle(
                color: AppColors.text(isDark).withOpacity(0.4),
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.red),
              filled: true,
              fillColor: AppColors.card(isDark),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primary(isDark),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primary(isDark),
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Text(
                      "no_result".tr, // Translated
                      style: TextStyle(
                        color: AppColors.text(isDark).withOpacity(0.5),
                        fontSize: 16,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: Column(
                        children: List.generate(filteredTasks.length, (index) {
                          return _buildTaskCard(filteredTasks[index], isDark);
                        }),
                      ),
                    ),
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildTaskCard(TaskModel task, bool isDark) {
    bool isTaskInPast = false;
    if (currentMode == 0 &&
        task.taskTimestamp != null &&
        task.taskTimestamp!.isNotEmpty) {
      DateTime? taskDateTime = DateTime.tryParse(task.taskTimestamp!);
      if (taskDateTime != null && taskDateTime.isBefore(DateTime.now())) {
        isTaskInPast = true;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task.time,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.text(isDark).withOpacity(0.6),
                ),
              ),
              Row(
                children: [
                  if (!isTaskInPast) ...[
                    GestureDetector(
                      onTap: () =>
                          taskController.addReminder(task, mode: currentMode),
                      child: Icon(
                        task.reminder ? Icons.alarm_on : Icons.alarm_add,
                        size: 20,
                        color: task.reminder
                            ? Colors.amber
                            : AppColors.primary(isDark),
                      ),
                    ),
                    const SizedBox(width: 15),
                  ],
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskHomeScreen(
                          task: task,
                          currentMode: currentMode,
                          routineDayName: selectedRoutineDay,
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 18,
                      color: AppColors.primary(isDark),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (currentMode == 2) {
                    taskController.updateDayTask(
                      task.copyWith(checked: !task.checked),
                    );
                  } else if (currentMode == 1) {
                    taskController.updateWeekTask(
                      task.copyWith(checked: !task.checked),
                    );
                  } else {
                    taskController.toggleTaskChecked(task);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: task.checked
                        ? Colors.red.shade600
                        : AppColors.background(isDark),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  child: task.checked
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.text(isDark),
                    decoration: task.checked
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (task.id.isNotEmpty) {
                    if (currentMode == 2) {
                      taskController.deleteDayTask(task.id);
                    } else if (currentMode == 1) {
                      taskController.deleteWeekTask(task.id);
                    } else {
                      taskController.deleteTask(task.id);
                    }
                  }
                },
                child: Icon(Icons.delete, size: 20, color: Colors.red.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
