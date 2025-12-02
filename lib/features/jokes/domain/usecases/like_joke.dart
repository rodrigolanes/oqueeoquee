import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/joke_repository.dart';

/// Use case para dar like em uma piada
class LikeJoke implements UseCase<void, LikeJokeParams> {
  final JokeRepository repository;

  LikeJoke(this.repository);

  @override
  Future<Either<Failure, void>> call(LikeJokeParams params) async {
    return await repository.likeJoke(params.jokeId);
  }
}

/// Parâmetros para like em piada
class LikeJokeParams {
  final int jokeId;

  const LikeJokeParams({required this.jokeId});
}
