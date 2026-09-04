import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Needed for Locale
import 'package:get/get.dart';
import 'package:to_do_list_app/data/controller/db_controller.dart';
import 'package:to_do_list_app/data/local/local_db_helper.dart';
import 'package:to_do_list_app/main.dart';
import 'package:to_do_list_app/data/models/user_model.dart';

class AppController extends GetxController {
  final DbController dbController = Get.put(DbController());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalDbHelper localDb = LocalDbHelper();

  Rx<UserModel?> firestoreUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadTheme();

    _loadLanguage();

    bindUser();
  }

  void _loadTheme() async {
    bool savedTheme = await localDb.getDarkMode();
    isDarkMode.value = savedTheme;
  }

  void _loadLanguage() async {
    String langCode = await localDb.getLanguage();
    if (langCode == 'km') {
      Get.updateLocale(const Locale('km', 'KH'));
    } else {
      Get.updateLocale(const Locale('en', 'US'));
    }
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
