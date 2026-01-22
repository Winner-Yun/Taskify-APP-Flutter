import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/config/translate_data.dart';
import 'package:to_do_list_app/controller/app_controller.dart';
import 'package:to_do_list_app/controller/auth_controller.dart';
import 'package:to_do_list_app/routes/routes.dart';
import 'package:to_do_list_app/services/notification_service.dart';
import 'package:to_do_list_app/theme/theme.dart';

import 'firebase_options.dart';

ValueNotifier<bool> isDarkMode = ValueNotifier(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init();
  await NotificationService().requestPermissions();

  Get.put(AuthController());
  Get.put(AppController());

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode,
      builder: (context, bool dark, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Taskify',

          // --- TRANSLATION CONFIGURATION ---
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          fallbackLocale: const Locale('en', 'US'),
          // ---------------------------------
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          initialRoute: AppRoutes.initial,
          getPages: AppRoutes.pages,
          builder: (context, child) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
