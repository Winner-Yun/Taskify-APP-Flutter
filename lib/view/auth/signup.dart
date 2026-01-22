import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/controller/auth_controller.dart';
import 'package:to_do_list_app/view/auth/login.dart';
import 'package:to_do_list_app/view/auth/welcomescreen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool ischeck = false;
  // Add loading state
  bool isLoading = false;

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController confirmCtrl = TextEditingController();

  String? nameError;
  String? emailError;
  String? passError;
  String? confirmError;

  final RegExp emailReg = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

  // ✅ USE AUTH CONTROLLER
  final AuthController authController = Get.put(AuthController());

  bool get isValid {
    return nameCtrl.text.isNotEmpty &&
        emailCtrl.text.isNotEmpty &&
        passCtrl.text.isNotEmpty &&
        confirmCtrl.text.isNotEmpty &&
        nameError == null &&
        emailError == null &&
        passError == null &&
        confirmError == null;
  }

  void validateName(String value) {
    if (value.isEmpty) {
      nameError = "Full name cannot be empty";
    } else {
      nameError = null;
    }
  }

  void validateEmail(String value) {
    if (value.isEmpty) {
      emailError = "Email cannot be empty";
    } else if (!emailReg.hasMatch(value)) {
      emailError = "Invalid email format";
    } else {
      emailError = null;
    }
  }

  void validatePassword(String value) {
    if (value.isEmpty) {
      passError = "Password cannot be empty";
    } else if (value.length < 6) {
      passError = "Password must be at least 6 characters";
    } else {
      passError = null;
    }
  }

  void validateConfirmPassword(String value) {
    if (value.isEmpty) {
      confirmError = "Confirm password cannot be empty";
    } else if (value != passCtrl.text) {
      confirmError = "Passwords do not match";
    } else {
      confirmError = null;
    }
  }

  // ✅ SIGN UP ACTION WITH LOADING
  Future<void> handleSignup() async {
    setState(() => isLoading = true);

    await authController.register(
      emailCtrl.text.trim(),
      passCtrl.text.trim(),
      nameCtrl.text.trim(),
    );

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Welcomescreen()),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: _buildSignupForm(context),
      ),
    );
  }

  BoxDecoration _buildBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.topRight,
        colors: [
          Color.fromARGB(255, 191, 2, 24),
          Color.fromARGB(255, 23, 0, 40),
        ],
      ),
    );
  }

  Widget _buildSignupForm(BuildContext context) {
    return Container(
      decoration: _buildBackground(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.all(20), child: _buildHeader()),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildInputField(
                        label: "Full Name",
                        hint: "Enter your Full name",
                        controller: nameCtrl,
                        errorText: nameError,
                        onChanged: (value) {
                          setState(() => validateName(value));
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        label: "Gmail",
                        hint: "Enter your Email",
                        controller: emailCtrl,
                        errorText: emailError,
                        onChanged: (value) {
                          setState(() => validateEmail(value));
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        label: "Password",
                        hint: "Enter password",
                        controller: passCtrl,
                        isPassword: true,
                        icon: Icons.visibility_off,
                        iconColor: Colors.grey,
                        errorText: passError,
                        onChanged: (value) {
                          setState(() {
                            validatePassword(value);
                            validateConfirmPassword(confirmCtrl.text);
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        label: "Confirm Password",
                        hint: "Enter confirm password",
                        controller: confirmCtrl,
                        isPassword: true,
                        icon: Icons.visibility_off,
                        iconColor: Colors.grey,
                        errorText: confirmError,
                        onChanged: (value) {
                          setState(() => validateConfirmPassword(value));
                        },
                      ),
                      const SizedBox(height: 40),

                      _buildButton(context, text: "SIGN UP"),

                      const SizedBox(height: 20),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Already have account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Sign in",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const FittedBox(
      child: Text(
        "Create Your\nAccount",
        style: TextStyle(
          height: 1.2,
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required Function(String) onChanged,
    bool isPassword = false,
    IconData? icon,
    Color iconColor = Colors.grey,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.black,
              selectionHandleColor: Colors.black,
              selectionColor: Colors.black.withValues(alpha: 0.2),
            ),
          ),

          child: TextField(
            controller: controller,
            onChanged: onChanged,
            obscureText: isPassword && !ischeck ? true : false,
            style: const TextStyle(color: Colors.black, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              errorStyle: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
              errorText: errorText,
              hintStyle: TextStyle(color: Colors.grey.shade600),
              suffixIcon: icon != null
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          ischeck = !ischeck;
                        });
                      },
                      child: Icon(
                        ischeck ? Icons.visibility : Icons.visibility_off,
                        size: 20,
                        color: iconColor,
                      ),
                    )
                  : null,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context, {required String text}) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 191, 2, 24),
              Color.fromARGB(255, 23, 0, 40),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: ElevatedButton(
          // ✅ CALL SIGNUP FUNCTION OR DISABLE IF INVALID/LOADING
          onPressed: (isValid && !isLoading) ? handleSignup : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.grey.withOpacity(1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
        ),
      ),
    );
  }
}
