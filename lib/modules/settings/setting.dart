import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:to_do_list_app/core/constants/appcolor.dart';
import 'package:to_do_list_app/data/controller/app_controller.dart';
import 'package:to_do_list_app/data/controller/auth_controller.dart';
import 'package:to_do_list_app/data/controller/db_controller.dart';
import 'package:to_do_list_app/data/local/local_db_helper.dart';
import 'package:to_do_list_app/main.dart';
import 'package:to_do_list_app/modules/settings/change_password_screen.dart';

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

  void _toggleLanguage(bool isKhmer) {
    if (isKhmer) {
      Get.updateLocale(const Locale('km', 'KH'));
      localDb.setLanguage('km');
    } else {
      Get.updateLocale(const Locale('en', 'US'));
      localDb.setLanguage('en');
    }
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

          return Scaffold(
            backgroundColor: AppColors.background(dark),
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  _buildProfileHeader(dark, imageUrl),

                  const SizedBox(height: 60),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildSectionTitle('appearance'.tr, dark),
                        _buildSettingsCard(
                          dark,
                          child: Column(
                            children: [
                              _buildDarkModeTile(dark),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Divider(
                                  height: 1,
                                  color: AppColors.text(dark).withOpacity(0.1),
                                ),
                              ),
                              _buildLanguageTile(dark),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        _buildSectionTitle('account'.tr, dark),
                        _buildSettingsCard(
                          dark,
                          child: Column(
                            children: [
                              _buildSettingTile(
                                icon: Icons.person_outline,
                                title: 'change_name'.tr,
                                iconColor: Colors.blueAccent,
                                onTap: _showChangeNameDialog,
                                dark: dark,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 60,
                                  right: 20,
                                ),
                                child: Divider(
                                  height: 1,
                                  color: AppColors.text(dark).withOpacity(0.1),
                                ),
                              ),
                              _buildSettingTile(
                                icon: Icons.lock_outline,
                                title: 'change_pass'.tr,
                                iconColor: Colors.purpleAccent,
                                onTap: () =>
                                    Get.to(() => const ChangePasswordScreen()),
                                dark: dark,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _showLogoutAccountDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.withOpacity(
                                0.1,
                              ),
                              foregroundColor: Colors.red,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                  color: Colors.redAccent.withOpacity(0.5),
                                ),
                              ),
                            ),
                            child: Text(
                              'logout'.tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }


  Widget _buildLanguageTile(bool dark) {
    bool isKhmer = Get.locale?.languageCode == 'km';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        title: Text(
          'language'.tr,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.text(dark),
          ),
        ),
        subtitle: Text(
          isKhmer ? "Khmer" : "English",
          style: TextStyle(
            fontSize: 12,
            color: AppColors.text(dark).withOpacity(0.5),
          ),
        ),
        activeColor: Colors.blue,
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.language, color: Colors.blue),
        ),
        value: isKhmer,
        onChanged: _toggleLanguage,
      ),
    );
  }

  Widget _buildProfileHeader(bool dark, String imageUrl) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 191, 2, 24),
                Color.fromARGB(255, 40, 4, 60),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: Padding(padding: const EdgeInsets.only(top: 20, right: 20)),
          ),
        ),

        Positioned(
          bottom: -50,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.background(dark),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: _pickAndSaveImageAsText,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: dark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        backgroundImage: _getImageProvider(
                          profileImageFile,
                          imageUrl,
                        ),
                        child: (profileImageFile == null && imageUrl.isEmpty)
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickAndSaveImageAsText,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary(dark),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.background(dark),
                          width: 3,
                        ),
                      ),
                      child: isUploading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                profileName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text(dark),
                ),
              ),
              Text(
                FirebaseAuth.instance.currentUser?.email ?? "",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.text(dark).withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool dark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.text(dark).withOpacity(0.5),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(bool dark, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(dark),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _buildDarkModeTile(bool dark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        title: Text(
          'dark_mode'.tr,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.text(dark),
          ),
        ),
        subtitle: Text(
          dark ? 'on'.tr : 'off'.tr,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.text(dark).withOpacity(0.5),
          ),
        ),
        activeColor: AppColors.primary(dark),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.dark_mode_rounded, color: Colors.amber),
        ),
        value: dark,
        onChanged: (value) {
          isDarkMode.value = value;
          localDb.setDarkMode(value);
        },
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool dark,
    required Color iconColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.text(dark),
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.text(dark).withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: AppColors.text(dark).withOpacity(0.5),
        ),
      ),
      onTap: onTap,
    );
  }

  ImageProvider? _getImageProvider(File? file, String dbValue) {
    if (file != null) {
      return FileImage(file);
    }
    if (dbValue.startsWith('http')) {
      return NetworkImage(dbValue);
    }
    if (dbValue.startsWith('base64')) {
      try {
        final cleanBase64 = dbValue.split(',')[1];
        return MemoryImage(base64Decode(cleanBase64));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> _pickAndSaveImageAsText() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 20,
      maxWidth: 400,
    );

    if (pickedFile != null) {
      setState(() {
        profileImageFile = File(pickedFile.path);
        isUploading = true;
      });

      try {
        final bytes = await File(pickedFile.path).readAsBytes();
        String base64Image = "base64,${base64Encode(bytes)}";
        String uid = FirebaseAuth.instance.currentUser!.uid;

        await dbController.updateUserProfile(uid, {
          'profileImage': base64Image,
        });

        Get.snackbar(
          "success".tr,
          "profile_updated".tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          "error".tr,
          "${"failed_image".tr}: $e",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() => isUploading = false);
      }
    }
  }

  void _showChangeNameDialog() async {
    int lastChanged = await localDb.getLastNameChangeTime();
    int now = DateTime.now().millisecondsSinceEpoch;
    int cooldown = 3600000;

    if (now - lastChanged < cooldown) {
      int minutesLeft = ((cooldown - (now - lastChanged)) / 60000).ceil();
      Get.snackbar(
        "cooldown_active".tr,
        "wait_minutes".trParams({'min': minutesLeft.toString()}),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "change_name".tr,
            style: TextStyle(color: AppColors.text(dark)),
          ),
          content: TextField(
            controller: textCtrl,
            decoration: InputDecoration(
              hintText: "enter_new_name".tr,
              hintStyle: TextStyle(
                color: AppColors.text(dark).withOpacity(0.5),
              ),
              filled: true,
              fillColor: AppColors.background(dark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(color: AppColors.text(dark)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "cancel".tr,
                style: TextStyle(color: AppColors.text(dark).withOpacity(0.6)),
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
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  Get.snackbar(
                    "success".tr,
                    "name_updated".tr,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(dark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text("save".tr),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("logout".tr, style: TextStyle(color: AppColors.text(dark))),
        content: Text(
          "logout_confirm".tr,
          style: TextStyle(color: AppColors.text(dark).withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "cancel".tr,
              style: TextStyle(color: AppColors.text(dark).withOpacity(0.6)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              authController.logout();
            },
            child: Text(
              "logout".tr,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
