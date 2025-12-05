import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/joke.dart';
import '../repositories/joke_repository.dart';

/// Use case para buscar todas as piadas (incluindo deletadas para admin)
class GetAllJokes implements UseCase<List<Joke>, NoParams> {
  final JokeRepository repository;

  GetAllJokes(this.repository);

  @override
  Future<Either<Failure, List<Joke>>> call(NoParams params) async {
    return await repository.getJokes();
  }
}
