import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/config/appcolor.dart';
import 'package:to_do_list_app/main.dart'; // For isDarkMode

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplashTimer();
  }

  void _startSplashTimer() {
    // 1. Wait for 3 seconds (Simulate loading like Facebook)
    Timer(const Duration(seconds: 3), () {
      // 2. Check Auth Status
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // User is logged in -> Go to Main App
        Get.offAllNamed('/appmain');
      } else {
        // User is NOT logged in -> Go to Welcome/Login
        Get.offAllNamed('/welcome');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode,
      builder: (context, bool dark, child) {
        return Scaffold(
          backgroundColor: AppColors.background(dark),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 191, 2, 24),
                        Color.fromARGB(255, 23, 0, 40),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Image.asset(
                    "assets/icons/logoApp.png",
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),

                // APP NAME (Optional)
                Text(
                  "Taskify",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text(dark),
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 40),

                // LOADING SPINNER (Optional, like Facebook)
                CircularProgressIndicator(
                  color: AppColors.primary(dark),
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
