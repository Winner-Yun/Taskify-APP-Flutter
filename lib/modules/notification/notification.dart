import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list_app/core/constants/appcolor.dart';
import 'package:to_do_list_app/data/controller/notification_controller.dart';
import 'package:to_do_list_app/main.dart';
import 'package:to_do_list_app/data/models/notification_model.dart';

final String today = DateFormat('MMM d, yyyy').format(DateTime.now());

class NotificationScreen extends StatelessWidget {
  final int currentMode;
  NotificationScreen({super.key, this.currentMode = 0});
  final NotificationController controller = Get.put(NotificationController());

  DateTime _parseDate(String date) {
    try {
      return DateFormat("MMM d, yyyy").parse(date);
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode,
      builder: (context, bool dark, _) {
        return Obx(() {
          final allNotifications = controller.notifications;

          final activeNotifications = allNotifications.where((item) {
            if (item.title == "Special Event") return false;

            if (currentMode == 2) {
              return item.title == "Daily Task";
            } else if (currentMode == 1) {
              return item.title == "Routine";
            } else {
              return item.title != "Daily Task" && item.title != "Routine";
            }
          }).toList();

          if (activeNotifications.isEmpty) {
            return _buildEmptyState(dark);
          }

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
            "no_notifications".tr,
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
          _buildSectionTitle("recent".tr, dark),
          ...recent.map((item) => _buildNotificationCard(item, dark)),
        ],
        if (older.isNotEmpty) ...[
          _buildSectionTitle("last_7_days".tr, dark),
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
                    onTap: () => controller.deleteNotification(item),
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
                      child: Text(
                        "remove".tr,
                        style: const TextStyle(
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
