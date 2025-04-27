class ApproverResponse {
  final int id;
  final int userId;
  final String userName;
  final int approverId;
  final String approverName;
  final String status;
  final String verificationCode;
  final String verificationCodeTime;
  final String? deviceName;

  ApproverResponse({
    required this.id,
    required this.userId,
    required this.userName,
    required this.approverId,
    required this.approverName,
    required this.status,
    required this.verificationCode,
    required this.verificationCodeTime,
    required this.deviceName,
  });

  factory ApproverResponse.fromJson(Map<String, dynamic> json) {
    return ApproverResponse(
      id: json['id'] as int,
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      approverId: json['approverId'] as int,
      approverName: json['approverName'] as String,
      status: json['status']?.toString() ?? '',         // <- safe default
      verificationCode: json['vCode']?.toString() ?? '',
      verificationCodeTime: json['vCodeTime']?.toString() ?? '',
      deviceName: json['deviceName']?.toString(), // <- nullable
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'approverId': approverId,
      'approverName': approverName,
      'status': status,
      'vCode': verificationCode,
      'vCodeTime': verificationCodeTime,
      'deviceName': deviceName,
    };
  }
}