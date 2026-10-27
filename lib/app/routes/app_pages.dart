import 'package:get/get.dart';

import '../../modules/auth/views/forgot_password_view.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/register_view.dart';
import '../../modules/main_layout/views/main_layout_view.dart';
import '../../modules/onboarding/views/profile_setup_view.dart';
import '../../modules/onboarding/views/welcome_view.dart';
import '../../modules/partner/views/enter_code_view.dart';
import '../../modules/partner/views/invite_partner_view.dart';
import '../../modules/privacy/views/privacy_view.dart';
import '../../modules/profile/views/edit_profile_view.dart';
import '../../modules/safe_arrival/views/safe_arrival_view.dart';
import '../../modules/splash/views/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppRoutes.welcome,
      page: () => const WelcomeView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profileSetup,
      page: () => const ProfileSetupView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.mainLayout,
      page: () => const MainLayoutView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.invitePartner,
      page: () => const InvitePartnerView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.enterCode,
      page: () => const EnterCodeView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.safeArrival,
      page: () => const SafeArrivalView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.privacy,
      page: () => const PrivacyView(),
      transition: Transition.rightToLeft,
    ),
  ];
}
