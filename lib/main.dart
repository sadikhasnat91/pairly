import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/services/notification_service.dart';
import 'data/services/storage_service.dart';
import 'data/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set romantic immersive system navigation and status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.warmCreamBackground,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Core Services prior to running application
  final storageService = await StorageService().init();
  Get.put<StorageService>(storageService, permanent: true);

  final supabaseService = await SupabaseService().init();
  Get.put<SupabaseService>(supabaseService, permanent: true);

  final notificationService = await NotificationService().init();
  Get.put<NotificationService>(notificationService, permanent: true);

  runApp(const PairlyApp());
}

class PairlyApp extends StatelessWidget {
  const PairlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.romanticTheme,
      darkTheme: AppTheme.darkRomanticTheme,
      themeMode: ThemeMode.light, // Uses the signature Warm Cream & Blush romantic experience
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
      defaultTransition: Transition.fade,
    );
  }
}
