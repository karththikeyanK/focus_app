// ignore_for_file: non_constant_identifier_names
import 'package:dio/dio.dart';
final base_url ='http://192.168.1.27:9090/FOCUS-SERVICE/api/v1/';
// final base_url ='http://192.168.8.138:9090/FOCUS-SERVICE/api/v1/';
final REGISTER_USER='auth/register';
final VERIFY_OTP ='auth/verify-otp';
final AUTHENTICATE ='auth/authenticate';
final RESEND_OTP ='auth/resend-otp';
final UPDATE_FIREBASE_TOKEN ='user/update-firebase-token/';
final ADD_APPROVER ='approver/approve/';
final CONFIRM_APPROVER ='approver/confirm/';
final GET_APPROVER_REQUEST='approver/get-approver-requset-by-approver/';



final dio = Dio(BaseOptions(baseUrl: base_url));

class ApiClient {
  final Dio _dio;

  ApiClient([Dio? dio]) : _dio = dio ?? Dio(BaseOptions(baseUrl: base_url));

  Dio get client => _dio;


}
