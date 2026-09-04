import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/core/constants/appcolor.dart';
import 'package:to_do_list_app/data/controller/app_controller.dart';
import 'package:to_do_list_app/main.dart'; // For isDarkMode
import 'package:to_do_list_app/modules/calendar/calenderscreen.dart';
import 'package:to_do_list_app/modules/routine/day_routine.dart';
import 'package:to_do_list_app/modules/notification/special_reminder.dart';
import 'package:to_do_list_app/modules/routine/week_routine.dart';

class MenuGridSheet extends StatefulWidget {
  final DateTime selectedDate;

  const MenuGridSheet({super.key, required this.selectedDate});

  @override
  State<MenuGridSheet> createState() => _MenuGridSheetState();
}

class _MenuGridSheetState extends State<MenuGridSheet> {
  final AppController appController = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode,
      builder: (context, bool dark, child) {
        return Scaffold(
          backgroundColor: AppColors.background(dark),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "update_prompt".tr, // Translated
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                      color: AppColors.text(dark),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "select_option".tr, // Translated
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.text(dark).withOpacity(0.5),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.85,
                      children: [
                        _buildModernCard(
                          context,
                          title: "weeks_routine".tr, // Translated
                          icon: Icons.view_column_rounded,
                          gradientColors: [
                            Colors.orangeAccent,
                            Colors.deepOrange,
                          ],
                          isDark: dark,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WeekRoutineScreen(),
                            ),
                          ),
                        ),

                        _buildModernCard(
                          context,
                          title: "days_routine".tr, // Translated
                          icon: Icons.view_stream_rounded,
                          gradientColors: [Colors.blueAccent, Colors.blue],
                          isDark: dark,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DayRoutineScreen(),
                            ),
                          ),
                        ),

                        _buildModernCard(
                          context,
                          title: "special_reminder".tr, // Translated
                          icon: Icons.notifications_active_rounded,
                          gradientColors: [
                            Colors.purpleAccent,
                            Colors.deepPurple,
                          ],
                          isDark: dark,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SpecialReminderScreen(),
                            ),
                          ),
                        ),

                        _buildModernCard(
                          context,
                          title: "calendar_mode".tr, // Translated
                          icon: Icons.calendar_month_rounded,
                          gradientColors: [
                            const Color(0xFFFF3B3B),
                            const Color(0xFFD32F2F),
                          ],
                          isDark: dark,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Calenderscreen(
                                initialDate: widget.selectedDate,
                                onDayUpdated: (date, events) {},
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    gradientColors[0].withOpacity(0.8),
                    gradientColors[1].withOpacity(0.8),
                  ]
                : gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              child: Icon(
                icon,
                size: 90,
                color: Colors.white.withOpacity(0.15),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
