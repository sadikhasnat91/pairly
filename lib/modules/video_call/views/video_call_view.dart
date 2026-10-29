import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../controllers/video_call_controller.dart';

class VideoCallView extends GetView<VideoCallController> {
  const VideoCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Remote Partner Video (Fullscreen)
            Positioned.fill(
              child: Obx(() {
                if (controller.isConnected.value && controller.isRemoteReady.value) {
                  return RTCVideoView(
                    controller.remoteRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  );
                }

                return Container(
                  color: AppColors.deepRomanticPlum,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: AppColors.softRose),
                        const SizedBox(height: 20),
                        Text(
                          controller.isCaller.value
                              ? 'Waiting for ${controller.partnerName.value} to accept...'
                              : 'Connecting video...',
                          style: AppTypography.titleMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),

            // 2. Top Privacy & Status Header
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.successAccent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Live Camera Active',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Obx(
                      () => Text(
                        controller.callDurationText.value,
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.softRose,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Local Camera Preview (Picture-in-Picture at top right)
            Positioned(
              top: 76,
              right: 16,
              width: 110,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryRomanticBlush.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Obx(() {
                    if (controller.isCameraOff.value) {
                      return const Center(
                        child: Icon(Icons.videocam_off, color: Colors.white54),
                      );
                    }
                    if (controller.isLocalReady.value) {
                      return RTCVideoView(
                        controller.localRenderer,
                        mirror: true,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.softRose, strokeWidth: 2),
                    );
                  }),
                ),
              ),
            ),

            // 4. Bottom Call Controls
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute / Unmute Mic
                    Obx(
                      () => IconButton(
                        icon: Icon(
                          controller.isMuted.value ? Icons.mic_off_rounded : Icons.mic_rounded,
                          color: controller.isMuted.value ? AppColors.errorAccent : Colors.white,
                          size: 26,
                        ),
                        onPressed: controller.toggleMute,
                      ),
                    ),

                    // Switch Camera (Front / Back)
                    IconButton(
                      icon: const Icon(
                        Icons.flip_camera_ios_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: controller.switchCamera,
                    ),

                    // Toggle Video Camera
                    Obx(
                      () => IconButton(
                        icon: Icon(
                          controller.isCameraOff.value
                              ? Icons.videocam_off_rounded
                              : Icons.videocam_rounded,
                          color: controller.isCameraOff.value
                              ? AppColors.errorAccent
                              : Colors.white,
                          size: 26,
                        ),
                        onPressed: controller.toggleCamera,
                      ),
                    ),

                    // End Session Button (Red)
                    GestureDetector(
                      onTap: controller.endCall,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.errorAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.call_end_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

