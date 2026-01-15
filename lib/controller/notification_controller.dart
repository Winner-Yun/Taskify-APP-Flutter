import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/controller/db_controller.dart';
import 'package:to_do_list_app/model/notification_model.dart';

class NotificationController extends GetxController {
  // Use lazy loading to prevent initialization errors
  DbController get dbController => Get.find<DbController>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _bindNotifications();
  }

  void _bindNotifications() {
    String? uid = _auth.currentUser?.uid;
    if (uid != null) {
      notifications.bindStream(dbController.getUserNotifications(uid));
    } else {
      notifications.clear();
    }
  }

  void deleteNotification(String id) {
    String? uid = _auth.currentUser?.uid;
    if (uid != null) dbController.deleteNotification(uid, id);
  }
}
