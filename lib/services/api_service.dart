// ignore_for_file: non_constant_identifier_names
import 'package:dio/dio.dart';

final base_url ='http://192.168.8.138:9090/FOCUS-SERVICE/api/v1/';
final REGISTER_USER='auth/register';
final VERIFY_OTP ='auth/verify-otp';
final AUTHENTICATE ='auth/authenticate';


final dio = Dio(BaseOptions(baseUrl: base_url));

class ApiClient {
  final Dio _dio;

  ApiClient([Dio? dio]) : _dio = dio ?? Dio(BaseOptions(baseUrl: base_url));

  Dio get client => _dio;
}
