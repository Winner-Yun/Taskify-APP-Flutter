import 'package:flutter/material.dart';
import 'package:to_do_list_app/modules/auth/login.dart';
import 'package:to_do_list_app/modules/auth/signup.dart';

class Welcomescreen extends StatefulWidget {
  const Welcomescreen({super.key});

  @override
  State<Welcomescreen> createState() => _WelcomescreenState();
}

class _WelcomescreenState extends State<Welcomescreen> {
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
      spacing: 20,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: MediaQuery.sizeOf(context).width * 0.08,
            color: Colors.white,
          ),
        ),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,

              side: BorderSide(width: 2, color: Colors.white),
            ),
            child: Text(
              "SIGN IN",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignupScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,

              side: BorderSide(width: 1, color: Colors.white),
            ),
            child: Text(
              "SIGN UP",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCredit() {
    return Column(
      spacing: 6,
      children: [
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
