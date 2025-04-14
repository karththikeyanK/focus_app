import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:focus_app/model/user_request.dart';
import '../exception/authentication_exception.dart';
import 'api_service.dart';

class UserService {
  final _client = ApiClient().client;

  Future<bool> registerUser(UserRequest user) async {
    try {
      final response = await _client.post(REGISTER_USER, data: user.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        log(
            "UserService::registerUser()::User registered successfully: ${response
                .data}");
        return true;
      } else {
        log("UserService::registerUser()::Failed to register user: ${response
            .statusCode}");
        throw Exception("Registration failed: ${response.statusCode}");
      }
    } catch (e) {
      log("UserService::registerUser()::Error: $e");
      throw Exception("API Error: $e");
    }
  }


  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await _client.post(
          VERIFY_OTP, data: {'email': email, 'otp': otp});
      if (response.statusCode == 200 || response.statusCode == 201) {
        log("UserService::verifyOtp()::OTP verified successfully: ${response
            .data}");
        return true;
      } else {
        log("UserService::verifyOtp()::Failed to verify OTP: ${response
            .statusCode}");
        throw Exception("OTP verification failed: ${response.statusCode}");
      }
    } catch (e) {
      log("UserService::verifyOtp()::Error: $e");
      throw Exception("API Error: $e");
    }
  }

  Future<bool> authenticate(String email, String password) async {
    try {
      final secureStorage = FlutterSecureStorage();

      final response = await _client.post(
        AUTHENTICATE,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await secureStorage.write(key: 'token', value: response.data['token']);
        log(
            "UserService::authenticate()::User authenticated successfully: ${response
                .data}");
        return true;
      } else {
        log("UserService::authenticate()::Unexpected status code: ${response
            .statusCode}");
        throw AuthenticationException(
            "Authentication failed. Try again later.");
      }
    } on DioException catch (dioError) {
      final res = dioError.response;

      if (res != null && res.statusCode == 400 &&
          res.data['msg'] == "Invalid credentials") {
        log("UserService::authenticate()::Invalid credentials: ${res.data}");
        throw AuthenticationException("Invalid username or password.");
      } else {
        log("UserService::authenticate()::DioException: ${dioError.message}");
        throw AuthenticationException(
            "Network error occurred. Please try again.");
      }
    } catch (e) {
      log("UserService::authenticate()::Unexpected error: $e");
      throw AuthenticationException(
          "Unexpected error occurred. Please try again later.");
    }
  }
}
