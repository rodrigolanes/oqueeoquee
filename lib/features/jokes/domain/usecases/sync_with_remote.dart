import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/joke_repository.dart';

/// Use case para sincronizar dados locais com servidor remoto
class SyncWithRemote implements UseCase<void, NoParams> {
  final JokeRepository repository;

  SyncWithRemote(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.syncWithRemote();
  }
}
