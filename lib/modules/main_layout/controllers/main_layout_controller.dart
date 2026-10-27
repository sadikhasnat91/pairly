import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/location_repository.dart';
import '../../../data/repositories/partner_repository.dart';

class MainLayoutController extends GetxController {
  final currentIndex = 0.obs;

  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final PartnerRepository _partnerRepository = Get.find<PartnerRepository>();
  final LocationRepository _locationRepository = Get.find<LocationRepository>();

  @override
  void onInit() {
    super.onInit();
    _startListeners();
  }

  void _startListeners() {
    final user = _authRepository.currentUser;
    if (user != null) {
      _partnerRepository.listenToPartnerConnection(user.id);

      _partnerRepository.connectionStream.listen((connection) {
        if (connection != null && connection.isActive) {
          final partnerUid = connection.getPartnerUid(user.id);
          _locationRepository.listenToPartnerLocation(partnerUid);
        } else {
          _locationRepository.listenToPartnerLocation(null);
        }
      });
    }
  }

  void changePage(int index) {
    currentIndex.value = index;
  }
}
