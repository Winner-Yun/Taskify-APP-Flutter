import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/data/controller/db_controller.dart';
import 'package:to_do_list_app/data/models/user_model.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DbController dbController = Get.put(DbController());

  final Rx<User?> firebaseUser = Rx<User?>(null);

  @override
  void onReady() {
    super.onReady();
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  Future<void> register(String email, String password, String name) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel newUser = UserModel(
        id: cred.user!.uid,
        name: name,
        email: email,
        password: "", // Security: Don't save password
        createdAt: DateTime.now().toString(),
        profileImage: "",
        tasks: [],
        notifications: [],
        reminders: [],
      );

      if (cred.user != null) {
        await dbController.createUserInFirestore(newUser, cred.user!.uid);
      }

      Get.offAllNamed('/appmain');

      Get.snackbar(
        "Success",
        "Account created!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already signed up. Go to sign in.';
      } else if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is badly formatted.';
      } else {
        message = e.message ?? "Registration failed.";
      }
      Get.snackbar(
        "Sign Up Failed",
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      Get.offAllNamed('/appmain');
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = 'Invalid email or password';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is badly formatted.';
      } else {
        message = e.message ?? "Authentication failed.";
      }
      Get.snackbar(
        "Login Failed",
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "An unexpected error occurred.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    Get.offAllNamed('/welcome');
  }
}
