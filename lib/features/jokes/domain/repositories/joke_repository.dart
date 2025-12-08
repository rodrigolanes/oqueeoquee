import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/joke.dart';

/// Interface abstrata do repositório de piadas
///
/// Define o contrato para acesso aos dados de piadas,
/// sem se preocupar com a implementação (local ou remota)
abstract class JokeRepository {
  /// Busca todas as piadas (local e remote)
  Future<Either<Failure, List<Joke>>> getJokes();

  /// Busca a próxima piada baseada na estratégia de seleção
  Future<Either<Failure, Joke>> getNextJoke();

  /// Incrementa o contador de visualizações de uma piada (APENAS LOCAL)
  Future<Either<Failure, void>> incrementViewCount(int jokeId);

  /// Reseta todos os contadores de visualização (APENAS LOCAL)
  Future<Either<Failure, void>> resetViewCounters();

  /// Cria uma nova piada (admin only)
  Future<Either<Failure, Joke>> createJoke({
    required String question,
    required String answer,
  });

  /// Atualiza uma piada existente (admin only)
  Future<Either<Failure, Joke>> updateJoke({
    required int id,
    required String question,
    required String answer,
  });

  /// Deleta uma piada (soft delete - admin only)
  Future<Either<Failure, void>> deleteJoke(int id);

  /// Incrementa o contador de likes de uma piada
  Future<Either<Failure, void>> likeJoke(int jokeId);

  /// Incrementa o contador de dislikes de uma piada
  Future<Either<Failure, void>> dislikeJoke(int jokeId);

  /// Sincroniza dados locais com remotos
  Future<Either<Failure, void>> syncWithRemote();
}
