import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/data/controller/auth_controller.dart';

class Welcomescreen extends StatefulWidget {
  const Welcomescreen({super.key});

  @override
  State<Welcomescreen> createState() => _WelcomescreenState();
}

class _WelcomescreenState extends State<Welcomescreen> {
  final AuthController authCtrl = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [
              Color.fromARGB(255, 191, 2, 24),
              Color.fromARGB(255, 23, 0, 40),
            ],
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_buildLogo(), _buildBodyButton(), _buildCredit()],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      "assets/icons/logoApp.png",
      width: MediaQuery.sizeOf(context).width * 0.8,
    );
  }

  Widget _buildBodyButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Welcome to Taskify',
          style: TextStyle(
            fontSize: MediaQuery.sizeOf(context).width * 0.08,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: Obx(() {
            final isLoading = authCtrl.isLoading.value;
            return ElevatedButton.icon(
              onPressed: isLoading ? null : () => authCtrl.signInWithGoogle(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              icon: isLoading
                  ? const SizedBox.shrink()
                  : const Icon(
                      Icons.g_mobiledata_rounded,
                      color: Colors.black,
                      size: 36,
                    ),
              label: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text(
                      "Continue with Google",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCredit() {
    return Column(
      children: const [
        Text(
          "By Winner Yun",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}
