class ConnectionRequestModel {
  final String id;
  final String senderUid;
  final String senderName;
  final String? senderPhotoUrl;
  final String recipientUid;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;

  const ConnectionRequestModel({
    required this.id,
    required this.senderUid,
    required this.senderName,
    this.senderPhotoUrl,
    required this.recipientUid,
    this.status = 'pending',
    required this.createdAt,
  });

  bool get isPending => status == 'pending';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderUid': senderUid,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'recipientUid': recipientUid,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ConnectionRequestModel.fromJson(Map<String, dynamic> json) {
    return ConnectionRequestModel(
      id: json['id'] as String? ?? '',
      senderUid: json['senderUid'] as String? ?? '',
      senderName: json['senderName'] as String? ?? 'User',
      senderPhotoUrl: json['senderPhotoUrl'] as String?,
      recipientUid: json['recipientUid'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
