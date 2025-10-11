class AppException implements Exception {
  final String message;

  final StackTrace? stackTrace;

  AppException(this.message, [this.stackTrace]);

  @override
  String toString() {
    return '$runtimeType: $message${stackTrace != null ? '\n$stackTrace' : ''}';
  }
}
