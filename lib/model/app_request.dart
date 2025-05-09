class AppRequest {
  final int? id;
  final int? appDetailId;
  final String status;
  final int userId;

  AppRequest({
    this.id,
    required this.appDetailId,
    required this.status,
    required this.userId,
  });

  factory AppRequest.fromJson(Map<String, dynamic> json) {
    return AppRequest(
      id: json['id'],
      appDetailId: json['appDetailId'],
      status: json['status'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'appDetailId': appDetailId,
      'status': status,
      'userId': userId,
    };
  }
}
