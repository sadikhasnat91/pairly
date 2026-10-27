class SafeArrivalDestination {
  final String id;
  final String title;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final bool isEnabled;
  final bool hasNotified;
  final DateTime updatedAt;

  const SafeArrivalDestination({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 100.0,
    this.isEnabled = true,
    this.hasNotified = false,
    required this.updatedAt,
  });

  SafeArrivalDestination copyWith({
    String? id,
    String? title,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    bool? isEnabled,
    bool? hasNotified,
    DateTime? updatedAt,
  }) {
    return SafeArrivalDestination(
      id: id ?? this.id,
      title: title ?? this.title,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      isEnabled: isEnabled ?? this.isEnabled,
      hasNotified: hasNotified ?? this.hasNotified,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'latitude': latitude,
      'longitude': longitude,
      'radiusMeters': radiusMeters,
      'isEnabled': isEnabled,
      'hasNotified': hasNotified,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SafeArrivalDestination.fromJson(Map<String, dynamic> json) {
    return SafeArrivalDestination(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      radiusMeters: (json['radiusMeters'] as num?)?.toDouble() ?? 100.0,
      isEnabled: json['isEnabled'] as bool? ?? true,
      hasNotified: json['hasNotified'] as bool? ?? false,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
