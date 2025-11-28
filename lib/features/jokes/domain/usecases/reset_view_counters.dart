import 'package:dartz/dartz.dart';
import 'package:oqueeoquee/core/error/failures.dart';
import 'package:oqueeoquee/core/usecases/usecase.dart';
import 'package:oqueeoquee/features/jokes/domain/repositories/joke_repository.dart';

class ResetViewCounters implements UseCase<void, NoParams> {
  final JokeRepository repository;

  ResetViewCounters(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.resetViewCounters();
  }
}
