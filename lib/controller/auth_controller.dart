import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/controller/db_controller.dart';
import 'package:to_do_list_app/model/user_model.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Put DbController here so it's available app-wide
  final DbController dbController = Get.put(DbController());

  // Observable User
  final Rx<User?> firebaseUser = Rx<User?>(null);

  @override
  void onReady() {
    super.onReady();
    // 1. Just bind the stream so 'firebaseUser' stays updated.
    // 2. WE REMOVED the 'ever()' listener here.
    //    Reason: The Splash Screen now handles the initial navigation.
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  // REGISTER
  Future<void> register(String email, String password, String name) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create User Model
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

      // Navigate to Main App manually
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

  // LOGIN
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Navigate to Main App manually
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

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
    // Navigate to Welcome Screen manually
    Get.offAllNamed('/welcome');
  }
}
