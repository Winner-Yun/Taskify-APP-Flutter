import 'package:get/get.dart';
import 'package:to_do_list_app/modules/auth/login.dart';
import 'package:to_do_list_app/modules/auth/signup.dart';
import 'package:to_do_list_app/modules/auth/welcomescreen.dart';
import 'package:to_do_list_app/modules/dashboard/appmainscreen.dart';
import 'package:to_do_list_app/modules/splash/splash_screen.dart';

class AppRoutes {
  static String initial = '/splash';

  static final pages = [
    GetPage(name: '/splash', page: () => const SplashScreen()),
    GetPage(name: '/welcome', page: () => const Welcomescreen()),
    GetPage(name: '/login', page: () => const LoginScreen()),
    GetPage(name: '/signup', page: () => const SignupScreen()),
    GetPage(name: '/appmain', page: () => const AppmainScreen()),
  ];
}
