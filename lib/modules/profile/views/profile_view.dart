import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/partner_avatar.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text('Account & Profile', style: AppTypography.titleMedium),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // User Avatar Card
              Obx(() {
                final user = controller.currentUser.value;
                return AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      PartnerAvatar(
                        name: user?.displayName,
                        photoUrl: user?.photoUrl,
                        size: 64,
                        isLive: true,
                        isSharing: false,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'User',
                              style: AppTypography.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? '',
                              style: AppTypography.bodySmall,
                            ),
                            if (user?.statusMessage?.isNotEmpty == true) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.cardSubtle,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '"${user!.statusMessage!}"',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.primaryAccent,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.primaryAccent,
                        ),
                        onPressed: () => Get.toNamed(AppRoutes.editProfile),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),

              // Settings Options
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.person_outline,
                      title: 'Edit Profile Information',
                      subtitle: 'Name, status, avatar',
                      onTap: () => Get.toNamed(AppRoutes.editProfile),
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.shield_outlined,
                      title: 'Privacy & Sharing Center',
                      subtitle: 'Access controls, GPS permissions',
                      onTap: () => Get.toNamed(AppRoutes.privacy),
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.lock_reset,
                      title: 'Change Password',
                      subtitle: 'Send reset link to your email',
                      onTap: controller.requestPasswordReset,
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.info_outline,
                      title: 'About Pairly',
                      subtitle: 'Version ${AppConstants.appVersion}',
                      onTap: () {
                        Get.snackbar(
                          'Pairly v${AppConstants.appVersion}',
                          'Built with Flutter, GetX, Google Maps & Firebase.',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Sign Out Button
              AppButton(
                text: 'Sign Out',
                variant: AppButtonVariant.secondary,
                leadingIcon: Icons.logout,
                onPressed: controller.signOut,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryAccent, size: 20),
      ),
      title: Text(title, style: AppTypography.labelLarge),
      subtitle: Text(subtitle, style: AppTypography.bodySmall),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: AppColors.secondaryText,
      ),
    );
  }
}
