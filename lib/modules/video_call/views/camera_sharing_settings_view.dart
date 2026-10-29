import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/services/video_call_service.dart';

class CameraSharingSettingsView extends StatefulWidget {
  const CameraSharingSettingsView({super.key});

  @override
  State<CameraSharingSettingsView> createState() =>
      _CameraSharingSettingsViewState();
}

class _CameraSharingSettingsViewState extends State<CameraSharingSettingsView> {
  final VideoCallService _videoService = Get.find<VideoCallService>();

  bool _isCameraGranted = false;
  bool _isMicGranted = false;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final camera = await Permission.camera.isGranted;
    final mic = await Permission.microphone.isGranted;
    if (mounted) {
      setState(() {
        _isCameraGranted = camera;
        _isMicGranted = mic;
      });
    }
  }

  Future<void> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();
    if (mounted) {
      setState(() {
        _isCameraGranted = cameraStatus.isGranted;
        _isMicGranted = micStatus.isGranted;
      });
    }
  }

  Future<void> _toggleHardwareTest() async {
    if (_isTesting) {
      await _videoService.stopAndCleanUp();
      setState(() => _isTesting = false);
    } else {
      await _videoService.initRenderers();
      final stream = await _videoService.startLocalMedia();
      if (stream != null) {
        setState(() => _isTesting = true);
      }
    }
  }

  @override
  void dispose() {
    if (_isTesting) {
      _videoService.stopAndCleanUp();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCreamBackground,
      appBar: AppBar(
        title: Text(
          'Live Camera & Video',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.mainText,
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Consent and Privacy Assurance Card
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.softPinkSurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: AppColors.softRose,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '100% Consent-Based Video',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Pairly values intimacy and absolute trust. Video sharing only connects when you or your partner send a request and the other explicitly taps Accept.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.secondaryTextCol,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Permissions Status Card
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Required Device Access',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPermissionTile(
                      icon: Icons.camera_alt_outlined,
                      title: 'Camera Access',
                      subtitle: 'Used for live video streaming with your partner',
                      isGranted: _isCameraGranted,
                    ),
                    const Divider(height: 24),
                    _buildPermissionTile(
                      icon: Icons.mic_none_outlined,
                      title: 'Microphone Access',
                      subtitle: 'Used for two-way audio during video calls',
                      isGranted: _isMicGranted,
                    ),
                    const SizedBox(height: 20),
                    if (!_isCameraGranted || !_isMicGranted)
                      AppButton(
                        text: 'Grant Permissions',
                        variant: AppButtonVariant.primary,
                        leadingIcon: Icons.shield_outlined,
                        onPressed: _requestPermissions,
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.softPinkSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryRomanticBlush.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.successAccent, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'All permissions granted and ready',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.deepRomanticPlum,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Hardware Connection Test Card
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Camera & Mic Diagnostics',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Preview your local camera feed and test WebRTC media hardware before connecting with your partner.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.secondaryTextCol,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isTesting)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: RTCVideoView(
                            _videoService.localRenderer,
                            mirror: true,
                            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    AppButton(
                      text: _isTesting ? 'Stop Camera Test' : 'Test Camera & Audio',
                      variant: _isTesting
                          ? AppButtonVariant.secondary
                          : AppButtonVariant.outline,
                      leadingIcon: _isTesting
                          ? Icons.videocam_off_outlined
                          : Icons.videocam_outlined,
                      onPressed: _toggleHardwareTest,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isGranted,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.softPinkSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.softRose, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.secondaryTextCol,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isGranted ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isGranted ? 'Enabled' : 'Disabled',
            style: AppTypography.labelSmall.copyWith(
              color: isGranted ? AppColors.successAccent : AppColors.errorAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

