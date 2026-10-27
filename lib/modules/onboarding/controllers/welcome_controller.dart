import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/services/storage_service.dart';

class WelcomeController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  void onGetStarted() {
    _storageService.setCompletedOnboarding(true);
    Get.toNamed(AppRoutes.register);
  }

  void onSignIn() {
    _storageService.setCompletedOnboarding(true);
    Get.toNamed(AppRoutes.login);
  }
}
