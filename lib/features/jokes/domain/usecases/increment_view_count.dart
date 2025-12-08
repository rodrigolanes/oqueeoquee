import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:oqueeoquee/core/error/failures.dart';
import 'package:oqueeoquee/core/usecases/usecase.dart';
import 'package:oqueeoquee/features/jokes/domain/repositories/joke_repository.dart';

/// Incrementa o contador de visualizações de uma piada (APENAS LOCAL)
///
/// Este contador NÃO é sincronizado com o Supabase.
/// É usado apenas para controlar quais piadas já foram vistas
/// e garantir que todas sejam mostradas antes de repetir.
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
