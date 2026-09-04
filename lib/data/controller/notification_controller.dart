import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list_app/data/controller/db_controller.dart';
import 'package:to_do_list_app/data/models/notification_model.dart';

class NotificationController extends GetxController {
  DbController get dbController => Get.find<DbController>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _bindNotifications();
  }

  void _bindNotifications() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        notifications.bindStream(dbController.getUserNotifications(user.uid));

        ever(notifications, (List<NotificationModel> list) {
          _checkAndSyncNotificationStates(user.uid, list);
        });
      } else {
        notifications.clear();
      }
    });
  }

  void _checkAndSyncNotificationStates(
    String uid,
    List<NotificationModel> list,
  ) {
    DateTime now = DateTime.now();

    for (var item in list) {
      DateTime? scheduledDate = _extractDateFromModel(item);
      if (scheduledDate == null) continue;

      if (!item.isAlert && now.isAfter(scheduledDate)) {
        dbController.markNotificationAsAlerted(uid, item.id);
      }
      else if (item.isAlert) {
        bool isRecurring =
            item.title.startsWith("Daily") || item.title.startsWith("Routine");

        if (isRecurring && scheduledDate.day != now.day) {
          dbController.resetNotificationForNextCycle(uid, item.id, item.date);
        }
      }
    }
  }

  DateTime? _extractDateFromModel(NotificationModel item) {
    try {
      DateTime now = DateTime.now();

      RegExp timeRegex = RegExp(r"(\d{1,2}:\d{2}\s?[AP]M)");
      Match? match = timeRegex.firstMatch(item.message);

      if (match == null) return null;
      DateTime timePart = DateFormat("h:mm a").parse(match.group(0)!);

      if (item.title.startsWith("Daily")) {
        return DateTime(
          now.year,
          now.month,
          now.day,
          timePart.hour,
          timePart.minute,
        );
      } else if (item.title.startsWith("Routine")) {
        String todayDay = DateFormat('EEEE').format(now);
        if (item.date != todayDay) {
          return null; // Not today, so don't alert
        }

        return DateTime(
          now.year,
          now.month,
          now.day,
          timePart.hour,
          timePart.minute,
        );
      } else {
        DateTime datePart = DateFormat("MMM d, yyyy").parse(item.date);
        return DateTime(
          datePart.year,
          datePart.month,
          datePart.day,
          timePart.hour,
          timePart.minute,
        );
      }
    } catch (e) {
      return null;
    }
  }

  void deleteNotification(NotificationModel notification) {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    bool isRecurring =
        notification.title.startsWith("Callender") ||
        notification.title.startsWith("Daily") ||
        notification.title.startsWith("Routine") ||
        notification.title.startsWith("Special");

    if (isRecurring) {
      dbController.hideNotification(uid, notification.id);
    } else {
      dbController.deleteNotification(uid, notification.id);
    }
  }
}
