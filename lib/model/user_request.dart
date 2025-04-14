// user_request.dart
class UserRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? vCode;
  final DateTime? vCodeTime;
  final String? status;

  UserRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.vCode,
    this.vCodeTime,
    this.status,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'password': password,
    'vCode': vCode,
    'vCodeTime': vCodeTime?.toIso8601String(),
    'status': status,
  };
}

// user_response.dart
class UserResponse {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String status;

  UserResponse({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.status,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
    id: json['id'] as int,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    email: json['email'] as String,
    status: json['status'] as String,
  );
}