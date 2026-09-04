import 'package:get/get.dart';
import 'package:to_do_list_app/modules/auth/welcomescreen.dart';
import 'package:to_do_list_app/modules/dashboard/appmainscreen.dart';
import 'package:to_do_list_app/modules/splash/splash_screen.dart';

class AppRoutes {
  static String initial = '/splash';

  static final pages = [
    GetPage(name: '/splash', page: () => const SplashScreen()),
    GetPage(name: '/welcome', page: () => const Welcomescreen()),
    GetPage(name: '/appmain', page: () => const AppmainScreen()),
  ];
}
