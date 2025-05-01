import 'dart:typed_data';

class AppDetailRequest {
  final int? id;
  final String appName;
  final String appId;
  final String appImageUrl;
  final String appImage;

  AppDetailRequest({
    this.id,
    required this.appName,
    required this.appId,
    required this.appImageUrl,
    required this.appImage,
  });

  Map<String, String> toJson() {
    final Map<String, String> data = {
      'appName': appName,
      'appId': appId,
      'appImageUrl': appImageUrl,
      'appImage': appImage,
    };
    if (id != null) {
      data['id'] = id.toString();
    }
    return data;
  }

  factory AppDetailRequest.fromJson(Map<String, dynamic> json) {
    return AppDetailRequest(
      id: json['id'],
      appName: json['appName'],
      appId: json['appId'],
      appImageUrl: json['appImageUrl'],
      // You'll need custom logic to decode Uint8List from base64 if you store it as string
      appImage: json['appImage'] != null
          ? json['appImage'] as String
          : '', // or handle it differently based on your needs
    );
  }
}
