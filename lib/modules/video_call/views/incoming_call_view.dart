import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/partner_avatar.dart';
import '../../../data/models/video_call_model.dart';
import '../controllers/video_call_controller.dart';
import 'video_call_view.dart';

class IncomingCallView extends StatelessWidget {
  final VideoCallSessionModel session;
  final String callerName;
  final String? callerPhotoUrl;

  const IncomingCallView({
    super.key,
    required this.session,
    required this.callerName,
    this.callerPhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VideoCallController());

    return Scaffold(
      backgroundColor: AppColors.deepRomanticPlum,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Romantic Tag
              Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.videocam_rounded, color: AppColors.softRose, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Live Video Request',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.warmCreamBackground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    callerName,
                    style: AppTypography.displayMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'wants to connect with you via live camera',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.warmCreamBackground.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),

              // Center Avatar with romantic glow
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryRomanticBlush.withValues(alpha: 0.15),
                      ),
                    ),
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryRomanticBlush.withValues(alpha: 0.25),
                      ),
                    ),
                    PartnerAvatar(
                      name: callerName,
                      photoUrl: callerPhotoUrl,
                      size: 110,
                    ),
                  ],
                ),
              ),

              // Bottom Privacy Notice & Action Buttons
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.privacy_tip_outlined, color: AppColors.softRose, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your camera and microphone will only activate after you tap Accept.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.warmCreamBackground.withValues(alpha: 0.85),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  Row(
                    children: [
                      // Decline Button
                      Expanded(
                        child: AppButton(
                          text: 'Decline',
                          variant: AppButtonVariant.danger,
                          leadingIcon: Icons.call_end_rounded,
                          onPressed: () => controller.declineCall(session.id),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Accept Button
                      Expanded(
                        child: AppButton(
                          text: 'Accept',
                          variant: AppButtonVariant.primary,
                          leadingIcon: Icons.videocam_rounded,
                          onPressed: () async {
                            await controller.acceptCall(session);
                            Get.off(() => const VideoCallView());
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

