import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list_app/config/appcolor.dart';
import 'package:to_do_list_app/controller/notification_controller.dart';
import 'package:to_do_list_app/main.dart';
import 'package:to_do_list_app/model/notification_model.dart';

final String today = DateFormat('MMM d, yyyy').format(DateTime.now());

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final NotificationController controller = Get.put(NotificationController());

  DateTime _parseDate(String date) {
    try {
      return DateFormat("MMM d, yyyy").parse(date);
    } catch (e) {
      return DateTime.now();
    }
  }

  // --- NEW LOGIC: Filter out Future Notifications ---
  bool _shouldShowNotification(NotificationModel item) {
    try {
      // 1. Parse the Scheduled Date (e.g. "Jan 20, 2026")
      DateTime datePart = DateFormat("MMM d, yyyy").parse(item.date);

      // 2. Extract Time from Message (e.g. "10:30 AM")
      // Regex looks for pattern like "10:30 AM" or "9:00 PM"
      RegExp timeRegex = RegExp(r"(\d{1,2}:\d{2}\s?[AP]M)");
      Match? match = timeRegex.firstMatch(item.message);

      if (match != null) {
        String timeStr = match.group(0)!;
        DateTime timePart = DateFormat("h:mm a").parse(timeStr);

        // 3. Combine Date + Time
        DateTime scheduledFullTime = DateTime(
          datePart.year,
          datePart.month,
          datePart.day,
          timePart.hour,
          timePart.minute,
        );

        // 4. SHOW ONLY IF: Current Time > Scheduled Time
        return DateTime.now().isAfter(scheduledFullTime);
      }

      // Fallback: If no time found, just check the Day
      // If the date is Today or Past -> Show it. If Future -> Hide it.
      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);

      // return true if datePart is BEFORE or SAME as today
      return !datePart.isAfter(todayMidnight);
    } catch (e) {
      // If parsing fails, default to showing it to avoid hiding real data
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode,
      builder: (context, bool dark, _) {
        return Obx(() {
          // 1. GET ALL & FILTER
          // We only keep notifications that have "passed" (are in the past)
          final allNotifications = controller.notifications;
          final activeNotifications = allNotifications
              .where((item) => _shouldShowNotification(item))
              .toList();

          if (activeNotifications.isEmpty) {
            return _buildEmptyState(dark);
          }

          // 2. GROUP BY DATE (Recent vs Older)
          final todayDate = _parseDate(today);
          final sevenDaysAgo = todayDate.subtract(const Duration(days: 1));

          final recent = activeNotifications.where((item) {
            final date = _parseDate(item.date);
            return date.isAfter(sevenDaysAgo) ||
                date.isAtSameMomentAs(sevenDaysAgo);
          }).toList();

          final older = activeNotifications.where((item) {
            return _parseDate(item.date).isBefore(sevenDaysAgo);
          }).toList();

          return Scaffold(
            backgroundColor: AppColors.background(dark),
            body: _buildNotificationList(dark, recent, older),
          );
        });
      },
    );
  }

  Widget _buildEmptyState(bool dark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 60,
            color: AppColors.text(dark).withOpacity(0.3),
          ),
          const SizedBox(height: 10),
          Text(
            "No notifications yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text(dark).withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(
    bool dark,
    List<NotificationModel> recent,
    List<NotificationModel> older,
  ) {
    return ListView(
      padding: const EdgeInsets.only(top: 10),
      children: [
        if (recent.isNotEmpty) ...[
          _buildSectionTitle("Recent", dark),
          ...recent.map((item) => _buildNotificationCard(item, dark)),
        ],
        if (older.isNotEmpty) ...[
          _buildSectionTitle("Last 7 days", dark),
          ...older.map((item) => _buildNotificationCard(item, dark)),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool dark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.text(dark),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel item, bool dark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(dark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!dark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary(dark),
                  AppColors.primary(dark).withOpacity(0.6),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                "assets/icons/logoApp.png",
                fit: BoxFit.contain,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.text(dark),
                      ),
                    ),
                    Text(
                      item.date,
                      style: TextStyle(
                        color: AppColors.text(dark).withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.message,
                  style: TextStyle(
                    color: AppColors.text(dark).withOpacity(0.8),
                    height: 1.4,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => controller.deleteNotification(item.id),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Remove",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
