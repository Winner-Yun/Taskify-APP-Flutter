import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/data/controller/auth_controller.dart'; // Import AuthController

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isCheck = false;
  bool isLoading = false; // Add loading state

  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  String? emailError;
  String? passError;

  final RegExp emailReg = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

  final AuthController authController = Get.put(AuthController());

  bool get isValid {
    return emailError == null &&
        passError == null &&
        emailCtrl.text.isNotEmpty &&
        passCtrl.text.isNotEmpty;
  }

  void validateEmail(String value) {
    if (value.isEmpty) {
      emailError = "Email cannot be empty";
    } else if (!emailReg.hasMatch(value)) {
      emailError = "Invalid email format";
    } else {
      emailError = null;
    }
    setState(() {});
  }

  void validatePassword(String value) {
    if (value.isEmpty) {
      passError = "Password cannot be empty";
    } else if (value.length < 6) {
      passError = "Password must be at least 6 characters";
    } else {
      passError = null;
    }
    setState(() {});
  }

  void login() async {
    setState(() => isLoading = true);
    await authController.login(emailCtrl.text.trim(), passCtrl.text.trim());
    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed('/welcome');
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: _buildLoginForm(context),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: const FittedBox(
              child: Text(
                "Hello \nSign in!",
                style: TextStyle(
                  height: 1.2,
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: MediaQuery.sizeOf(context).height * 0.8,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    _buildInputField(
                      label: "Email",
                      hint: "Enter your Email",
                      controller: emailCtrl,
                      errorText: emailError,
                      onChanged: validateEmail,
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
                      onChanged: validatePassword,
                    ),
                    const SizedBox(height: 40),
                    _buildButton(
                      text: "SIGN IN",
                      onPressed: (isValid && !isLoading) ? login : null,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Don't have account?"),
                    TextButton(
                      onPressed: () {
                        Get.toNamed('/signup');
                      },
                      child: const Text(
                        "Sign up",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
            style: const TextStyle(color: Colors.black, fontSize: 16),
            obscureText: isPassword && !isCheck,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade600),
              errorText: errorText,
              errorStyle: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
              suffixIcon: icon != null
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          isCheck = !isCheck;
                        });
                      },
                      child: Icon(
                        isCheck ? Icons.visibility : Icons.visibility_off,
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

  Widget _buildButton({
    required String text,
    required VoidCallback? onPressed,
  }) {
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
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: isLoading
              ? SizedBox(
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
