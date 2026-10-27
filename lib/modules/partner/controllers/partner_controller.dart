import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/validator.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../data/models/connection_request_model.dart';
import '../../../data/models/invite_model.dart';
import '../../../data/models/partner_connection_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/partner_repository.dart';

class PartnerController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final PartnerRepository _partnerRepo = Get.find<PartnerRepository>();

  final codeInputController = TextEditingController();

  final activeConnection = Rxn<PartnerConnectionModel>();
  final partnerUser = Rxn<UserModel>();
  final activeInvite = Rxn<InviteModel>();
  final pendingRequests = <ConnectionRequestModel>[].obs;

  final isLoading = false.obs;
  final isGeneratingCode = false.obs;
  final errorMessage = ''.obs;

  StreamSubscription? _connSub;
  StreamSubscription? _reqSub;

  @override
  void onInit() {
    super.onInit();
    _bind();
  }

  void _bind() {
    activeConnection.value = _partnerRepo.currentConnection;
    partnerUser.value = _partnerRepo.partnerUser;

    _connSub = _partnerRepo.connectionStream.listen((conn) {
      activeConnection.value = conn;
      partnerUser.value = _partnerRepo.partnerUser;
    });

    _reqSub = _partnerRepo.pendingRequestsStream.listen((requests) {
      pendingRequests.assignAll(requests);
    });
  }

  /// Generate a brand new expiring 6-character code
  Future<void> generateNewInviteCode() async {
    final user = _authRepo.currentUser;
    if (user == null) return;

    try {
      isGeneratingCode.value = true;
      errorMessage.value = '';
      final invite = await _partnerRepo.createInviteCode(
        currentUid: user.id,
        creatorName: user.displayName,
      );
      activeInvite.value = invite;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception:', '').trim();
      Get.snackbar(
        'Code Generation Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGeneratingCode.value = false;
    }
  }

  /// Share code through Android system share sheet
  void shareInviteCode() {
    final invite = activeInvite.value;
    if (invite == null) return;

    final text =
        'Join me on Pairly to share our live location privately! Use my pairing code: ${invite.code} (Valid for 24h)';
    SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: 'Pairly Pairing Code',
      ),
    );
  }

  /// Submit entered partner pairing code
  Future<void> submitCode() async {
    final code = codeInputController.text.trim();
    final validation = Validators.validateInviteCode(code);
    if (validation != null) {
      Get.snackbar(
        'Invalid Code',
        validation,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final user = _authRepo.currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _partnerRepo.redeemInviteCode(code: code, currentUser: user);
      codeInputController.clear();
      Get.back(); // Return from enter code view
      Get.snackbar(
        'Connected!',
        'You are now paired with your partner. Live location sharing is ready to be enabled.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception:', '').trim();
      Get.snackbar(
        'Connection Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Disconnect partner with confirmation
  Future<void> confirmDisconnect() async {
    final confirmed = await AppDialog.showConfirmation(
      title: 'Disconnect Partner?',
      description: 'You will immediately stop sharing locations with each other. You can pair again anytime with a new code.',
      confirmText: 'Disconnect',
      isDanger: true,
      icon: Icons.link_off,
    );

    if (confirmed == true) {
      final conn = activeConnection.value;
      final user = _authRepo.currentUser;
      if (conn != null && user != null) {
        await _partnerRepo.disconnectPartner(
          connectionId: conn.id,
          currentUid: user.id,
        );
        Get.snackbar(
          'Disconnected',
          'Partner connection removed.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  /// Block partner with confirmation
  Future<void> confirmBlock() async {
    final confirmed = await AppDialog.showConfirmation(
      title: 'Block Partner?',
      description: 'Blocking will terminate the connection and immediately revoke all location access.',
      confirmText: 'Block',
      isDanger: true,
      icon: Icons.block,
    );

    if (confirmed == true) {
      final conn = activeConnection.value;
      final user = _authRepo.currentUser;
      if (conn != null && user != null) {
        await _partnerRepo.blockPartner(
          connectionId: conn.id,
          currentUid: user.id,
        );
        Get.snackbar(
          'Blocked',
          'Partner has been blocked and location access revoked.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  void onClose() {
    codeInputController.dispose();
    _connSub?.cancel();
    _reqSub?.cancel();
    super.onClose();
  }
}
