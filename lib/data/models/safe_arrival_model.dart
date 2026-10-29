class SafeArrivalSettingsModel {
  final String? id;
  final String userId;
  final double homeLatitude;
  final double homeLongitude;
  final String? homeAddress;
  final double geofenceRadiusMeters;
  final bool isEnabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SafeArrivalSettingsModel({
    this.id,
    required this.userId,
    required this.homeLatitude,
    required this.homeLongitude,
    this.homeAddress,
    this.geofenceRadiusMeters = 150.0,
    this.isEnabled = true,
    this.createdAt,
    this.updatedAt,
  });

  SafeArrivalSettingsModel copyWith({
    String? id,
    String? userId,
    double? homeLatitude,
    double? homeLongitude,
    String? homeAddress,
    double? geofenceRadiusMeters,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SafeArrivalSettingsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      homeLatitude: homeLatitude ?? this.homeLatitude,
      homeLongitude: homeLongitude ?? this.homeLongitude,
      homeAddress: homeAddress ?? this.homeAddress,
      geofenceRadiusMeters: geofenceRadiusMeters ?? this.geofenceRadiusMeters,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'home_latitude': homeLatitude,
      'home_longitude': homeLongitude,
      'home_address': homeAddress,
      'geofence_radius_meters': geofenceRadiusMeters,
      'enabled': isEnabled,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory SafeArrivalSettingsModel.fromJson(Map<String, dynamic> json) {
    return SafeArrivalSettingsModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String? ?? '',
      homeLatitude: (json['home_latitude'] as num?)?.toDouble() ?? 0.0,
      homeLongitude: (json['home_longitude'] as num?)?.toDouble() ?? 0.0,
      homeAddress: json['home_address'] as String?,
      geofenceRadiusMeters:
          (json['geofence_radius_meters'] as num?)?.toDouble() ?? 150.0,
      isEnabled: json['enabled'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}

class SafeArrivalEventModel {
  final String? id;
  final String userId;
  final String? connectionId;
  final String eventType;
  final DateTime eventTimestamp;
  final String idempotencyKey;
  final String processingStatus;
  final DateTime? createdAt;

  const SafeArrivalEventModel({
    this.id,
    required this.userId,
    this.connectionId,
    this.eventType = 'arrival',
    required this.eventTimestamp,
    required this.idempotencyKey,
    this.processingStatus = 'pending',
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      if (connectionId != null) 'connection_id': connectionId,
      'event_type': eventType,
      'event_timestamp': eventTimestamp.toIso8601String(),
      'idempotency_key': idempotencyKey,
      'processing_status': processingStatus,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  factory SafeArrivalEventModel.fromJson(Map<String, dynamic> json) {
    return SafeArrivalEventModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String? ?? '',
      connectionId: json['connection_id'] as String?,
      eventType: json['event_type'] as String? ?? 'arrival',
      eventTimestamp: json['event_timestamp'] != null
          ? DateTime.tryParse(json['event_timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      idempotencyKey: json['idempotency_key'] as String? ?? '',
      processingStatus: json['processing_status'] as String? ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
