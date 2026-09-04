import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/core/constants/appcolor.dart';
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
    Timer(const Duration(seconds: 3), () {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        Get.offAllNamed('/appmain');
      } else {
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
