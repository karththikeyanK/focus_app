import 'app_detail_request.dart';
import 'app_request.dart';

class AppAndDetailResponse{
  final AppRequest appRequest;
  final AppDetailRequest appDetailRequest;
  AppAndDetailResponse({
    required this.appRequest,
    required this.appDetailRequest,
  });

  factory AppAndDetailResponse.fromJson(Map<String, dynamic> json) {
    return AppAndDetailResponse(
      appRequest: AppRequest.fromJson(json['appResponse']),
      appDetailRequest: AppDetailRequest.fromJson(json['appDetailResponse']),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'appRequest': appRequest.toJson(),
      'appDetailRequest': appDetailRequest.toJson(),
    };
  }
}