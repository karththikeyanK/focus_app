import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:focus_app/utill/Appconstant.dart';

import 'dart:developer' as developer;

import '../model/app_and_detail_response.dart';
import 'api_service.dart';

class AppService{
  final _client = ApiClient().client;

  Future<List<AppAndDetailResponse>> getAllApps() async {
    try {
      developer.log('[getAllApps] Fetching all apps', name: 'AppService', level: 200);

      final secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: "token");

      final response = await _client.get(
        '$GET_ALL_APPS${AppsConstant.clientId}/${AppsConstant.userId}',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log('[getAllApps] Successfully fetched apps', name: 'AppService', level: 300);

        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as List<dynamic>;

        return data.map((item) => AppAndDetailResponse.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        developer.log('[getAllApps] Failed to fetch apps with status: ${response.statusCode}',
            name: 'AppService', level: 400, error: 'Response data: ${response.data}');
        throw Exception("Failed to fetch apps: ${response.statusCode}");
      }
    } on DioException catch (dioError) {
      developer.log('[getAllApps] DioError occurred',
          name: 'AppService', level: 500, error: dioError.message, stackTrace: dioError.stackTrace);
      throw Exception("API Error: ${dioError.message}");
    } catch (e, s) {
      developer.log('[getAllApps] Unexpected error occurred',
          name: 'AppService', level: 500, error: e, stackTrace: s);
      throw Exception("Unexpected error: $e");
    }
  }
}