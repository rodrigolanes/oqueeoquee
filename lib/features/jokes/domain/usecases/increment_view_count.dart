import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:oqueeoquee/core/error/failures.dart';
import 'package:oqueeoquee/core/usecases/usecase.dart';
import 'package:oqueeoquee/features/jokes/domain/repositories/joke_repository.dart';

class IncrementViewCount implements UseCase<void, IncrementViewCountParams> {
  final JokeRepository repository;

  IncrementViewCount(this.repository);

  @override
  Future<Either<Failure, void>> call(IncrementViewCountParams params) async {
    return await repository.incrementViewCount(params.jokeId);
  }
}

class IncrementViewCountParams extends Equatable {
  final int jokeId;

  const IncrementViewCountParams({required this.jokeId});

  @override
  List<Object> get props => [jokeId];
}
