import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_app/model/user_request.dart';
import '../services/user_service.dart';

// Provider to expose UserService
final userServiceProvider = Provider((ref) => UserService());


final registerUserProvider = FutureProvider.family<bool, UserRequest>((ref, request) async {
  return ref.read(userServiceProvider).registerUser(request);
});

final verifyOtpProvider = FutureProvider.family<bool, Map<String, String>>((ref, data) async {
  return ref.read(userServiceProvider).verifyOtp(data['email']!, data['otp']!);
});

final authenticateProvider = FutureProvider.family<bool, Map<String, String>>((ref, data) async {
  return ref.read(userServiceProvider).authenticate(data['email']!, data['password']!);
});
