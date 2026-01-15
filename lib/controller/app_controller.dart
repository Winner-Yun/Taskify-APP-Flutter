import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/controller/db_controller.dart';
import 'package:to_do_list_app/data/local_db_helper.dart'; // Import SQLite Helper
import 'package:to_do_list_app/main.dart'; // To access isDarkMode global
import 'package:to_do_list_app/model/user_model.dart';

class AppController extends GetxController {
  final DbController dbController = Get.put(DbController());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalDbHelper localDb = LocalDbHelper();

  Rx<UserModel?> firestoreUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    // 1. Load Dark Mode Preference from SQL
    _loadTheme();

    // 2. Bind User Data
    bindUser();
  }

  void _loadTheme() async {
    bool savedTheme = await localDb.getDarkMode();
    isDarkMode.value = savedTheme;
  }

  void bindUser() {
    String? uid = _auth.currentUser?.uid;
    if (uid != null) {
      firestoreUser.bindStream(dbController.getUserStream(uid));
    }

    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        firestoreUser.bindStream(dbController.getUserStream(user.uid));
      } else {
        firestoreUser.value = null;
      }
    });
  }
}
