class VerifyException implements Exception {
  final String message;
  VerifyException(this.message);

  @override
  String toString() => message;
}
