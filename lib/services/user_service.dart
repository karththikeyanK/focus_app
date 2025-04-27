import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:focus_app/exception/verify_exception.dart';
import 'package:focus_app/model/user_request.dart';
import 'package:focus_app/utill/Appconstant.dart';
import '../config/push_notification_config.dart';
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


  Future<bool> resendOtp(String email) async {
    try {
      final response = await _client.get(
          RESEND_OTP, data: {'email': email});
      if (response.statusCode == 200 || response.statusCode == 201) {
        log("UserService::resendOtp()::OTP resent successfully: ${response
            .data}");
        return true;
      } else {
        log("UserService::resendOtp()::Failed to resend OTP: ${response
            .statusCode}");
        throw Exception("Resend OTP failed: ${response.statusCode}");
      }
    } catch (e) {
      log("UserService::resendOtp()::Error: $e");
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
        final id = response.data['data']['id'];
        final token = response.data['data']['token'];

        await secureStorage.write(key: 'token', value: token);
        await secureStorage.write(key: 'userId', value: id.toString());

        AppsConstant.userId = id;

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
      }else if(res != null && res.statusCode == 400 &&
          res.data['msg'] == 'Verify your email to login'){
        log("UserService::authenticate()::Email not verified: ${res.data}");
        throw VerifyException("Email not verified. Please verify your email to login.");
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

  Future<bool> updateFirebaseToken() async {
    try {
      final firebaseToken = AppsConstant.firebaseToken;
      final secureStorage = FlutterSecureStorage();
      int userId = AppsConstant.userId;
      final token = await secureStorage.read(key: "token");

      if (userId == null) {
        throw Exception("User ID not found in secure storage");
      }
      if (token == null) {
        throw Exception("Authentication token not found");
      }

      log("UserService::updateFirebaseToken()::Updating Firebase token for userId: $userId, token: $token, firebaseToken: $firebaseToken");
      final response = await _client.post(
        '$UPDATE_FIREBASE_TOKEN$userId',
        queryParameters: {
          'firebaseToken': firebaseToken,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Explicitly add Bearer Token
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("UserService::updateFirebaseToken()::Firebase token updated successfully: ${response.data}");
        return true;
      } else {
        log("UserService::updateFirebaseToken()::Failed to update Firebase token: ${response.statusCode}");
        throw Exception("Update Firebase token failed: ${response.statusCode}");
      }
    } catch (e) {
      log("UserService::updateFirebaseToken()::Error: $e");
      throw Exception("API Error: $e");
    }
  }


}