import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/joke.dart';
import '../repositories/joke_repository.dart';

/// Use case para buscar a próxima piada
///
/// Retorna a próxima piada baseada na estratégia de seleção
/// (geralmente a piada menos visualizada)
class GetNextJoke implements UseCase<Joke, NoParams> {
  final JokeRepository repository;

  GetNextJoke(this.repository);

  @override
  Future<Either<Failure, Joke>> call(NoParams params) async {
    return await repository.getNextJoke();
  }
}
