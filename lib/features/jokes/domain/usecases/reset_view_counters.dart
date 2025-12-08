import 'package:dartz/dartz.dart';
import 'package:oqueeoquee/core/error/failures.dart';
import 'package:oqueeoquee/core/usecases/usecase.dart';
import 'package:oqueeoquee/features/jokes/domain/repositories/joke_repository.dart';

/// Reseta todos os contadores de visualização (APENAS LOCAL)
///
/// Este contador NÃO é sincronizado com o Supabase.
/// É usado para permitir que o usuário veja todas as piadas novamente
/// quando já viu todas pelo menos uma vez.
class ResetViewCounters implements UseCase<void, NoParams> {
  final JokeRepository repository;

  ResetViewCounters(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.resetViewCounters();
  }
}
