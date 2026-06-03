class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({required this.message, this.statusCode});
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'No internet connection'});
}

class AuthException implements Exception {
  final String message;
  const AuthException({required this.message});
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});
}

class ValidationException implements Exception {
  final String message;
  const ValidationException({required this.message});
}

class PermissionException implements Exception {
  final String message;
  const PermissionException({required this.message});
}

class FileException implements Exception {
  final String message;
  const FileException({required this.message});
}
