import 'package:focus_app/model/app_request.dart';
import 'package:focus_app/model/app_detail_request.dart';

class AppAndDetail{
  final AppRequest appRequest;
  final AppDetailRequest appDetailRequest;
  AppAndDetail({
    required this.appRequest,
    required this.appDetailRequest,
  });

  factory AppAndDetail.fromJson(Map<String, dynamic> json) {
    return AppAndDetail(
      appRequest: AppRequest.fromJson(json['appRequest']),
      appDetailRequest: AppDetailRequest.fromJson(json['appDetailRequest']),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'appRequest': appRequest.toJson(),
      'appDetailRequest': appDetailRequest.toJson(),
    };
  }

}