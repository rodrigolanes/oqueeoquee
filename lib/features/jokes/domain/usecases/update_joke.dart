import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:oqueeoquee/core/error/failures.dart';
import 'package:oqueeoquee/core/usecases/usecase.dart';
import 'package:oqueeoquee/features/jokes/domain/entities/joke.dart';
import 'package:oqueeoquee/features/jokes/domain/repositories/joke_repository.dart';

class UpdateJoke implements UseCase<Joke, UpdateJokeParams> {
  final JokeRepository repository;

  UpdateJoke(this.repository);

  @override
  Future<Either<Failure, Joke>> call(UpdateJokeParams params) async {
    return await repository.updateJoke(
      id: params.id,
      question: params.question,
      answer: params.answer,
    );
  }
}

class UpdateJokeParams extends Equatable {
  final int id;
  final String question;
  final String answer;

  const UpdateJokeParams({
    required this.id,
    required this.question,
    required this.answer,
  });

  @override
  List<Object> get props => [id, question, answer];
}
