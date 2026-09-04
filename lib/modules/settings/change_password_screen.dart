import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/core/constants/appcolor.dart';
import 'package:to_do_list_app/main.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController oldCtrl = TextEditingController();
  final TextEditingController newCtrl = TextEditingController();
  final TextEditingController confirmCtrl = TextEditingController();

  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode,
      builder: (context, bool dark, child) {
        return Scaffold(
          backgroundColor: AppColors.background(dark),
          appBar: AppBar(
            backgroundColor: AppColors.card(dark),
            elevation: 0,
            title: Text(
              "Change Password",
              style: TextStyle(color: AppColors.text(dark)),
            ),
            iconTheme: IconThemeData(color: AppColors.text(dark)),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                _buildInput(
                  controller: oldCtrl,
                  label: "Old Password",
                  dark: dark,
                  obscure: true,
                ),

                const SizedBox(height: 20),

                _buildInput(
                  controller: newCtrl,
                  label: "New Password",
                  dark: dark,
                  obscure: true,
                ),

                const SizedBox(height: 20),

                _buildInput(
                  controller: confirmCtrl,
                  label: "Confirm Password",
                  dark: dark,
                  obscure: true,
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(dark),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.3,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Save Password",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required bool dark,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: AppColors.text(dark)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.text(dark).withOpacity(0.7)),
        filled: true,
        fillColor: AppColors.card(dark),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary(dark), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.text(dark).withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _changePassword() async {
    String oldPass = oldCtrl.text.trim();
    String newPass = newCtrl.text.trim();
    String confirmPass = confirmCtrl.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showError("Please fill in all fields.");
      return;
    }

    if (newPass.length < 6) {
      _showError("New password must be at least 6 characters.");
      return;
    }

    if (newPass != confirmPass) {
      _showError("Passwords do not match.");
      return;
    }

    setState(() => isLoading = true);

    try {
      User? user = _auth.currentUser;
      String email = user?.email ?? "";

      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: oldPass,
      );

      await user?.reauthenticateWithCredential(credential);

      await user?.updatePassword(newPass);

      setState(() => isLoading = false);
      Get.back();
      Get.snackbar(
        "Success",
        "Password updated successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      setState(() => isLoading = false);
      _showError("Error: ${e.toString()}");
    }
  }

  void _showError(String message) {
    Get.snackbar(
      "Error",
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}



