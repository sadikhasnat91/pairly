import 'package:get/get.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/repositories/partner_repository.dart';
import '../../data/repositories/safe_arrival_repository.dart';
import '../../data/repositories/video_signaling_repository.dart';
import '../../data/services/location_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/supabase_service.dart';
import '../../data/services/video_call_service.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../modules/auth/controllers/forgot_password_controller.dart';
import '../../modules/auth/controllers/register_controller.dart';
import '../../modules/home/controllers/home_controller.dart';
import '../../modules/live_map/controllers/live_map_controller.dart';
import '../../modules/main_layout/controllers/main_layout_controller.dart';
import '../../modules/onboarding/controllers/profile_setup_controller.dart';
import '../../modules/onboarding/controllers/welcome_controller.dart';
import '../../modules/partner/controllers/partner_controller.dart';
import '../../modules/privacy/controllers/privacy_controller.dart';
import '../../modules/profile/controllers/profile_controller.dart';
import '../../modules/safe_arrival/controllers/safe_arrival_controller.dart';
import '../../modules/splash/controllers/splash_controller.dart';
import '../../modules/video_call/controllers/video_call_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<LocationService>(() => LocationService(), fenix: true);
    Get.lazyPut<VideoCallService>(() => VideoCallService(), fenix: true);

    // Repositories (dependencies on SupabaseService & StorageService registered in main())
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(
        supabaseService: Get.find<SupabaseService>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<PartnerRepository>(
      () => PartnerRepository(
        supabaseService: Get.find<SupabaseService>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<LocationRepository>(
      () => LocationRepository(
        supabaseService: Get.find<SupabaseService>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<SafeArrivalRepository>(
      () => SafeArrivalRepository(
        supabaseService: Get.find<SupabaseService>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<VideoSignalingRepository>(
      () => VideoSignalingRepository(
        supabaseService: Get.find<SupabaseService>(),
      ),
      fenix: true,
    );

    // Controllers
    Get.lazyPut<SplashController>(() => SplashController(), fenix: true);
    Get.lazyPut<WelcomeController>(() => WelcomeController(), fenix: true);
    Get.lazyPut<ProfileSetupController>(
      () => ProfileSetupController(),
      fenix: true,
    );
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<RegisterController>(() => RegisterController(), fenix: true);
    Get.lazyPut<ForgotPasswordController>(
      () => ForgotPasswordController(),
      fenix: true,
    );
    Get.lazyPut<MainLayoutController>(
      () => MainLayoutController(),
      fenix: true,
    );
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<LiveMapController>(() => LiveMapController(), fenix: true);
    Get.lazyPut<PartnerController>(() => PartnerController(), fenix: true);
    Get.lazyPut<PrivacyController>(() => PrivacyController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<SafeArrivalController>(
      () => SafeArrivalController(),
      fenix: true,
    );
    Get.put<VideoCallController>(
      VideoCallController(),
      permanent: true,
    );
  }
}
