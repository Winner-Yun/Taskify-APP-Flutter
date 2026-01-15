import 'dart:convert'; // REQUIRED: To convert image to text
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:to_do_list_app/config/appcolor.dart';
import 'package:to_do_list_app/controller/app_controller.dart';
import 'package:to_do_list_app/controller/auth_controller.dart';
import 'package:to_do_list_app/controller/db_controller.dart';
import 'package:to_do_list_app/data/local_db_helper.dart';
import 'package:to_do_list_app/main.dart';
import 'package:to_do_list_app/view/screens/change_password_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final AppController controller = Get.find<AppController>();
  final AuthController authController = Get.find<AuthController>();
  final DbController dbController = Get.find<DbController>();
  final LocalDbHelper localDb = LocalDbHelper();

  String profileName = "";
  File? profileImageFile;
  bool isUploading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = controller.firestoreUser.value;
    profileName = user?.name ?? "Unknown User";
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode,
      builder: (context, bool dark, child) {
        return Obx(() {
          final user = controller.firestoreUser.value;
          profileName = user?.name ?? "";
          final imageUrl = user?.profileImage ?? "";

          return SafeArea(
            child: Container(
              color: AppColors.background(dark),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 10),

                  // --- PROFILE CARD ---
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.card(dark),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: dark
                              ? Colors.black.withOpacity(0.4)
                              : Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: _pickAndSaveImageAsText, // New Function
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: dark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                                // LOGIC:
                                // 1. If we just picked a file, show it.
                                // 2. If DB has "base64", decode the text to image.
                                // 3. If DB has "http", use network (legacy support).
                                backgroundImage: _getImageProvider(
                                  profileImageFile,
                                  imageUrl,
                                ),
                                child:
                                    (profileImageFile == null &&
                                        imageUrl.isEmpty)
                                    ? const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                            ),

                            Positioned(
                              bottom: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: _pickAndSaveImageAsText,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary(dark),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.card(dark),
                                      width: 2,
                                    ),
                                  ),
                                  child: isUploading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Text(
                          profileName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text(dark),
                          ),
                        ),

                        const SizedBox(height: 10),

                        GestureDetector(
                          onTap: _showChangeNameDialog,
                          child: Text(
                            "Change Name",
                            style: TextStyle(
                              color: AppColors.primary(dark),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  _buildSettingCard(
                    dark: dark,
                    children: [
                      _buildDarkModeTile(),
                      _buildSettingTile(
                        icon: Icons.lock,
                        title: "Change Password",
                        iconColor: AppColors.text(dark),
                        colortext: AppColors.text(dark),
                        onTap: () => Get.to(() => const ChangePasswordScreen()),
                        dark: dark,
                      ),
                      Divider(color: AppColors.text(dark).withOpacity(0.2)),
                      _buildSettingTile(
                        icon: Icons.logout,
                        title: "Log Out",
                        iconColor: Colors.red,
                        colortext: Colors.red,
                        onTap: _showLogoutAccountDialog,
                        dark: dark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // --- HELPER TO DISPLAY IMAGE ---
  ImageProvider? _getImageProvider(File? file, String dbValue) {
    if (file != null) {
      return FileImage(file);
    }
    if (dbValue.startsWith('http')) {
      return NetworkImage(dbValue);
    }
    if (dbValue.startsWith('base64')) {
      // Decode the text back to an image
      try {
        final cleanBase64 = dbValue.split(',')[1];
        return MemoryImage(base64Decode(cleanBase64));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // --- 1. PICK IMAGE & SAVE AS TEXT (HACKER WAY) ---
  Future<void> _pickAndSaveImageAsText() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 20, // VERY IMPORTANT: Keep quality low to save space
      maxWidth: 400, // Resize to keep string short
    );

    if (pickedFile != null) {
      setState(() {
        profileImageFile = File(pickedFile.path);
        isUploading = true;
      });

      try {
        // Convert Image -> Bytes -> String
        final bytes = await File(pickedFile.path).readAsBytes();
        String base64Image = "base64,${base64Encode(bytes)}";

        String uid = FirebaseAuth.instance.currentUser!.uid;

        // Save String to Firestore (Free!)
        await dbController.updateUserProfile(uid, {
          'profileImage': base64Image,
        });

        Get.snackbar(
          "Success",
          "Profile picture updated!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          "Error",
          "Failed to save image: $e",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() => isUploading = false);
      }
    }
  }

  // --- 2. CHANGE NAME & UI HELPERS ---
  // (Keep the rest of your UI code exactly the same as before)

  Widget _buildDarkModeTile() {
    return ValueListenableBuilder(
      valueListenable: isDarkMode,
      builder: (context, bool dark, child) {
        return SwitchListTile(
          title: Text(
            "Dark Mode",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text(dark),
            ),
          ),
          activeColor: AppColors.primary(dark),
          secondary: const Icon(Icons.dark_mode, color: Colors.amber, size: 28),
          value: dark,
          onChanged: (value) {
            isDarkMode.value = value;
            localDb.setDarkMode(value);
          },
        );
      },
    );
  }

  Widget _buildSettingCard({
    required List<Widget> children,
    required bool dark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(dark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black54 : Colors.black12,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool dark,
    Color colortext = Colors.black,
    Color iconColor = Colors.black,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: iconColor, size: 28),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colortext,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.text(dark).withOpacity(0.6),
      ),
      onTap: onTap,
    );
  }

  void _showChangeNameDialog() async {
    // Check Cooldown
    int lastChanged = await localDb.getLastNameChangeTime();
    int now = DateTime.now().millisecondsSinceEpoch;
    int cooldown = 3600000; // 1 Hour

    if (now - lastChanged < cooldown) {
      int minutesLeft = ((cooldown - (now - lastChanged)) / 60000).ceil();
      Get.snackbar(
        "Cooldown Active",
        "Wait $minutesLeft minutes to change name.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    TextEditingController textCtrl = TextEditingController(text: profileName);
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        bool dark = isDarkMode.value;
        return AlertDialog(
          backgroundColor: AppColors.card(dark),
          title: Text(
            "Change Name",
            style: TextStyle(color: AppColors.text(dark)),
          ),
          content: TextField(
            controller: textCtrl,
            decoration: InputDecoration(
              hintText: "Enter new name",
              hintStyle: TextStyle(
                color: AppColors.text(dark).withOpacity(0.5),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.text(dark).withOpacity(0.3),
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary(dark)),
              ),
            ),
            style: TextStyle(color: AppColors.text(dark)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: AppColors.text(dark)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (textCtrl.text.isNotEmpty) {
                  await dbController.updateUserProfile(
                    FirebaseAuth.instance.currentUser!.uid,
                    {'name': textCtrl.text.trim()},
                  );
                  await localDb.setLastNameChangeTime(
                    DateTime.now().millisecondsSinceEpoch,
                  );
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  Get.snackbar(
                    "Success",
                    "Name updated!",
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(dark),
              ),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutAccountDialog() {
    bool dark = isDarkMode.value;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(dark),
        title: Text("Logout", style: TextStyle(color: AppColors.text(dark))),
        content: Text(
          "Are you sure you want to log out?",
          style: TextStyle(color: AppColors.text(dark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: AppColors.text(dark)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              authController.logout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
