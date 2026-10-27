import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/storage_service.dart';

class SplashController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  @override
  void onReady() {
    super.onReady();
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    // Elegant transition delay
    await Future.delayed(const Duration(milliseconds: 1800));

    if (_authRepository.currentUser != null) {
      Get.offAllNamed(AppRoutes.mainLayout);
    } else if (_storageService.hasCompletedOnboarding) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.offAllNamed(AppRoutes.welcome);
    }
  }
}
