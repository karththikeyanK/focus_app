import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:focus_app/exception/general_exception.dart';
import 'package:focus_app/utill/Appconstant.dart';

import '../model/approver_response.dart';
import '../utill/apps_utill.dart';
import 'api_service.dart';

class ApproverService {
  static const String _logTag = 'ApproverService';
  final _client = ApiClient().client;

  Future<String> approveRequest(String mail, String deviceName) async {
    const String methodName = 'approveRequest';
    developer.log('[$methodName] Initiating approval request for email: $mail',
        name: _logTag, level: 200); // Debug level

    try {
      final secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: "token");

      developer.log('[$methodName] Making API call to $ADD_APPROVER${AppsConstant.userId}',
          name: _logTag, level: 200);
      final apps = await getInstalledAppsSimple();
      final response = await _client.post(
        '$ADD_APPROVER${AppsConstant.userId}',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        data: {'email': mail, 'deviceName': deviceName, 'apps': apps},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log('[$methodName] Request approved successfully',
            name: _logTag, level: 300); // Info level

        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as Map<String, dynamic>;
        final vcode = data['vcode'].toString();

        developer.log('[$methodName] Verification code retrieved: $vcode',
            name: _logTag, level: 200);
        return vcode;
      } else {
        developer.log('[$methodName] Approval failed with status: ${response.statusCode}',
            name: _logTag, level: 400, // Warning level
            error: 'Response data: ${response.data}');
        throw Exception("Approval failed: ${response.statusCode}");
      }
    } on DioException catch (dioError) {
      final res = dioError.response;

      if (res != null) {
        if (res.statusCode == 400 && res.data['msg'] == "User cannot be approver") {
          developer.log('[$methodName] User cannot be approver',
              name: _logTag, level: 400, // Warning level
              error: res.data);
          throw GeneralException("User cannot be approver.");
        } else if (res.statusCode == 400 && res.data['msg'] == "Approver already exists for this user") {
          developer.log('[$methodName] Approver already exists',
              name: _logTag, level: 400, // Warning level
              error: res.data);
          throw GeneralException("Approver already exists for this user.");
        }
      }

      developer.log('[$methodName] DioError occurred',
          name: _logTag, level: 500, // Error level
          error: dioError.message,
          stackTrace: dioError.stackTrace);
      throw Exception("API Error: ${dioError.message}");
    } catch (e, s) {
      developer.log('[$methodName] Unexpected error occurred',
          name: _logTag, level: 500, // Error level
          error: e,
          stackTrace: s);
      throw Exception("API Error: $e");
    }
  }

  Future<bool> confirmApproval(String vcode) async {
    const String methodName = 'confirmApproval';
    developer.log('[$methodName] Confirming approval with vcode: $vcode',
        name: _logTag, level: 200);

    try {
      final secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: "token");

      developer.log('[$methodName] Making API call to CONFIRM_APPROVER${AppsConstant.userId}',
          name: _logTag, level: 200);

      final response = await _client.post(
        '$CONFIRM_APPROVER${AppsConstant.approveRequestId}',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        data: {'vcode': vcode},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log('[$methodName] Approval confirmed successfully',
            name: _logTag, level: 300);
        return true;
      } else {
        developer.log('[$methodName] Confirmation failed with status: ${response.statusCode}',
            name: _logTag, level: 400,
            error: 'Response data: ${response.data}');
        throw Exception("Approval failed: ${response.statusCode}");
      }
    } on DioException catch (dioError) {
      final res = dioError.response;

      if (res != null && res.statusCode == 400 && res.data['msg'] == "VCode is not valid") {
        developer.log('[$methodName] Invalid vcode provided',
            name: _logTag, level: 400,
            error: res.data);
        throw GeneralException("VCode is not valid");
      }

      developer.log('[$methodName] DioError occurred',
          name: _logTag, level: 500,
          error: dioError.message,
          stackTrace: dioError.stackTrace);
      throw Exception("API Error: ${dioError.message}");
    } catch (e, s) {
      developer.log('[$methodName] Unexpected error occurred',
          name: _logTag, level: 500,
          error: e,
          stackTrace: s);
      throw Exception("API Error: $e");
    }
  }

  Future<List<ApproverResponse>> getApproverRequestBYApprover(int userId) async {
    const String methodName = 'getApproverRequestBYApprover';
    developer.log('[$methodName] Fetching approver requests for user: $userId',
        name: _logTag, level: 200);

    try {
      final secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: "token");

      developer.log('[$methodName] Making API call to $GET_APPROVER_REQUEST$userId',
          name: _logTag, level: 200);

      final response = await _client.get(
        '$GET_APPROVER_REQUEST$userId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log('[$methodName] Successfully fetched approver requests',
            name: _logTag, level: 300);

        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as List<dynamic>;

        developer.log('[$methodName] Found ${data.length} approver requests',
            name: _logTag, level: 200);

        return data.map((item) => ApproverResponse.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        developer.log('[$methodName] Failed to fetch approver requests with status: ${response.statusCode}',
            name: _logTag, level: 400,
            error: 'Response data: ${response.data}');
        throw Exception("Request failed: ${response.statusCode}");
      }
    } on DioException catch (dioError) {
      developer.log('[$methodName] DioError occurred',
          name: _logTag, level: 500,
          error: dioError.message,
          stackTrace: dioError.stackTrace);
      throw Exception("API Error: ${dioError.message}");
    } catch (e, s) {
      developer.log('[$methodName] Unexpected error occurred',
          name: _logTag, level: 500,
          error: e,
          stackTrace: s);
      throw Exception("API Error: $e");
    }
  }
}