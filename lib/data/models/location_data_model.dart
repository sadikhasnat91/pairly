import '../../core/constants/app_constants.dart';
import '../../core/utils/location_utils.dart';

class LocationDataModel {
  final String uid;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double? altitude;
  final double? speed;
  final double? heading;
  final DateTime updatedAt;
  final bool isSharing;

  const LocationDataModel({
    required this.uid,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    required this.updatedAt,
    this.isSharing = true,
  });

  bool get isStale =>
      DateTime.now().difference(updatedAt) > AppConstants.staleLocationThreshold;

  bool get isOffline =>
      DateTime.now().difference(updatedAt) > AppConstants.offlineThreshold;

  LocationFreshness get freshness => LocationUtils.getFreshness(updatedAt);

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'updatedAt': updatedAt.toIso8601String(),
      'isSharing': isSharing,
    };
  }

  factory LocationDataModel.fromJson(Map<String, dynamic> json) {
    return LocationDataModel(
      uid: json['uid'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      altitude: (json['altitude'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isSharing: json['isSharing'] as bool? ?? false,
    );
  }

  LocationDataModel copyWith({
    String? uid,
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    DateTime? updatedAt,
    bool? isSharing,
  }) {
    return LocationDataModel(
      uid: uid ?? this.uid,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      updatedAt: updatedAt ?? this.updatedAt,
      isSharing: isSharing ?? this.isSharing,
    );
  }
}
