import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // REQUIRED: Import this for DateFormat
import 'package:to_do_list_app/config/appcolor.dart';
import 'package:to_do_list_app/controller/app_controller.dart';
import 'package:to_do_list_app/controller/task_controller.dart';
import 'package:to_do_list_app/main.dart';
import 'package:to_do_list_app/model/task_model.dart';
import 'package:to_do_list_app/view/screens/add_update_list.dart';

class Homepagescreen extends StatefulWidget {
  final VoidCallback onGoSetting;

  const Homepagescreen({super.key, required this.onGoSetting});

  @override
  State<Homepagescreen> createState() => _HomepagescreenState();
}

class _HomepagescreenState extends State<Homepagescreen> {
  final TaskController taskController = Get.put(TaskController());
  final AppController appController = Get.find<AppController>();

  String searchQuery = "";
  DateTime selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode.value;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildheaderTitle(isDark),
          const SizedBox(height: 20),
          _buildTabbar(isDark),
          const SizedBox(height: 10),
          Text(
            "Today's Task",
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

  // ==========================================
  //  HEADER
  // ==========================================
  Widget _buildheaderTitle(bool isDark) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour >= 5 && hour < 12) {
      greeting = "Good Morning, ";
    } else if (hour >= 12 && hour < 17) {
      greeting = "Good Afternoon, ";
    } else {
      greeting = "Good Evening, ";
    }

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
            child: Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2,
                      color: AppColors.primary(isDark),
                    ),
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  ),
                  child: ClipOval(child: _buildProfileImage(imageStr)),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 1, color: Colors.red),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, size: 10, color: Colors.red),
                  ),
                ),
              ],
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
    if (imageStr.startsWith('base64')) {
      try {
        final cleanBase64 = imageStr.split(',')[1];
        return Image.memory(
          base64Decode(cleanBase64),
          fit: BoxFit.cover,
          width: 50,
          height: 50,
          errorBuilder: (_, __, ___) =>
              const Center(child: Icon(Icons.error, size: 20)),
        );
      } catch (e) {
        return const Center(
          child: Icon(Icons.person, size: 30, color: Colors.grey),
        );
      }
    }
    if (imageStr.startsWith('http')) {
      return Image.network(
        imageStr,
        fit: BoxFit.cover,
        width: 50,
        height: 50,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.person, size: 30, color: Colors.grey),
        ),
      );
    }
    return const Center(
      child: Icon(Icons.person, size: 30, color: Colors.grey),
    );
  }

  Widget _buildTabbar(bool isDark) {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.add(Duration(days: i - 3)));

    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, i) {
          final day = days[i];
          final isSelected =
              day.year == selectedDay.year &&
              day.month == selectedDay.month &&
              day.day == selectedDay.day;

          return GestureDetector(
            onTap: () => setState(() => selectedDay = day),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Text(
                    [
                      "Mon",
                      "Tue",
                      "Wed",
                      "Thu",
                      "Fri",
                      "Sat",
                      "Sun",
                    ][day.weekday - 1],
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
                        color: isSelected ? Colors.white : Colors.red.shade300,
                      ),
                    ),
                  ),
                  if (day.day == now.day &&
                      day.month == now.month &&
                      day.year == now.year)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        "Today",
                        style: TextStyle(
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

  // ==========================================
  //  MODIFIED TASK LIST (SORT: CHECKED + TIME)
  // ==========================================
  Widget _buildTaskList(bool isDark) {
    return Obx(() {
      final selectedDateStr =
          "${_monthToStr(selectedDay.month)} ${selectedDay.day}, ${selectedDay.year}";

      // 1. GET TASKS
      final tasks = taskController.getTasksByDate(selectedDateStr);

      // 2. SORT TASKS
      tasks.sort((a, b) {
        // A. Primary Sort: Checked Status (Unchecked first, Checked last)
        if (a.checked != b.checked) {
          return a.checked ? 1 : -1;
        }

        // B. Secondary Sort: Time (AM to PM)
        // Parse time string (e.g. "10:30 AM") to compare
        try {
          final dateA = DateFormat("h:mm a").parse(a.time);
          final dateB = DateFormat("h:mm a").parse(b.time);
          return dateA.compareTo(dateB);
        } catch (e) {
          return 0; // If time format is invalid, keep original order
        }
      });

      // 3. CHECK IF EMPTY
      if (tasks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/communication.png",
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),
              const Text(
                "No tasks for today!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }

      // 4. FILTER (Search)
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
              hintText: "Search...",
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
                      "No result found",
                      style: TextStyle(
                        color: AppColors.text(isDark).withOpacity(0.5),
                        fontSize: 16,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Column(
                        children: List.generate(filteredTasks.length, (index) {
                          final task = filteredTasks[index];
                          return _buildTaskCard(task, isDark);
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

    if (task.taskTimestamp != null && task.taskTimestamp!.isNotEmpty) {
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
                      onTap: () => taskController.addReminder(task),
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
                        builder: (context) => TaskHomeScreen(task: task),
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
                onTap: () => taskController.toggleTaskChecked(task),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.text(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (task.id.isNotEmpty) taskController.deleteTask(task.id);
                },
                child: Icon(Icons.delete, size: 20, color: Colors.red.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _monthToStr(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }
}
