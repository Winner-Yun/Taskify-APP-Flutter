import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:to_do_list_app/data/controller/db_controller.dart';
import 'package:to_do_list_app/data/models/user_model.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DbController dbController = Get.put(DbController());

  final Rx<User?> firebaseUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        UserModel newUser = UserModel(
          id: user.uid,
          name: user.displayName ?? 'Google User',
          email: user.email ?? '',
          password: "",
          createdAt: DateTime.now().toString(),
          profileImage: user.photoURL ?? "",
          tasks: [],
          notifications: [],
          reminders: [],
        );
        
        await dbController.createUserInFirestore(newUser, user.uid);
      }

      isLoading.value = false;
      Get.offAllNamed('/appmain');
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Login Failed",
        e.message ?? "Authentication failed.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "Google sign-in failed. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> logout() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
    Get.offAllNamed('/welcome');
  }
}
