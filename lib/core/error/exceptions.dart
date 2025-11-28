/// Exceção lançada quando há erro no servidor/API
class ServerException implements Exception {
  final String message;
  
  const ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}

/// Exceção lançada quando há erro no cache local
class CacheException implements Exception {
  final String message;
  
  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

/// Exceção lançada quando há erro de rede
class NetworkException implements Exception {
  final String message;
  
  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exceção lançada quando há erro de validação
class ValidationException implements Exception {
  final String message;
  
  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}
