import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_bottom_nav.dart';
import '../../home/views/home_view.dart';
import '../../live_map/views/live_map_view.dart';
import '../../partner/views/partner_hub_view.dart';
import '../../privacy/views/privacy_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/main_layout_controller.dart';

class MainLayoutView extends GetView<MainLayoutController> {
  const MainLayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCreamBackground,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            HomeView(),
            LiveMapView(),
            PartnerHubView(),
            PrivacyView(),
            ProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => CustomBottomNav(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
        ),
      ),
    );
  }
}
