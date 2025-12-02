import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/joke_repository.dart';

/// Use case para dar dislike em uma piada
class DislikeJoke implements UseCase<void, DislikeJokeParams> {
  final JokeRepository repository;

  DislikeJoke(this.repository);

  @override
  Future<Either<Failure, void>> call(DislikeJokeParams params) async {
    return await repository.dislikeJoke(params.jokeId);
  }
}

/// Parâmetros para dislike em piada
class DislikeJokeParams {
  final int jokeId;

  const DislikeJokeParams({required this.jokeId});
}
