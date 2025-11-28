import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Interface base para todos os casos de uso da aplicação
///
/// Type: Tipo de retorno do caso de uso
/// Params: Parâmetros necessários para executar o caso de uso
abstract class UseCase<Type, Params> {
  /// Executa o caso de uso
  ///
  /// Retorna [Right] com o resultado em caso de sucesso
  /// Retorna [Left] com [Failure] em caso de erro
  Future<Either<Failure, Type>> call(Params params);
}

/// Classe para casos de uso que não precisam de parâmetros
class NoParams {
  const NoParams();
}
