import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:oqueeoquee/core/error/failures.dart';
import 'package:oqueeoquee/core/usecases/usecase.dart';
import 'package:oqueeoquee/features/jokes/domain/entities/joke.dart';
import 'package:oqueeoquee/features/jokes/domain/repositories/joke_repository.dart';

class CreateJoke implements UseCase<Joke, CreateJokeParams> {
  final JokeRepository repository;

  CreateJoke(this.repository);

  @override
  Future<Either<Failure, Joke>> call(CreateJokeParams params) async {
    return await repository.createJoke(
      question: params.question,
      answer: params.answer,
    );
  }
}

class CreateJokeParams extends Equatable {
  final String question;
  final String answer;

  const CreateJokeParams({
    required this.question,
    required this.answer,
  });

  @override
  List<Object> get props => [question, answer];
}
