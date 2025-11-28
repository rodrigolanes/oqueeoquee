import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:oqueeoquee/core/error/failures.dart';
import 'package:oqueeoquee/core/usecases/usecase.dart';
import 'package:oqueeoquee/features/jokes/domain/repositories/joke_repository.dart';

class DeleteJoke implements UseCase<void, DeleteJokeParams> {
  final JokeRepository repository;

  DeleteJoke(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteJokeParams params) async {
    return await repository.deleteJoke(params.jokeId);
  }
}

class DeleteJokeParams extends Equatable {
  final int jokeId;

  const DeleteJokeParams({required this.jokeId});

  @override
  List<Object> get props => [jokeId];
}
