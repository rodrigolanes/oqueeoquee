import 'package:equatable/equatable.dart';

/// Classe base para representar falhas no domínio da aplicação
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Falha relacionada ao servidor/API remota
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Falha relacionada ao cache/armazenamento local
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Falha relacionada à conexão de rede
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Falha de validação de dados
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
